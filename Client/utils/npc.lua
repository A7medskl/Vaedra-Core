Vaedra = Vaedra or {}
Vaedra.NPCs = {
    Active = {},
    uidCounter = 0
}

-- Générateur d'UID robuste
local function generateUID()
    Vaedra.NPCs.uidCounter = (Vaedra.NPCs.uidCounter or 0) + 1
    return "NPC-" .. Vaedra.NPCs.uidCounter
end

-- Création d'un NPC
function Vaedra.NPCs:CreateNPC(coords, model, heading, scenario, interaction, range, text3D)
    local id = generateUID()
    Vaedra.NPCs.Active[id] = {
        id = id,
        coords = coords,
        model = model or "a_m_y_business_01",
        heading = heading or 0.0,
        scenario = scenario or nil,
        interaction = interaction or function() end,
        range = range or 100.0,
        text3D = text3D or nil,
        handle = nil,
        spawned = false,
        interactionRange = 2.0,
        showingText = false
    }
    
    return id
end

-- Suppression d'un NPC
function Vaedra.NPCs:RemoveNPC(id)
    local npc = Vaedra.NPCs.Active[id]
    if not npc then
        return false
    end
    
    if npc.handle and DoesEntityExist(npc.handle) then
        DeleteEntity(npc.handle)
    end
    
    Vaedra.NPCs.Active[id] = nil
    return true
end

-- Mise à jour d'un NPC
function Vaedra.NPCs:UpdateNPC(id, coords, model, heading, scenario, interaction, range, text3D)
    local npc = Vaedra.NPCs.Active[id]
    if not npc then
        return false
    end

    local needRespawn = false
    
    if coords and coords ~= npc.coords then 
        npc.coords = coords 
        needRespawn = true
    end
    if model and model ~= npc.model then 
        npc.model = model 
        needRespawn = true
    end
    if heading then npc.heading = heading end
    if scenario then npc.scenario = scenario end
    if interaction then npc.interaction = interaction end
    if range then npc.range = range end
    if text3D then npc.text3D = text3D end

    -- Respawn si nécessaire
    if needRespawn and npc.spawned then
        if npc.handle and DoesEntityExist(npc.handle) then
            DeleteEntity(npc.handle)
        end
        npc.spawned = false
        npc.handle = nil
    end
end

-- Spawn d'un NPC
local function spawnNPC(npcData)
    local modelHash = GetHashKey(npcData.model)
    
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 50 do
        Citizen.Wait(100)
        timeout = timeout + 1
    end
    
    if not HasModelLoaded(modelHash) then
        return nil
    end
    
    local ped = CreatePed(4, modelHash, npcData.coords.x, npcData.coords.y, npcData.coords.z - 1.0, npcData.heading, false, true)
    
    if DoesEntityExist(ped) then
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
        SetPedCanRagdoll(ped, false)
        SetPedCanBeTargetted(ped, false)
        SetPedCanBeDraggedOut(ped, false)
        
        -- Applique le scénario si spécifié
        if npcData.scenario then
            TaskStartScenarioInPlace(ped, npcData.scenario, 0, true)
        end
        
        SetModelAsNoLongerNeeded(modelHash)
        return ped
    end
    
    SetModelAsNoLongerNeeded(modelHash)
    return nil
end

-- Thread principal de gestion des NPCs
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for id, npc in pairs(Vaedra.NPCs.Active) do
            local distance = #(npc.coords - playerCoords)
            local shouldSpawn = distance < npc.range
            
            -- Gestion du spawn du NPC
            if shouldSpawn and not npc.spawned then
                local handle = spawnNPC(npc)
                if handle then
                    npc.handle = handle
                    npc.spawned = true
                end
                
            elseif not shouldSpawn and npc.spawned then
                if npc.handle and DoesEntityExist(npc.handle) then
                    DeleteEntity(npc.handle)
                end
                npc.handle = nil
                npc.spawned = false
                npc.showingText = false
            end
        end
    end
end)

-- Thread de gestion des interactions et texte 3D
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local hasInteraction = false
        
        for id, npc in pairs(Vaedra.NPCs.Active) do
            if npc.spawned and npc.handle and DoesEntityExist(npc.handle) then
                local distance = #(npc.coords - playerCoords)
                
                -- Gestion des interactions
                if distance < npc.interactionRange then
                    hasInteraction = true
                    Vaedra.Draw:DrawText3D(npc.coords.x, npc.coords.y, npc.coords.z + 1.0,"~g~[E]~w~ "..npc.text3D)
                    
                    if IsControlJustPressed(0, 38) then -- Touche E
                        npc.interaction(npc.id, npc)
                    end
                end
            end
        end
        
        if not hasInteraction then
            Citizen.Wait(200)
        end
    end
end)

-- Fonctions utilitaires
function Vaedra.NPCs:GetNPC(id)
    return Vaedra.NPCs.Active[id]
end

function Vaedra.NPCs:GetAllNPCs()
    return Vaedra.NPCs.Active
end

function Vaedra.NPCs:CountNPCs()
    local count = 0
    for _ in pairs(Vaedra.NPCs.Active) do
        count = count + 1
    end
    return count
end

function Vaedra.NPCs:ClearAllNPCs()
    for id, npc in pairs(Vaedra.NPCs.Active) do
        if npc.handle and DoesEntityExist(npc.handle) then
            DeleteEntity(npc.handle)
        end
    end
    Vaedra.NPCs.Active = {}
    Vaedra.NPCs.uidCounter = 0
end
