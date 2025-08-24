# Vaedra Draw System Documentation

**File:** `Client/utils/draw.lua`

Comprehensive text rendering system for both 2D and 3D text with advanced visual effects.

## Features

- **3D Text Rendering**: World-space text with distance culling
- **2D Text Rendering**: Screen-space text with positioning
- **Visual Effects**: Shadows, outlines, backgrounds, fading
- **Distance-based Fading**: Automatic alpha adjustment
- **Performance Optimized**: Configurable rendering settings

## Configuration

```lua
Vaedra.Draw.Config = {
    defaultFont = 4,
    defaultScale = 0.35,
    defaultColor = {255, 255, 255, 215},
    enableShadows = true,
    enableOutlines = true,
    enableBackgrounds = true,
    maxDrawDistance = 50.0,
    updateInterval = 0
}
```

## 3D Text Functions

### Basic 3D Text
Draws text at a 3D world position.

```lua
Vaedra.Draw:DrawText3D(x, y, z, text, options)

-- Parameters:
-- x, y, z (number): World coordinates
-- text (string): Text to display
-- options (table): Optional styling options
```

### 3D Text with Distance Fade
Draws 3D text that fades based on distance.

```lua
Vaedra.Draw:DrawText3DFade(x, y, z, text, options)

-- Parameters:
-- x, y, z (number): World coordinates
-- text (string): Text to display
-- options (table): Options including fadeDistance and maxDistance
```

### 3D Text with Rotation
Draws 3D text with rotation support (limited implementation).

```lua
Vaedra.Draw:DrawText3DRotated(x, y, z, text, rotation, options)

-- Parameters:
-- x, y, z (number): World coordinates
-- text (string): Text to display
-- rotation (number): Rotation angle in degrees
-- options (table): Optional styling options
```

## 2D Text Functions

### Basic 2D Text
Draws text at screen coordinates.

```lua
Vaedra.Draw:DrawText2D(x, y, text, options)

-- Parameters:
-- x, y (number): Screen coordinates (0.0 to 1.0)
-- text (string): Text to display
-- options (table): Optional styling options
```

## Options Table

```lua
local options = {
    scale = 0.5,                    -- Text scale
    font = 4,                       -- Font ID (0-8)
    color = {255, 255, 255, 255},   -- RGBA color array
    shadow = true,                  -- Enable drop shadow
    outline = true,                 -- Enable text outline
    background = true,              -- Enable background rectangle
    backgroundColor = {0, 0, 0, 100}, -- Background RGBA color
    center = true,                  -- Center alignment (2D only)
    maxDistance = 50.0,             -- Max render distance (3D only)
    fadeDistance = 35.0             -- Distance to start fading (3D only)
}
```

## Utility Functions

### Get Text Dimensions
```lua
local width = Vaedra.Draw:GetTextWidth(text, scale, font)
local height = Vaedra.Draw:GetTextHeight(scale, font)

-- Parameters:
-- text (string): Text to measure
-- scale (number): Text scale (optional)
-- font (number): Font ID (optional)

-- Returns:
-- number: Width/height in screen units
```

### Configuration Management
```lua
-- Set configuration value
Vaedra.Draw:SetConfig("defaultScale", 0.4)

-- Get configuration value
local currentScale = Vaedra.Draw:GetConfig("defaultScale")
```

## Example Usage

### Basic 3D Text
```lua
-- Draw simple 3D text above player
local playerPed = PlayerPedId()
local coords = GetEntityCoords(playerPed)

Vaedra.Draw:DrawText3D(
    coords.x, coords.y, coords.z + 2.0,
    "Player Name",
    {
        scale = 0.6,
        color = {255, 255, 255, 255}
    }
)
```

### Vehicle Information Display
```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
if vehicle ~= 0 then
    local coords = GetEntityCoords(vehicle)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    local speed = GetEntitySpeed(vehicle) * 3.6 -- Convert to km/h
    
    Vaedra.Draw:DrawText3DFade(
        coords.x, coords.y, coords.z + 2.0,
        string.format("%s\nSpeed: %.1f km/h", model, speed),
        {
            scale = 0.5,
            color = {0, 255, 0, 255},
            maxDistance = 30.0,
            fadeDistance = 20.0,
            background = true
        }
    )
end
```

### HUD Elements
```lua
-- Health display
local health = GetEntityHealth(PlayerPedId())
Vaedra.Draw:DrawText2D(
    0.02, 0.95,
    string.format("Health: %d", health),
    {
        scale = 0.4,
        color = health > 100 and {0, 255, 0, 255} or {255, 0, 0, 255},
        background = true,
        center = false
    }
)

-- Centered notification
Vaedra.Draw:DrawText2D(
    0.5, 0.1,
    "Mission Completed!",
    {
        scale = 0.8,
        color = {255, 255, 0, 255},
        center = true,
        outline = true,
        shadow = true
    }
)
```

### Interactive Shop Display
```lua
-- Shop interaction text with background
local shopCoords = vector3(25.7, -1347.3, 29.49)
local playerCoords = GetEntityCoords(PlayerPedId())
local distance = #(shopCoords - playerCoords)

if distance < 5.0 then
    Vaedra.Draw:DrawText3D(
        shopCoords.x, shopCoords.y, shopCoords.z + 1.0,
        "~g~[E]~w~ Open Shop\n~y~24/7 Store~w~",
        {
            scale = 0.5,
            color = {255, 255, 255, 255},
            background = true,
            backgroundColor = {0, 0, 0, 150},
            shadow = true,
            outline = true
        }
    )
end
```

### Dynamic Text with Fade
```lua
-- Create a thread for dynamic text updates
CreateThread(function()
    while true do
        local coords = vector3(100.0, 200.0, 30.0)
        local time = GetGameTimer()
        local alpha = math.abs(math.sin(time / 1000)) * 255
        
        Vaedra.Draw:DrawText3D(
            coords.x, coords.y, coords.z,
            "Pulsing Text",
            {
                scale = 0.6,
                color = {255, 255, 255, alpha},
                outline = true
            }
        )
        
        Wait(0)
    end
end)
```

## Font IDs

Available font IDs:
- `0` - ChaletLondon
- `1` - HouseScript
- `2` - Monospace
- `4` - ChaletComprimeCologne (default)
- `7` - Pricedown

## Performance Notes

- 3D text performs distance checks before rendering
- Use `maxDistance` to limit rendering range
- Background rectangles add minimal performance cost
- Text width calculations are cached internally
- Avoid calling draw functions every frame for static text
