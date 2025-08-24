Vaedra = Vaedra or {}
Vaedra.RequestManager = {}

-- Storage for all requests and player queues
local activeRequests = {}
local playerQueues = {} -- Store request queues for each player
local currentActiveRequest = {} -- Currently active request per player
local requestIdCounter = 0
local requestTimers = {} -- Store timers for request expiration

-- Configuration
local REQUEST_EXPIRE_TIME = 30000 -- 30 seconds in milliseconds

-- Generate unique request ID
local function generateRequestId()
    requestIdCounter = requestIdCounter + 1
    return requestIdCounter
end

-- Initialize player queue if it doesn't exist
local function initializePlayerQueue(playerId)
    if not playerQueues[playerId] then
        playerQueues[playerId] = {}
    end
end

-- Add request to player's queue
local function addToQueue(playerId, requestData)
    initializePlayerQueue(playerId)
    table.insert(playerQueues[playerId], requestData)
end

-- Remove request from player's queue
local function removeFromQueue(playerId, requestId)
    if not playerQueues[playerId] then return end
    
    for i, request in ipairs(playerQueues[playerId]) do
        if request.id == requestId then
            table.remove(playerQueues[playerId], i)
            break
        end
    end
end

-- Get next request in queue (FIFO)
local function getNextRequest(playerId)
    if not playerQueues[playerId] or #playerQueues[playerId] == 0 then
        return nil
    end
    return playerQueues[playerId][1]
end

-- Process next request in queue
local function processNextRequest(playerId)
    if not playerQueues[playerId] or #playerQueues[playerId] == 0 then
        currentActiveRequest[playerId] = nil
        return
    end
    
    local nextRequest = playerQueues[playerId][1]
    currentActiveRequest[playerId] = nextRequest
    
    -- Send notification to player
    TriggerClientEvent('vaedra:showRequestNotification', playerId, nextRequest)
    
    -- Set expiration timer
    requestTimers[nextRequest.id] = SetTimeout(REQUEST_EXPIRE_TIME, function()
        -- Auto-decline if not responded
        if activeRequests[nextRequest.id] then
            handleRequestResponse(playerId, nextRequest.id, false, true) -- true = expired
        end
    end)
end

-- Create a new request
function Vaedra.RequestManager.createRequest(source, target, title, description, callback)
    if not source or not target or not title or not description then
        return false
    end
    
    local requestId = generateRequestId()
    local timestamp = os.time()
    
    -- Create request data
    local requestData = {
        id = requestId,
        source = source,
        target = target,
        title = title,
        description = description,
        callback = callback,
        timestamp = timestamp,
        sourceName = GetPlayerName(source) or "Unknown"
    }
    
    -- Store in active requests
    activeRequests[requestId] = requestData
    
    -- Add to target player's queue
    addToQueue(target, requestData)
    
    -- If no active request, process this one immediately
    if not currentActiveRequest[target] then
        processNextRequest(target)
    end
    
    return requestId
end

-- Handle request response (accept/decline)
local function handleRequestResponse(playerId, requestId, response, expired)
    local request = activeRequests[requestId]
    
    if not request then
        return
    end
    
    -- Clear timer if exists
    if requestTimers[requestId] then
        ClearTimeout(requestTimers[requestId])
        requestTimers[requestId] = nil
    end
    
    -- Remove from queue
    removeFromQueue(playerId, requestId)
    
    -- Remove from active requests
    activeRequests[requestId] = nil
    
    -- Clear current active request
    currentActiveRequest[playerId] = nil
    
    -- Execute callback if provided
    if request.callback and type(request.callback) == "function" then
        request.callback(response, request)
    end
    
    -- Notify source player of response
    local responseText
    if expired then
        responseText = "expired"
    else
        responseText = response and "accepted" or "declined"
    end
    
    TriggerClientEvent('vaedra:notify', request.source, 
        string.format("Your request '%s' was %s by %s", request.title, responseText, GetPlayerName(playerId)))
    
    -- Hide current notification
    TriggerClientEvent('vaedra:hideRequestNotification', playerId)
    
    -- Process next request in queue after small delay
    SetTimeout(500, function()
        processNextRequest(playerId)
    end)
end

RegisterServerEvent('vaedra:requestResponse')
AddEventHandler('vaedra:requestResponse', function(requestId, response)
    local playerId = source
    local request = activeRequests[requestId]
    
    if not request then
        TriggerClientEvent('vaedra:notify', playerId, "Invalid request", "error")
        return
    end
    
    if request.target ~= playerId then
        TriggerClientEvent('vaedra:notify', playerId, "Unauthorized request response", "error")
        return
    end
    
    handleRequestResponse(playerId, requestId, response, false)
end)


-- Clear all requests for a player (when they disconnect)
AddEventHandler('playerDropped', function()
    local playerId = source
    
    -- Clear timers for this player's requests
    if currentActiveRequest[playerId] then
        local requestId = currentActiveRequest[playerId].id
        if requestTimers[requestId] then
            ClearTimeout(requestTimers[requestId])
            requestTimers[requestId] = nil
        end
    end
    
    -- Clear player's queue
    if playerQueues[playerId] then
        for _, request in ipairs(playerQueues[playerId]) do
            if requestTimers[request.id] then
                ClearTimeout(requestTimers[request.id])
                requestTimers[request.id] = nil
            end
            activeRequests[request.id] = nil
        end
        playerQueues[playerId] = nil
    end
    
    -- Clear current active request
    currentActiveRequest[playerId] = nil
    
    -- Remove any requests sent by this player
    for requestId, request in pairs(activeRequests) do
        if request.source == playerId then
            removeFromQueue(request.target, requestId)
            activeRequests[requestId] = nil
            -- Clear timer if exists
            if requestTimers[requestId] then
                ClearTimeout(requestTimers[requestId])
                requestTimers[requestId] = nil
            end
            -- Hide notification and process next
            TriggerClientEvent('vaedra:hideRequestNotification', request.target)
            processNextRequest(request.target)
        end
    end
end)

-- Handle create request from client
RegisterServerEvent('vaedra:createRequest')
AddEventHandler('vaedra:createRequest', function(target, title, description)
    local source = source
    Vaedra.RequestManager.createRequest(source, target, title, description, nil)
end)
