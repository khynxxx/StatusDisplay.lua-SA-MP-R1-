script_name("StatusDisplay")
script_author("khynxx")

require "moonloader"
local imgui = require "mimgui"
local ffi = require "ffi"
local bit = require "bit"
local inicfg = require "inicfg"
local memory = require "memory"

-- ================= CONFIGURATION =================
local cfg = inicfg.load({
    elements = {
        HP_show=true, HP_name="HP", HP_x=40, HP_y=420, HP_color=0xFF00FF00,
        AR_show=true, AR_name="AR", AR_x=40, AR_y=440, AR_color=0xFF00AAFF,
        ST_show=true, ST_name="ST", ST_x=40, ST_y=460, ST_color=0xFFFFFFFF,
        DL_show=true, DL_name="DL", DL_x=40, DL_y=480, DL_color=0xFFFFAA00,
        FPS_show=true, FPS_name="FPS", FPS_x=40, FPS_y=500, FPS_color=0xFFFFFF00,
        PING_show=true, PING_name="PING", PING_x=40, PING_y=520, PING_color=0xFFFF00FF,
        TPING_show=true, TPING_name="T_PING", TPING_x=40, TPING_y=540, TPING_color=0xFFFF5555,
        font_name="Tahoma", font_size=9
    }
}, "StatusDisplay.ini")

-- ================= CONSTANTS =================
local KEYS = {"HP","AR","ST","DL","FPS","PING","TPING"}
local NAMES = {HP="Health", AR="Armor", ST="Stamina", DL="Vehicle Health", FPS="FPS", PING="Ping", TPING="Target Ping"}
local FONTS = {"Tahoma", "Arial", "Verdana", "Courier New", "Impact"}
local ST_ADDR, ST_MAX, ST_MIN = 0xB7CDB4, 3147.08, -150.0
local ST_RANGE = ST_MAX - ST_MIN
local MIN_FONT, MAX_FONT = 1, 20

-- Precalculated bit masks
local MASK_A, MASK_R, MASK_G, MASK_B = 0xFF000000, 0x00FF0000, 0x0000FF00, 0x000000FF

-- ================= STATE =================
local win = imgui.new.bool(false)
local mov, click = nil, false
local fontIdx, fontOpen = 1, false
local font, elems = nil, {}

-- Initialize font index
for i = 1, #FONTS do
    if FONTS[i] == cfg.elements.font_name then fontIdx = i break end
end
font = renderCreateFont(cfg.elements.font_name, cfg.elements.font_size, 5)

-- Initialize elements (optimized single pass)
for i = 1, #KEYS do
    local k = KEYS[i]
    elems[k] = {
        cfg.elements[k.."_name"],     -- [1] name
        cfg.elements[k.."_show"],     -- [2] show
        cfg.elements[k.."_x"],        -- [3] x
        cfg.elements[k.."_y"],        -- [4] y
        cfg.elements[k.."_color"]     -- [5] color
    }
end

-- ================= OPTIMIZED FUNCTIONS =================
local floor, max, min = math.floor, math.max, math.min
local band, bor, lshift, rshift = bit.band, bit.bor, bit.lshift, bit.rshift

-- FFI union for float conversion (single allocation)
local floatBuf = ffi.new("union { uint32_t i; float f; }")
local function intToFloat(i)
    floatBuf.i = i
    return floatBuf.f
end

-- Stamina (optimized)
local function getStamina()
    local ok, raw = pcall(readMemory, ST_ADDR, 4, false)
    if not ok or not raw then return 100 end

    raw = ffi.cast("uint32_t", raw)

    return floor(min(100, max(0, ((intToFloat(raw) - ST_MIN) / ST_RANGE) * 100)) + 0.5)
end



-- FPS counter (optimized)
local fpsFrames, fpsStart, fpsCache = 0, os.clock(), 0
local function updateFPS()
    fpsFrames = fpsFrames + 1
    local now = os.clock()
    if now - fpsStart >= 0.5 then
        fpsCache = floor((fpsFrames / (now - fpsStart)) + 0.5)
        fpsFrames, fpsStart = 0, now
    end
end

-- Ping (optimized with cache)
local pingCache, pingLast = 0, 0
local function getPing()
    local now = os.clock()
    if now - pingLast < 0.1 then return pingCache end
    pingLast = now
    local ok, id = pcall(function() return select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) end)
    pingCache = ok and sampGetPlayerPing(id) or 0
    return pingCache
end

local function getTargetPing()
    local r, h = getCharPlayerIsTargeting(PLAYER_HANDLE)
    if not r then return nil end
    local ok, id = pcall(function() return select(2, sampGetPlayerIdByCharHandle(h)) end)
    return ok and sampGetPlayerPing(id) or nil
end

-- Drawing (ultra optimized)
local drawText = renderFontDrawText
local tostr = tostring
local function draw(e, v)
    drawText(font, e[1] ~= "" and e[1]..": "..v or v, e[3], e[4], e[5])
end

-- Cleanup value
local function clean(v) return tostr(floor(max(0, v or 0))) end

-- Save config
local function save()
    for i = 1, #KEYS do
        local k, e = KEYS[i], elems[KEYS[i]]
        cfg.elements[k.."_name"], cfg.elements[k.."_show"] = e[1], e[2]
        cfg.elements[k.."_x"], cfg.elements[k.."_y"] = e[3], e[4]
        cfg.elements[k.."_color"] = e[5]
    end
    cfg.elements.font_name, cfg.elements.font_size = FONTS[fontIdx], cfg.elements.font_size
    inicfg.save(cfg, "StatusDisplay.ini")
end

-- ================= RENDER HANDLERS (lookup table) =================
local handlers = {
    HP = function(e)
        local hp = getCharHealth(PLAYER_PED)
        if hp > 1000 then hp = hp % 1000 end
        draw(e, clean(hp))
    end,
    AR = function(e) draw(e, clean(getCharArmour(PLAYER_PED))) end,
    ST = function(e) draw(e, getStamina().."%") end,
    DL = function(e)
        if win[0] or click then
            draw(e, "1000")
        elseif isCharInAnyCar(PLAYER_PED) then
            draw(e, clean(getCarHealth(storeCarCharIsInNoSave(PLAYER_PED))))
        end
    end,
    FPS = function(e) draw(e, tostr(fpsCache)) end,
    PING = function(e) draw(e, tostr(getPing())) end,
    TPING = function(e)
        if win[0] or click then
            draw(e, "0")
        else
            local tp = getTargetPing()
            if tp then draw(e, tostr(tp)) end
        end
    end
}

-- ================= MAIN =================
function main()
    repeat wait(0) until isSampAvailable()
    wait(3000)
    sampAddChatMessage("{FFFACD}UltraStatusDisplay.lua {FFFFFF}by {FF0000}@khynxx {FFFFFF}| {999999}/configstatusd", -1)
    sampRegisterChatCommand("configstatusd", function() win[0] = not win[0] end)

    local isPlaying = isPlayerPlaying
    local handle = PLAYER_HANDLE
    local getCursor = getCursorPos
    local isKey = isKeyJustPressed

    while true do
        wait(0)
        updateFPS()

        if isPlaying(handle) then
            for i = 1, #KEYS do
                local k, e = KEYS[i], elems[KEYS[i]]
                if e[2] then handlers[k](e) end
            end
        end

        if click and mov then
            local mx, my = getCursor()
            local e = elems[mov]
            e[3], e[4] = mx, my
            if isKey(0x01) then
                sampAddChatMessage("Position of "..mov.." saved at X:"..mx.." Y:"..my, 0xFF00FF00)
                click, mov = false, nil
            end
        end
    end
end

-- ================= IMGUI =================
local ImVec2, ImVec4 = imgui.ImVec2, imgui.ImVec4
local txt, txtCol, sep, spc = imgui.Text, imgui.TextColored, imgui.Separator, imgui.Spacing
local btn, checkbox, input, colorEdit = imgui.Button, imgui.Checkbox, imgui.InputText, imgui.ColorEdit4
local newBool, newChar, newFloat, newInt = imgui.new.bool, imgui.new.char, imgui.new.float, imgui.new.int

imgui.OnFrame(
    function() return win[0] end,
    function()
        imgui.SetNextWindowSize(ImVec2(380, 600), imgui.Cond.FirstUseEver)
        imgui.Begin("Status Menu", win, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)

        imgui.PushStyleColor(imgui.Col.Header, ImVec4(0.08, 0.12, 0.17, 1.0))
        imgui.PushStyleColor(imgui.Col.Text, ImVec4(1.0, 0.9, 0.6, 1.0))
        txt("Indicators Configuration")
        imgui.PopStyleColor(2)
        sep()
        spc()

        for i = 1, #KEYS do
            local k, e = KEYS[i], elems[KEYS[i]]
            txtCol(ImVec4(0.3, 0.8, 1.0, 1.0), "[ "..(NAMES[k] or k).." ]")

            local show = newBool(e[2])
            if checkbox("Show indicator##"..k, show) then e[2] = show[0] end

            local name = newChar[32](e[1])
            if input("Indicator text##"..k, name, 32) then e[1] = ffi.string(name) end

            -- Optimized color extraction
            local c = e[5]
            local col = newFloat[4](
                band(rshift(c, 16), 0xFF) / 255.0,
                band(rshift(c, 8), 0xFF) / 255.0,
                band(c, 0xFF) / 255.0,
                band(rshift(c, 24), 0xFF) / 255.0
            )

            if colorEdit("Color##"..k, col, imgui.ColorEditFlags.AlphaBar) then
                e[5] = bor(
                    lshift(floor(col[3] * 255), 24),
                    lshift(floor(col[0] * 255), 16),
                    lshift(floor(col[1] * 255), 8),
                    floor(col[2] * 255)
                )
            end

            local btnTxt = (click and mov == k) and "Click on the screen..." or "Move Position"
            if btn(btnTxt.."##"..k, ImVec2(220, 0)) then
                if not click then
                    mov, click = k, true
                    sampAddChatMessage("Move the cursor and LEFT CLICK on the screen to place the "..k.." indicator", 0xFFFFFF00)
                end
            end

            spc()
            sep()
        end

        spc()
        txtCol(ImVec4(0.8, 0.8, 0.8, 1.0), "Indicators font")

        if btn("Font: "..FONTS[fontIdx].." ##font_current", ImVec2(300, 0)) then
            fontOpen = not fontOpen
        end

        if fontOpen then
            spc()
            for i = 1, #FONTS do
                local fname, sel = FONTS[i], (i == fontIdx)
                if sel then imgui.PushStyleColor(imgui.Col.Text, ImVec4(0.2, 1.0, 0.2, 1.0)) end
                
                if btn(fname.." ##font_sel_"..i, ImVec2(140, 0)) then
                    if not sel then
                        fontIdx = i
                        cfg.elements.font_name = fname
                        font = renderCreateFont(fname, cfg.elements.font_size, 5)
                        sampAddChatMessage("Font changed to "..fname, 0xFFFFFF00)
                    end
                    fontOpen = false
                end
                
                if sel then imgui.PopStyleColor() end
                if i % 2 ~= 0 and i < #FONTS then imgui.SameLine() end
            end
            spc()
        end

        local size = newInt(cfg.elements.font_size)
        if imgui.InputInt("Font size##font_size", size, 1, 5) then
            local newSize = size[0]
            if newSize < MIN_FONT then
                sampAddChatMessage("{FF0000}Minimum limit is "..MIN_FONT, -1)
                newSize = MIN_FONT
            elseif newSize > MAX_FONT then
                sampAddChatMessage("{FF0000}Maximum limit is "..MAX_FONT, -1)
                newSize = MAX_FONT
            end
            
            if cfg.elements.font_size ~= newSize then
                cfg.elements.font_size = newSize
                font = renderCreateFont(FONTS[fontIdx], newSize, 5)
                sampAddChatMessage("Font size changed to "..newSize, 0xFFFFFF00)
            end
        end

        imgui.NewLine()
        spc()

        if btn("Save configuration", ImVec2(300, 0)) then
            save()
            sampAddChatMessage("Configuration saved to StatusDisplay.ini", 0xFF00FF00)
        end

        spc()
        sep()
        imgui.TextDisabled("Made by khynxx - YT khynxx")
        txt("Config: moonloader/config/StatusDisplay.ini")
        imgui.End()
    end
)
