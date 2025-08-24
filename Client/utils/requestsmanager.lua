Vaedra = Vaedra or {}
Vaedra.RequestManager = {}

-- Local storage for notification state
local currentRequest = nil
local notificationActive = false
local nuiReady = false

-- Initialize NUI
CreateThread(function()
    Wait(1000) -- Wait for resource to fully load
    SendNUIMessage({
        action = "init"
    })
    nuiReady = true
end)

-- Create request function (wrapper for server call)
function Vaedra.RequestManager.createRequest(target, title, description, callback)
    if not target or not title or not description then
        return false
    end
    
    -- Trigger server event to create request
    TriggerServerEvent('vaedra:createRequest', target, title, description)
    return true
end

-- Show request notification
local function showRequestNotification(requestData)
    if not nuiReady then return end
    
    currentRequest = requestData
    notificationActive = true
    
    -- Play notification sound
    PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", 1)
    
    -- Show custom UI notification
    SendNUIMessage({
        action = "showRequest",
        request = requestData
    })
    
end

-- Hide request notification
local function hideRequestNotification()
    if not nuiReady then return end
    
    currentRequest = nil
    notificationActive = false
    
    -- Hide custom UI notification
    SendNUIMessage({
        action = "hideRequest"
    })
end

-- Handle showing request notification
RegisterNetEvent('vaedra:showRequestNotification')
AddEventHandler('vaedra:showRequestNotification', function(requestData)
    showRequestNotification(requestData)
end)

-- Handle hiding request notification
RegisterNetEvent('vaedra:hideRequestNotification')
AddEventHandler('vaedra:hideRequestNotification', function()
    hideRequestNotification()
end)

-- NUI Callbacks
RegisterNUICallback('respondToRequest', function(data, cb)
    local requestId = tonumber(data.requestId)
    local response = data.response == "accept"
    
    if requestId and currentRequest and currentRequest.id == requestId then
        TriggerServerEvent('vaedra:requestResponse', requestId, response)
        hideRequestNotification()
    end
    
    cb('ok')
end)

-- Keyboard input handler (backup for NUI)
CreateThread(function()
    while true do
        if notificationActive and currentRequest then
            -- Check for Y key (Accept)
            if IsControlJustPressed(0, 246) then -- Y key
                TriggerServerEvent('vaedra:requestResponse', currentRequest.id, true)
                hideRequestNotification()
            end
            
            -- Check for N key (Decline) - Using correct control ID
            if IsControlJustPressed(0, 306) then -- N key (correct ID)
                TriggerServerEvent('vaedra:requestResponse', currentRequest.id, false)
                hideRequestNotification()
            end
            Wait(0)
        else
            Wait(500) -- Reduce CPU usage when no active request
        end
    end
end)
