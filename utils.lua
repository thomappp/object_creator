SpawnedObjects = {}
ObjectCreator = {}

ObjectCreator.ShowNotification = function(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end

ObjectCreator.KeyboardInput = function(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, "", inputText, "", "", "", maxLength)

    Boolean = true
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        Boolean = false
        return result
    else
        Citizen.Wait(500)
        Boolean = false
        return false
    end
end

ObjectCreator.CreateObjectWorld = function(object)
    local playerPed = PlayerPedId()
    local objectCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
    local objectHeading = GetEntityHeading(playerPed)

    local objectCreated = CreateObject(object, objectCoords, true, false, false)

    if DoesEntityExist(objectCreated) ~= false then
        SetEntityHeading(objectCreated, objectHeading)
        local tbl = {
            obj = objectCreated,
            name = object
        }
        
        table.insert(SpawnedObjects, tbl)
        ObjectCreator.ShowNotification(("Vous avez ajouté l'objet ~g~%s~s~."):format(object))
    end
end

ObjectCreator.RemoveObjectTable = function(objectId, objectObj, objectName)
    for _, object in pairs(SpawnedObjects) do
        if _ == objectId and object.obj == objectObj then
            table.remove(SpawnedObjects, _)
            ObjectCreator.ShowNotification(("Vous avez supprimé l'objet ~g~%s~s~."):format(objectName))
            break;
        end
    end
end

ObjectCreator.SetCoords = function(object, x, y, z)
    local coords = GetOffsetFromEntityInWorldCoords(object, x, y, z)
    SetEntityCoords(object, coords)
end

ObjectCreator.SetRotation = function(object, x, y, z)
    local rotation = GetEntityRotation(object)
    SetEntityRotation(object, vector3(rotation.x + x, rotation.y + y, rotation.z + z))
end

RegisterNetEvent("object_creator:show_notification")
AddEventHandler("object_creator:show_notification", function(text)
    ObjectCreator.ShowNotification(text)
end)