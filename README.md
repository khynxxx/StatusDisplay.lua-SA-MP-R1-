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

1.  Download `UltraStatusDisplay.lua`
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
  <br><img src="https://github.com/user-attachments/assets/c86357df-467c-497b-a049-2e08b251c890" width="250" height="250"><br>
  <br><img src="https://github.com/user-attachments/assets/0f7dc5ba-7e42-4153-a9d1-8fa27a68f2b1" width="250" height="250"><br>
  <br><img src="https://github.com/user-attachments/assets/dca844d9-ecc0-400e-9e76-d7a0fad4e6f9" width="250" height="250" ><br>
</p>



------------------------------------------------------------------------

## ⚠ Disclaimer

Some features (such as `T_PING`) may be restricted or considered unfair
on certain servers.
