local RSGCore = exports['rsg-core']:GetCoreObject()
local spawnedProps = {}
local GroundBoxs = {}
local isBusy = false
lib.locale()

--------
-- NUI
--------
RegisterNUICallback('RewardCollectable', function(data)
    if not data then return end
    local Collectable = data.Collectable
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'flip', 0.8)
    TriggerServerEvent('tilp-hdrp-collectablecards:server:getCollect', Collectable)
end)

RegisterNUICallback('randomCardCollectable', function()
    TriggerServerEvent('tilp-hdrp-collectablecards:server:rewarditem')
end)

RegisterNUICallback('CloseNui', function()
    SetNuiFocus(false, false)
end)

RegisterNetEvent('tilp-hdrp-collectablecards:client:Collectable')
AddEventHandler('tilp-hdrp-collectablecards:client:Collectable', function(card)
    SendNUIMessage({ open = true, class = 'choose', data = card })
end)

---------------------
-- OPEN CARDS/ITEMS
---------------------
RegisterNetEvent('tilp-hdrp-collectablecards:client:opencollactable')
AddEventHandler('tilp-hdrp-collectablecards:client:opencollactable', function()

    lib.progressBar({
        duration = Config.Card.progressTime,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disableControl = true,
        disable = {
            move = true,
            mouse = true,
        },
        label = locale('cl_lang_1'),
    })

    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'dealfour', 0.8)

    Wait(500)
    SetNuiFocus(true, true)
    SendNUIMessage({ open = true, class = 'open' })

    ClearPedTasks(cache.ped)
    TriggerServerEvent('tilp-hdrp-collectablecards:server:removeitem')

end)

---------------------
-- OPEN BAG
---------------------
-- open box
RegisterNetEvent('tilp-hdrp-collectablecards:client:BoxOn', function(data)
    if Config.Card.Storage.activeProp == true then
        -- TriggerServerEvent('tilp-hdrp-collectablecards:client:spawnBoxOnGround', data)
    else
        local serial = data.serie
        RSGCore.Functions.TriggerCallback('tilp-hdrp-collectablecards:server:getBoxInfo', function(info)
            if not info then
                lib.notify({ title = locale('cl_error_1'), type = 'error' })
                return
            end

            TriggerServerEvent('tilp-hdrp-collectablecards:server:openBox', serial)
        end, serial)
    end
end)

---------------------
-- OPEN BAG ON GROUND
---------------------
--[[ local function crouchInspectAnim()
    local anim1 = `WORLD_HUMAN_CROUCH_INSPECT`
    if not IsPedMale(cache.ped) then
        anim1 = `WORLD_HUMAN_CROUCH_INSPECT`
    end

    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    FreezeEntityPosition(cache.ped, true)

    TaskStartScenarioInPlace(cache.ped, anim1, 3000, true, false, false, false)

    Wait(3000)
    ClearPedTasks(cache.ped)
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
    FreezeEntityPosition(cache.ped, false)
end

local function CleanupSpecificGround(serial)
    for k, v in pairs(GroundBoxs) do
        if k == serial then
            if v.prop then
                SetEntityAsMissionEntity(v.prop, false)
                FreezeEntityPosition(v.prop, false)
                DeleteObject(v.prop)
            end
            GroundBoxs[k] = nil  -- Eliminar de la tabla
        end
    end
    lib.notify({ title = locale('cl_lang_3'), type = 'info' })
end

-- place props 
RegisterNetEvent('tilp-hdrp-collectablecards:client:spawnBoxOnGround')
AddEventHandler('tilp-hdrp-collectablecards:client:spawnBoxOnGround', function(data)
    local serial = data.serie
    local pos    = GetEntityCoords(cache.ped)
    local forward = GetEntityForwardVector(cache.ped)
    local x, y, z = table.unpack(pos + forward * 0.5)

    local model  = Config.Card.Storage.prop
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(50)
    end

    crouchInspectAnim()

    -- creo el objeto en el suelo
    local box = CreateObject(model, x, y, z, true, true, true)

    if not DoesEntityExist(box) then
        lib.notify({ title = locale('cl_error_11'), description = locale('cl_error_12'), type = 'error' })
        return
    else
        GroundBoxs[serial] = { prop = box, data = data}

        local _, groundZ = GetGroundZFor_3dCoord(x, y, z, true)
        if groundZ > 0 then
            SetEntityCoords(box, x, y, groundZ + 0.1)
        end

        FreezeEntityPosition(box, true)
        SetModelAsNoLongerNeeded(box)
        PlaceObjectOnGroundProperly(box)
        Wait(1000)

        -- 2) añado interacción
        exports.ox_target:addLocalEntity(box, {
            {   name    = 'box_prop_open',
                icon    = 'fas fa-box',
                label   = locale('cl_lang_4'),
                onSelect = function()
                    -- pido info al server (creator, owner…)
                    RSGCore.Functions.TriggerCallback('tilp-hdrp-collectablecards:server:getBoxInfo', function(info)
                        if not info then
                            lib.notify({ title = locale('cl_error_13'), description = locale('cl_error_14'), type = 'error' })
                            return
                        end
                        -- abro stash con el evento server
                        TriggerServerEvent('tilp-hdrp-collectablecards:server:openBox', serial)
                    end, serial)
                end,
                distance = 2.5,
            },
            {   name    = 'box_prop_safe',
                icon = 'fas fa-archive',
                label = locale('cl_lang_5'),
                onSelect = function()
                    CleanupSpecificGround(serial)
                    TriggerServerEvent('tilp-hdrp-collectablecards:server:addBox', data, serial)
                    Wait(3000)
                end,
                distance = 2.5,
            }
        })
    end

    local position = vector3(x, y, z)
    TriggerServerEvent('tilp-hdrp-collectablecards:server:syncBox', data, position)
end)

-- update props 
RegisterNetEvent('tilp-hdrp-collectablecards:client:updatePropData')
AddEventHandler('tilp-hdrp-collectablecards:client:updatePropData', function(data)
    Config.PlayerProps = data
end)

-- request sync
RegisterNetEvent('tilp-hdrp-collectablecards:client:requestSync', function()
    TriggerServerEvent('tilp-hdrp-collectablecards:server:syncRequest')
end) ]]

---------------------
-- TAKE CARDS/ITEMS
---------------------
local playerCooldowns = {}

RegisterNetEvent('tilp-hdrp-collectablecards:client:takecard')
AddEventHandler('tilp-hdrp-collectablecards:client:takecard', function(item)
    local playerId = GetPlayerServerId(PlayerId())
    local currentTime = GetGameTimer()

    if not playerCooldowns[playerId] then
        playerCooldowns[playerId] = {}
    end

    if not playerCooldowns[playerId][item] then
        playerCooldowns[playerId][item] = 0
    end

    if (currentTime - playerCooldowns[playerId][item]) >= Config.Card.Cooldowns then
        playerCooldowns[playerId][item] = currentTime

        lib.progressBar({
            duration = Config.Card.takeTime,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disableControl = true,
            disable = {
                move = true,
                mouse = true,
            },
            anim = {
                scenario = 'WORLD_HUMAN_CROUCH_INSPECT'
            },
            label = locale('cl_lang_2'),
        })

        TriggerServerEvent('InteractSound_SV:PlayOnSource', 'dealfour', 0.8)

        Wait(500)
        SetNuiFocus(true, true)
        SendNUIMessage({ open = true, class = 'open' })

        ClearPedTasks(cache.ped)

    else
        local timeRemaining = math.ceil(Config.Card.Cooldowns - (currentTime - playerCooldowns[playerId][item]))
        local minutes = math.floor(timeRemaining / 60)
        local seconds = timeRemaining % 60

        lib.notify({ title = locale('cl_error_2'), description = locale('cl_error_5'), type = 'error', duration = 5000 })
        Wait(5000)
        lib.notify({ title = locale('cl_error_4'), description = string.format(locale('cl_error_5'), minutes, seconds), type = 'error', duration = 5000 })
    end
end)

------------- 
-- EXTRA MOVE 
-------------
local isObjectActive = false
local cardModelw10_h6 = {
    's_inv_cigcard_AML_01x',
    's_inv_cigcard_AML_02x',
    's_inv_cigcard_AML_03x',
    's_inv_cigcard_AML_04x',
    's_inv_cigcard_AML_05x',
    's_inv_cigcard_AML_06x',
    's_inv_cigcard_AML_07x',
    's_inv_cigcard_AML_08x',
    's_inv_cigcard_AML_09x',
    's_inv_cigcard_AML_10x',
    's_inv_cigcard_AML_11x',
    's_inv_cigcard_AML_12x',
    's_inv_cigcard_HRS_01x',
    's_inv_cigcard_HRS_02x',
    's_inv_cigcard_HRS_03x',
    's_inv_cigcard_HRS_04x',
    's_inv_cigcard_HRS_05x',
    's_inv_cigcard_HRS_06x',
    's_inv_cigcard_HRS_07x',
    's_inv_cigcard_HRS_08x',
    's_inv_cigcard_HRS_09x',
    's_inv_cigcard_HRS_10x',
    's_inv_cigcard_HRS_11x',
    's_inv_cigcard_HRS_12x',
    's_inv_cigcard_INV_01x',
    's_inv_cigcard_INV_02x',
    's_inv_cigcard_INV_03x',
    's_inv_cigcard_INV_04x',
    's_inv_cigcard_INV_05x',
    's_inv_cigcard_INV_06x',
    's_inv_cigcard_INV_07x',
    's_inv_cigcard_INV_08x',
    's_inv_cigcard_INV_09x',
    's_inv_cigcard_INV_10x',
    's_inv_cigcard_INV_11x',
    's_inv_cigcard_INV_12x',
    's_inv_cigcard_VEH_01x',
    's_inv_cigcard_VEH_02x',
    's_inv_cigcard_VEH_03x',
    's_inv_cigcard_VEH_04x',
    's_inv_cigcard_VEH_05x',
    's_inv_cigcard_VEH_06x',
    's_inv_cigcard_VEH_07x',
    's_inv_cigcard_VEH_08x',
    's_inv_cigcard_VEH_09x',
    's_inv_cigcard_VEH_10x',
    's_inv_cigcard_VEH_11x',
    's_inv_cigcard_VEH_12x'
}

-- Sonido y partículas de carta
local function StartCardSoundHint()
    local soundset_ref = Config.Card.ptfx.soundset_ref
    local soundset_name = Config.Card.ptfx.soundset_name

    if soundset_ref ~= 0 then
        Citizen.InvokeNative(0x0F2A2175734926D8, soundset_name, soundset_ref) -- Cargar sonido
    end
    while Citizen.InvokeNative(0x45AB66D02B601FA7, PlayerId()) do
        Citizen.InvokeNative(0x67C540AA08E4A6F5, soundset_name, soundset_ref, true, 0) -- Reproducir sonido
        Wait(200) -- Ajuste de tiempo de espera para el sonido
    end
    Citizen.InvokeNative(0x9D746964E0CF2C5F, soundset_name, soundset_ref) -- Detener sonido
end

RegisterNetEvent('tilp-hdrp-collectablecards:client:cardsIndivudal')
AddEventHandler('tilp-hdrp-collectablecards:client:cardsIndivudal', function(card, cardmodel, type)
    if not card or not cardmodel or card == "" or cardmodel == "" then
        return
    end
    
    if GetVehiclePedIsIn(cache.ped, false) ~= 0 then
        lib.notify({ title = locale('cl_error_7'), description = locale('cl_error_8'), type = 'error', duration = 7000 })
        return
    end

    if isObjectActive == true then
        lib.notify({ title = locale('cl_error_9'), description = locale('cl_error_10'), type = 'error', duration = 7000 })
        isObjectActive = false
        return
    end

    if not isBusy then
        isBusy = true
        SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)

        ClearPedTasksImmediately(cache.ped)
        RemoveAllPedWeapons(cache.ped, true)
        ClearPedSecondaryTask(cache.ped)
        ClearPedTasks(cache.ped)

        if Config.Card.ptfx.enabled == true then
            StartCardSoundHint()
        end

        local prop = CreateObject(joaat(cardmodel), GetEntityCoords(cache.ped), false, true, false, false, true)
        table.insert(spawnedProps, {prop = prop })

        Citizen.InvokeNative(0xCB9401F918CB0F75, cache.ped, 'GENERIC_DOCUMENT_FLIP_AVAILABLE', true, -1)

        if type == 'Inspect' then
            if card and cardmodel == cardModelw10_h6 then
                TaskItemInteraction_2(cache.ped, joaat(card), prop, joaat("PrimaryItem"), joaat('CIGARETTE_CARD_W10-7_H6-5_SINGLE_HOLSTER'), 1, 0, -1.0)
            else
                TaskItemInteraction_2(cache.ped, joaat(card), prop, joaat("PrimaryItem"), joaat('CIGARETTE_CARD_W6-5_H10-7_SINGLE_HOLSTER'), 1, 0, -1.0)
            end
        end

        if type == 'InspectZ' then
            if card and cardmodel == cardModelw10_h6 then
                TaskItemInteraction_2(cache.ped, joaat(card), prop, joaat("PrimaryItem"), joaat('CIGARETTE_CARD_W10-7_H6-5_SINGLE_INTRO'), 1, 0, -1.0)
            else
                TaskItemInteraction_2(cache.ped, joaat(card), prop, joaat("PrimaryItem"), joaat('CIGARETTE_CARD_W6-5_H10-7_SINGLE_INTRO'), 1, 0, -1.0)
            end
        end

        SetEntityAsNoLongerNeeded(prop)

        Wait(Config.Card.AutoDelete) -- Tiempo antes de eliminar el hueso (60 segundos)
        if DoesEntityExist(prop) then
            DeleteEntity(prop)    -- Eliminación del objeto
            for k, v in pairs(spawnedProps) do    -- Limpieza de la tabla de objetos
                if v.prop == prop then
                    spawnedProps[k] = nil
                end
            end
        end

        ClearPedTasks(cache.ped)
        SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
        isBusy = false
    end
end)

----------------------
-- START/STOP RESOURCE
----------------------
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    TriggerEvent('RSGCore:client:OnPlayerLoaded')
end)

AddEventHandler('RSGCore:Client:OnPlayerLoaded', function()
    PlayerData = RSGCore.Functions.GetPlayerData()
end)

RegisterNetEvent('RSGCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    playerCooldowns = {}
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    SetNuiFocus(false, false)
    
    for k, v in pairs(spawnedProps) do
        if v.prop then
            SetEntityAsMissionEntity(v.prop, false)
            FreezeEntityPosition(v.prop, false)
            DeleteObject(v.prop)
        end
        spawnedProps[k] = nil
    end
    
    for k, v in pairs(GroundBoxs) do
        if v.prop then
            SetEntityAsMissionEntity(v.prop, false)
            FreezeEntityPosition(v.prop, false)
            DeleteObject(v.prop)
        end
        GroundBoxs[k] = nil
    end

    playerCooldowns = {}
    ClearPedTasks(cache.ped)
    isBusy = false
    isObjectActive = false
end)