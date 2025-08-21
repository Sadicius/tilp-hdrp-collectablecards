local RSGCore = exports['rsg-core']:GetCoreObject()
local spawnedPeds = {}

local function NearPed(npcmodel, npccoords, id, name)
    RequestModel(npcmodel)
    while not HasModelLoaded(npcmodel) do
        Wait(50)
    end
    local spawnedPed = CreatePed(npcmodel, npccoords.x, npccoords.y, npccoords.z - 1.0, npccoords.w, false, false, 0, 0)
    SetEntityAlpha(spawnedPed, 0, false)
    SetRandomOutfitVariation(spawnedPed, true)
    SetEntityCanBeDamaged(spawnedPed, false)
    SetEntityInvincible(spawnedPed, true)
    FreezeEntityPosition(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    SetPedCanBeTargetted(spawnedPed, false)

    if Config.FadeIn then
        for i = 0, 255, 51 do
            Wait(50)
            SetEntityAlpha(spawnedPed, i, false)
        end
    end
    if Config.EnableTarget then
        exports.ox_target:addLocalEntity(spawnedPed, {
            {
                name = 'npc_collectablecards_shop',
                icon = 'fa-solid fa-eye',
                targeticon = 'fa-solid fa-box',
                label = name,
                onSelect = function()
                    TriggerEvent('tilp-hdrp-collectablecards:client:openmain', id)
                end,
                distance = 3.0
            }
        })
    end
    return spawnedPed
end

CreateThread(function()
    while true do
        Wait(500)
        for k,v in pairs(Config.ShopLocation) do
            local playerCoords = GetEntityCoords(cache.ped)
            local distance = #(playerCoords - v.coords)

            if tonumber(distance) < tonumber(Config.DistanceSpawn) and not spawnedPeds[k] then
                local spawnedPed = NearPed(v.npcmodel, v.npccoords, v.id, v.name)
                spawnedPeds[k] = { spawnedPed = spawnedPed }
            end

            if distance >= Config.DistanceSpawn and spawnedPeds[k] then
                if Config.FadeIn then
                    for i = 255, 0, -51 do
                        Wait(50)
                        SetEntityAlpha(spawnedPeds[k].spawnedPed, i, false)
                    end
                end
                DeletePed(spawnedPeds[k].spawnedPed)
                spawnedPeds[k] = nil
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(500)
        for _,v in pairs(Config.ShopLocation) do

            if not Config.EnableTarget then
                exports['rsg-core']:createPrompt(v.id, v.coords, RSGCore.Shared.Keybinds[Config.Shop.Key], v.name, {
                    type = 'client',
                    event = 'tilp-hdrp-collectablecards:client:openmain',
                    args = {v.id},
                })
            end

            if Config.Blip.showblipShop == true then
                local blipCardshop = BlipAddForCoords(1664425300, v.coords)
                SetBlipSprite(blipCardshop, joaat(Config.Blip.ShopSprite), true)
                SetBlipScale(blipCardshop, Config.Blip.ShopScale)
                SetBlipName(blipCardshop, Config.Blip.ShopName)
            end
        end
    end
end)

-----------------------
-- START/STOP RESOURCE
-----------------------
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for k, v in pairs(spawnedPeds) do
        if v.spawnedPed and DoesEntityExist(v.spawnedPed) then
            DeleteEntity(v.spawnedPed)
        end
        spawnedPeds[k] = nil
    end
end)