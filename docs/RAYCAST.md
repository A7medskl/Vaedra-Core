# Vaedra Raycast System Documentation

## 📖 Overview

The Vaedra Raycast System provides powerful functions to detect what players are looking at and interact with the game world through raycasting. It includes teleportation functionality and coordinate detection.

## 🚀 Features

- **Coordinate Detection**: Get precise coordinates where the player is looking
- **Entity Detection**: Identify objects, vehicles, peds, and world elements
- **Ground Detection**: Specifically target ground/world surfaces
- **Teleportation**: Instantly teleport to looked-at locations
- **Distance Control**: Configurable raycast distance

## 📋 API Reference

### Functions

#### `Vaedra.Raycast.getLookingAtCoords(distance)`

**Description**: Detects everything the player is looking at (objects, vehicles, peds, world)

**Parameters**:
- `distance` (number, optional): Maximum raycast distance. Default: 1000.0

**Returns**: Table with the following structure:
```lua
{
    hit = boolean,           -- Whether something was hit
    coords = vector3,        -- Hit coordinates (x, y, z)
    entity = number|nil,     -- Entity ID if hit, nil if world
    normal = vector3|nil,    -- Surface normal vector
    distance = number        -- Distance to hit point
}
```

**Example**:
```lua
local result = Vaedra.Raycast.getLookingAtCoords(500.0)
if result.hit then
    print("Hit at:", result.coords)
    if result.entity then
        print("Entity ID:", result.entity)
    end
end
```

---

#### `Vaedra.Raycast.getLookingAtGround(distance)`

**Description**: Detects only ground/world surfaces (ignores objects and entities)

**Parameters**:
- `distance` (number, optional): Maximum raycast distance. Default: 1000.0

**Returns**: Table with the following structure:
```lua
{
    hit = boolean,      -- Whether ground was hit
    coords = vector3,   -- Hit coordinates (x, y, z)
    distance = number   -- Distance to hit point
}
```

**Example**:
```lua
local ground = Vaedra.Raycast.getLookingAtGround()
if ground.hit then
    print("Ground at:", ground.coords)
    -- Spawn object at ground location
    CreateObject(model, ground.coords.x, ground.coords.y, ground.coords.z, true, true, true)
end
```

---

#### `RotationToDirection(rotation)`

**Description**: Helper function to convert camera rotation to direction vector

**Parameters**:
- `rotation` (vector3): Camera rotation in degrees

**Returns**: Direction vector (vector3)

**Note**: This is an internal helper function, typically not used directly.

## 🎮 Commands

### `/tphere`

**Description**: Teleports the player to the location they are looking at

**Usage**: 
1. Look at the desired location
2. Type `/tphere` in chat
3. Player teleports with fade effect

**Features**:
- Automatic height adjustment (+1.0 Z to avoid clipping)
- Visual fade out/in effect
- Console feedback with coordinates
- Safety check for valid locations

**Example Output**:
```
Teleported to: 123.45, 456.78, 12.34
```

## 💡 Usage Examples

### Basic Coordinate Detection
```lua
-- Get what player is looking at
local result = Vaedra.Raycast.getLookingAtCoords()
if result.hit then
    local coords = result.coords
    -- Use coordinates for spawning, marking, etc.
end
```

### Entity Interaction
```lua
-- Check if looking at a vehicle
local result = Vaedra.Raycast.getLookingAtCoords()
if result.hit and result.entity then
    if IsEntityAVehicle(result.entity) then
        print("Looking at vehicle:", result.entity)
        -- Interact with vehicle
    end
end
```

### Ground Placement
```lua
-- Place object on ground where looking
local ground = Vaedra.Raycast.getLookingAtGround()
if ground.hit then
    local obj = CreateObject(
        GetHashKey("prop_barrier_work05"), 
        ground.coords.x, 
        ground.coords.y, 
        ground.coords.z, 
        true, true, true
    )
end
```

### Distance-Limited Detection
```lua
-- Short-range detection (50 units)
local nearby = Vaedra.Raycast.getLookingAtCoords(50.0)
if nearby.hit then
    print("Something nearby at:", nearby.distance, "units")
end
```

## 🔧 Integration

### In Your Scripts
```lua
-- Access the functions directly
local coords = Vaedra.Raycast.getLookingAtCoords()

-- Or use in events/commands
RegisterCommand('mark', function()
    local result = Vaedra.Raycast.getLookingAtCoords()
    if result.hit then
        -- Add marker at location
        TriggerEvent('addMarker', result.coords)
    end
end)
```

### With Other Systems
```lua
-- Integration with building system
RegisterNetEvent('placeBuild')
AddEventHandler('placeBuild', function(buildType)
    local ground = Vaedra.Raycast.getLookingAtGround()
    if ground.hit then
        -- Send to server for building placement
        TriggerServerEvent('server:placeBuild', buildType, ground.coords)
    end
end)
```

## ⚙️ Configuration

### Raycast Flags
The system uses different raycast flags for different purposes:

- **All Entities** (`-1`): Hits everything (default for `getLookingAtCoords`)
- **World Only** (`1`): Hits only ground/world (used in `getLookingAtGround`)

### Distance Settings
- **Default Distance**: 1000.0 units
- **Recommended Range**: 50.0 - 2000.0 units
- **Performance**: Lower distances = better performance

## 🐛 Troubleshooting

### Common Issues

**Raycast not hitting anything**:
- Check if looking at valid surface
- Increase distance parameter
- Ensure no objects blocking the view

**Teleport not working**:
- Verify the hit location is valid
- Check for collision issues
- Ensure player has necessary permissions

**Performance issues**:
- Reduce raycast distance
- Avoid calling in tight loops
- Use appropriate raycast flags

### Debug Tips
```lua
-- Debug raycast results
local result = Vaedra.Raycast.getLookingAtCoords()
print("Hit:", result.hit)
print("Coords:", result.coords)
print("Entity:", result.entity)
print("Distance:", result.distance)
```

## 📝 Notes

- Raycast uses the gameplay camera direction
- Coordinates are in world space
- Entity detection includes all game objects
- Ground detection ignores props and vehicles
- Teleportation includes safety height offset

## 🔄 Version History

- **v1.0**: Initial raycast system with basic detection
- **v1.1**: Added teleportation command
- **v1.2**: Improved ground detection and documentation
