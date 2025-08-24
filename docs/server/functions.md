# Vaedra Framework - Server Functions Documentation

## Overview
This document provides comprehensive documentation for all server-side functions available in the Vaedra Framework. These functions are designed to handle server-side operations, player management, and FiveM integration.

## Table of Contents
1. [Core Functions](#core-functions)
2. [Player Management](#player-management)
3. [Player Identifiers](#player-identifiers)
4. [Player Information](#player-information)
5. [Discord Integration](#discord-integration)

---

## Core Functions

### RegisterFunction
Registers a new method to the core framework.

```lua
Vaedra.functions:RegisterFunction(methodName, handler)
```

**Parameters:**
- `methodName` (string): Name of the method to register
- `handler` (function): Function handler to execute

**Returns:**
- `boolean`: Success status
- `string`: Status message

**Important Note:** When using this function, you need to add an event handler for `TriggerEvent('Vaedra:Client:updateObject')` to update the Core object on other servers.

**Example:**
```lua
local success, message = Vaedra.functions:RegisterFunction("customMethod", function()
    print("Custom method executed!")
end)

-- Don't forget to add this event handler on other servers
AddEventHandler('Vaedra:Server:updateObject', function()
    Vaedra = exports["vaedra-core"].GetCoreObject()
end)
```

---

### RegisterCommand
Registers a new command with FiveM, including chat suggestions and console control.

```lua
Vaedra.functions:RegisterCommand(name, cb, allowConsole, suggestion)
```

**Parameters:**
- `name` (string|table): Command name(s) - can be single string or table of aliases
- `cb` (function): Callback function to execute when command is triggered
- `allowConsole` (boolean, optional): Whether console can execute this command
- `suggestion` (table|string, optional): Command suggestion for chat

**Returns:**
- `boolean`: Success status

**Example:**
```lua
Vaedra.functions:RegisterCommand("kick", function(source, args, rawCommand)
    local target = tonumber(args[1])
    if target then
        DropPlayer(target, "Kicked by admin")
    end
end, true, {
    help = "Kick a player",
    arguments = {{name = "player", help = "Player ID"}}
})
```

---

## Player Management

### IsPlayerOnline
Checks if a player is currently online.

```lua
Vaedra.functions:IsPlayerOnline(source)
```

**Parameters:**
- `source` (number): Player source ID

**Returns:**
- `boolean`: True if player is online, false otherwise

**Example:**
```lua
if Vaedra.functions:IsPlayerOnline(1) then
    print("Player 1 is online")
end
```

---

### GetPlayerCount
Returns the total number of online players.

```lua
Vaedra.functions:GetPlayerCount()
```

**Parameters:**
- None

**Returns:**
- `number`: Total count of online players

**Example:**
```lua
local playerCount = Vaedra.functions:GetPlayerCount()
print("Online players: " .. playerCount)
```

---

### GetOnlinePlayers
Returns a table containing all online player source IDs.

```lua
Vaedra.functions:GetOnlinePlayers()
```

**Parameters:**
- None

**Returns:**
- `table`: Array of online player source IDs

**Example:**
```lua
local players = Vaedra.functions:GetOnlinePlayers()
for _, playerId in ipairs(players) do
    print("Player " .. playerId .. " is online")
end
```

---

## Player Identifiers

### GetPlayerIdentifiersTable
Retrieves all player identifiers in a structured table format.

```lua
Vaedra.functions:GetPlayerIdentifiersTable(source)
```

**Parameters:**
- `source` (number): Player source ID

**Returns:**
- `table`: Table containing all player identifiers:
  - `steam`: Steam identifier
  - `license`: License identifier
  - `discord`: Discord identifier
  - `xbl`: Xbox Live identifier
  - `cfx`: FiveM identifier
  - `ip`: IP address
  - `tokens`: Array of player tokens

**Example:**
```lua
local identifiers = Vaedra.functions:GetPlayerIdentifiersTable(1)
if identifiers.steam then
    print("Steam ID: " .. identifiers.steam)
end
```

---

### GetPlayerSteamId
Gets the player's Steam identifier.

```lua
Vaedra.functions:GetPlayerSteamId(source)
```

**Parameters:**
- `source` (number): Player source ID

**Returns:**
- `string|nil`: Steam identifier or nil if not found

**Example:**
```lua
local steamId = Vaedra.functions:GetPlayerSteamId(1)
if steamId then
    print("Steam ID: " .. steamId)
end
```

---

### GetPlayerLicense
Gets the player's license identifier.

```lua
Vaedra.functions:GetPlayerLicense(source)
```

**Parameters:**
- `source` (number): Player source ID

**Returns:**
- `string|nil`: License identifier or nil if not found

**Example:**
```lua
local license = Vaedra.functions:GetPlayerLicense(1)
if license then
    print("License: " .. license)
end
```

---

### GetPlayerDiscordId
Gets the player's Discord identifier.

```lua
Vaedra.functions:GetPlayerDiscordId(source)
```

**Parameters:**
- `source` (number): Player source ID

**Returns:**
- `string|nil`: Discord identifier or nil if not found

**Example:**
```lua
local discordId = Vaedra.functions:GetPlayerDiscordId(1)
if discordId then
    print("Discord ID: " .. discordId)
end
```

---

### GetPlayerXboxLiveId
Gets the player's Xbox Live identifier.

```lua
Vaedra.functions:GetPlayerXboxLiveId(source)
```

**Parameters:**
- `source` (number): Player source ID

**Returns:**
- `string|nil`: Xbox Live identifier or nil if not found

**Example:**
```lua
local xblId = Vaedra.functions:GetPlayerXboxLiveId(1)
if xblId then
    print("Xbox Live ID: " .. xblId)
end
```

---

### GetPlayerLiveId
Gets the player's Live identifier.

```lua
Vaedra.functions:GetPlayerLiveId(source)
```

**Parameters:**
- `source` (number): Player source ID

**Returns:**
- `string|nil`: Live identifier or nil if not found

**Example:**
```lua
local liveId = Vaedra.functions:GetPlayerLiveId(1)
if liveId then
    print("Live ID: " .. liveId)
end
```

---

### GetPlayerFiveMId
Gets the player's FiveM identifier.

```lua
Vaedra.functions:GetPlayerFiveMId(source)
```

**Parameters:**
- `source` (number): Player source ID

**Returns:**
- `string|nil`: FiveM identifier or nil if not found

**Example:**
```lua
local fivemId = Vaedra.functions:GetPlayerFiveMId(1)
if fivemId then
    print("FiveM ID: " .. fivemId)
end
```

---

### GetPlayerIP
Gets the player's IP address.

```lua
Vaedra.functions:GetPlayerIP(source)
```

**Parameters:**
- `source` (number): Player source ID

**Returns:**
- `string|nil`: IP address or nil if not found

**Example:**
```lua
local ip = Vaedra.functions:GetPlayerIP(1)
if ip then
    print("IP Address: " .. ip)
end
```

---

### GetPlayerTokens
Gets all player tokens.

```lua
Vaedra.functions:GetPlayerTokens(source)
```

**Parameters:**
- `source` (number): Player source ID

**Returns:**
- `table`: Array of player tokens

**Example:**
```lua
local tokens = Vaedra.functions:GetPlayerTokens(1)
for _, token in ipairs(tokens) do
    print("Token: " .. token)
end
```

---

## Player Information

### GetPlayerName
Gets the player's display name.

```lua
Vaedra.functions:GetPlayerName(source)
```

**Parameters:**
- `source` (number): Player source ID

**Returns:**
- `string|nil`: Player name or nil if not found

**Example:**
```lua
local name = Vaedra.functions:GetPlayerName(1)
if name then
    print("Player name: " .. name)
end
```

---

### GetPlayerPing
Gets the player's current ping.

```lua
Vaedra.functions:GetPlayerPing(source)
```

**Parameters:**
- `source` (number): Player source ID

**Returns:**
- `number|nil`: Player ping or nil if not found

**Example:**
```lua
local ping = Vaedra.functions:GetPlayerPing(1)
if ping then
    print("Player ping: " .. ping .. "ms")
end
```

---

### GetPlayerCoords
Gets the player's current coordinates.

```lua
Vaedra.functions:GetPlayerCoords(source)
```

**Parameters:**
- `source` (number): Player source ID

**Returns:**
- `table|nil`: Coordinates table `{x, y, z}` or nil if not found

**Example:**
```lua
local coords = Vaedra.functions:GetPlayerCoords(1)
if coords then
    print(string.format("Position: %.2f, %.2f, %.2f", coords.x, coords.y, coords.z))
end
```

---

## Discord Integration

### SendDiscord
Sends a Discord webhook message with embed support.

```lua
Vaedra.functions:SendDiscord(webhook, embed)
```

**Parameters:**
- `webhook` (string): Discord webhook URL
- `embed` (table): Discord embed data

**Returns:**
- `boolean`: Success status
- `string`: Status message

**Example:**
```lua
local embed = {
    title = "Player Joined",
    description = "A new player has joined the server",
    color = 0x00ff00,
    fields = {
        {name = "Player", value = "John Doe", inline = true},
        {name = "Time", value = os.date("%H:%M:%S"), inline = true}
    }
}

local success, message = Vaedra.functions:SendDiscord("WEBHOOK_URL", embed)
if success then
    print("Discord message sent successfully")
else
    print("Failed to send Discord message: " .. message)
end
```

---

## Usage Examples

### Basic Player Management
```lua
-- Check if player is online
if Vaedra.functions:IsPlayerOnline(source) then
    local name = Vaedra.functions:GetPlayerName(source)
    local coords = Vaedra.functions:GetPlayerCoords(source)
    
    print(string.format("Player %s is at position %.2f, %.2f, %.2f", 
        name, coords.x, coords.y, coords.z))
end
```

### Player Monitoring
```lua
-- Get server statistics
local playerCount = Vaedra.functions:GetPlayerCount()
local onlinePlayers = Vaedra.functions:GetOnlinePlayers()

print("Server Status:")
print("Total Players: " .. playerCount)
print("Online Players: " .. #onlinePlayers)

for _, playerId in ipairs(onlinePlayers) do
    local name = Vaedra.functions:GetPlayerName(playerId)
    local ping = Vaedra.functions:GetPlayerPing(playerId)
    print(string.format("  %s (ID: %d) - Ping: %dms", name, playerId, ping))
end
```

### Identifier Lookup
```lua
-- Get all player identifiers
local identifiers = Vaedra.functions:GetPlayerIdentifiersTable(source)

if identifiers.steam then
    print("Steam: " .. identifiers.steam)
end

if identifiers.discord then
    print("Discord: " .. identifiers.discord)
end

if identifiers.license then
    print("License: " .. identifiers.license)
end
```

---

## Error Handling

All functions include proper error handling and input validation:

- **Invalid source IDs**: Functions return `nil` or `false` for invalid player sources
- **Missing data**: Functions gracefully handle cases where data is not available
- **Type checking**: Input parameters are validated for correct types
- **Safe returns**: Functions never crash and always return expected types

---

## Performance Considerations

- **Identifier functions**: Use individual identifier functions when you only need specific data
- **Batch operations**: Use `GetPlayerIdentifiersTable` when you need multiple identifiers
- **Player validation**: Always check `IsPlayerOnline` before calling other player functions
- **Caching**: Consider caching frequently accessed data for better performance

---

## Notes

- All functions are **server-side only** and should not be called from client scripts
- Functions use FiveM native functions internally for maximum compatibility
- The framework automatically handles FiveM version differences
- All functions are thread-safe and can be called from any server context
