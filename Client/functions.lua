Vaedra.functions = Vaedra.functions or {}



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
    TriggerEvent('Vaedra:Client:updateObject')
    return true, 'success'
end


-- Get nearest player to coordinates
---@param coords vector3 Coordinates to check from
---@param maxDistance number Maximum distance to check
---@return number|nil playerId
---@return number|nil distance
function Vaedra.functions:GetNearestPlayer(coords, maxDistance)
    local players = GetActivePlayers()
    local closestDistance = maxDistance or -1
    local closestPlayer = nil

    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(coords - targetCoords)

        if closestDistance == -1 or closestDistance > distance then
            closestPlayer = playerId
            closestDistance = distance
        end
    end

    return closestPlayer, closestDistance
end

-- Get nearest vehicle to coordinates
---@param coords vector3 Coordinates to check from
---@param maxDistance number Maximum distance to check
---@return number|nil vehicleId
---@return number|nil distance
function Vaedra.functions:GetNearestVehicle(coords, maxDistance)
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = maxDistance or -1
    local closestVehicle = nil

    for _, vehicle in ipairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(coords - vehicleCoords)

        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicle
            closestDistance = distance
        end
    end

    return closestVehicle, closestDistance
end

-- Get nearest object to coordinates
---@param coords vector3 Coordinates to check from
---@param maxDistance number Maximum distance to check
---@param model string|nil Specific model to look for
---@return number|nil objectId
---@return number|nil distance
function Vaedra.functions:GetNearestObject(coords, maxDistance, model)
    local objects = GetGamePool('CObject')
    local closestDistance = maxDistance or -1
    local closestObject = nil

    for _, object in ipairs(objects) do
        if not model or GetEntityModel(object) == GetHashKey(model) then
            local objectCoords = GetEntityCoords(object)
            local distance = #(coords - objectCoords)

            if closestDistance == -1 or closestDistance > distance then
                closestObject = object
                closestDistance = distance
            end
        end
    end

    return closestObject, closestDistance
end

-- Get all players in a zone
---@param center vector3 Center of the zone
---@param radius number Radius of the zone
---@return table players
function Vaedra.functions:GetPlayersInZone(center, radius)
    local players = {}
    local activePlayers = GetActivePlayers()

    for _, playerId in ipairs(activePlayers) do
        local targetPed = GetPlayerPed(playerId)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(center - targetCoords)

        if distance <= radius then
            table.insert(players, {
                id = playerId,
                ped = targetPed,
                coords = targetCoords,
                distance = distance
            })
        end
    end

    return players
end

-- Get all vehicles in a zone
---@param center vector3 Center of the zone
---@param radius number Radius of the zone
---@param model string|nil Specific model to look for
---@return table vehicles
function Vaedra.functions:GetVehiclesInZone(center, radius, model)
    local vehicles = {}
    local allVehicles = GetGamePool('CVehicle')

    for _, vehicle in ipairs(allVehicles) do
        if not model or GetEntityModel(vehicle) == GetHashKey(model) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(center - vehicleCoords)

            if distance <= radius then
                table.insert(vehicles, {
                    id = vehicle,
                    coords = vehicleCoords,
                    distance = distance,
                    model = GetEntityModel(vehicle)
                })
            end
        end
    end

    return vehicles
end

-- Get all objects in a zone
---@param center vector3 Center of the zone
---@param radius number Radius of the zone
---@param model string|nil Specific model to look for
---@return table objects
function Vaedra.functions:GetObjectsInZone(center, radius, model)
    local objects = {}
    local allObjects = GetGamePool('CObject')

    for _, object in ipairs(allObjects) do
        if not model or GetEntityModel(object) == GetHashKey(model) then
            local objectCoords = GetEntityCoords(object)
            local distance = #(center - objectCoords)

            if distance <= radius then
                table.insert(objects, {
                    id = object,
                    coords = objectCoords,
                    distance = distance,
                    model = GetEntityModel(object)
                })
            end
        end
    end

    return objects
end


-- Check if entity exists and is valid
---@param entity number Entity handle
---@return boolean
function Vaedra.functions:IsEntityValid(entity)
    return DoesEntityExist(entity) and not IsEntityDead(entity)
end

-- Get entity type
---@param entity number Entity handle
---@return string type
function Vaedra.functions:GetEntityType(entity)
    if IsPedAPlayer(entity) then
        return 'player'
    elseif IsEntityAVehicle(entity) then
        return 'vehicle'
    elseif IsEntityAnObject(entity) then
        return 'object'
    else
        return 'unknown'
    end
end 


function Vaedra.functions:GetGroundZ(x, y, z)
    local groundZ = 0.0
    local found, ground = GetGroundZFor_3dCoord(x, y, z, groundZ, false)
    
    if found then
        return true, vector3(x, y, ground)
    else
        -- Try with a higher Z value if first attempt fails
        found, ground = GetGroundZFor_3dCoord(x, y, z + 300.0, groundZ, false)
        if found then
            return true, vector3(x, y, ground)
        end
    end
    
    return false, vector3(x, y, z)
end



Vaedra.functions.OpenPlayerCustomization = function()
    local config = {
            ped = true,
            headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        allowExit = true,
        tattoos = true
    }
    
    exports['fivem-appearance']:startPlayerCustomization(function(appearance)
        if appearance then
        else
        end
    end, config)
end


Vaedra.functions.GetPlayerAppearance = function()
    return exports['fivem-appearance']:getPedAppearance(PlayerPedId())
end

Vaedra.functions.SetPlayerAppearance = function(appearance)
    exports['fivem-appearance']:setPlayerAppearance(appearance)
end

Vaedra.functions.SetPlayerModel = function(model)
    exports['fivem-appearance']:setPlayerModel(model)
end

Vaedra.functions.GetPlayerComponents = function()
    return exports['fivem-appearance']:getPedComponents(PlayerPedId())
end

Vaedra.functions.SetPlayerComponents = function(components)
    exports['fivem-appearance']:setPedComponents(PlayerPedId(), components)
end


-- Check if a key is pressed
---@param key number Key code to check
---@return boolean
function Vaedra.functions:IsKeyPressed(key)
    return IsControlPressed(0, key)
end

-- Check if a key was just pressed
---@param key number Key code to check
---@return boolean
function Vaedra.functions:IsKeyJustPressed(key)
    return IsControlJustPressed(0, key)
end

-- Disable/enable controls
---@param control number Control to disable
---@param disable boolean Whether to disable or enable
function Vaedra.functions:DisableControl(control, disable)
    DisableControlAction(0, control, disable)
end


-- Check if player is in vehicle
---@return boolean
---@return number|nil vehicleHandle
function Vaedra.functions:IsPlayerInVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    return vehicle ~= 0, vehicle ~= 0 and vehicle or nil
end

-- Get player's current vehicle
---@return number|nil vehicleHandle
function Vaedra.functions:GetPlayerVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    return vehicle ~= 0 and vehicle or nil
end


-- Play animation on player
---@param dict string Animation dictionary
---@param anim string Animation name
---@param flag number Animation flag
---@param duration number Duration to play
function Vaedra.functions:PlayAnimation(dict, anim, flag, duration)
    flag = flag or 0
    duration = duration or -1
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
    
    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, -8.0, duration, flag, 0, false, false, false)
end


function Vaedra.functions:GetPlayerData()
    return Vaedra.playerData
end



function Vaedra.functions:GetRandomPoint(points)
    return points[math.random(1, #points)]
end


function Vaedra.functions:GetNearestPoint(coords, points)
    local nearestSpawnPoint = nil
    local nearestDistance = -1

    for _, spawnPoint in ipairs(points) do
        local distance = #(coords - vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z))
        if nearestDistance == -1 or distance < nearestDistance then
            nearestSpawnPoint = spawnPoint
            nearestDistance = distance
        end
    end

    return nearestSpawnPoint
end





function Vaedra.functions:TeleportPlayer(coords)
    local playerPed = PlayerPedId()
    
    -- Start the switch out animation
    if not IsPlayerSwitchInProgress() then
        SwitchOutPlayer(playerPed, 0, 1)
    end
    
    -- Wait for the switch cam to be in the sky in the 'waiting' state (5)
    while GetPlayerSwitchState() ~= 5 do
        Citizen.Wait(0)
        SetCloudHatOpacity(0.01)
        HideHudAndRadarThisFrame()
    end
    
    -- Fade out screen
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(0)
        SetCloudHatOpacity(0.01)
        HideHudAndRadarThisFrame()
    end
    -- Teleport the player while screen is faded out
    local found, newCoords = Vaedra.functions:GetGroundZ(coords.x, coords.y, coords.z)
    if found and newCoords then
        SetEntityCoords(playerPed, newCoords.x, newCoords.y, newCoords.z, false, false, false, true)
    else
        -- Fallback to original coordinates if ground detection fails
        SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
    end
    
    if coords.h then
        SetEntityHeading(playerPed, coords.h)
    end
    
    -- Wait a moment for position to set
    Citizen.Wait(500)
    
    -- Fade back in
    DoScreenFadeIn(500)
    while not IsScreenFadedIn() do
        Citizen.Wait(0)
        SetCloudHatOpacity(0.01)
        HideHudAndRadarThisFrame()
    end
    
    -- Switch back to the player
    SwitchInPlayer(playerPed)
    
    -- Wait for the player switch to be completed (state 12)
    while GetPlayerSwitchState() ~= 12 do
        Citizen.Wait(0)
        SetCloudHatOpacity(0.01)
        HideHudAndRadarThisFrame()
    end
    
    -- Reset draw origin to ensure HUD elements appear correctly
    ClearDrawOrigin()
end 
    


function Vaedra.functions:TpPlayer(coords)
    local playerPed = PlayerPedId()
    local found, newCoords = Vaedra.functions:GetGroundZ(coords.x, coords.y, coords.z)
    if found and newCoords then
        SetEntityCoords(playerPed, newCoords.x, newCoords.y, newCoords.z, false, false, false, true)
    else
        SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
    end
    
    if coords.h then
        SetEntityHeading(playerPed, coords.h)
    end
end



function Vaedra.functions:TogglePvp(bool)  
    SetCanAttackFriendly(PlayerPedId(), bool, false)
    NetworkSetFriendlyFireOption(bool)
end


function Vaedra.functions:GetPvpState()
    return GetCanAttackFriendly(PlayerPedId()), GetIsFriendlyFireOptionEnabled()
end



function Vaedra.functions:ToggleCriticalDamage(bool)
    SetPedSuffersCriticalHits(PlayerPedId(), bool)
end

