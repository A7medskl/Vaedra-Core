AddEventHandler('chatMessage', function(_, _, message)
    if string.sub(message, 1, 1) == '/' then
        CancelEvent()
        return
    end
end)





AddEventHandler('playerDropped', function (reason, resourceName, clientDropReason)
    local source = source
end)



Vaedra.Callback:RegisterServerCallback('Vaedra:Server:GetItem', function(source, cb, itemName)
    cb(Vaedra.functions:GetItem(itemName))
end)

Vaedra.Callback:RegisterServerCallback('Vaedra:Server:GetItems', function(source, cb)
    cb(Vaedra.functions:GetItems())
end)

Vaedra.Callback:RegisterServerCallback('Vaedra:Server:ItemExists', function(source, cb, itemName)
    cb(Vaedra.functions:ItemExists(itemName))
end)


Vaedra.Callback:RegisterServerCallback('Vaedra:Server:GetPlayerBucket', function(source)
    return Vaedra.functions:GetPlayerBucket(source)
end)


RegisterNetEvent('Vaedra:Server:SetPlayerBucket')
AddEventHandler('Vaedra:Server:SetPlayerBucket', function(bucket)
    local source = source
    Vaedra.functions:SetPlayerBucket(source, bucket)
end)


RegisterNetEvent('Vaedra:Server:PlayerJoin')
AddEventHandler('Vaedra:Server:PlayerJoin', function()
    local source = source
    local identifiers = Vaedra.functions:GetPlayerIdentifiersTable(source)
    local name = GetPlayerName(source)
end)

RegisterNetEvent('Vaedra:Server:RequestPlayerDataUpdate')
AddEventHandler('Vaedra:Server:RequestPlayerDataUpdate', function()
    local source = source
    local Xplayer = Vaedra.functions:GetPlayer(source)
    Xplayer.updatePlaytime()
    if Xplayer then
        TriggerClientEvent('Vaedra:Client:UpdatePlayerData', source, Xplayer)
    end
end)


RegisterNetEvent('Vaedra:Server:SetSkin')
AddEventHandler('Vaedra:Server:SetSkin', function(skinData)
    local source = source
    local Xplayer = Vaedra.functions:GetPlayer(source)
    if Xplayer then
        Xplayer.SetSkin(skinData)
    end
end)
