local RSGCore = exports['rsg-core']:GetCoreObject()

local cards_points = require("shared/cards_points")
lib.locale()

-----------------
-- SQL
-----------------
local successStart, resultStart = pcall(MySQL.scalar.await, 'SELECT 1 FROM hdrp_boxes')
if not successStart then
    MySQL.query([[CREATE TABLE IF NOT EXISTS `hdrp_boxes` (
        `serial`   VARCHAR(20) NOT NULL,
        `creator`  VARCHAR(32) NOT NULL,
        `owner`    VARCHAR(32) NOT NULL,
        `position` JSON       DEFAULT NULL,
        PRIMARY KEY (`serial`),
        INDEX `idx_creator` (`creator`),
        INDEX `idx_owner`   (`owner`)
    )]])
    if Config.Debug then print(locale('sv_print_1')) end
else
    if Config.Debug then print(locale('sv_print_2')) end
end

--------
-- INVENTORY BOX
----------------
local function GenerateSerial()
    return tostring(
        RSGCore.Shared.RandomInt(4)
        .. RSGCore.Shared.RandomStr(3)
        .. RSGCore.Shared.RandomInt(3)
        .. RSGCore.Shared.RandomStr(3)
    ):upper()
end

local function CreateUniqueSerial()
    local serial
    repeat
        serial = GenerateSerial()
        local successS = pcall(MySQL.scalar.await, 'SELECT 1 FROM `hdrp_boxes`')
        if not successS then return end
        local successQ, res = pcall(MySQL.query.await, 'SELECT COUNT(1) AS c FROM `hdrp_boxes` WHERE `serial` = @s', { ['@s'] = serial })
        if not successQ or not res or not res[1] then return nil end
    until res[1].c == 0
    return serial
end

RSGCore.Functions.CreateCallback('tilp-hdrp-collectablecards:server:getBoxInfo', function(source, cb, serial)
    local success, res = pcall(MySQL.query.await, 'SELECT creator, owner FROM `hdrp_boxes` WHERE `serial` = @s LIMIT 1', { ['@s'] = serial })
    if success and res and res[1] then
        cb(res[1])
    else
        cb(nil)
    end
end)

RegisterNetEvent('tilp-hdrp-collectablecards:server:openBox', function(serial)
    local src = source
    local success, info = pcall(MySQL.query.await, 'SELECT creator, owner FROM hdrp_boxes WHERE serial = @s LIMIT 1', { ['@s'] = serial })
    if not success or not info or not info[1] then return end
    local stash = 'box_' .. serial
    local data = {
        label     = locale('sv_lang_1') .. ' #'..serial,
        maxweight = Config.Card.Storage.MaxWeight,
        slots = Config.Card.Storage.MaxSlots
    }
    exports['rsg-inventory']:OpenInventory(src, stash, data)
end)

-----------------
-- USEABLE BOX
-----------------
RSGCore.Functions.CreateUseableItem('card_storage_box', function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    if not item or not item.info then
        TriggerClientEvent('ox_lib:notify', src, {title = 'Error', description = 'Invalid item data', type = 'error', duration = 5000 })
        return
    end

    local info = item.info or {}
    local serial = info.serie

    if not serial or serial == "" then
        serial = CreateUniqueSerial()
        local cid = Player.PlayerData.citizenid

        local success, result = pcall(MySQL.insert, 'INSERT INTO hdrp_boxes (serial, creator, owner) VALUES (@s,@c,@o)', { ['@s'] = serial, ['@c'] = cid, ['@o'] = cid, })
        if not success then return end

        local discordMessage = string.format(
            locale('sv_lang_2') .. ":** ".. locale('sv_lang_3') .."** \n" ..
            locale('sv_lang_4') .. ":** %s **\n"    ..
            locale('sv_lang_5') .. ":** %s **",
            serial,
            cid
        )
        TriggerEvent( 'rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTitle, Config.WebhookColour, discordMessage, false )

        -- reemplazo el item en el inventario con el info.serie
        Player.Functions.RemoveItem(item.name, 1, item.slot)
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_lang_40'), description = locale('sv_lang_41'), type = 'info', duration = 5000 })
        Player.Functions.AddItem(item.name, 1, item.slot, { serie = serial })
    else
        -- Ya tiene serial: lo saco del inventario y lo coloco en el suelo
        -- Player.Functions.RemoveItem(item.name, 1, item.slot, info)
        local successB, resultB = pcall(MySQL.update, 'UPDATE hdrp_boxes SET owner = ? WHERE serial = ?', { Player.PlayerData.citizenid, serial })
        if not successB then return end
        TriggerClientEvent('tilp-hdrp-collectablecards:client:BoxOn', src, { serie = serial })
    end
end)

---------
-- CARDS
---------

local basicCards = {
    'card_cigcard_act_c1',
    'card_cigcard_act_c2',
    'card_cigcard_act_c3',
    'card_cigcard_act_c4',
    'card_cigcard_act_c5',
    'card_cigcard_act_c6',
    'card_cigcard_act_c7',
    'card_cigcard_act_c8',
    'card_cigcard_act_c9',
    'card_cigcard_act_c10',
    'card_cigcard_act_c11',
    'card_cigcard_act_c12',

    'card_cigcard_amer_c1',
    'card_cigcard_amer_c2',
    'card_cigcard_amer_c3',
    'card_cigcard_amer_c4',
    'card_cigcard_amer_c5',
    'card_cigcard_amer_c6',
    'card_cigcard_amer_c7',
    'card_cigcard_amer_c8',
    'card_cigcard_amer_c9',
    'card_cigcard_amer_c10',
    'card_cigcard_amer_c11',
    'card_cigcard_amer_c12',

    'card_cigcard_aml_c1',
    'card_cigcard_aml_c2',
    'card_cigcard_aml_c3',
    'card_cigcard_aml_c4',
    'card_cigcard_aml_c5',
    'card_cigcard_aml_c6',
    'card_cigcard_aml_c7',
    'card_cigcard_aml_c8',
    'card_cigcard_aml_c9',
    'card_cigcard_aml_c10',
    'card_cigcard_aml_c11',
    'card_cigcard_aml_c12',

    'card_cigcard_inv_c1',
    'card_cigcard_inv_c2',
    'card_cigcard_inv_c3',
    'card_cigcard_inv_c4',
    'card_cigcard_inv_c5',
    'card_cigcard_inv_c6',
    'card_cigcard_inv_c7',
    'card_cigcard_inv_c8',
    'card_cigcard_inv_c9',
    'card_cigcard_inv_c10',
    'card_cigcard_inv_c11',
    'card_cigcard_inv_c12',
}

local rareCards = {

    'card_cigcard_art_c1',
    'card_cigcard_art_c2',
    'card_cigcard_art_c3',
    'card_cigcard_art_c4',
    'card_cigcard_art_c5',
    'card_cigcard_art_c6',
    'card_cigcard_art_c7',
    'card_cigcard_art_c8',
    'card_cigcard_art_c9',
    'card_cigcard_art_c10',
    'card_cigcard_art_c11',
    'card_cigcard_art_c12',

    'card_cigcard_lnd_c1',
    'card_cigcard_lnd_c2',
    'card_cigcard_lnd_c3',
    'card_cigcard_lnd_c4',
    'card_cigcard_lnd_c5',
    'card_cigcard_lnd_c6',
    'card_cigcard_lnd_c7',
    'card_cigcard_lnd_c8',
    'card_cigcard_lnd_c9',
    'card_cigcard_lnd_c10',
    'card_cigcard_lnd_c11',
    'card_cigcard_lnd_c12',

    'card_cigcard_grl_c1',
    'card_cigcard_grl_c2',
    'card_cigcard_grl_c3',
    'card_cigcard_grl_c4',
    'card_cigcard_grl_c5',
    'card_cigcard_grl_c6',
    'card_cigcard_grl_c7',
    'card_cigcard_grl_c8',
    'card_cigcard_grl_c9',
    'card_cigcard_grl_c10',
    'card_cigcard_grl_c11',
    'card_cigcard_grl_c12',

}

local ultraCards = {

    'card_cigcard_plt_c1',
    'card_cigcard_plt_c2',
    'card_cigcard_plt_c3',
    'card_cigcard_plt_c4',
    'card_cigcard_plt_c5',
    'card_cigcard_plt_c6',
    'card_cigcard_plt_c7',
    'card_cigcard_plt_c8',
    'card_cigcard_plt_c9',
    'card_cigcard_plt_c10',
    'card_cigcard_plt_c11',
    'card_cigcard_plt_c12',

    'card_cigcard_gun_c1',
    'card_cigcard_gun_c2',
    'card_cigcard_gun_c3',
    'card_cigcard_gun_c4',
    'card_cigcard_gun_c5',
    'card_cigcard_gun_c6',
    'card_cigcard_gun_c7',
    'card_cigcard_gun_c8',
    'card_cigcard_gun_c9',
    'card_cigcard_gun_c10',
    'card_cigcard_gun_c11',
    'card_cigcard_gun_c12',

}

local vCards = {

    'card_cigcard_spt_c1',
    'card_cigcard_spt_c2',
    'card_cigcard_spt_c3',
    'card_cigcard_spt_c4',
    'card_cigcard_spt_c5',
    'card_cigcard_spt_c6',
    'card_cigcard_spt_c7',
    'card_cigcard_spt_c8',
    'card_cigcard_spt_c9',
    'card_cigcard_spt_c10',
    'card_cigcard_spt_c11',
    'card_cigcard_spt_c12',

    'card_cigcard_hrs_c1',
    'card_cigcard_hrs_c2',
    'card_cigcard_hrs_c3',
    'card_cigcard_hrs_c4',
    'card_cigcard_hrs_c5',
    'card_cigcard_hrs_c6',
    'card_cigcard_hrs_c7',
    'card_cigcard_hrs_c8',
    'card_cigcard_hrs_c9',
    'card_cigcard_hrs_c10',
    'card_cigcard_hrs_c11',
    'card_cigcard_hrs_c12',

}

local vmaxCards = {

    'card_cigcard_veh_c1',
    'card_cigcard_veh_c2',
    'card_cigcard_veh_c3',
    'card_cigcard_veh_c4',
    'card_cigcard_veh_c5',
    'card_cigcard_veh_c6',
    'card_cigcard_veh_c7',
    'card_cigcard_veh_c8',
    'card_cigcard_veh_c9',
    'card_cigcard_veh_c10',
    'card_cigcard_veh_c11',
    'card_cigcard_veh_c12',

}

local rainbowCards = {
    'card_cigcard_act',
    'card_cigcard_amer',
    'card_cigcard_aml',
    'card_cigcard_art',
    'card_cigcard_grl',
    'card_cigcard_gun',
    'card_cigcard_hrs',
    'card_cigcard_inv',
    'card_cigcard_lnd',
    'card_cigcard_plt',
    'card_cigcard_spt',
    'card_cigcard_veh',
}

-----------------
-- CARDS IN BOX
-----------------
-- local allowedCards = {}
-- -- puebla tu whitelist a partir de tus tablas de cartas:
-- for _, name in ipairs(basicCards)   do allowedCards[name] = true end
-- for _, name in ipairs(rareCards)    do allowedCards[name] = true end
-- for _, name in ipairs(ultraCards)   do allowedCards[name] = true end
-- for _, name in ipairs(vCards)       do allowedCards[name] = true end
-- for _, name in ipairs(vmaxCards)    do allowedCards[name] = true end
-- for _, name in ipairs(rainbowCards) do allowedCards[name] = true end

-- RegisterNetEvent('rsg-inventory:server:moveItem')
-- AddEventHandler('rsg-inventory:server:moveItem', function(fromInv, toInv, itemName, amount, slot, info)
--     local src = source

--     if toInv:match("^box_") then
--         if not allowedCards[itemName] then
--             TriggerClientEvent('ox_lib:notify', src, {
--                 title       = locale('sv_error_3'),
--                 description = locale('sv_error_4'),
--                 type        = 'error',
--                 duration    = 3000
--             })
--             return
--         end
--     end

--     exports['rsg-inventory']:MoveItem(fromInv, toInv, itemName, amount, slot, info)
-- end)

-----------------
-- USEABLE CARDS
-----------------

RSGCore.Functions.CreateUseableItem('card_packge_cards', function(source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    TriggerClientEvent('tilp-hdrp-collectablecards:client:opencollactable', src)
    Wait(4000)
end)

----------------
-- REMOVE ITEM
----------------
RegisterServerEvent('tilp-hdrp-collectablecards:server:removeitem')
AddEventHandler('tilp-hdrp-collectablecards:server:removeitem', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local pack = Player.Functions.GetItemByName('card_packge_cards')
    if pack.amount == nil then
        TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_error_1'), description = locale('sv_error_2'), type = 'error', duration = 5000 })
    else
        Player.Functions.RemoveItem('card_packge_cards', 1)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items['card_packge_cards'], 'remove')
    end
end)

-----------
-- RANDOM
-----------
CreateThread(function()
    math.randomseed(os.time())
end)

------------------------
-- ITEM FOR ADD REWARD
------------------------
RegisterServerEvent('tilp-hdrp-collectablecards:server:rewarditem')
AddEventHandler('tilp-hdrp-collectablecards:server:rewarditem', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    local card = ''

    local randomChance = math.random(1, 1000)
    if Config.Debug then print(locale('sv_print_3').. randomChance) end

    if randomChance <= 5 then
        card = rainbowCards[math.random(1,#rainbowCards)]
	elseif randomChance >= 6 and randomChance <= 19 then
        card = vmaxCards[math.random(1, #vmaxCards)]
	elseif randomChance >= 20 and randomChance <= 50 then
        card = vCards[math.random(1, #vCards)]
	elseif randomChance >= 51 and randomChance <= 100 then
        card = ultraCards[math.random(1, #ultraCards)]
    elseif randomChance >= 101 and randomChance <= 399 then
        card = rareCards[math.random(1, #rareCards)]
    else
        card = basicCards[math.random(1, #basicCards)]
	end

    Wait(10)
    if Config.Debug then print(card) end

    if card ~= '' then
        local discordMessage = string.format(
            locale('sv_lang_6') .. ": ** ".. locale('sv_lang_7') .." **\n" ..
            locale('sv_lang_8') .. ":** %s ** \n" ..
            locale('sv_lang_9') .. ": ** %d/1000 ** \n"..
            locale('sv_lang_10') .. ": ** %s **",
            Player.PlayerData.citizenid,
            randomChance,
            card
        )
        TriggerEvent( 'rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTitle, Config.WebhookColour, discordMessage, false )

        TriggerClientEvent('tilp-hdrp-collectablecards:client:Collectable', src, card)
    end
end)

---------------
-- COUNT CARDS
---------------

local cardsCollectObtained = {}

local function checkAllCardsAndDecksObtained(playerId)
    if playerId then
        local allCardsObtained = true
        local allCards = {basicCards, rareCards, ultraCards, vCards, vmaxCards} --, rainbowCards
        local playerObtainedCards = cardsCollectObtained[playerId]

        if playerObtainedCards then
            for _, cardList in ipairs(allCards) do
                for _, cardName in ipairs(cardList) do
                    if not playerObtainedCards[cardName] then
                        allCardsObtained = false
                        break
                    end
                end
                if not allCardsObtained then
                    break
                end
            end
        else
            allCardsObtained = false
        end
        return allCardsObtained
    else
        return false
    end
end

---------------------
-- ADD RANDOM REWARD
---------------------

RegisterServerEvent('tilp-hdrp-collectablecards:server:getCollect')
AddEventHandler('tilp-hdrp-collectablecards:server:getCollect', function(card)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    if card == nil then return end

    Player.Functions.AddItem(card, 1)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[card], 'add')

    TriggerClientEvent('ox_lib:notify', src, {title = locale('sv_lang_11').. ' 1 x '..RSGCore.Shared.Items[card].label, type = 'inform', duration = 5000 })

    local citizenid = Player.PlayerData.citizenid
    cardsCollectObtained[card] = true

    local allCardsObtained = checkAllCardsAndDecksObtained(citizenid)

    if allCardsObtained then
        TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_lang_12'),  description = locale('sv_lang_13'), type = 'inform', icon = 'fa-solid fa-check-circle', duration = 7000 })
        local discordMessage2 = string.format(
            locale('sv_lang_14') .. ": **" .. locale('sv_lang_15') .." ** \n" ..
            locale('sv_lang_16') .. ": ** %s (CID %d) ** \n" ..
            locale('sv_lang_17') .. ": **".. locale('sv_lang_18') .."**",
            citizenid,
            Player.PlayerData.cid
        )
        TriggerEvent( 'rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTitle, Config.WebhookColour, discordMessage2, false )
    end
end)

AddEventHandler('rsg-core:server:PlayerLoaded', function(playerId, cards)
    cardsCollectObtained[playerId] = {}
    for _, card in ipairs(cards) do
        cardsCollectObtained[playerId][card] = false
    end
end)

--------------
-- USE CARDS
--------------
local function createCardUsableItems(cards)
    for _, cardName in ipairs(cards) do
        RSGCore.Functions.CreateUseableItem(cardName, function(source, item)
            local src = source
            local Player = RSGCore.Functions.GetPlayer(src)
            if not Player then return end

            for _, v in pairs(cards_points) do
                if v.item == cardName then
                    TriggerClientEvent('tilp-hdrp-collectablecards:client:cardsIndivudal', src, v.item, v.model, v.type)
                    break
                end
            end
        end)
    end
end

createCardUsableItems(basicCards)
createCardUsableItems(rareCards)
createCardUsableItems(ultraCards)
createCardUsableItems(vCards)
createCardUsableItems(vmaxCards)
createCardUsableItems(rainbowCards)