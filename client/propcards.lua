local RSGCore = exports['rsg-core']:GetCoreObject()
local spawnedProps = {}

local cards_points = require("shared/cards_points")
local prompts = {} -- Table to store prompts
local promptGroups = {} -- Table to store prompt groups
local blips = {} -- Table to store blips
local lastInteraction = 0 -- Debounce timer for keypresses

-- Create a native prompt for a card with hold mode
local function CreateCardPrompt(name, key)
    local prompt = PromptRegisterBegin()
    PromptSetControlAction(prompt, RSGCore.Shared.Keybinds[Config.Card.Key] or 0xF3830D8E) -- Configurable key or default [J]
    PromptSetText(prompt, CreateVarString(10, 'LITERAL_STRING', name))
    PromptSetEnabled(prompt, true)
    PromptSetVisible(prompt, true)
    PromptSetHoldMode(prompt, Config.Card.HoldDuration or 1000) -- Hold for 1000ms (configurable)
    local group = GetRandomIntInRange(0, 0xffffff) -- Unique group ID
    PromptSetGroup(prompt, group)
    PromptRegisterEnd(prompt)
    return prompt, group
end

local function SpawnCard(model, coords, item, name, key)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(50)
    end
    local spawnedProp = CreateObject(joaat(model), coords.x, coords.y, coords.z, false, false, false, false, false)
    Citizen.InvokeNative(0x9587913B9E772D29, spawnedProp, true) -- Colocar la carta en el suelo
    Citizen.InvokeNative(0x543DFE14BE720027, PlayerId(), spawnedProp, true) -- Registrar efectos de visión de águila
    Citizen.InvokeNative(0x62ED71E133B6C9F1, spawnedProp, 255, 255, 0) -- Aplicar tintado a la entidad
    Citizen.InvokeNative(0x907B16B3834C69E2, spawnedProp, Config.Card.visionDist) -- Establecer distancia para visión de águila
    Wait(1500)
    FreezeEntityPosition(spawnedProp, true)
    if Config.FadeIn then
        for i = 0, 255, 51 do
            Wait(50)
            SetEntityAlpha(spawnedProp, i, false)
        end
    end
    if Config.EnableTarget then
        exports.ox_target:addLocalEntity(spawnedProp, {
            {
                name = 'collectable_cards',
                icon = 'fa-solid fa-eye',
                targeticon = 'fa-solid fa-box',
                label = name,
                onSelect = function()
                    TriggerEvent("tilp-hdrp-collectablecards:client:takecard", item)
                end,
                distance = 3.0
            }
        })
    else
        local prompt, group = CreateCardPrompt(name, key)
        prompts[key] = prompt
        promptGroups[key] = group
    end
    return spawnedProp
end

CreateThread(function()
    while true do
        Wait(500)
        for k,v in pairs(cards_points) do
            local playerCoords = GetEntityCoords(cache.ped)
            local distance = #(playerCoords - v.coords.xyz)

            if tonumber(distance) < tonumber(Config.DistanceSpawn) and not spawnedProps[k] then
                local spawnedProp = SpawnCard(v.model, v.coords, v.item, v.name, k)
                spawnedProps[k] = { spawnedProp = spawnedProp }
            end

            if distance >= Config.DistanceSpawn and spawnedProps[k] then
                if Config.FadeIn then
                    for i = 255, 0, -51 do
                        Wait(50)
                        SetEntityAlpha(spawnedProps[k].spawnedProp, i, false)
                    end
                end
                if not Config.EnableTarget then
                    if prompts[k] then
                        PromptDelete(prompts[k])
                        prompts[k] = nil
                        promptGroups[k] = nil
                    end
                end
                DeleteObject(spawnedProps[k].spawnedProp)
                spawnedProps[k] = nil
            end
        end
    end
end)

-- Thread for showing prompt labels
CreateThread(function()
    if not Config.EnableTarget then return end
    while true do
        Wait(0) -- Run every frame for smooth prompt visibility
        local playerCoords = GetEntityCoords(cache.ped)
        local closestCard, closestDistance, closestGroup, closestLabel = nil, math.huge, nil, nil

        -- Find the closest card within range
        for k, v in pairs(spawnedProps) do
            if promptGroups[k] then
                local distance = #(playerCoords - cards_points[k].coords.xyz)
                if distance < 3.0 and distance < closestDistance then
                    closestCard = k
                    closestDistance = distance
                    closestGroup = promptGroups[k]
                    closestLabel = CreateVarString(10, 'LITERAL_STRING', cards_points[k].name)
                end
            end
        end

        -- Show prompt for the closest card
        if closestGroup and closestLabel then
            PromptSetActiveGroupThisFrame(closestGroup, closestLabel)
        end
    end
end)

-- Thread for handling prompt interaction
CreateThread(function()
    if not Config.EnableTarget then return end
    while true do
        Wait(0) -- Run every frame to check prompt input
        local currentTime = GetGameTimer()
        for k, v in pairs(spawnedProps) do
            if prompts[k] and PromptHasHoldModeCompleted(prompts[k]) and (currentTime - lastInteraction) > 500 then
                lastInteraction = currentTime -- Update debounce timer
                PromptSetEnabled(prompts[k], false) -- Disable prompt to prevent repeat triggers
                PromptSetVisible(prompts[k], false)

                -- Trigger card pickup event
                TriggerEvent("tilp-hdrp-collectablecards:client:takecard", cards_points[k].item)

                -- Optional feedback (sound or notification)
                if Config.Card.PickupFeedback then
                    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'dealfour', 0.8)
                    -- Alternatively, use a notification:
                    -- lib.notify({ title = 'Card Collected', description = cards_points[k].name, type = 'success', duration = 3000 })
                end

                -- Clean up after interaction
                DeleteObject(v.spawnedProp)
                PromptDelete(prompts[k])
                spawnedProps[k] = nil
                prompts[k] = nil
                promptGroups[k] = nil
            elseif prompts[k] and PromptIsJustPressed(prompts[k]) and Config.Card.PickupFeedback then
                -- Play sound when starting to hold the key
                TriggerServerEvent('InteractSound_SV:PlayOnSource', 'click', 0.5)
            end
        end
    end
end)

CreateThread(function()
    if not Config.Blip.showblipCards then return end
    for k, v in pairs(cards_points) do
        local CardsBlip = BlipAddForCoords(1664425300, v.coords.xyz)
        SetBlipSprite(CardsBlip, joaat(Config.Blip.cardSprite), true)
        SetBlipScale(CardsBlip, Config.Blip.cardScale)
        SetBlipName(CardsBlip, v.name or Config.Blip.cardName)
        blips[k] = CardsBlip
    end
end)

-----------------------
-- START/STOP RESOURCE
-----------------------
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for k, v in pairs(spawnedProps) do
        if v.spawnedProp and DoesEntityExist(v.spawnedProp) then  -- Acceso correcto a spawnedProp
            DeleteObject(v.spawnedProp)  -- Usar DeleteObject para eliminar el prop
        end
        spawnedProps[k] = nil
    end
    -- Clean up prompts
    if not Config.EnableTarget then
        for k, prompt in pairs(prompts) do
            PromptDelete(prompt)
            prompts[k] = nil
            promptGroups[k] = nil
        end
    end
    -- Clean up blips
    for k, blip in pairs(blips) do
        RemoveBlip(blip)
        blips[k] = nil
    end
end)