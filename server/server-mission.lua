local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

local MissionsShared = require("shared/missions")
------------------------------------
-- misions active
------------------------------------

local activeM = {}
local previousM = {}

local function assignMissions()
    activeM = {}

    for _, loc in ipairs(Config.CardMission) do
        local id = loc.id
        activeM[id] = {}
        previousM[id] = previousM[id] or {}

        local available = {}
        for idx = 1, #MissionsShared do
            if not previousM[id][idx] then
                table.insert(available, idx)
            end
        end

        local maxActive = Config.Missions.MaxAvice or 1
        for i = 1, maxActive do
            if #available == 0 then break end
            local pick = math.random(#available)
            local missionIdx = table.remove(available, pick)
            local missionData = MissionsShared[missionIdx]

            local cardsList = {}
            for k, _ in pairs(missionData.cards) do
                table.insert(cardsList, k)
            end

            local shuffled = {}
            while #cardsList > 0 do
                local rand = math.random(#cardsList)
                table.insert(shuffled, table.remove(cardsList, rand))
            end
            local numMaxCards = Config.Missions.MaxCards or #shuffled
            local numMinCards = Config.Missions.MinCards or 2
            local numCardsToSelect = math.random(numMinCards, numMaxCards)

            local selectedCards = {}
            for k = 1, numCardsToSelect do
                local cardName = shuffled[k]
                local qty = missionData.cards[cardName] or 1
                selectedCards[cardName] = qty
            end

            local randomizedMission = {
                reward = missionData.reward,
                Amount = missionData.Amount or 1,
                cards = selectedCards
            }

            table.insert(activeM[id], randomizedMission)
            previousM[id][missionIdx] = true
        end

        local maxHist = Config.Missions.MaxHist
        local cnt = 0
        for _ in pairs(previousM[id]) do cnt = cnt + 1 end
        if cnt > maxHist then
            local keys = {}
            for k in pairs(previousM[id]) do table.insert(keys, k) end
            table.sort(keys)
            for i = 1, cnt - maxHist do
                previousM[id][keys[i]] = nil
            end
        end

    end

    if Config.Debug then print(locale('sv_print_5'), activeM) end
end

CreateThread(function()
    assignMissions()
    while true do
        Wait(Config.Missions.Refresh)
        assignMissions()
    end
end)

RSGCore.Functions.CreateCallback('tilp-hdrp-collectablecards:server:getactiveM', function(source, cb, mission)
    cb(activeM[mission] or {})
end)

-----------------------
-- TRADE CARDS FOR MISSION
-----------------------
RegisterServerEvent('tilp-hdrp-collectablecards:server:missions')
AddEventHandler('tilp-hdrp-collectablecards:server:missions', function(missionData)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    for k, v in pairs(missionData.cards) do
        Player.Functions.RemoveItem(k, v)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[k], 'remove')
    end

    Wait(2000)
    Player.Functions.AddItem(missionData.reward, missionData.Amount)
    TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[missionData.reward], 'add')
    TriggerClientEvent('ox_lib:notify', src, { title = locale('sv_lang_33') .. ' ' .. RSGCore.Shared.Items[missionData.reward]['label'], type = 'inform', duration = 5000 })

    -- dentro de tu evento de Trade Rewards
    local discordMessage = string.format(
        locale('sv_lang_34').. ": **" .. locale('sv_lang_35').."** \n" ..
        locale('sv_lang_36').. ": ** %s  (CID %d) ** \n"    ..
        locale('sv_lang_37').. ": ** %s %s **\n"      ..
        locale('sv_lang_38').. ": **" .. locale('sv_lang_39').. " %s ** ",
        Player.PlayerData.citizenid,
        Player.PlayerData.cid,
        Player.PlayerData.charinfo.firstname,
        Player.PlayerData.charinfo.lastname,
        RSGCore.Shared.Items[missionData.reward].label
    )
    TriggerEvent( 'rsg-log:server:CreateLog', Config.WebhookName, Config.WebhookTittle, Config.WebhookColour, discordMessage, false )

end)

RSGCore.Commands.Add('load_cardsmission', locale('sv_command_find'), {}, false, function(source)
    local src = source
    assignMissions()

    activeM = {}
    previousM = {}
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    activeM = {}
    previousM = {}
end)