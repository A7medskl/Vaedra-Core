Vaedra.functions = Vaedra.functions or {}
Vaedra.Items = Vaedra.Items or {}


-- Register a new method to the core
---@param methodName string Name of the method
---@param handler function Function handler
---@return boolean success
---@return string message
function Vaedra.functions:RegisterFunction(methodName, handler)
    if type(methodName) ~= 'string' then
        return false, 'invalid_method_name'
    end

    if type(handler) ~= 'function' then
        return false, 'invalid_handler'
    end

    Vaedra.functions[methodName] = handler
    TriggerEvent('Vaedra:Server:updateObject')
    return true, 'success'
end



---@param name string | table
---@param cb function
---@param allowConsole? boolean
---@param suggestion? table
---@return boolean success
function Vaedra.functions:RegisterCommand(name, cb, allowConsole, suggestion)
    if type(name) == "table" then
        for _, v in ipairs(name) do
            Vaedra.functions:RegisterCommand(v, cb, allowConsole, suggestion)
        end
        return
    end

    if not name or type(name) ~= 'string' then
        return false, 'invalid_command_name'
    end

    if not cb or type(cb) ~= 'function' then
        return false, 'invalid_callback'
    end

    -- Register the command with FiveM
    RegisterCommand(name, function(source, args, rawCommand)
        -- Check if console is allowed
        if not allowConsole and source == 0 then
            Vaedra.Shared.Logger:Warn('Console command execution blocked', { command = name })
            return
        end

        -- Execute the callback
        cb(source, args, rawCommand)
    end, false)

    -- Add command suggestion if provided
    if suggestion then
        if type(suggestion) == 'string' then
            TriggerEvent('chat:addSuggestion', '/' .. name, suggestion)
        elseif type(suggestion) == 'table' then
            if suggestion.help then
                TriggerEvent('chat:addSuggestion', '/' .. name, suggestion.help, suggestion.arguments)
            end
        end
    end

    return true, 'success'
end



---@param webhook string Discord webhook URL
---@param embed table Discord embed data
---@return boolean success
---@return string message
function Vaedra.functions:SendDiscord(webhook, embed)
    if not webhook or webhook == '' then
        return false, 'invalid_webhook'
    end

    if not embed then
        return false, 'invalid_embed'
    end

    -- Add timestamp if not provided
    if not embed.footer then
        embed.footer = {
            text = "Vaedra Framework • " .. os.date("%Y-%m-%d %H:%M:%S")
        }
    end

    -- Send to Discord
    PerformHttpRequest(webhook, function(err, text, headers)
        if err then
            return false, 'request_failed : '.. err
        end
        Vaedra.Shared.Logger:Info('Discord log sent successfully', { webhook = webhook })
    end, 'POST', json.encode({
        username = 'Vaedra Logs',
        embeds = {embed}
    }), { ['Content-Type'] = 'application/json' })

    return true, 'success'
end

---@param source number The player source ID
---@return table A table containing all player identifiers
function Vaedra.functions:GetPlayerIdentifiersTable(source)
    local identifiers = {
        steam = nil,
        license = nil,
        discord = nil,
        xbl = nil,
        cfx = nil,
        ip = nil,
        tokens = {}
    }

    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.sub(id, 1, 6) == "steam:" then
            identifiers.steam = id
        elseif string.sub(id, 1, 8) == "license:" then
            identifiers.license = id
        elseif string.sub(id, 1, 8) == "discord:" then
            identifiers.discord = id
        elseif string.sub(id, 1, 4) == "xbl:" then
            identifiers.xbl = id
        elseif string.sub(id, 1, 4) == "live:" then
            identifiers.live = id
        elseif string.sub(id, 1, 4) == "fivem:" then
            identifiers.cfx = id
        end
    end

    identifiers.ip = GetPlayerEndpoint(source)

    -- Get player tokens
    for i = 0, GetNumPlayerTokens(source) - 1 do
        table.insert(identifiers.tokens, GetPlayerToken(source, i))
    end

    return identifiers
end

---@param source number The player source ID
---@return string|nil The player's Steam identifier or nil if not found
function Vaedra.functions:GetPlayerSteamId(source)
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.sub(id, 1, 6) == "steam:" then
            return id
        end
    end
    return nil
end

---@param source number The player source ID
---@return string|nil The player's license identifier or nil if not found
function Vaedra.functions:GetPlayerLicense(source)
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.sub(id, 1, 8) == "license:" then
            return id
        end
    end
    return nil
end

---@param source number The player source ID
---@return string|nil The player's Discord identifier or nil if not found
function Vaedra.functions:GetPlayerDiscordId(source)
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.sub(id, 1, 8) == "discord:" then
            return id
        end
    end
    return nil
end

---@param source number The player source ID
---@return string|nil The player's Xbox Live identifier or nil if not found
function Vaedra.functions:GetPlayerXboxLiveId(source)
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.sub(id, 1, 4) == "xbl:" then
            return id
        end
    end
    return nil
end

---@param source number The player source ID
---@return string|nil The player's Live identifier or nil if not found
function Vaedra.functions:GetPlayerLiveId(source)
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.sub(id, 1, 4) == "live:" then
            return id
        end
    end
    return nil
end

---@param source number The player source ID
---@return string|nil The player's FiveM identifier or nil if not found
function Vaedra.functions:GetPlayerFiveMId(source)
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.sub(id, 1, 4) == "fivem:" then
            return id
        end
    end
    return nil
end

---@param source number The player source ID
---@return string|nil The player's IP address or nil if not found
function Vaedra.functions:GetPlayerIP(source)
    return GetPlayerEndpoint(source)
end

---@param source number The player source ID
---@return table A table containing all player tokens
function Vaedra.functions:GetPlayerTokens(source)
    local tokens = {}
    for i = 0, GetNumPlayerTokens(source) - 1 do
        table.insert(tokens, GetPlayerToken(source, i))
    end
    return tokens
end

-- Player Management functions

---@param source number The player source ID
---@return boolean True if player is online, false otherwise
function Vaedra.functions:IsPlayerOnline(source)
    if not source or source <= 0 then
        return false
    end
    
    local player = GetPlayerName(source)
    return player ~= nil and player ~= ""
end

---@return number The total number of online players
function Vaedra.functions:GetPlayerCount()
    local count = 0
    for _, playerId in ipairs(GetPlayers()) do
        if Vaedra.functions:IsPlayerOnline(tonumber(playerId)) then
            count = count + 1
        end
    end
    return count
end

---@return table A table containing all online player source IDs
function Vaedra.functions:GetOnlinePlayers()
    local players = {}
    for _, playerId in ipairs(GetPlayers()) do
        local source = tonumber(playerId)
        if Vaedra.functions:IsPlayerOnline(source) then
            table.insert(players, source)
        end
    end
    return players
end

-- Player Info functions

---@param source number The player source ID
---@return string|nil The player's name or nil if not found
function Vaedra.functions:GetPlayerName(source)
    if not source or source <= 0 then
        return nil
    end
    
    local name = GetPlayerName(source)
    return name ~= "" and name or nil
end

---@param source number The player source ID
---@return number|nil The player's ping or nil if not found
function Vaedra.functions:GetPlayerPing(source)
    if not source or source <= 0 then
        return nil
    end
    
    local ping = GetPlayerPing(source)
    return ping > 0 and ping or nil
end

---@param source number The player source ID
---@return table|nil The player's coordinates {x, y, z} or nil if not found
function Vaedra.functions:GetPlayerCoords(source)
    if not source or source <= 0 then
        return nil
    end
    
    local ped = GetPlayerPed(source)
    if ped and DoesEntityExist(ped) then
        local coords = GetEntityCoords(ped)
        return {
            x = coords.x,
            y = coords.y,
            z = coords.z
        }
    end
    
    return nil
end


function Vaedra.functions:RegisterItem (itemName, itemData) 
    if not itemName or not itemData then
        return false, 'invalid_item_name'
    end

    if type(itemData) ~= 'table' then
        return false, 'invalid_item_data'
    end

    Vaedra.Items[itemName] = itemData
    TriggerEvent('Vaedra:Server:updateObject')
    return true, 'success'
end

function Vaedra.functions:GetItem(itemName) 
    if not itemName then
        return false, 'invalid_item_name'
    end

    return Vaedra.Items[itemName]
end

function Vaedra.functions:GetItems() 
    return Vaedra.Items
end

function Vaedra.functions:ItemExists(itemName) 
    if not itemName then
        return false, 'invalid_item_name'
    end

    return Vaedra.Items[itemName] ~= nil
end



function Vaedra.functions:UseWeapon(source, itemName) 

end

function Vaedra.functions:UseItem(source, itemName) 
    if not source or not itemName then
        return false, 'invalid_parameters'
    end

    local item = Vaedra.functions:ItemExists(itemName)
    if not item then
        return false, 'item_not_found'
    end

    if not item.useable then
        return false, 'item_not_useable'
    end

    if not item.callback then
        return false, 'item_no_callback'
    end

    if item.type == 'item' then
        item.callback(source, item)
    elseif item.type == 'weapon' then
        Vaedra.functions:UseWeapon(source, item)
    end
    
    return true, 'success'
end

function Vaedra.functions:GetPlayerBucket(source) 
    if not source then
        return false, 'invalid_source'
    end
    
    return GetPlayerRoutingBucket(source)
end

function Vaedra.functions:SetPlayerBucket(source, bucket) 
    if not source then
        return false, 'invalid_source'
    end

    if not bucket and type(bucket) ~= 'number'  then
        return false, 'invalid_bucket'
    end
    
    SetPlayerRoutingBucket(source, bucket)
end




function Vaedra.functions:RegisterPlayer(source, identifiers, name)  
end


function Vaedra.functions:loadPlayer(source, identifiers, name)
end

function Vaedra.functions:GetPlayer(source)
    if not source then
        return false, 'invalid_source'
    end
    
    return Vaedra.Players[source]
end


function Vaedra.functions:GetPlayers()
    return Vaedra.Players
end


function Vaedra.functions:GetPlayerCount()
    return #Vaedra.Players
end



function Vaedra.functions:GetSpawnPoint()
    return Config.SpawnPoint[math.random(1, #Config.SpawnPoint)]
end


function Vaedra.functions:GetNearestSpawnPoint(coords)
    local nearestSpawnPoint = nil
    local nearestDistance = -1

    for _, spawnPoint in ipairs(Config.SpawnPoint) do
        local distance = #(coords - vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z))
        if nearestDistance == -1 or distance < nearestDistance then
            nearestSpawnPoint = spawnPoint
            nearestDistance = distance
        end
    end

    return nearestSpawnPoint
end
        
    

