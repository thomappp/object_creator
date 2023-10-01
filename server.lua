local resourceName = GetCurrentResourceName()
local fileName = "data.json"

local GetFile = function()
    local data = LoadResourceFile(resourceName, fileName)
    return json.decode(data)
end

local SaveFile = function(data)
    local dataFile = GetFile()
    table.insert(dataFile, data)
    local success = SaveResourceFile(resourceName, fileName, json.encode(dataFile), -1)
    return success
end

RegisterServerEvent("object_creator:save_object")
AddEventHandler("object_creator:save_object", function(data)
    local playerId = source
    local success = SaveFile(data)

    if success then
        TriggerClientEvent("object_creator:show_notification", playerId, ("Vous avez enregistré l'objet ~g~%s~s~."):format(data.name))
    else
        TriggerClientEvent("object_creator:show_notification", playerId, "~r~Une erreur est survenue durant l'enregistrement de l'objet.")
    end
end)