local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

---------
-- SHOP
---------
-- manu main
RegisterNetEvent('tilp-hdrp-collectablecards:client:openmain')
AddEventHandler('tilp-hdrp-collectablecards:client:openmain', function(shop)
    for k, v in pairs(Config.ShopLocation) do
        if shop == v.id then

            local cardMenu = {
                id = 'cards_tilp_menu',
                title = locale('cl_lang_12'),
                options = {
                        {
                            title = locale('cl_lang_13'),
                            description = locale('cl_lang_14'),
                            onSelect = function()
                                TriggerEvent('tilp-hdrp-collectablecards:client:opensellmenu', shop)
                            end,
                            icon = 'fa-solid fa-tag',
                            arrow = true
                        },
                        {
                            title = locale('cl_lang_15'),
                            description = locale('cl_lang_16'),
                            serverEvent = 'tilp-hdrp-collectablecards:server:openShop',
                            icon = 'fa-solid fa-tag',
                            iconColor = "yellow",
                            arrow = true
                        }
                    }
                }

            lib.registerContext(cardMenu)
            lib.showContext('cards_tilp_menu')
        end
    end
end)

-- check items player for menu sell
RegisterNetEvent('tilp-hdrp-collectablecards:client:opensellmenu') -- change resource
AddEventHandler('tilp-hdrp-collectablecards:client:opensellmenu', function(shop)
    local actualmenuid
    if type(shop) == "table" then
        actualmenuid = tostring(shop[1])
    else
        actualmenuid = tostring(shop)
    end

    if not actualmenuid then return end

    RSGCore.Functions.TriggerCallback('tilp-hdrp-collectablecards:server:getitems', function(result)
        if not result or not result.items or #result.items == 0 then return end
        for _, v in pairs(Config.ShopLocation) do --  change resource config
            if v.id == actualmenuid then
                local data =  result.items or {}
                TriggerEvent('tilp-hdrp-collectablecards:client:shopsell', data) -- change resource
                break
            end
        end
    end, actualmenuid)

end)

-- menu sell
RegisterNetEvent('tilp-hdrp-collectablecards:client:shopsell') -- change resource
AddEventHandler('tilp-hdrp-collectablecards:client:shopsell', function(data)
    if not type(data) == "table" then return end

    local sellsubmenu = {
        id = 'items_sell_menu',
        title = locale('cl_lang_18'),
        description = locale('cl_lang_19'),
        menu = 'cards_tilp_menu', -- change resource menu 
        options = {},
        onBack = function()
        end,
    }

    local subOptionAll = {
        title = locale('cl_lang_20'),
        description = locale('cl_lang_21'),
        event = 'tilp-hdrp-collectablecards:client:sellall', -- change resource
        args = { data },
        icon = 'fa-solid fa-handshake',
        arrow = true,
    }

    table.insert(sellsubmenu.options, subOptionAll)

    for _, v in ipairs(data) do
        if Config.Debug then print(locale('cl_print_1'), json.encode(v)) end
        if v and v.name then
            local itemImage = "nui://" .. Config.img .. RSGCore.Shared.Items[tostring(v.name)].image
            --local itemprice = tonumber(item.price) / 100
            local optiontitle = string.format("$%d | %s | Ud: %d", tonumber(v.price), RSGCore.Shared.Items[tostring(v.name)].label, tonumber(v.amount))

            local suboptions = {
                title = optiontitle,
                event = 'tilp-hdrp-collectablecards:client:sellcount', -- change resource
                args = {
                    name = v.name,
                    amount = tonumber(v.amount),
                    price = tonumber(v.price)
                },
                icon = itemImage,
                image = itemImage,
                arrow = true,
            }
            table.insert(sellsubmenu.options, suboptions)

        else
            if Config.Debug then print(locale('cl_print_2'), json.encode(v)) end
        end
    end

    lib.registerContext(sellsubmenu)
    lib.showContext('items_sell_menu')
end)

---------------
-- INPUT SELL
---------------
RegisterNetEvent('tilp-hdrp-collectablecards:client:sellcount')
AddEventHandler('tilp-hdrp-collectablecards:client:sellcount', function(data)

    local input = lib.inputDialog(locale('cl_lang_22'), {
        {   label = locale('cl_lang_23').. RSGCore.Shared.Items[tostring(data.name)].label .. locale('cl_lang_24') .. data.amount,
            type = 'slider',
            min = 1,
            max = data.amount,
            required = true,
            icon = 'fa-solid fa-hashtag'
        },
    })

    if not input then return end

    local hasItem = RSGCore.Functions.HasItem(data.name, tonumber(input[1]))
    if not hasItem then
        lib.notify({ title = locale('cl_error_20'), description = locale('cl_error_21'), type = 'error', duration = 7000 })
        return
    end

    TriggerServerEvent('tilp-hdrp-collectablecards:server:sellitem', data.name, tonumber(input[1]), data.price) -- change resource

end)

RegisterNetEvent('tilp-hdrp-collectablecards:client:sellall')
AddEventHandler('tilp-hdrp-collectablecards:client:sellall', function(data)

    local input = lib.inputDialog(locale('cl_lang_25'), {
        {   label = locale('cl_lang_26'),
            type = 'select',
            options = {
                { value = 'yes', label = locale('cl_lang_27')},
                { value = 'no', label = locale('cl_lang_28')}
            },
            required = true,
            icon = 'fa-solid fa-circle-question'
        },
    })

    LocalPlayer.state:set("inv_busy", true, true)
    if not input or input[1] == 'no' then LocalPlayer.state:set("inv_busy", false, true) return end

    if input[1] == 'yes' then
        if not type(data) == "table" then return end

        lib.progressBar({
            duration = Config.Shop.progressTime,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disableControl = true,
            disable = {
                move = true,
                mouse = true,
            },
            label = locale('cl_lang_29'),
        })

        TriggerServerEvent('tilp-hdrp-collectablecards:server:sellall', data)
        LocalPlayer.state:set("inv_busy", false, true)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
end)