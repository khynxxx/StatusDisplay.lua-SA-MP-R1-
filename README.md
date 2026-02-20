# UltraStatusDisplay.lua -- SA:MP R1

Status Indicator mod for **GTA: San Andreas (SA:MP R1)** that reads game
memory and converts real-time values into fully configurable on-screen
indicators.

------------------------------------------------------------------------

## Features

-   Real-time memory access
-   Fully customizable indicators
-   ARGB color configuration
-   Movable UI elements
-   Custom font selection
-   Persistent configuration (INI file)
-   Lightweight and optimized

------------------------------------------------------------------------

## Available Indicators

  **HP**                              Character Health

  **AR**                              Character Armor

  **ST**                              Character Stamina

  **DL**                              Vehicle Health (only visible inside
                                      vehicles)

  **PING**                            Your client ping

  **T_PING**                          Target player ping *(may be
                                      restricted on some servers)*

  **FPS**                             Frames per second

------------------------------------------------------------------------

## Requirements

To use this mod, you must have:

-   SA-MP R1 Client
-   SAMPFUNCS v5.4.1
-   MoonLoader 0.26 or higher
-   Microsoft Visual C++ Redistributable

------------------------------------------------------------------------

## Installation

1.  Download `UltraStatusDisplay.lua` on [Releases](https://github.com/khynxxx/StatusDisplay.lua-SA-MP-R1-/releases/tag/Final)
2.  Place the file inside your game folder moonloader folder:

```
GTA San Andreas/moonloader/
```
3.  Launch SA:MP
4.  If loaded correctly, a confirmation message will appear in the chat.

------------------------------------------------------------------------

## ⚙ Configuration

Open the configuration menu using:

    /configstatusd

Inside the menu you can:

-   Enable or disable indicators
-   Rename indicators
-   Change colors using ARGB palette
-   Move indicators freely on screen
-   Change font type and size
-   Save configuration profile

> ⚠ **Important:**
> You must click **"Guardar configuración"** to save your changes.
> Otherwise, your configuration will reset on next login.

------------------------------------------------------------------------

## 🧠 How It Works

UltraStatusDisplay:

-   Reads specific GTA:SA memory addresses
-   Converts raw memory values into readable data
-   Normalizes values when required (e.g., stamina scaling)
-   Renders dynamic UI elements using ImGui
-   Stores configuration in a local INI file

------------------------------------------------------------------------

## Preview

<p align="center">
  <br><img width="250" height="250" alt="image" src="https://github.com/user-attachments/assets/8c36600a-3ad5-4d53-af28-bb565d7e101e" />
<br>
  <br><img width="250" height="250" alt="image" src="https://github.com/user-attachments/assets/690cb6da-1b45-4fbd-a092-1d2623ecf46e" />
<br>
  <br><img width="250" height="250" alt="image" src="https://github.com/user-attachments/assets/acaff745-fb02-45cb-8e35-7643022cd072" />
<br>
</p>



------------------------------------------------------------------------

## ⚠ Disclaimer

Some features (such as `T_PING`) may be restricted or considered unfair
on certain servers.
