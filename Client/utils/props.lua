Vaedra = Vaedra or {}
Vaedra.Props = {
    Active = {},
    uidCounter = 0
}

-- Generate unique ID
local function generateUID()
    Vaedra.Props.uidCounter = (Vaedra.Props.uidCounter or 0) + 1
    return "PROP-" .. Vaedra.Props.uidCounter
end

-- Create prop
function Vaedra.Props:CreateProp(coords, model, heading, interaction, range, text3D, options)
    local id = generateUID()
    options = options or {}
    
    Vaedra.Props.Active[id] = {
        id = id,
        coords = coords,
        model = model,
        heading = heading or 0.0,
        interaction = interaction or function() end,
        range = range or 100.0,
        text3D = text3D or nil,
        handle = nil,
        spawned = false,
        interactionRange = options.interactionRange or 2.0,
        frozen = options.frozen ~= false,
        invincible = options.invincible ~= false,
        collision = options.collision ~= false,
        alpha = options.alpha or 255,
        lodDistance = options.lodDistance or nil,
        textureVariation = options.textureVariation or nil,
        isNPC = options.isNPC or false,
        scenario = options.scenario or nil,
        animation = options.animation or nil
    }
    
    return id
end

-- Remove prop
function Vaedra.Props:RemoveProp(id)
    local prop = Vaedra.Props.Active[id]
    if not prop then
        return false
    end
    
    if prop.handle and DoesEntityExist(prop.handle) then
        DeleteEntity(prop.handle)
    end
    
    Vaedra.Props.Active[id] = nil
    return true
end

-- Update prop
function Vaedra.Props:UpdateProp(id, coords, model, heading, interaction, range, text3D, options)
    local prop = Vaedra.Props.Active[id]
    if not prop then
        return false
    end

    local needRespawn = false
    options = options or {}
    
    if coords and coords ~= prop.coords then 
        prop.coords = coords 
        needRespawn = true
    end
    if model and model ~= prop.model then 
        prop.model = model 
        needRespawn = true
    end
    if heading then prop.heading = heading end
    if interaction then prop.interaction = interaction end
    if range then prop.range = range end
    if text3D then prop.text3D = text3D end
    
    -- Update options
    if options.interactionRange then prop.interactionRange = options.interactionRange end
    if options.frozen ~= nil then prop.frozen = options.frozen end
    if options.invincible ~= nil then prop.invincible = options.invincible end
    if options.collision ~= nil then prop.collision = options.collision end
    if options.alpha then prop.alpha = options.alpha end
    if options.lodDistance then prop.lodDistance = options.lodDistance end
    if options.textureVariation then prop.textureVariation = options.textureVariation end

    -- Respawn if necessary
    if needRespawn and prop.spawned then
        if prop.handle and DoesEntityExist(prop.handle) then
            DeleteEntity(prop.handle)
        end
        prop.spawned = false
        prop.handle = nil
    end
    
    return true
end

-- Spawn prop
local function spawnProp(propData)
    local modelHash = GetHashKey(propData.model)
    local obj = nil
    
    -- Check if it's a ped model
    if IsModelAPed(modelHash) then
        RequestModel(modelHash)
        local timeout = 0
        while not HasModelLoaded(modelHash) and timeout < 50 do
            Citizen.Wait(100)
            timeout = timeout + 1
        end
        
        if HasModelLoaded(modelHash) then
            obj = CreatePed(4, modelHash, propData.coords.x, propData.coords.y, propData.coords.z, propData.heading, false, false)
        end
    else
        -- Regular object/item
        RequestModel(modelHash)
        local timeout = 0
        while not HasModelLoaded(modelHash) and timeout < 50 do
            Citizen.Wait(100)
            timeout = timeout + 1
        end
        
        if HasModelLoaded(modelHash) then
            obj = CreateObject(modelHash, propData.coords.x, propData.coords.y, propData.coords.z, false, false, false)
        end
    end
    
    if not obj then
        SetModelAsNoLongerNeeded(modelHash)
        return nil
    end
    
    if DoesEntityExist(obj) then
        SetEntityHeading(obj, propData.heading)
        
        -- Apply options
        if propData.frozen then
            FreezeEntityPosition(obj, true)
        end
        
        if propData.invincible then
            SetEntityInvincible(obj, true)
        end
        
        if not propData.collision then
            SetEntityCollision(obj, false, false)
        end
        
        if propData.alpha and propData.alpha < 255 then
            SetEntityAlpha(obj, propData.alpha, false)
        end
        
        if propData.lodDistance then
            SetEntityLodDist(obj, propData.lodDistance)
        end
        
        if propData.textureVariation then
            SetObjectTextureVariation(obj, propData.textureVariation)
        end
        
        -- NPC specific settings
        if IsEntityAPed(obj) then
            SetPedCanRagdoll(obj, false)
            SetEntityCanBeDamaged(obj, false)
            SetPedCanBeTargetted(obj, false)
            SetBlockingOfNonTemporaryEvents(obj, true)
            
            -- Apply scenario or animation
            if propData.scenario then
                TaskStartScenarioInPlace(obj, propData.scenario, 0, true)
            elseif propData.animation and propData.animation.dict and propData.animation.name then
                RequestAnimDict(propData.animation.dict)
                while not HasAnimDictLoaded(propData.animation.dict) do
                    Wait(10)
                end
                TaskPlayAnim(obj, propData.animation.dict, propData.animation.name, 8.0, -8.0, -1, 1, 0, false, false, false)
            end
        end
        
        SetModelAsNoLongerNeeded(modelHash)
        return obj
    end
    
    SetModelAsNoLongerNeeded(modelHash)
    return nil
end

-- Main prop management thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for id, prop in pairs(Vaedra.Props.Active) do
            local distance = #(prop.coords - playerCoords)
            local shouldSpawn = distance < prop.range
            
            -- Spawn/despawn management
            if shouldSpawn and not prop.spawned then
                local handle = spawnProp(prop)
                if handle then
                    prop.handle = handle
                    prop.spawned = true
                end
                
            elseif not shouldSpawn and prop.spawned then
                if prop.handle and DoesEntityExist(prop.handle) then
                    DeleteEntity(prop.handle)
                end
                prop.handle = nil
                prop.spawned = false
            end
        end
    end
end)

-- Interaction and 3D text thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local hasInteraction = false
        
        for id, prop in pairs(Vaedra.Props.Active) do
            if prop.spawned and prop.handle and DoesEntityExist(prop.handle) and prop.text3D then
                local distance = #(prop.coords - playerCoords)
                
                -- Interaction management
                if distance < prop.interactionRange then
                    hasInteraction = true
                    Vaedra.Draw:DrawText3D(prop.coords.x, prop.coords.y, prop.coords.z + 1.0, "~g~[E]~w~ " .. prop.text3D)
                    
                    if IsControlJustPressed(0, 38) then -- E key
                        prop.interaction(prop.id, prop)
                    end
                end
            end
        end
        
        if not hasInteraction then
            Citizen.Wait(200)
        end
    end
end)

-- Utility functions
function Vaedra.Props:GetProp(id)
    return Vaedra.Props.Active[id]
end

function Vaedra.Props:GetAllProps()
    return Vaedra.Props.Active
end

function Vaedra.Props:CountProps()
    local count = 0
    for _ in pairs(Vaedra.Props.Active) do
        count = count + 1
    end
    return count
end

function Vaedra.Props:ClearAllProps()
    for id, prop in pairs(Vaedra.Props.Active) do
        if prop.handle and DoesEntityExist(prop.handle) then
            DeleteEntity(prop.handle)
        end
    end
    Vaedra.Props.Active = {}
    Vaedra.Props.uidCounter = 0
end

-- Advanced prop functions
function Vaedra.Props:SetPropAlpha(id, alpha)
    local prop = Vaedra.Props.Active[id]
    if prop and prop.handle and DoesEntityExist(prop.handle) then
        SetEntityAlpha(prop.handle, alpha, false)
        prop.alpha = alpha
        return true
    end
    return false
end

function Vaedra.Props:SetPropCollision(id, collision)
    local prop = Vaedra.Props.Active[id]
    if prop and prop.handle and DoesEntityExist(prop.handle) then
        SetEntityCollision(prop.handle, collision, collision)
        prop.collision = collision
        return true
    end
    return false
end

function Vaedra.Props:SetPropFrozen(id, frozen)
    local prop = Vaedra.Props.Active[id]
    if prop and prop.handle and DoesEntityExist(prop.handle) then
        FreezeEntityPosition(prop.handle, frozen)
        prop.frozen = frozen
        return true
    end
    return false
end

function Vaedra.Props:GetPropCoords(id)
    local prop = Vaedra.Props.Active[id]
    if prop and prop.handle and DoesEntityExist(prop.handle) then
        return GetEntityCoords(prop.handle)
    elseif prop then
        return prop.coords
    end
    return nil
end

function Vaedra.Props:GetPropHeading(id)
    local prop = Vaedra.Props.Active[id]
    if prop and prop.handle and DoesEntityExist(prop.handle) then
        return GetEntityHeading(prop.handle)
    elseif prop then
        return prop.heading
    end
    return nil
end

-- Create NPC (simplified function)
function Vaedra.Props:CreateNPC(coords, model, scenario, alpha)
    local id = generateUID()
    alpha = alpha or 255
    
    Vaedra.Props.Active[id] = {
        id = id,
        coords = coords,
        model = model,
        heading = 0.0,
        interaction = function() end,
        range = 100.0,
        text3D = nil,
        handle = nil,
        spawned = false,
        interactionRange = 2.0,
        frozen = true,
        invincible = true,
        collision = false,
        alpha = alpha,
        lodDistance = nil,
        textureVariation = nil,
        isNPC = true,
        scenario = scenario,
        animation = nil
    }
    
    return id
end

-- Update NPC coordinates
function Vaedra.Props:UpdateNPCCoords(id, newCoords)
    local prop = Vaedra.Props.Active[id]
    if not prop then
        return false
    end
    
    -- Update coordinates
    prop.coords = newCoords
    
    -- If NPC is currently spawned, move it
    if prop.spawned and prop.handle and DoesEntityExist(prop.handle) then
        SetEntityCoords(prop.handle, newCoords.x, newCoords.y, newCoords.z, false, false, false, true)
    end
    
    return true
end

function Vaedra.Props:UpdateNPCAlpha(id, alpha)
    local prop = Vaedra.Props.Active[id]
    if prop and prop.handle and DoesEntityExist(prop.handle) then
        SetEntityAlpha(prop.handle, alpha, false)
        prop.alpha = alpha
        return true
    end
    return false
end


function Vaedra.Props:UpdateNPCHeading(id, heading)
    local prop = Vaedra.Props.Active[id]
    if prop and prop.handle and DoesEntityExist(prop.handle) then
        SetEntityHeading(prop.handle, heading)
        prop.heading = heading
        return true
    end
    return false
end 