RegisterNetEvent('Vaedra:Client:PlayerJoin')
AddEventHandler('Vaedra:Client:PlayerJoin', function(data)
    Vaedra.playerData = data
    Wait(1000)

    exports.spawnmanager:spawnPlayer()
    exports.spawnmanager:setAutoSpawn(false)


    Wait(1000)
    coords = Vaedra.functions:GetRandomPoint(Config.SpawnPoint)
    Vaedra.functions:TeleportPlayer(coords) 

    Wait(1000)

    
    if data.skin and next(data.skin) ~= nil then
        Vaedra.functions.SetPlayerAppearance(data.skin)
    else
        Vaedra.functions.OpenPlayerCustomization()
    end
end)

RegisterNetEvent('Vaedra:Client:UpdatePlayerData')
AddEventHandler('Vaedra:Client:UpdatePlayerData', function(data)
    Vaedra.playerData = data
end)


