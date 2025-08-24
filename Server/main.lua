Vaedra = Vaedra or {}
Vaedra.Players = Vaedra.Players or {}
Vaedra.IdentifierIndex = Vaedra.IdentifierIndex or {
    steam = {},
    license = {},
    discord = {},
    ip = {},
    token = {}
}

function GetCoreObject()
    return Vaedra
end 

exports('GetCoreObject', GetCoreObject)