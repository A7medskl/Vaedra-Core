# Vaedra Framework - Client Functions Documentation

## Overview
This document provides comprehensive documentation for all client-side functions available in the Vaedra Framework. These functions are designed to handle client-side operations, player interactions, world queries, and FiveM client integration.

## Table of Contents
1. [Core Functions](#core-functions)
2. [Player & Entity Detection](#player--entity-detection)
3. [Zone & Area Functions](#zone--area-functions)
4. [Entity Management](#entity-management)
5. [World & Environment](#world--environment)
6. [Player Customization](#player-customization)

---

## Core Functions

### RegisterFunction
Registers a new method to the core framework on the client side.

```lua
Vaedra.functions:RegisterFunction(methodName, handler)
```

**Parameters:**
- `methodName` (string): Name of the method to register
- `handler` (function): Function handler to execute

**Returns:**
- `boolean`: Success status
- `string`: Status message

**Important Note:** When using this function, you need to add an event handler for `TriggerEvent('Vaedra:Client:updateObject')` to update the Core object on other clients.

**Example:**
```lua
local success, message = Vaedra.functions:RegisterFunction("customMethod", function()
    print("Custom method executed!")
end)

-- Don't forget to add this event handler on other clients
AddEventHandler('Vaedra:Client:updateObject', function()
    -- Update your Core object here
    -- This ensures the new method is available across all clients
end)
```

---

## Player & Entity Detection

### GetNearestPlayer
Finds the nearest player to specified coordinates.

```lua
Vaedra.functions:GetNearestPlayer(coords, maxDistance)
```

**Parameters:**
- `coords` (vector3): Coordinates to check from
- `maxDistance` (number, optional): Maximum distance to check

**Returns:**
- `number|nil`: Player ID of the nearest player, or nil if none found
- `number|nil`: Distance to the nearest player

**Example:**
```lua
local playerCoords = GetEntityCoords(PlayerPedId())
local nearestPlayer, distance = Vaedra.functions:GetNearestPlayer(playerCoords, 10.0)

if nearestPlayer then
    print("Nearest player: " .. nearestPlayer .. " at distance: " .. distance)
end
```

---

### GetNearestVehicle
Finds the nearest vehicle to specified coordinates.

```lua
Vaedra.functions:GetNearestVehicle(coords, maxDistance)
```

**Parameters:**
- `coords` (vector3): Coordinates to check from
- `maxDistance` (number, optional): Maximum distance to check

**Returns:**
- `number|nil`: Vehicle handle of the nearest vehicle, or nil if none found
- `number|nil`: Distance to the nearest vehicle

**Example:**
```lua
local playerCoords = GetEntityCoords(PlayerPedId())
local nearestVehicle, distance = Vaedra.functions:GetNearestVehicle(playerCoords, 20.0)

if nearestVehicle then
    local model = GetEntityModel(nearestVehicle)
    print("Nearest vehicle model: " .. model .. " at distance: " .. distance)
end
```

---

### GetNearestObject
Finds the nearest object to specified coordinates, optionally filtering by model.

```lua
Vaedra.functions:GetNearestObject(coords, maxDistance, model)
```

**Parameters:**
- `coords` (vector3): Coordinates to check from
- `maxDistance` (number, optional): Maximum distance to check
- `model` (string, optional): Specific model hash to look for

**Returns:**
- `number|nil`: Object handle of the nearest object, or nil if none found
- `number|nil`: Distance to the nearest object

**Example:**
```lua
local playerCoords = GetEntityCoords(PlayerPedId())
local nearestObject, distance = Vaedra.functions:GetNearestObject(playerCoords, 15.0, "prop_box_wood02a")

if nearestObject then
    print("Nearest wooden box at distance: " .. distance)
end
```

---

## Zone & Area Functions

### GetPlayersInZone
Gets all players within a specified zone.

```lua
Vaedra.functions:GetPlayersInZone(center, radius)
```

**Parameters:**
- `center` (vector3): Center point of the zone
- `radius` (number): Radius of the zone

**Returns:**
- `table`: Array of players in the zone with their data:
  - `id`: Player ID
  - `ped`: Player ped handle
  - `coords`: Player coordinates
  - `distance`: Distance from center

**Example:**
```lua
local zoneCenter = vector3(100.0, 200.0, 30.0)
local playersInZone = Vaedra.functions:GetPlayersInZone(zoneCenter, 25.0)

print("Players in zone: " .. #playersInZone)
for _, player in ipairs(playersInZone) do
    print("Player " .. player.id .. " at distance " .. player.distance)
end
```

---

### GetVehiclesInZone
Gets all vehicles within a specified zone, optionally filtering by model.

```lua
Vaedra.functions:GetVehiclesInZone(center, radius, model)
```

**Parameters:**
- `center` (vector3): Center point of the zone
- `radius` (number): Radius of the zone
- `model` (string, optional): Specific model to look for

**Returns:**
- `table`: Array of vehicles in the zone with their data:
  - `id`: Vehicle handle
  - `coords`: Vehicle coordinates
  - `distance`: Distance from center
  - `model`: Vehicle model hash

**Example:**
```lua
local zoneCenter = vector3(100.0, 200.0, 30.0)
local carsInZone = Vaedra.functions:GetVehiclesInZone(zoneCenter, 30.0, "adder")

print("Cars in zone: " .. #carsInZone)
for _, vehicle in ipairs(carsInZone) do
    print("Vehicle at distance " .. vehicle.distance)
end
```

---

### GetObjectsInZone
Gets all objects within a specified zone, optionally filtering by model.

```lua
Vaedra.functions:GetObjectsInZone(center, radius, model)
```

**Parameters:**
- `center` (vector3): Center point of the zone
- `radius` (number): Radius of the zone
- `model` (string, optional): Specific model to look for

**Returns:**
- `table`: Array of objects in the zone with their data:
  - `id`: Object handle
  - `coords`: Object coordinates
  - `distance`: Distance from center
  - `model`: Object model hash

**Example:**
```lua
local zoneCenter = vector3(100.0, 200.0, 30.0)
local objectsInZone = Vaedra.functions:GetObjectsInZone(zoneCenter, 20.0)

print("Objects in zone: " .. #objectsInZone)
for _, object in ipairs(objectsInZone) do
    print("Object at distance " .. object.distance)
end
```

---

## Entity Management

### IsEntityValid
Checks if an entity exists and is valid (not dead).

```lua
Vaedra.functions:IsEntityValid(entity)
```

**Parameters:**
- `entity` (number): Entity handle to check

**Returns:**
- `boolean`: True if entity is valid, false otherwise

**Example:**
```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
if Vaedra.functions:IsEntityValid(vehicle) then
    print("Vehicle is valid and not destroyed")
end
```

---

### GetEntityType
Determines the type of an entity.

```lua
Vaedra.functions:GetEntityType(entity)
```

**Parameters:**
- `entity` (number): Entity handle to check

**Returns:**
- `string`: Entity type ('player', 'vehicle', 'object', or 'unknown')

**Example:**
```lua
local entity = GetEntityInFront(PlayerPedId())
local entityType = Vaedra.functions:GetEntityType(entity)
print("Entity in front is a: " .. entityType)
```

---

### GetGroundZ
Gets the ground Z coordinate at specified X,Y coordinates.

```lua
Vaedra.functions:GetGroundZ(x, y, z)
```

**Parameters:**
- `x` (number): X coordinate
- `y` (number): Y coordinate
- `z` (number): Z coordinate (starting height)

**Returns:**
- `boolean`: Success status
- `vector3`: Ground coordinates (x, y, groundZ)

**Example:**
```lua
local success, groundCoords = Vaedra.functions:GetGroundZ(100.0, 200.0, 50.0)
if success then
    print("Ground level at (100, 200): " .. groundCoords.z)
end
```

---

## World & Environment

### GetGroundZ
Gets the ground Z coordinate at specified X,Y coordinates.

```lua
Vaedra.functions:GetGroundZ(x, y, z)
```

**Parameters:**
- `x` (number): X coordinate
- `y` (number): Y coordinate
- `z` (number): Z coordinate (starting height)

**Returns:**
- `boolean`: Success status
- `vector3`: Ground coordinates (x, y, groundZ)

**Example:**
```lua
local success, groundCoords = Vaedra.functions:GetGroundZ(100.0, 200.0, 50.0)
if success then
    print("Ground level at (100, 200): " .. groundCoords.z)
end
```

---

## Player Customization

### OpenPlayerCustomization
Opens the player customization menu using the fivem-appearance resource.

```lua
Vaedra.functions:OpenPlayerCustomization()
```

**Parameters:**
- None

**Returns:**
- None

**Example:**
```lua
-- Open customization menu
Vaedra.functions:OpenPlayerCustomization()
```

---

### GetPlayerAppearance
Gets the current player's appearance data.

```lua
Vaedra.functions:GetPlayerAppearance()
```

**Parameters:**
- None

**Returns:**
- `table`: Player appearance data from fivem-appearance

**Example:**
```lua
local appearance = Vaedra.functions:GetPlayerAppearance()
if appearance then
    print("Current appearance loaded")
end
```

---

### SetPlayerAppearance
Sets the player's appearance using appearance data.

```lua
Vaedra.functions:SetPlayerAppearance(appearance)
```

**Parameters:**
- `appearance` (table): Appearance data to apply

**Returns:**
- None

**Example:**
```lua
local appearance = Vaedra.functions:GetPlayerAppearance()
-- Modify appearance data here
Vaedra.functions:SetPlayerAppearance(appearance)
```

---

### SetPlayerModel
Sets the player's model/ped.

```lua
Vaedra.functions:SetPlayerModel(model)
```

**Parameters:**
- `model` (string): Model name to set

**Returns:**
- None

**Example:**
```lua
Vaedra.functions:SetPlayerModel("mp_m_freemode_01")
```

---

### GetPlayerComponents
Gets the player's current clothing components.

```lua
Vaedra.functions:GetPlayerComponents()
```

**Parameters:**
- None

**Returns:**
- `table`: Player clothing components from fivem-appearance

**Example:**
```lua
local components = Vaedra.functions:GetPlayerComponents()
for componentId, component in pairs(components) do
    print("Component " .. componentId .. ": " .. component.drawable)
end
```

---

### SetPlayerComponents
Sets the player's clothing components.

```lua
Vaedra.functions:SetPlayerComponents(components)
```

**Parameters:**
- `components` (table): Components data to apply

**Returns:**
- None

**Example:**
```lua
local components = Vaedra.functions:GetPlayerComponents()
-- Modify components data here
Vaedra.functions:SetPlayerComponents(components)
```

---

## Usage Examples

### Basic Entity Detection
```lua
-- Get player's current position
local playerCoords = GetEntityCoords(PlayerPedId())

-- Find nearest player
local nearestPlayer, distance = Vaedra.functions:GetNearestPlayer(playerCoords, 10.0)
if nearestPlayer then
    print("Nearest player at distance: " .. distance)
end

-- Find nearest vehicle
local nearestVehicle, vehicleDistance = Vaedra.functions:GetNearestVehicle(playerCoords, 20.0)
if nearestVehicle then
    print("Nearest vehicle at distance: " .. vehicleDistance)
end
```

### Zone Monitoring
```lua
-- Monitor a specific area
local zoneCenter = vector3(0.0, 0.0, 0.0)
local zoneRadius = 25.0

-- Get all entities in zone
local playersInZone = Vaedra.functions:GetPlayersInZone(zoneCenter, zoneRadius)
local vehiclesInZone = Vaedra.functions:GetVehiclesInZone(zoneCenter, zoneRadius)
local objectsInZone = Vaedra.functions:GetObjectsInZone(zoneCenter, zoneRadius)

print("Zone Status:")
print("Players: " .. #playersInZone)
print("Vehicles: " .. #vehiclesInZone)
print("Objects: " .. #objectsInZone)
```

### Player Customization Workflow
```lua
-- Save current appearance
local currentAppearance = Vaedra.functions:GetPlayerAppearance()

-- Open customization menu
Vaedra.functions:OpenPlayerCustomization()

-- Later, restore appearance if needed
Vaedra.functions:SetPlayerAppearance(currentAppearance)
```

---

## Error Handling

All functions include proper error handling and input validation:

- **Invalid entities**: Functions return `nil` or `false` for invalid entity handles
- **Missing data**: Functions gracefully handle cases where data is not available
- **Type checking**: Input parameters are validated for correct types
- **Safe returns**: Functions never crash and always return expected types

---

## Performance Considerations

- **Zone functions**: Use appropriate radius values to avoid performance issues
- **Entity queries**: Limit the frequency of entity detection calls
- **Model filtering**: Use model parameters to reduce unnecessary entity processing
- **Caching**: Consider caching frequently accessed data for better performance

---

## Dependencies

Some functions require specific resources to be running:

- **fivem-appearance**: Required for player customization functions
- **FiveM natives**: All functions use FiveM native functions internally

---

## Notes

- All functions are **client-side only** and should not be called from server scripts
- Functions use FiveM native functions internally for maximum compatibility
- The framework automatically handles FiveM version differences
- All functions are thread-safe and can be called from any client context
- Player customization functions require the fivem-appearance resource to be installed and running
