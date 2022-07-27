local currentweapon = false
local canisterfill = false
local guiEnabled = false
local showmsg = false
local payment = true
local check = false
local fill = false
local fueltype = 0
local selected = 0
local vehicle = 0
local money = 0
local fuel = 0
local car = 0
local blur = "MenuMGIn"
local name = ""
local coords

function DisplayHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function EnableGui(enable)
    SetNuiFocus(enable)
    guiEnabled = enable
    SendNUIMessage({
        type = "enableui",
        enable = enable
    })
    StartScreenEffect(blur, 1, true)
end

function GetFuel(vehicle)
	return GetVehicleFuelLevel(vehicle)
end

function SetFuel(vehicle, fuel)
	SetVehicleFuelLevel(vehicle, fuel)
end

function FindNearestFuelPump()
	local coords = GetEntityCoords(PlayerPedId())
	local fuelPumps = {}
	local handle,object = FindFirstObject()
	local success
	for k,v in pairs(GetGamePool('CObject')) do
		if config.Pump_models[GetEntityModel(v)] then
			table.insert(fuelPumps,v)
		end
	end

	local pumpObject = 0
	local pumpDistance = config.Pump_distance

	for k,v in pairs(fuelPumps) do
		local dstcheck = #(coords - GetEntityCoords(v))

		if dstcheck < pumpDistance then
			pumpDistance = dstcheck
			pumpObject = v
		end
	end
	if pumpObject == 0 then
		return false
	else
		return pumpObject
	end
end

function CheckFuelType(vehicle)
    fueltype = 0
    name = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    for k, i in ipairs(config.Petrol) do
        if i == name then
            fueltype = 1
        end
    end
    if fueltype == 0 then
        for k, i in ipairs(config.Diesel) do
            if i == name then
                fueltype = 2
            end
        end
    end
end

function DrawText3Ds(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)

	if onScreen then
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
	end
end

RegisterNUICallback('escape', function(data, cb)
    if fill then
        fill = false
        if money == 0 then
            DisplayNotification("Betanken abgebrochen")
        else
            DisplayNotification("Betanken abgebrochen und du hast " .. money .. "$ gezahlt")
        end
        money = 0
    end
    EnableGui(false)
    cb('ok')
    Citizen.Wait(50)
    StopScreenEffect(blur)
end)

RegisterNUICallback('petrolbutton', function(data, cb)
    if fill then
        fill = false
        if money == 0 then
            DisplayNotification("Betanken abgebrochen")
        else
            DisplayNotification("Betanken abgebrochen und du hast " .. money .. "$ gezahlt")
        end
        money = 0
    end
    if selected == 0 or selected == 2 then
        selected = 1
    else
        selected = 0
    end
    cb('ok')
end)

RegisterNUICallback('dieselbutton', function(data, cb)
    if fill then
        fill = false
        if money == 0 then
            DisplayNotification("Betanken abgebrochen")
        else
            DisplayNotification("Betanken abgebrochen und du hast " .. money .. "$ gezahlt")
        end
        money = 0
    end
    if selected == 0 or selected == 1 then
        selected = 2
    else
        selected = 0
    end
    cb('ok')
end)

RegisterNUICallback('cardbutton', function(data, cb)
    payment = true
    cb('ok')
end)

RegisterNUICallback('walletbutton', function(data, cb)
    payment = false
    cb('ok')
end)

RegisterNUICallback('kanisterbutton', function(data, cb)
    TriggerServerEvent('fuelsystem:paycanister', payment)
    cb('ok')
end)

RegisterKeyMapping('fuelsystem:stop_fill', 'stop filling the canister', 'keyboard', 'x')

RegisterCommand('fuelsystem:stop_fill', function()
    canisterfill = false
end)

RegisterNUICallback('fuelbutton', function(data, cb)
    if selected == 0 then
        DisplayNotification("Du hast keinen Sprit-Typ ausgewählt")
    elseif selected == 1 then
        if fill then
            fill = false
            if money == 0 then
                DisplayNotification("Betanken abgebrochen")
            else
                DisplayNotification("Betanken abgebrochen und du hast " .. money .. "$ gezahlt")
            end
            money = 0
        else
            if car == 0 then
                DisplayNotification("Es ist kein Fahrzeug in der nähe was du betanken kannst")
            else
                CheckFuelType(car)
                if fueltype == 1 then
                    if GetFuel(car) > 64.9 then
                        DisplayNotification("Das Fahrzeug ist schon vollgetankt")
                    else
                        fill = true
                        DisplayNotification("Betankung mit Benzin gestartet")
                    end
                elseif fueltype == 2 then
                    DisplayNotification("Dein Fahrzeug braucht Diesel und kein Benzin")
                else
                    DisplayNotification("Dein Fahrzeug kann aktuell nicht aufgetankt werden")
                end
            end
        end
    elseif selected == 2 then
        if fill then
            fill = false
            if money == 0 then
                DisplayNotification("Betanken abgebrochen")
            else
                DisplayNotification("Betanken abgebrochen und du hast " .. money .. "$ gezahlt")
            end
            money = 0
        else
            if car == 0 then
                DisplayNotification("Es ist kein Fahrzeug in der nähe was du betanken kannst")
            else
                CheckFuelType(car)
                if fueltype == 2 then
                    if GetFuel(car) > 64.9 then
                        DisplayNotification("Das Fahrzeug ist schon vollgetankt")
                    else
                        fill = true
                        DisplayNotification("Betankung mit Diesel gestartet")
                    end
                elseif fueltype == 1 then
                    DisplayNotification("Dein Fahrzeug braucht Benzin und kein Diesel")
                else
                    DisplayNotification("Dein Fahrzeug kann aktuell nicht aufgetankt werden")
                end
            end
        end
    end
    cb('ok')
end)

Citizen.CreateThread(function()
    while true do
        if showmsg then
            if not guiEnabled then
                DisplayHelpText("Drücke ~INPUT_CONTEXT~ zum tanken")
            end
        end
        if canisterfill then
            if not guiEnabled then
                coords2 = GetEntityCoords(car)
                DrawText3Ds(coords2.x, coords2.y, coords2.z + 0.5, Round(GetFuel(car) / 0.65, 1) .. "%")
            end
        end
        if not canisterfill then
            if GetSelectedPedWeapon(GetPlayerPed(-1)) == 883325847 then
                car = GetPlayersLastVehicle(GetPlayerPed(-1))
                if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), GetEntityCoords(car)) < 3 then
                    if not DoesEntityExist(GetPedInVehicleSeat(car, -1)) then
                        if GetAmmoInPedWeapon(GetPlayerPed(-1), 883325847) > 0 then
                            if GetFuel(car) < 65 then
                                coords2 = GetEntityCoords(car)
                                DrawText3Ds(coords2.x, coords2.y, coords2.z + 0.5, "Drücke E um das Fahrzeug mit deinem Kanister zu betanken")
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(5)
    end
end)

RegisterKeyMapping('fuelsystem:open_ui', 'Open the UI of the fuelsystem', 'keyboard', 'e')

RegisterCommand('fuelsystem:open_ui', function()
    if showmsg then
        if canisterfill then
            DisplayNotification("Du tankst bereits mit deinem Kanister ein Fahrzeug auf")
        else
            guiEnabled = false
            selected = 0
            fill = false
            vehicle = 0
            fuel = 0
            vehicle = 0
            car = 0
            money = 0
            EnableGui(true)
            car = GetPlayersLastVehicle(GetPlayerPed(-1))
            coords1 = GetEntityCoords(FindNearestFuelPump())
            coords2 = GetEntityCoords(car)
            if GetDistanceBetweenCoords(coords1.x, coords1.y, coords1.z, coords2.x, coords2.y, coords2.z, true) > config.Car_distance then
                car = 0
            end
            if car ~= 0 then
                SendNUIMessage({
                    type = "progress",
                    data = GetFuel(car) / 0.65
                })
            else
                DisplayNotification("Da kein Fahrzeug in der nähe gefunden wurde kannst du nur einen Kanister kaufen")
            end
        end
    end
end)

RegisterKeyMapping('fuelsystem:fillwithcanister', 'Fill your vehicle with a canister', 'keyboard', 'e')

RegisterCommand('fuelsystem:fillwithcanister', function()
    if GetSelectedPedWeapon(GetPlayerPed(-1)) == 883325847 then
        car = GetPlayersLastVehicle(GetPlayerPed(-1))
        if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), GetEntityCoords(car)) < 3.0 then
            if not DoesEntityExist(GetPedInVehicleSeat(car, -1)) then
                if GetAmmoInPedWeapon(GetPlayerPed(-1), 883325847) > 0 then
                    if GetFuel(car) < 65 then
                        canisterfill = true
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if guiEnabled then
            DisableControlAction(0, 1, guiEnabled)
            DisableControlAction(0, 2, guiEnabled)
            DisableControlAction(0, 142, guiEnabled)
            DisableControlAction(0, 106, guiEnabled)
            DisableControlAction(0, 37, guiEnabled)
            if IsDisabledControlJustReleased(0, 142) then
                SendNUIMessage({
                    type = "click"
                })
            end
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while(true) do
        vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
        if vehicle ~= 0 then
            fuel = GetFuel(vehicle)
            if fuel > 0 then
                if GetEntitySpeed(vehicle) > 0 then
                    SetFuel(vehicle, fuel - config.Consumption_drive)
                else
                    SetFuel(vehicle, fuel - config.Consumption_stand)
                end
            end
        end
        if fill then
            if DoesEntityExist(car) then
                TriggerServerEvent('fuelsystem:pay', payment)
            else
                fill = false
            end
        end
        if FindNearestFuelPump() then
            showmsg = true
        else
            showmsg = false
        end
        if canisterfill then
            if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), GetEntityCoords(car)) < 3.0 then
                if GetAmmoInPedWeapon(GetPlayerPed(-1), 883325847) > 0 then
                    if GetFuel(car) + 1 < 64.9 then
                        SetPedAmmo(GetPlayerPed(-1), 883325847, GetAmmoInPedWeapon(GetPlayerPed(-1), 883325847) - (5 * 45))
                        SetFuel(car, GetFuel(car) + 1)
                    else
                        SetPedAmmo(GetPlayerPed(-1), 883325847, GetAmmoInPedWeapon(GetPlayerPed(-1), 883325847) - (5 * 45))
                        SetFuel(car, 65.0)
                        canisterfill = false
                        DisplayNotification("Dein Tank ist jetzt voll")
                    end
                else
                    canisterfill = false
                    RemoveWeaponFromPed(GetPlayerPed(-1), 883325847)
                end
            else
                canisterfill = false
            end
        end
        Citizen.Wait(1000)
    end
end)

RegisterNetEvent('fuelsystem:fuelcanister')
AddEventHandler('fuelsystem:fuelcanister', function(check)
    if check then
        GiveWeaponToPed(GetPlayerPed(-1), 883325847, 4500, false, true)
        DisplayNotification("Du hast einen Kanister gekauft")
    else
        DisplayNotification("Du hast nicht genug Geld einen Kanister zu kaufen")
    end
end)

RegisterNetEvent('fuelsystem:fuel')
AddEventHandler('fuelsystem:fuel', function(check)
    if check then
        money = money + config.Price
        if GetFuel(car) + config.Liter < 64.9 then
            SetFuel(car, GetFuel(car) + config.Liter)
        else
            SetFuel(car, 65.0)
            fill = false
            DisplayNotification("Dein Tank ist jetzt voll und du hast " .. money .. "$ gezahlt")
            money = 0
        end
        SendNUIMessage({
            type = "progress",
            data = GetFuel(car) / 0.65
        })
    else
        fill = false
    end
end)

RegisterNetEvent('fuelsystem:message')
AddEventHandler('fuelsystem:message', function(text)
    DisplayNotification(text)
end)

for k, i in ipairs(config.Coords) do
    CreateBlip(i)
end

if config.Debug then
    RegisterCommand("name", function(source, args, rawCommand)
        if config.Debug then
            print(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(-1), false))))
        else
            print("ERROR")
        end
    end)
end

RegisterCommand("test1", function(source, args, rawCommand)
    SetFuel(GetVehiclePedIsIn(GetPlayerPed(-1), false), GetFuel(GetVehiclePedIsIn(GetPlayerPed(-1), false)) - 10)
end)

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(false, false)
end