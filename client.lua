local MainMenu = RageUI.CreateMenu("Création", "Options de creation");
local ObjectListMenu = RageUI.CreateSubMenu(MainMenu, "Création", "Liste des objets");
local EditObjectMenu = RageUI.CreateSubMenu(ObjectListMenu, "Création", "Editer un objet");
local SelectedObject = nil
local MarkerActive = false

function RageUI.PoolMenus:CreatorMenu()
	MainMenu:IsVisible(function(Items)
		Items:AddButton("Ajouter un objet", "Ajouter un objet (/createobj)", { IsDisabled = false }, function(onSelected)
			if (onSelected) then
				local object = ObjectCreator.KeyboardInput("OBJECT_SPAWNER", "Nom de l'objet", "", 30)
				ObjectCreator.CreateObjectWorld(object)
			end
		end)

		Items:AddButton("Liste des objets", "Liste des objets placés", { IsDisabled = #SpawnedObjects == 0 }, function(onSelected)
		end, ObjectListMenu)
	end, function()
	end)

	ObjectListMenu:IsVisible(function(Items)
		if #SpawnedObjects > 0 then
			for i = 1, #SpawnedObjects do
				Items:AddButton(("(%s) - %s"):format(i, SpawnedObjects[i].name), nil, { IsDisabled = false }, function(onSelected)
					if (onSelected) then
						SelectedObject = i
					end
				end, EditObjectMenu)
			end
		end
	end, function()
	end)

	EditObjectMenu:IsVisible(function(Items)
		local Object = SpawnedObjects[SelectedObject]
		local ditance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(Object.obj))

		if ditance < 100 then

			Items:AddSeparator("~y~Information")

			Items:AddButton(("Nom - %s"):format(Object.name), nil, { IsDisabled = false }, function(onSelected)
			end)
            Items:AddButton(("Objet - %s"):format(Object.obj), nil, { IsDisabled = false }, function(onSelected)
			end)

			Items:AddSeparator("~y~Actions")

			Items:AddButton("Se téléporter", nil, { IsDisabled = false }, function(onSelected)
				if (onSelected) then
					SetEntityCoords(PlayerPedId(), GetEntityCoords(Object.obj))
				end
			end)

			if MarkerActive then
				local coords = GetOffsetFromEntityInWorldCoords(Object.obj, 0.0, 0.0, 2.0)
				DrawMarker(2, coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 150, 0, 255, false, true, false, false, false, false, false)
			end

			Items:CheckBox("Marqueur", nil, MarkerActive, { Style = 1 }, function(onSelected, IsChecked)
				if (onSelected) then
					MarkerActive = IsChecked
				end
			end)

			Items:CheckBox("Freeze", nil, IsEntityPositionFrozen(Object.obj), { Style = 1 }, function(onSelected, IsChecked)
				if (onSelected) then
					FreezeEntityPosition(Object.obj, not IsEntityPositionFrozen(Object.obj))
				end
			end)

			Items:AddButton("Coordonnées", "Utilisez 4, 5, 6, 8, - et + pour modifier les coordonnées", { Style = 1 }, function(onSelected)
				if IsControlPressed(0, 108) then -- 4
					ObjectCreator.SetCoords(Object.obj, -0.02, 0.0, 0.0)
				elseif IsControlPressed(0, 109) then -- 6
					ObjectCreator.SetCoords(Object.obj, 0.02, 0.0, 0.0)
				end

				if IsControlPressed(0, 110) then -- 5
					ObjectCreator.SetCoords(Object.obj, 0.0, -0.02, 0.0)
				elseif IsControlPressed(0, 111) then -- 8
					ObjectCreator.SetCoords(Object.obj, 0.0, 0.02, 0.0)
				end

				if IsControlPressed(0, 315) then -- -
					ObjectCreator.SetCoords(Object.obj, 0.0, 0.0, -0.02)
				elseif IsControlPressed(0, 314) then -- +
					ObjectCreator.SetCoords(Object.obj, 0.0, 0.0, 0.02)
				end
			end)

			Items:AddButton("Rotation", "Utilisez 4, 5, 6, 8  et les fèches pour modifier la rotation", { Style = 1 }, function(onSelected)
				if IsControlPressed(0, 111) then -- 8
					ObjectCreator.SetRotation(Object.obj, -0.5, 0.0, 0.0)
				elseif IsControlPressed(0, 110) then -- 5
					ObjectCreator.SetRotation(Object.obj, 0.5, 0.0, 0.0)
				end

				if IsControlPressed(0, 108) then -- 4
					ObjectCreator.SetRotation(Object.obj, 0.0, -0.5, 0.0)
				elseif IsControlPressed(0, 109) then -- 6
					ObjectCreator.SetRotation(Object.obj, 0.0, 0.5, 0.0)
				end

				if IsControlPressed(0, 174) then -- Left Arrow
					ObjectCreator.SetRotation(Object.obj, 0.0, 0.0, -0.5)
				elseif IsControlPressed(0, 175) then -- Right Arrow
					ObjectCreator.SetRotation(Object.obj, 0.0, 0.0, 0.5)
				end
			end)

			Items:AddButton("Réinitialiser", nil, { IsDisabled = false }, function(onSelected)
				if (onSelected) then
					SetEntityRotation(Object.obj, vector3(0.0, 0.0, 0.0))
				end
			end)
            
            Items:AddButton("Enregistrer", nil, { IsDisabled = false }, function(onSelected)
				if (onSelected) then
                    local data = {
                        name = Object.name,
                        coords = GetEntityCoords(Object.obj),
                        rotation = GetEntityRotation(Object.obj),
                        freeze = IsEntityPositionFrozen(Object.obj) and true or false
                    }

                    TriggerServerEvent("object_creator:save_object", data)
				end
			end)

			Items:AddButton("Supprimer", nil, { IsDisabled = false }, function(onSelected)
				if (onSelected) then
					if DoesEntityExist(Object.obj) then
						DeleteObject(Object.obj)
						ObjectCreator.RemoveObjectTable(SelectedObject, Object.obj, Object.name)
					end
				end
			end, MainMenu)
		else
			Items:AddButton("~r~Assurez vous d'être assez proche de l'objet", nil, { IsDisabled = false }, function(onSelected)
			end)

			Items:AddButton("Se téléporter", nil, { IsDisabled = false }, function(onSelected)
				if (onSelected) then
					SetEntityCoords(PlayerPedId(), GetEntityCoords(Object.obj))
				end
			end)
		end
	end, function()
	end)
end

Keys.Register("F10", "F10", "Menu création", function()
	RageUI.Visible(MainMenu, not RageUI.Visible(MainMenu))
end)

RegisterCommand("createobj", function(source, args)
	local object = args[1]
	if object then
		ObjectCreator.CreateObjectWorld(object)
	end
end)