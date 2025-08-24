# Vaedra Callback System Documentation

The Vaedra Callback System provides a robust way to handle asynchronous communication between client and server in your FiveM resources. This system allows you to make requests from client to server (or vice versa) and receive responses asynchronously.

## Table of Contents
- [Client-Side Usage](#client-side-usage)
- [Server-Side Usage](#server-side-usage)
- [Examples](#examples)
- [Best Practices](#best-practices)
- [API Reference](#api-reference)

## Client-Side Usage

### Triggering a Server Callback
There are two ways to trigger a server callback from the client side:

1. Using callbacks:
```lua
Vaedra.Callback:TriggerServerCallback('eventName', function(result)
    print('Received result:', result)
end, arg1, arg2)
```

2. Using async/await (recommended):
```lua
local result = Vaedra.Callback:AwaitServerCallback('eventName', arg1, arg2)
print('Received result:', result)
```

### Registering a Client Callback
To handle callbacks from the server:
```lua
Vaedra.Callback:RegisterClientCallback('eventName', function(cb, ...)
    -- Handle the request
    local result = DoSomething(...)
    
    -- Send the result back to the server
    cb(result)
end)
```

## Server-Side Usage

### Triggering a Client Callback
Similar to client-side, there are two ways:

1. Using callbacks:
```lua
Vaedra.Callback:TriggerClientCallback(playerId, 'eventName', function(result)
    print('Received result from client:', result)
end, arg1, arg2)
```

2. Using async/await (recommended):
```lua
local result = Vaedra.Callback:AwaitClientCallback(playerId, 'eventName', arg1, arg2)
print('Received result from client:', result)
```

### Registering a Server Callback
To handle callbacks from clients:
```lua
Vaedra.Callback:RegisterServerCallback('eventName', function(source, cb, ...)
    -- Handle the request
    local result = DoSomething(...)
    
    -- Send the result back to the client
    cb(result)
end)
```

## Examples

### Example 1: Getting Player Data
Server-side:
```lua
Vaedra.Callback:RegisterServerCallback('Vaedra:getPlayerData', function(source, cb)
    local player = GetPlayer(source)
    cb({
        name = player.name,
        job = player.job,
        inventory = player.inventory
    })
end)
```

Client-side:
```lua
-- Using async/await
local function GetMyPlayerData()
    local playerData = Vaedra.Callback:AwaitServerCallback('Vaedra:getPlayerData')
    return playerData
end

-- Using callback
Vaedra.Callback:TriggerServerCallback('Vaedra:getPlayerData', function(playerData)
    print('My name is: ' .. playerData.name)
end)
```

### Example 2: Checking Item Ownership
Server-side:
```lua
Vaedra.Callback:RegisterServerCallback('Vaedra:hasItem', function(source, cb, itemName)
    local player = GetPlayer(source)
    local hasItem = player.hasItem(itemName)
    cb(hasItem)
end)
```

Client-side:
```lua
local hasItem = Vaedra.Callback:AwaitServerCallback('Vaedra:hasItem', 'phone')
if hasItem then
    print('You have a phone!')
else
    print('You don\'t have a phone!')
end
```

## Best Practices

1. **Use Meaningful Event Names**
   - Prefix your callback events with your resource name
   - Use descriptive names that indicate the purpose
   - Example: `Vaedra:getPlayerInventory`, `Vaedra:checkPermission`

2. **Handle Errors**
   - Always include error handling in your callbacks
   - Use pcall when executing complex operations
   - Set appropriate timeouts for async operations

3. **Timeout Handling**
   - The system automatically includes a 15-second timeout
   - For long operations, inform the user about potential delays
   - Handle timeout cases gracefully

4. **Resource Management**
   - Callbacks are automatically cleaned up when a resource stops
   - Unregister callbacks when they're no longer needed
   - Check if callbacks exist before triggering them

## API Reference

### Client-Side API

#### Vaedra.Callback:TriggerServerCallback
```lua
Vaedra.Callback:TriggerServerCallback(eventName, callback, ...)
```
- `eventName`: string - The name of the server callback event
- `callback`: function - The callback function to handle the response
- `...`: any - Additional arguments to pass to the server

#### Vaedra.Callback:AwaitServerCallback
```lua
Vaedra.Callback:AwaitServerCallback(eventName, ...)
```
- `eventName`: string - The name of the server callback event
- `...`: any - Additional arguments to pass to the server
- Returns: The server's response

#### Vaedra.Callback:RegisterClientCallback
```lua
Vaedra.Callback:RegisterClientCallback(eventName, callback)
```
- `eventName`: string - The name of the client callback event
- `callback`: function - The function to handle the server's request

#### Vaedra.Callback:DoesClientCallbackExist
```lua
Vaedra.Callback:DoesClientCallbackExist(eventName)
```
- `eventName`: string - The name of the client callback event
- Returns: boolean - Whether the callback exists

### Server-Side API

#### Vaedra.Callback:TriggerClientCallback
```lua
Vaedra.Callback:TriggerClientCallback(player, eventName, callback, ...)
```
- `player`: number - The player ID to send the callback to
- `eventName`: string - The name of the client callback event
- `callback`: function - The callback function to handle the response
- `...`: any - Additional arguments to pass to the client

#### Vaedra.Callback:AwaitClientCallback
```lua
Vaedra.Callback:AwaitClientCallback(player, eventName, ...)
```
- `player`: number - The player ID to send the callback to
- `eventName`: string - The name of the client callback event
- `...`: any - Additional arguments to pass to the client
- Returns: The client's response

#### Vaedra.Callback:RegisterServerCallback
```lua
Vaedra.Callback:RegisterServerCallback(eventName, callback)
```
- `eventName`: string - The name of the server callback event
- `callback`: function - The function to handle the client's request

#### Vaedra.Callback:DoesServerCallbackExist
```lua
Vaedra.Callback:DoesServerCallbackExist(eventName)
```
- `eventName`: string - The name of the server callback event
- Returns: boolean - Whether the callback exists
