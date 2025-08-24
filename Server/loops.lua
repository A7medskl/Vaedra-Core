AddEventHandler('OnResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for k, v in pairs(Vaedra.Shared.Items) do
            Vaedra.functions:RegisterItem(k, v)
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Wait(15 * 60 * 1000) -- 15 minutes = 900,000 milliseconds
    end 
end)