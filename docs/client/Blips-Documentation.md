# Vaedra Blips System Documentation

**File:** `Client/utils/blips.lua`

Optimized blip management system with range-based visibility.

## Features

- **Standard & Radius Blips**: Normal blips and area radius blips
- **Range-based Display**: Only show blips within specified distance
- **Performance Optimized**: Efficient update system with coordinate caching
- **Clean API**: Simplified function names and parameters

## Configuration

```lua
Vaedra.Blips.Config = {
    defaultRange = 100.0,
    updateInterval = 500
}
```

## Blip Creation

### 1. Standard Blip
```lua
local blipId = Vaedra.Blips:Create(
    coords,     -- vector3: Blip coordinates
    sprite,     -- number: Blip sprite ID
    scale,      -- number: Blip scale (default: 0.8)
    color,      -- number: Blip color ID
    text,       -- string: Blip label
    range,      -- number: Display range (optional)
    options     -- table: Additional options (optional)
)
```

### 2. Radius Blip
```lua
local blipId = Vaedra.Blips:CreateRadius(
    coords,     -- vector3: Center coordinates
    radius,     -- number: Radius size (default: 50.0)
    color,      -- number: Blip color ID (default: 1)
    alpha,      -- number: Alpha transparency (default: 128)
    range       -- number: Display range (optional)
)
```

## Options Table

```lua
local options = {
    shortRange = true,      -- Show only at short range (default: true)
    rotation = 0            -- Blip rotation angle (default: 0)
}
```

## Blip Management

### Update Blip
```lua
local success = Vaedra.Blips:Update(
    id,         -- string: Blip ID
    coords,     -- vector3: New coordinates (optional)
    sprite,     -- number: New sprite (optional)
    scale,      -- number: New scale (optional)
    color,      -- number: New color (optional)
    text,       -- string: New text (optional)
    range       -- number: New range (optional)
)
```

### Remove Blip
```lua
local success = Vaedra.Blips:Remove(id)
```

### Get Blip Information
```lua
local blip = Vaedra.Blips:Get(id)
local exists = Vaedra.Blips:Exists(id)
```

### Utility Functions
```lua
-- Clear all blips
Vaedra.Blips:Clear()

-- Set visibility
Vaedra.Blips:SetVisible(id, true)
```

## Example Usage

### Basic Shop Blip
```lua
local shopBlip = Vaedra.Blips:Create(
    vector3(150.0, 250.0, 30.0),
    52, -- Shop sprite
    0.8, -- Scale
    2, -- Green color
    "24/7 Shop",
    100.0 -- Show within 100 units
)
```

### Mission Objective Blip
```lua
local missionBlip = Vaedra.Blips:Create(
    vector3(200.0, 300.0, 40.0),
    1, -- Default sprite
    1.0, -- Scale
    5, -- Yellow color
    "Mission Objective",
    500.0, -- Range
    {
        shortRange = false
    }
)
```

### Radius Zone Blip
```lua
local zoneBlip = Vaedra.Blips:CreateRadius(
    vector3(100.0, 100.0, 30.0),
    50.0, -- 50 unit radius
    1, -- Red color
    100, -- Semi-transparent
    200.0 -- Show within 200 units
)
```

### Dynamic Alert Blip
```lua
local alertBlip = Vaedra.Blips:Create(
    vector3(0.0, 0.0, 0.0),
    1, -- Sprite
    1.2, -- Larger scale
    3, -- Blue color
    "Alert",
    1000.0, -- Long range
    {
        shortRange = false
    }
)

-- Update blip position dynamically
CreateThread(function()
    while Vaedra.Blips:Exists(alertBlip) do
        local newCoords = GetSomeCoordinates()
        Vaedra.Blips:Update(alertBlip, newCoords)
        Wait(1000)
    end
end)
```

## Performance Notes

- Blips update every `updateInterval` milliseconds (default: 500ms)
- Player coordinates cached and updated every 1 second
- Range-based culling improves performance with many blips
- Automatic cleanup when blips are removed
