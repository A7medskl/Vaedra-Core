Vaedra = Vaedra or {}
Vaedra.Blips = {
    Active = {},
    uidCounter = 0,
    Config = {
        defaultRange = 100.0,
        updateInterval = 500
    }
}

-- Generate unique ID
local function generateUID()
    Vaedra.Blips.uidCounter = Vaedra.Blips.uidCounter + 1
    return "BLIP_" .. Vaedra.Blips.uidCounter
end

-- Create standard blip
function Vaedra.Blips:Create(coords, sprite, scale, color, text, range, options)
    local id = generateUID()
    options = options or {}
    
    local blipData = {
        id = id,
        coords = coords,
        sprite = sprite or 1,
        scale = scale or 0.8,
        color = color or 1,
        text = text or "Blip",
        range = range,
        handle = nil,
        visible = false,
        type = "normal",
        shortRange = options.shortRange ~= false,
        rotation = options.rotation or 0,
    }
    
    Vaedra.Blips.Active[id] = blipData
    return id
end

-- Create radius blip
function Vaedra.Blips:CreateRadius(coords, radius, color, alpha, range)
    local id = generateUID()
    
    local blipData = {
        id = id,
        coords = coords,
        radius = radius or 50.0,
        color = color or 1,
        alpha = alpha or 128,
        range = range,
        radiusHandle = nil,
        visible = false,
        type = "radius"
    }
    
    Vaedra.Blips.Active[id] = blipData
    return id
end

-- Remove blip
function Vaedra.Blips:Remove(id)
    local blip = Vaedra.Blips.Active[id]
    if not blip then return false end
    
    if blip.handle and DoesBlipExist(blip.handle) then
        RemoveBlip(blip.handle)
    end
    
    if blip.radiusHandle and DoesBlipExist(blip.radiusHandle) then
        RemoveBlip(blip.radiusHandle)
    end
    
    Vaedra.Blips.Active[id] = nil
    return true
end

-- Update blip
function Vaedra.Blips:Update(id, coords, sprite, scale, color, text, range)
    local blip = Vaedra.Blips.Active[id]
    if not blip then return false end
    
    if coords then blip.coords = coords end
    if sprite then blip.sprite = sprite end
    if scale then blip.scale = scale end
    if color then blip.color = color end
    if text then blip.text = text end
    if range ~= nil then blip.range = range end
    
    -- Force refresh if visible
    if blip.visible then
        if blip.handle and DoesBlipExist(blip.handle) then
            RemoveBlip(blip.handle)
            blip.handle = nil
        end
        if blip.radiusHandle and DoesBlipExist(blip.radiusHandle) then
            RemoveBlip(blip.radiusHandle)
            blip.radiusHandle = nil
        end
        blip.visible = false
    end
    
    return true
end

-- Get blip data
function Vaedra.Blips:Get(id)
    return Vaedra.Blips.Active[id]
end

-- Check if blip exists
function Vaedra.Blips:Exists(id)
    return Vaedra.Blips.Active[id] ~= nil
end

-- Clear all blips
function Vaedra.Blips:Clear()
    for id in pairs(Vaedra.Blips.Active) do
        Vaedra.Blips:Remove(id)
    end
    Vaedra.Blips.uidCounter = 0
end

-- Set blip visibility
function Vaedra.Blips:SetVisible(id, visible)
    local blip = Vaedra.Blips.Active[id]
    if not blip then return end
    
    if blip.handle and DoesBlipExist(blip.handle) then
        SetBlipDisplay(blip.handle, visible and 4 or 0)
    end
    if blip.radiusHandle and DoesBlipExist(blip.radiusHandle) then
        SetBlipDisplay(blip.radiusHandle, visible and 4 or 0)
    end
end

-- Create blip handle
local function createBlipHandle(blip)
    local handle = AddBlipForCoord(blip.coords)
    if not handle or handle == 0 then return nil end
    
    SetBlipSprite(handle, blip.sprite)
    SetBlipScale(handle, blip.scale)
    SetBlipColour(handle, blip.color)
    SetBlipAsShortRange(handle, blip.shortRange)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blip.text)
    EndTextCommandSetBlipName(handle)
    
    if blip.rotation ~= 0 then
        SetBlipRotation(handle, blip.rotation)
    end
    
    
    return handle
end

-- Main update thread
local lastPlayerCoords = vector3(0, 0, 0)
local lastCoordsUpdate = 0

CreateThread(function()
    while true do
        Wait(Vaedra.Blips.Config.updateInterval)
        
        -- Update player coords less frequently
        local currentTime = GetGameTimer()
        if currentTime - lastCoordsUpdate > 1000 then
            lastPlayerCoords = GetEntityCoords(PlayerPedId())
            lastCoordsUpdate = currentTime
        end
        
        -- Process blips
        for id, blip in pairs(Vaedra.Blips.Active) do
            local shouldShow = true
            
            if blip.range then
                local distance = #(blip.coords - lastPlayerCoords)
                shouldShow = distance < blip.range
            end
            
            if shouldShow and not blip.visible then
                -- Show blip
                if blip.type == "radius" then
                    local handle = AddBlipForRadius(blip.coords, blip.radius)
                    if handle and handle > 0 then
                        SetBlipColour(handle, blip.color)
                        SetBlipAlpha(handle, blip.alpha)
                        blip.radiusHandle = handle
                        blip.visible = true
                    end
                else
                    local handle = createBlipHandle(blip)
                    if handle then
                        blip.handle = handle
                        blip.visible = true
                    end
                end
            elseif not shouldShow and blip.visible then
                -- Hide blip
                if blip.handle and DoesBlipExist(blip.handle) then
                    RemoveBlip(blip.handle)
                    blip.handle = nil
                end
                if blip.radiusHandle and DoesBlipExist(blip.radiusHandle) then
                    RemoveBlip(blip.radiusHandle)
                    blip.radiusHandle = nil
                end
                blip.visible = false
            end
        end
    end
end)
