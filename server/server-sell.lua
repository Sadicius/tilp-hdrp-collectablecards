local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

----------
-- SELL
----------

RegisterServerEvent('tilp-hdrp-collectablecards:server:sellitem') -- change resource
AddEventHandler('tilp-hdrp-collectablecards:server:sellitem', function(item, amount, price)
    local src = source
	local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local totalvalue = tonumber(amount * price) or 0

    Player.Functions.RemoveItem(item, amount)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'remove')

    Wait(1000)

    Player.Functions.AddMoney(Config.Shop.Payment, totalvalue, 'sellvendor-sold')
    TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_lang_19').. RSGCore.Shared.Items[tostring(item)].label.. locale('sv_lang_20').. totalvalue, description = locale('sv_lang_21'), type = 'inform', duration = 5000 })

    local discordMessage = string.format(
        locale('sv_lang_22').. ": **" .. locale('sv_lang_23').."** \n" ..
        locale('sv_lang_24').. ": ** %s  (CID %d) ** \n"    ..
        locale('sv_lang_25').. ": ** %s %s **\n"      ..
        locale('sv_lang_26').. ": ** %dx %s ** \n" ..
        locale('sv_lang_27').. ": ** $%.2f ** ",
        Player.PlayerData.citizenid,
        Player.PlayerData.cid,
        Player.PlayerData.charinfo.firstname,
        Player.PlayerData.charinfo.lastname,
        amount,
        RSGCore.Shared.Items[item].label,
        totalvalue
    )
    TriggerEvent( 'rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTittle, Config.WebhookColour, discordMessage, false )
end)

RegisterServerEvent('tilp-hdrp-collectablecards:server:sellall')-- change resource
AddEventHandler('tilp-hdrp-collectablecards:server:sellall', function(sellid)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local items = sellid
    if type(sellid[1]) == 'table' then  items = sellid[1] end

    local totalValue = 0

    if Config.debug then for k, v in pairs(items) do print('Items sell player: ', items) print(k, v) end end
    for _, item in pairs(items) do
        if Config.debug then for k, v in pairs(item) do print('Items sell player: ', item) print(k, v) end end
        local itemName = item.name
        local itemAmount = item.amount
        local itemPrice = item.price

        Player.Functions.RemoveItem(itemName, itemAmount)
        totalValue = totalValue + ((itemAmount * itemPrice) / 100)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[itemName], 'remove')

    end

    Wait(1000)

    Player.Functions.AddMoney(Config.Shop.Payment, totalValue, 'sellvendor-sold')
    TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_lang_26').. ' ' .. totalValue, description = locale('sv_lang_27'), type = 'inform', duration = 5000 })

    local discordMessage = string.format(
        locale('sv_lang_28').. ": **" .. locale('sv_lang_29').."** \n" ..
        locale('sv_lang_30').. ": ** %s  (CID %d) ** \n" ..
        locale('sv_lang_31').. ": ** %s %s **\n" ..
        locale('sv_lang_32').. ": ** $%.2f ** ",
        Player.PlayerData.citizenid,
        Player.PlayerData.cid,
        Player.PlayerData.charinfo.firstname,
        Player.PlayerData.charinfo.lastname,
        totalValue
    )
    TriggerEvent( 'rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTittle, Config.WebhookColour, discordMessage, false )

end)

--------------------
-- ADD MENU OPTIONS
--------------------

RSGCore.Functions.CreateCallback('tilp-hdrp-collectablecards:server:getitems', function(source, cb, data) -- change resource
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return end

    local playerItems = {}
    if Player.PlayerData.items and next(Player.PlayerData.items) then
        for _, item in pairs(Player.PlayerData.items) do
            playerItems[item.name] =  item.amount
        end
    end

    local id = tostring(data)
    local response = {
        id = id,
        items = {}
    }

    for _, shop in ipairs(Config.ShopLocation) do -- change resource config
        if shop.id == id then
            for _, subTable in pairs(shop.shopdata) do
                for itemName, itemPrice in pairs(subTable) do
                    local playerItemAmount = playerItems[itemName] or 0
                    local tableSub = {}
                    if playerItemAmount > 0 then
                        tableSub = {
                            name = itemName,
                            amount = playerItemAmount,
                            price = itemPrice,
                        }
                        table.insert(response.items, tableSub)
                        if Config.Debug then print(locale('sv_print_4'), itemName, playerItemAmount, itemPrice) end
                    end
                end
            end
            cb(response)
            break
        end
    end

end)

--------------------------------------
-- register shop
--------------------------------------
CreateThread(function()
    exports['rsg-inventory']:CreateShop({
        name = 'cardcollect',
        label = locale('cl_lang_17'),
        slots = #Config.CardsShopItems,
        items = Config.CardsShopItems,
        persistentStock = Config.PersistStock,
    })
end)

--------------------------------------
-- open shop
--------------------------------------
RegisterNetEvent('tilp-hdrp-collectablecards:server:openShop', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    exports['rsg-inventory']:OpenShop(src, 'cardcollect')
end)