# Vaedra Polyzone System Documentation

**File:** `Client/utils/Polyzone.lua`

The Polyzone system provides comprehensive zone management with support for multiple zone types, collision detection, and visual debugging.

## Features

- **Multiple Zone Types**: Sphere, Box, Polygon, Combo, and Entity zones
- **Event Callbacks**: onEnter, onExit, onInside events
- **Visual Debugging**: Dense wireframe rendering with filled borders
- **Performance Optimized**: Configurable check intervals
- **Automatic Management**: Thread-based zone monitoring

## Configuration

```lua
Vaedra.Polyzone.checkInterval = 100 -- Check interval in milliseconds
```

## Zone Types

### 1. Sphere Zone
Creates a circular zone around a center point.

```lua
local zoneId = Vaedra.Polyzone:CreateSphereZone(
    center,     -- vector3: Center coordinates
    radius,     -- number: Radius in units
    onEnter,    -- function: Called when player enters
    onExit,     -- function: Called when player exits
    onInside,   -- function: Called while player is inside
    debug       -- boolean: Enable visual debugging
)
```

### 2. Box Zone
Creates a rectangular zone with rotation support.

```lua
local zoneId = Vaedra.Polyzone:CreateBoxZone(
    center,     -- vector3: Center coordinates
    length,     -- number: Length of the box
    width,      -- number: Width of the box
    heading,    -- number: Rotation angle in degrees
    onEnter,    -- function: Called when player enters
    onExit,     -- function: Called when player exits
    onInside,   -- function: Called while player is inside
    debug       -- boolean: Enable visual debugging
)
```

### 3. Polygon Zone
Creates a zone defined by multiple vertices.

```lua
local zoneId = Vaedra.Polyzone:CreatePolyZone(
    vertices,   -- table: Array of vector3 coordinates
    onEnter,    -- function: Called when player enters
    onExit,     -- function: Called when player exits
    onInside,   -- function: Called while player is inside
    debug       -- boolean: Enable visual debugging
)
```

### 4. Combo Zone
Combines multiple existing zones into one logical zone.

```lua
local zoneId = Vaedra.Polyzone:CreateComboZone(
    zoneIds,    -- table: Array of existing zone IDs
    onEnter,    -- function: Called when player enters
    onExit,     -- function: Called when player exits
    onInside,   -- function: Called while player is inside
    debug       -- boolean: Enable visual debugging
)
```

### 5. Entity Zone
Creates a zone that follows an entity.

```lua
local zoneId = Vaedra.Polyzone:CreateEntityZone(
    entity,     -- number: Entity handle
    radius,     -- number: Radius around entity
    onEnter,    -- function: Called when player enters
    onExit,     -- function: Called when player exits
    onInside,   -- function: Called while player is inside
    debug       -- boolean: Enable visual debugging
)
```

## Zone Management

### Remove Zone
```lua
local success = Vaedra.Polyzone:Remove(zoneId)
```

### Check Player Status
```lua
local isInside = Vaedra.Polyzone:IsPlayerInZone(zoneId)
```

## Example Usage

```lua
-- Create a sphere zone around a shop
local shopZone = Vaedra.Polyzone:CreateSphereZone(
    vector3(100.0, 200.0, 30.0),
    5.0,
    function(playerCoords, zone)
        print("Entered shop zone!")
        -- Show shop UI
    end,
    function(playerCoords, zone)
        print("Left shop zone!")
        -- Hide shop UI
    end,
    function(playerCoords, zone)
        -- Player is inside, could show help text
    end,
    true -- Enable debug visualization
)

-- Create a polygon zone for a complex area
local vertices = {
    vector3(100.0, 100.0, 30.0),
    vector3(150.0, 100.0, 30.0),
    vector3(150.0, 150.0, 30.0),
    vector3(125.0, 175.0, 30.0),
    vector3(100.0, 150.0, 30.0)
}

local complexZone = Vaedra.Polyzone:CreatePolyZone(
    vertices,
    function(playerCoords, zone)
        print("Entered complex zone!")
    end,
    function(playerCoords, zone)
        print("Left complex zone!")
    end,
    nil, -- No onInside callback
    false -- Disable debug
)

-- Create an entity zone that follows a vehicle
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
if vehicle ~= 0 then
    local vehicleZone = Vaedra.Polyzone:CreateEntityZone(
        vehicle,
        10.0,
        function(playerCoords, zone)
            print("Player near vehicle!")
        end,
        function(playerCoords, zone)
            print("Player left vehicle area!")
        end,
        nil,
        true -- Enable debug
    )
end
```

## Debug Visualization

When `debug` is set to `true`, zones will be visually rendered with:
- **Green wireframes** for sphere, box, and polygon zones
- **Red wireframes** for entity zones
- **Dense cross-hatching** for solid appearance
- **Zone ID labels** displayed above zones

## Performance Notes

- Zone checking runs every `checkInterval` milliseconds (default: 100ms)
- Visual debugging runs every frame when enabled
- Zones automatically clean up when removed
- Entity zones check for entity existence before processing
