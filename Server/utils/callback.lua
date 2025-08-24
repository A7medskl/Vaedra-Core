
Callbacks = {}

Callbacks.requests = {}
Callbacks.storage = {}
Callbacks.id = 0

Vaedra.Callback = Vaedra.Callback or {}


function Callbacks:Register(name, resource, cb)
    self.storage[name] = {
        resource = resource,
        cb = cb
    }
end

function Callbacks:Execute(cb, ...)
    local success, errorString = pcall(cb, ...)

    if not success then
        print(("[^1ERROR^7] Failed to execute Callback with RequestId: ^5%s^7"):format(self.currentId))
        print("^3Callback Error:^7 " .. tostring(errorString))  -- just log, don't throw
        self.currentId = nil
        return
    end

    self.currentId = nil
end

function Callbacks:Trigger(player, event, cb, invoker, ...)
    self.requests[self.id] = {
        await = type(cb) == "boolean",
        cb = cb or promise:new()
    }
    local table = self.requests[self.id]

    TriggerClientEvent("Vaedra:triggerClientCallback", player, event, self.id, invoker, ...)

    self.id += 1

    return table.cb
end

function Callbacks:ServerRecieve(player, event, requestId, invoker, ...)
    self.currentId = requestId

    if not self.storage[event] then
        return error(("Server Callback with requestId ^5%s^1 Was Called by ^5%s^1 but does not exist."):format(event, invoker))
    end

    local returnCb = function(...)
        TriggerClientEvent("Vaedra:serverCallback", player, requestId, invoker, ...)
    end
    local callback = self.storage[event].cb

    self:Execute(callback, player, returnCb, ...)
end

function Callbacks:RecieveClient(requestId, invoker, ...)
    self.currentId = requestId

    if not self.requests[self.currentId] then
        return error(("Client Callback with requestId ^5%s^1 Was Called by ^5%s^1 but does not exist."):format(self.currentId, invoker))
    end

    local callback = self.requests[self.currentId]

    self.requests[requestId] = nil
    if callback.await then
        callback.cb:resolve({ ... })
    else
        self:Execute(callback.cb, ...)
    end
end

-- =============================================
-- MARK: Vaedra Functions
-- =============================================

---@param player number playerId
---@param eventName string
---@param callback function
---@param ... any
function Vaedra.Callback:TriggerClientCallback(player, eventName, callback, ...)
    local invokingResource = GetInvokingResource()
    local invoker = (invokingResource and invokingResource ~= "Unknown") and invokingResource or "Vaedra-Core"

    Callbacks:Trigger(player, eventName, callback, invoker, ...)
end

---@param player number playerId
---@param eventName string
---@param ... any
---@return ...
function Vaedra.Callback:AwaitClientCallback(player, eventName, ...)
    local invokingResource = GetInvokingResource()
    local invoker = (invokingResource and invokingResource ~= "Unknown") and invokingResource or "Vaedra-Core"

    local p = Callbacks:Trigger(player, eventName, false, invoker, ...)
    if not p then return end

    SetTimeout(15000, function()
        if p.state == "pending" then
            p:reject("Server Callback Timed Out")
        end
    end)

    Citizen.Await(p)

    return table.unpack(p.value)
end

---@param eventName string
---@param callback function
---@return nil
function Vaedra.Callback:RegisterServerCallback(eventName, callback)
    local invokingResource = GetInvokingResource()
    local invoker = (invokingResource and invokingResource ~= "Unknown") and invokingResource or "Vaedra-Core"

    Callbacks:Register(eventName, invoker, callback)
end

---@param eventName string
---@return boolean
function Vaedra.Callback:DoesServerCallbackExist(eventName)
    return Callbacks.storage[eventName] ~= nil
end

-- =============================================
-- MARK: Events
-- =============================================

RegisterNetEvent("Vaedra:clientCallback")
AddEventHandler("Vaedra:clientCallback", function(requestId, invoker, ...)
    Callbacks:RecieveClient(requestId, invoker, ...)
end)

RegisterNetEvent("Vaedra:triggerServerCallback")
AddEventHandler("Vaedra:triggerServerCallback", function(eventName, requestId, invoker, ...)
    local source = source
    Callbacks:ServerRecieve(source, eventName, requestId, invoker, ...)
end)

AddEventHandler("onResourceStop", function(resource)
    for k, v in pairs(Callbacks.storage) do
        if v.resource == resource then
            Callbacks.storage[k] = nil
        end
    end
end)