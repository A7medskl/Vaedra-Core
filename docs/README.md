# 🚀 Vaedra Framework Documentation

A comprehensive FiveM framework for roleplay servers with advanced player management, inventory systems, and utility functions.

## 📋 Table of Contents

- [Installation](#-installation)
- [Framework Structure](#-framework-structure)
- [Configuration](#-configuration)
- [Server Functions](#-server-functions)
- [Client Functions](#-client-functions)
- [Player Class](#-player-class)
- [Callback System](#-callback-system)
- [Events](#-events)
- [Items System](#-items-system)
- [Examples](#-examples)

## 🛠 Installation

### Prerequisites
- FiveM Server
- MySQL Database
- [oxmysql](https://github.com/overextended/oxmysql) resource

### Setup Steps

1. **Place in resources folder**
   ```
   resources/[Vaedra]/Vaedra-Core/
   ```

2. **Import database structure**
   ```sql
   CREATE TABLE `Players` (
     `id` int(11) NOT NULL AUTO_INCREMENT,
     `steam` varchar(255) DEFAULT NULL,
     `license` varchar(255) DEFAULT NULL,
     `discord` varchar(255) DEFAULT NULL,
     `xbl` varchar(255) DEFAULT NULL,
     `live` varchar(255) DEFAULT NULL,
     `fivem` varchar(255) DEFAULT NULL,
     `ip` varchar(45) DEFAULT NULL,
     `tokens` longtext DEFAULT NULL,
     `username` varchar(255) DEFAULT NULL,
     `inventory` longtext DEFAULT NULL,
     `stash` longtext DEFAULT NULL,
     `stats` longtext DEFAULT NULL,
     `metadata` longtext DEFAULT NULL,
     `settings` longtext DEFAULT NULL,
     `skin` longtext DEFAULT NULL,
     `playtime` int(11) DEFAULT 0,
     `last_login` timestamp NULL DEFAULT NULL,
     `created_at` timestamp NULL DEFAULT current_timestamp(),
     `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
     PRIMARY KEY (`id`),
     UNIQUE KEY `steam` (`steam`)
   );
   ```

3. **Add to server.cfg**
   ```cfg
   ensure oxmysql
   ensure Vaedra-Core
   ```

## 🏗 Framework Structure

```
Vaedra-Core/
├── Client/
│   ├── main.lua           # Client initialization
│   ├── functions.lua      # Client utility functions
│   ├── events.lua         # Client event handlers
│   └── loops.lua          # Client loops and threads
├── Server/
│   ├── main.lua           # Server initialization
│   ├── functions.lua      # Server core functions
│   ├── events.lua         # Server event handlers
│   ├── loops.lua          # Server loops
│   ├── Commands.lua       # Command handlers
│   ├── classes/
│   │   └── Player.lua     # Player class definition
│   └── utils/
│       └── callback.lua   # Callback system
├── Shared/
│   ├── main.lua           # Shared initialization
│   └── items.lua          # Items configuration
├── Config/
│   ├── Config.lua         # Main configuration
│   ├── Polyzone.lua       # Polyzone settings
│   └── weapons.lua        # Weapon configurations
└── fxmanifest.lua         # Resource manifest
```

## ⚙️ Configuration

### Main Config (`Config/Config.lua`)

```lua
Config = {}

-- HUD Components to hide
Config.RemoveHudComponents = {
    [1] = true,   -- WANTED_STARS
    [2] = true,   -- WEAPON_ICON
    [3] = true,   -- CASH
    [6] = true,   -- VEHICLE_NAME
    [7] = true,   -- AREA_NAME
    -- Add more as needed
}

-- Critical damage setting
Config.AllowCritical = true

-- Spawn points
Config.SpawnPoint = {
    {x = 256.0015, y = 338.6160, z = 135.3033, h = 272.1410},
}

-- Discord Configuration (optional)
Config.Discord = {
    Enabled = false,
    Webhooks = {
        PlayerActions = "",
        Security = "",
        Economy = "",
        Admin = "",
        General = ""
    }
}
```

## 🖥 Server Functions

### Core Functions

#### `Vaedra.functions:RegisterFunction(methodName, handler)`
Register a new method to the framework core.
```lua
-- Parameters:
-- methodName (string): Name of the method
-- handler (function): Function handler
-- Returns: boolean success, string message

Vaedra.functions:RegisterFunction("MyCustomFunction", function(param1, param2)
    -- Your custom logic here
    return param1 + param2
end)
```

#### `Vaedra.functions:RegisterCommand(name, callback, allowConsole, suggestion)`
Register a new command with the framework.
```lua
-- Parameters:
-- name (string|table): Command name or array of names
-- callback (function): Command handler
-- allowConsole (boolean): Allow console execution
-- suggestion (table): Command suggestion data

Vaedra.functions:RegisterCommand("heal", function(source, args, rawCommand)
    -- Heal player logic
end, false, {
    help = "Heal yourself",
    arguments = {}
})
```

#### `Vaedra.functions:SendDiscord(webhook, embed)`
Send a message to Discord webhook.
```lua
-- Parameters:
-- webhook (string): Discord webhook URL
-- embed (table): Discord embed data
-- Returns: boolean success, string message

local embed = {
    title = "Player Action",
    description = "Player joined the server",
    color = 65280,
    fields = {
        {name = "Player", value = "John Doe", inline = true}
    }
}
Vaedra.functions:SendDiscord("webhook_url", embed)
```

### Player Management Functions

#### `Vaedra.functions:GetPlayer(source)`
Get player object by source ID.
```lua
-- Parameters:
-- source (number): Player source ID
-- Returns: Player object or nil

local player = Vaedra.functions:GetPlayer(source)
if player then
    print("Player name:", player.getName())
end
```

#### `Vaedra.functions:CreatePlayer(source, identifiers, name)`
Create a new player in the system.
```lua
-- Parameters:
-- source (number): Player source ID
-- identifiers (table): Player identifiers
-- name (string): Player name
-- Returns: Player object or nil

local identifiers = Vaedra.functions:GetPlayerIdentifiersTable(source)
local player = Vaedra.functions:CreatePlayer(source, identifiers, name)
```

#### `Vaedra.functions:GetPlayerIdentifiersTable(source)`
Get all identifiers for a player.
```lua
-- Parameters:
-- source (number): Player source ID
-- Returns: table with identifiers

local identifiers = Vaedra.functions:GetPlayerIdentifiersTable(source)
-- Returns: {steam, license, discord, xbl, live, fivem, ip, tokens}
```

#### `Vaedra.functions:GetPlayerIP(source)`
Get player's IP address.
```lua
-- Parameters:
-- source (number): Player source ID
-- Returns: string IP address

local ip = Vaedra.functions:GetPlayerIP(source)
```

### Item Management Functions

#### `Vaedra.functions:UseItem(source, itemName)`
Use an item for a player.
```lua
-- Parameters:
-- source (number): Player source ID
-- itemName (string): Name of the item
-- Returns: boolean success, string message

local success, message = Vaedra.functions:UseItem(source, "medkit")
if success then
    print("Item used successfully")
else
    print("Failed to use item:", message)
end
```

#### `Vaedra.functions:GetItem(itemName)`
Get item configuration.
```lua
-- Parameters:
-- itemName (string): Name of the item
-- Returns: table item data or nil

local item = Vaedra.functions:GetItem("weapon_pistol")
```

#### `Vaedra.functions:GetItems()`
Get all items configuration.
```lua
-- Returns: table of all items

local allItems = Vaedra.functions:GetItems()
```

#### `Vaedra.functions:ItemExists(itemName)`
Check if an item exists.
```lua
-- Parameters:
-- itemName (string): Name of the item
-- Returns: boolean

local exists = Vaedra.functions:ItemExists("money")
```

### Utility Functions

#### `Vaedra.functions:GetSpawnPoint()`
Get a random spawn point.
```lua
-- Returns: table with x, y, z, h coordinates

local spawnPoint = Vaedra.functions:GetSpawnPoint()
```

#### `Vaedra.functions:GetNearestSpawnPoint(coords)`
Get the nearest spawn point to coordinates.
```lua
-- Parameters:
-- coords (vector3): Coordinates to check from
-- Returns: table with spawn point data

local nearestSpawn = Vaedra.functions:GetNearestSpawnPoint(vector3(0, 0, 0))
```

#### `Vaedra.functions:GetPlayerBucket(source)`
Get player's routing bucket.
```lua
-- Parameters:
-- source (number): Player source ID
-- Returns: number bucket ID

local bucket = Vaedra.functions:GetPlayerBucket(source)
```

#### `Vaedra.functions:SetPlayerBucket(source, bucket)`
Set player's routing bucket.
```lua
-- Parameters:
-- source (number): Player source ID
-- bucket (number): Bucket ID

Vaedra.functions:SetPlayerBucket(source, 1)
```

## 💻 Client Functions

### Core Functions

#### `Vaedra.functions:RegisterFunction(methodName, handler)`
Register a client-side function.
```lua
Vaedra.functions:RegisterFunction("MyClientFunction", function()
    -- Client logic here
end)
```

### Utility Functions

#### `Vaedra.functions:GetNearestPlayer(coords, maxDistance)`
Get the nearest player to coordinates.
```lua
-- Parameters:
-- coords (vector3): Coordinates to check from
-- maxDistance (number): Maximum distance to search
-- Returns: number playerId, number distance

local playerId, distance = Vaedra.functions:GetNearestPlayer(GetEntityCoords(PlayerPedId()), 10.0)
```

#### `Vaedra.functions:GetNearestVehicle(coords, maxDistance)`
Get the nearest vehicle to coordinates.
```lua
-- Parameters:
-- coords (vector3): Coordinates to check from
-- maxDistance (number): Maximum distance to search
-- Returns: number vehicleId, number distance

local vehicleId, distance = Vaedra.functions:GetNearestVehicle(GetEntityCoords(PlayerPedId()), 5.0)
```

#### `Vaedra.functions:GetGroundZ(x, y, z)`
Get ground Z coordinate for given position.
```lua
-- Parameters:
-- x, y, z (number): Coordinates
-- Returns: boolean found, vector3 groundCoords

local found, groundCoords = Vaedra.functions:GetGroundZ(100.0, 200.0, 50.0)
```

#### `Vaedra.functions:TeleportPlayer(coords)`
Teleport player with cinematic effect.
```lua
-- Parameters:
-- coords (table): {x, y, z, h} coordinates

Vaedra.functions:TeleportPlayer({x = 100.0, y = 200.0, z = 30.0, h = 90.0})
```

#### `Vaedra.functions:TpPlayer(coords)`
Instant teleport player.
```lua
-- Parameters:
-- coords (table): {x, y, z, h} coordinates

Vaedra.functions:TpPlayer({x = 100.0, y = 200.0, z = 30.0, h = 90.0})
```

#### `Vaedra.functions:GetSpawnPoint()`
Get a random spawn point (client-side).
```lua
local spawnPoint = Vaedra.functions:GetSpawnPoint()
```

#### `Vaedra.functions:GetNearestSpawnPoint(coords)`
Get nearest spawn point (client-side).
```lua
local nearestSpawn = Vaedra.functions:GetNearestSpawnPoint(GetEntityCoords(PlayerPedId()))
```

#### `Vaedra.functions:GetPlayerData()`
Get current player data.
```lua
local playerData = Vaedra.functions:GetPlayerData()
```

## 👤 Player Class

The Player class is created using `CreatePlayer(source, identifiers, name, data)` and contains the following properties and methods:

### Properties
```lua
player.id              -- Database ID
player.source          -- FiveM source ID
player.steam           -- Steam identifier
player.license         -- Rockstar license
player.discord         -- Discord identifier
player.xbl             -- Xbox Live identifier
player.live            -- Microsoft Live identifier
player.fivem           -- FiveM identifier
player.ip              -- IP address
player.tokens          -- Player tokens
player.username        -- Player name
player.inventory       -- Player inventory
player.stash           -- Player stash
player.stats           -- Player statistics
player.metadata        -- Player metadata
player.settings        -- Player settings
player.skin            -- Player appearance
player.playtime        -- Total playtime
player.session_start   -- Current session start time
```

### Getter Methods
```lua
player.getId()                    -- Get player database ID
player.getSource()                -- Get player source ID
player.getName()                  -- Get player name
player.getIdentifiers()           -- Get all identifiers
player.getInventory()             -- Get inventory
player.getStash()                 -- Get stash
player.getStats()                 -- Get statistics
player.getMetadata()              -- Get metadata
player.getSettings()              -- Get settings
player.getSkin()                  -- Get appearance data
player.getPlaytime()              -- Get total playtime
player.getLastLogin()             -- Get last login time
player.getCurrentSessionTime()    -- Get current session time
player.getTotalPlaytime()         -- Get total playtime including current session
```

### Inventory Methods
```lua
-- Check if player has item
player.hasItem(itemName, amount)

-- Get specific item
player.getItem(itemName)

-- Get item by slot
player.getItemBySlot(slot)

-- Get all items
player.getItems()

-- Get item count
player.getItemCount(itemName)

-- Add item to inventory
player.addItem(itemName, amount, metadata, slot)

-- Remove item from inventory
player.removeItem(itemName, amount, slot)

-- Clear entire inventory
player.clearInventory()

-- Set item metadata
player.setItemMetadata(slot, metadata)

-- Get item metadata
player.getItemMetadata(slot)
```

### Stash Methods
```lua
-- Check if player has item in stash
player.hasItemInStash(itemName, amount)

-- Get item from stash
player.getItemFromStash(itemName)

-- Add item to stash
player.addItemToStash(itemName, amount, metadata)

-- Remove item from stash
player.removeItemFromStash(itemName, amount)
```

### Other Methods
```lua
-- Set player skin
player.setSkin(skinData)
player.SetSkin(skinData)  -- Alternative method

-- Update playtime
player.updatePlaytime()

-- Save player data to database
player.save()

-- Get complete player data
player.getPlayerData()
```

## 📞 Callback System

The framework includes a robust callback system for client-server communication.

### Server-Side Callbacks

#### `Vaedra.Callback:RegisterServerCallback(eventName, callback)`
Register a server callback.
```lua
Vaedra.Callback:RegisterServerCallback('GetPlayerMoney', function(source, cb)
    local player = Vaedra.functions:GetPlayer(source)
    if player then
        local money = player.getItemCount('money')
        cb(money)
    else
        cb(0)
    end
end)
```

#### `Vaedra.Callback:TriggerClientCallback(player, eventName, callback, ...)`
Trigger a client callback from server.
```lua
Vaedra.Callback:TriggerClientCallback(source, 'GetPlayerPosition', function(coords)
    print('Player position:', coords.x, coords.y, coords.z)
end)
```

#### `Vaedra.Callback:AwaitClientCallback(player, eventName, ...)`
Wait for client callback response.
```lua
local coords = Vaedra.Callback:AwaitClientCallback(source, 'GetPlayerPosition')
print('Player is at:', coords.x, coords.y, coords.z)
```

#### `Vaedra.Callback:DoesServerCallbackExist(eventName)`
Check if a server callback exists.
```lua
local exists = Vaedra.Callback:DoesServerCallbackExist('GetPlayerMoney')
```

### Client-Side Usage
```lua
-- Trigger server callback
Vaedra.Callback:TriggerServerCallback('GetPlayerMoney', function(money)
    print('Player has $' .. money)
end)

-- Register client callback
Vaedra.Callback:RegisterClientCallback('GetPlayerPosition', function(cb)
    local coords = GetEntityCoords(PlayerPedId())
    cb(coords)
end)
```

## 📡 Events

### Server Events

#### Core Events
```lua
'Vaedra:Server:PlayerJoin'          -- Player joins server
'Vaedra:Server:UseItem'             -- Player uses an item
'Vaedra:Server:RequestPlayerDataUpdate'  -- Request player data update
'Vaedra:Server:SetPlayerBucket'     -- Set player routing bucket
```

#### Event Handlers
```lua
-- Player join event
RegisterNetEvent('Vaedra:Server:PlayerJoin')
AddEventHandler('Vaedra:Server:PlayerJoin', function()
    local source = source
    -- Player join logic
end)

-- Use item event
RegisterNetEvent('Vaedra:Server:UseItem')
AddEventHandler('Vaedra:Server:UseItem', function(itemName)
    local source = source
    Vaedra.functions:UseItem(source, itemName)
end)
```

### Client Events

#### Core Events
```lua
'Vaedra:Client:PlayerJoin'          -- Receive player data on join
'Vaedra:Client:UpdatePlayerData'    -- Update player data
```

#### Event Handlers
```lua
-- Player join event
RegisterNetEvent('Vaedra:Client:PlayerJoin')
AddEventHandler('Vaedra:Client:PlayerJoin', function(playerData)
    Vaedra.playerData = playerData
    -- Handle player join on client
end)
```

### Built-in Event Handlers
```lua
-- Chat message filtering
AddEventHandler('chatMessage', function(_, _, message)
    if string.sub(message, 1, 1) == '/' then
        CancelEvent()  -- Cancel command messages
    end
end)

-- Player disconnect handling
AddEventHandler('playerDropped', function(reason, resourceName, clientDropReason)
    local source = source
    local player = Vaedra.functions:GetPlayer(source)
    if player then
        player.save()  -- Save player data
        -- Remove player after delay
        Citizen.SetTimeout(1000, function()
            Vaedra.Players[source] = nil
        end)
    end
end)
```

## 🎒 Items System

### Item Configuration (`Shared/items.lua`)

Items are defined in the `VdShared.Items` table:

```lua
VdShared.Items = {
    ["money"] = {
        name = "money",
        label = "Cash",
        type = "item",
        stackable = true,
        useable = false,
        shouldClose = true,
        description = "Clean money for transactions"
    },
    
    ["weapon_pistol"] = {
        name = "weapon_pistol",
        label = "Pistol",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Standard issue pistol",
        metadata = {
            Components = {}
        }
    },
    
    ["medkit"] = {
        name = "medkit",
        label = "Medkit",
        type = "item",
        stackable = true,
        useable = true,
        shouldClose = true,
        description = "Medical kit for healing injuries",
        callback = function(source, item)
            -- Healing logic here
            local player = Vaedra.functions:GetPlayer(source)
            if player then
                -- Add your healing logic
                print("Player " .. player.getName() .. " used a medkit")
            end
        end
    }
}
```

### Item Properties
- **name**: Unique item identifier
- **label**: Display name
- **type**: "item" or "weapon"
- **stackable**: Can multiple items stack in one slot
- **useable**: Can the item be used
- **shouldClose**: Should inventory close when used
- **description**: Item description
- **callback**: Function called when item is used
- **metadata**: Additional item data (for weapons, etc.)

## 💡 Examples

### Creating a Custom Command
```lua
-- In Server/Commands.lua
Vaedra.functions:RegisterCommand("heal", function(source, args, rawCommand)
    local player = Vaedra.functions:GetPlayer(source)
    if not player then return end
    
    -- Heal player logic
    local playerPed = GetPlayerPed(source)
    SetEntityHealth(playerPed, 200)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"System", "You have been healed!"}
    })
end, false, {
    help = "Heal yourself",
    arguments = {}
})
```

### Creating a Custom Item
```lua
-- In Shared/items.lua
["energy_drink"] = {
    name = "energy_drink",
    label = "Energy Drink",
    type = "item",
    stackable = true,
    useable = true,
    shouldClose = true,
    description = "Restores stamina",
    callback = function(source, item)
        local player = Vaedra.functions:GetPlayer(source)
        if player then
            -- Remove item from inventory
            player.removeItem("energy_drink", 1)
            player.save()
            
            -- Restore stamina on client
            TriggerClientEvent('Vaedra:Client:RestoreStamina', source)
            
            TriggerClientEvent('chat:addMessage', source, {
                args = {"System", "You feel energized!"}
            })
        end
    end
}
```

### Using Callbacks
```lua
-- Server-side: Register callback
Vaedra.Callback:RegisterServerCallback('GetPlayerInventory', function(source, cb)
    local player = Vaedra.functions:GetPlayer(source)
    if player then
        cb(player.getInventory())
    else
        cb({})
    end
end)

-- Client-side: Use callback
Vaedra.Callback:TriggerServerCallback('GetPlayerInventory', function(inventory)
    print('Player inventory:', json.encode(inventory))
end)
```

### Custom Client Function
```lua
-- Client/functions.lua
Vaedra.functions:RegisterFunction("ShowNotification", function(message, type)
    -- Custom notification system
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end)

-- Usage
Vaedra.functions:ShowNotification("Welcome to the server!", "success")
```

### Player Data Management
```lua
-- Get player and modify data
local player = Vaedra.functions:GetPlayer(source)
if player then
    -- Add money
    player.addItem("money", 5000)
    
    -- Update stats
    player.stats.health = 100
    player.stats.armor = 50
    
    -- Save changes
    player.save()
    
    -- Update client
    TriggerClientEvent('Vaedra:Client:UpdatePlayerData', source, player.getPlayerData())
end
```

## 🔧 Advanced Configuration

### Custom Spawn Points
```lua
Config.SpawnPoint = {
    {x = 256.0015, y = 338.6160, z = 135.3033, h = 272.1410},
    {x = -1037.0, y = -2737.0, z = 20.0, h = 330.0},
    {x = 1725.0, y = 3325.0, z = 41.0, h = 200.0}
}
```

### HUD Component Management
```lua
Config.RemoveHudComponents = {
    [1] = true,   -- WANTED_STARS
    [2] = false,  -- WEAPON_ICON
    [3] = true,   -- CASH
    [4] = true,   -- MP_CASH
    [6] = true,   -- VEHICLE_NAME
    [7] = true,   -- AREA_NAME
    [13] = true,  -- CASH_CHANGE
    [19] = true,  -- WEAPON_WHEEL
}
```

## 🐛 Troubleshooting

### Common Issues

**Player data not saving:**
- Check database connection
- Verify oxmysql is running properly
- Check server console for SQL errors

**Items not working:**
- Verify item exists in `VdShared.Items`
- Check item callback function syntax
- Ensure player has the item in inventory

**Callbacks timing out:**
- Check if callback is properly registered
- Verify client-server communication
- Check for script errors in console

### Debug Tips
```lua
-- Enable debug mode
Config.Debug = true

-- Check player data
local player = Vaedra.functions:GetPlayer(source)
print("Player data:", json.encode(player.getPlayerData()))

-- Check item existence
print("Item exists:", Vaedra.functions:ItemExists("money"))
```

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**Made with ❤️ for the FiveM community**
