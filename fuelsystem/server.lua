ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('fuelsystem:paycanister')
AddEventHandler('fuelsystem:paycanister', function(payment)
    xPlayer = ESX.GetPlayerFromId(source)
    check = false
    if payment then
        if xPlayer.getAccount('bank').money >= config.Canister_price * 20 then
            xPlayer.removeAccountMoney('bank', config.Canister_price * 20)
            check = true
        else
            check = false
        end
    else
        if xPlayer.getMoney() >= config.Canister_price * 20 then
            xPlayer.removeMoney(config.Canister_price * 20)
            check = true
        else
            check = false
        end
    end
    TriggerClientEvent('fuelsystem:fuelcanister', source, check)
end)

RegisterServerEvent('fuelsystem:pay')
AddEventHandler('fuelsystem:pay', function(payment)
    xPlayer = ESX.GetPlayerFromId(source)
    check = false
    if payment then
        if xPlayer.getAccount('bank').money >= config.Price then
            xPlayer.removeAccountMoney('bank', config.Price)
            check = true
        else
            check = false
        end
    else
        if xPlayer.getMoney() >= config.Price then
            xPlayer.removeMoney(config.Price)
            check = true
        else
            check = false
        end
    end
    TriggerClientEvent('fuelsystem:fuel', source, check)
end)