local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

local MissionsShared = require("shared/missions")
local cards_points = require("shared/cards_points")
--------------------------
-- MENU MISSION TRADE
--------------------------
RegisterNetEvent('tilp-hdrp-collectablecards:client:openmission')
AddEventHandler('tilp-hdrp-collectablecards:client:openmission', function(missionId)

    RSGCore.Functions.TriggerCallback('tilp-hdrp-collectablecards:server:getactiveM', function(missions)
        local selectedLoc = nil
        for _, loc in ipairs(Config.CardMission) do
            if loc.id == missionId then
                selectedLoc = loc
                break
            end
        end


        if not selectedLoc or not missions or #missions == 0 then
            lib.notify({ title = locale('cl_error_16'), description = locale('cl_error_17'), type = 'error', duration = 7000 })
            return
        end

        local cardMenu = {
            id = 'cards_mission_menu',
            title = locale('cl_lang_6'),
            options = {}
        }

        -- table.insert(cardMenu.options, {
        --     title = locale('cl_lang_12'), -- Nombre de la opción, por ejemplo "Iniciar caza de cartas"
        --     description = locale('cl_lang_13'), -- Breve descripción de la mecánica
        --     arrow = true,
        --     onSelect = function()
        --         lib.notify({ title = locale('cl_treasurehunt_start'), description = locale('cl_treasurehunt_start_des'), type = 'info' })
        --         startTreasureHunt()
        --     end
        -- })
        
        for _, m in ipairs(missions) do
            local img  = "nui://" .. Config.img .. RSGCore.Shared.Items[tostring(m.reward)].image
            local lbl  = RSGCore.Shared.Items[tostring(m.reward)].label

            local opt = {
                title       = locale('cl_lang_7'),
                description = locale('cl_lang_8') .. " - " .. lbl,
                icon        = img,
                arrow       = true,
                metadata    = {{
                    label = locale('cl_lang_9'),
                    value = locale('cl_lang_10')
                }},
                onSelect = function()
                    for cardName, qty in pairs(m.cards) do
                        local hasItem = RSGCore.Functions.HasItem(cardName, qty)
                        if not hasItem then
                            lib.notify({ title = locale('cl_error_18'), description = locale('cl_error_19') .. ' '.. lbl, type = 'error', duration = 7000 })
                            return
                        end
                    end
                    TriggerServerEvent('tilp-hdrp-collectablecards:server:missions', m)
                end
            }

            for cardName, qty in pairs(m.cards) do
                table.insert(opt.metadata, {
                    label = locale('cl_lang_11'),
                    value = RSGCore.Shared.Items[tostring(cardName)].label .. ' x ' .. qty
                })
            end
            table.insert(cardMenu.options, opt)
        end
        lib.registerContext(cardMenu)
        lib.showContext('cards_mission_menu')
    end, missionId)

end)

--------------------------
-- GAME LOCATION CARD
--------------------------
-- local currentHuntStep = 0
-- local totalHuntSteps = 0
-- local treasurePoints = {}
-- local huntInProgress = false
-- local headingToTarget = false
-- local waitingForPlayer = false
-- local gpsRoute = false

-- local function getRandomCardLocation()
--     local keys = {}
--     for k in pairs(cards_points) do
--         table.insert(keys, k)
--     end

--     local randomKey = keys[math.random(1, #keys)]
--     return cards_points[randomKey], randomKey
-- end

-- local function finishTreasureHunt()
--     lib.notify({ title = locale('cl_treasurehunt'), description = locale('cl_treasurehunt_des'), type = 'success' })

--     TaskPlayAnim(companionPed, 'amb_creature_mammal@world_dog_digging@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
--     Wait(Config.TreasureHunt.digAnimTime)
--     ClearPedTasksImmediately(companionPed)

--     if Config.TreasureHunt.DoMiniGame then
--         local success = lib.skillCheck({{areaSize = 50, speedMultiplier = 0.5}}, {'w', 'a', 's', 'd'})
--         if not success then

--             local numberGenerator = math.random(1, 100)
--             if numberGenerator <= tonumber(Config.TreasureHunt.lostClue) then
--                 huntInProgress = false
--                 treasurePoints = {}
--                 currentHuntStep = 0
--                 totalHuntSteps = 0
--             end

--             SetPedToRagdoll(cache.ped, 1000, 1000, 0, 0, 0, 0)
--             Wait(1000)
--             ClearPedTasks(cache.ped)
--             return
--         end
--     end

--     -- crouchInspectAnim()
--     -- TriggerServerEvent("tilp-hdrp-collectablecards:server:giveTreasureItem")
--     lib.notify({ title = locale('cl_treasurehunt_give'), description = locale('cl_treasurehunt_give_des'), type = 'success' })

--     huntInProgress = false
--     treasurePoints = {}
--     currentHuntStep = 0
--     totalHuntSteps = 0
-- end

-- local function moveToClue(index)
--     if not companionPed or not DoesEntityExist(companionPed) then return end
--     if not treasurePoints[index] then return end

--     local target = treasurePoints[index]
--     local targetCoords = vector3(target.x, target.y, target.z)    -- Get target coordinates

--     if Config.TreasureHunt.blipClue then
--         if gpsRoute ~= nil then    -- Clear any existing GPS route
--             ClearGpsMultiRoute()
--         end

--         StartGpsMultiRoute(GetHashKey("COLOR_BLUE"), true, true)    -- Start new GPS route to target

--         AddPointToGpsMultiRoute(targetCoords.x, targetCoords.y, targetCoords.z)
--         SetGpsMultiRouteRender(true)    -- Set the route to render on the map
--         gpsRoute = true
--     end
--     headingToTarget = true
--     waitingForPlayer = false

--     TaskGoToCoordAnyMeans(companionPed, target.x, target.y, target.z, 2.0, 0, 0, 786603, 0)

--     lib.notify({title = locale('cl_treasurehunt_follow'),description = string.format(locale('cl_treasurehunt_follow_des')..' %d '..locale('cl_treasurehunt_follow_desc')..' %d', index, totalHuntSteps), type = 'info'})

--     ClearPedTasksImmediately(companionPed)
--     TaskPlayAnim(companionPed, 'amb_creature_mammal@world_dog_howling_sitting@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
--     Wait(Config.TreasureHunt.sniAnimTime)
--     ClearPedTasksImmediately(companionPed)

--     if Config.Debug then print(locale('cl_print_treasurehunt_move')..' ' .. index) end

--     CreateThread(function()
--         local step = index
--         local lastReissueTime = GetGameTimer()
--         local clueStartTime = GetGameTimer()
--         local clueTimeout = 1200000  -- 60 segundos por pista
    
--         while huntInProgress and currentHuntStep == step do
--             Wait(1000)

--             local dogPos = GetEntityCoords(companionPed)
--             local playerPos = GetEntityCoords(cache.ped)
--             local distToTarget = #(dogPos - target)
--             local distToPlayer = #(dogPos - playerPos)

--             if GetGameTimer() - lastReissueTime > 10000 and headingToTarget then
--                 if Config.Debug then print(locale('cl_print_treasurehunt_move_b')) end
--                 TaskGoToCoordAnyMeans(companionPed, targetCoords.x, targetCoords.y, targetCoords.z, 2.0, 0, 0, 786603, 0)
--                 lastReissueTime = GetGameTimer()
--             end

--             if GetGameTimer() - clueStartTime > clueTimeout and headingToTarget then
--                 lib.notify({ title = locale('cl_treasurehunt_fail'), description = locale('cl_treasurehunt_fail_des'), type = 'warning' })
                
--                 ClearPedTasksImmediately(companionPed)
--                 TaskPlayAnim(companionPed, 'amb_creature_mammal@world_dog_sniffing_ground@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
--                 Wait(Config.TreasureHunt.sniAnimTime)
--                 ClearPedTasksImmediately(companionPed)

--                 TaskGoToCoordAnyMeans(companionPed, targetCoords.x, targetCoords.y, targetCoords.z, 2.0, 0, 0, 786603, 0)
--                 clueStartTime = GetGameTimer()
--                 lastReissueTime = GetGameTimer()
--             end
            
--             if headingToTarget and distToPlayer > Config.TreasureHunt.maxdistToPlayer then
--                 ClearPedTasksImmediately(companionPed)
--                 TaskGoToEntity(companionPed, cache.ped, -1, 2.0, 2.0, 0, 0)
                
--                 lib.notify({ title = locale('cl_treasurehunt_check'), description = locale('cl_treasurehunt_check_des'), type = 'warning' })
--                 headingToTarget = false
--                 waitingForPlayer = true

--             elseif waitingForPlayer and distToPlayer <= Config.TreasureHunt.mindistToPlayer then
                
--                 ClearPedTasksImmediately(companionPed)
--                 TaskPlayAnim(companionPed, 'amb_creature_mammal@world_dog_guard_growl@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
--                 Wait(Config.TreasureHunt.sniAnimTime)
--                 ClearPedTasksImmediately(companionPed)

--                 lib.notify({ title = locale('cl_treasurehunt_check_player'), description = locale('cl_treasurehunt_check_player_des'), type = 'info' })
--                 TaskGoToCoordAnyMeans(companionPed, target.x, target.y, target.z, 2.0, 0, 0, 786603, 0)
--                 headingToTarget = true
--                 waitingForPlayer = false
--                 lastReissueTime = GetGameTimer()
--             end

--             if distToTarget < Config.TreasureHunt.distToTarget then
--                 ClearPedTasksImmediately(companionPed)
--                 local roll = math.random(1, 100)
--                 if roll <= 25 then
-- 	                TaskPlayAnim(companionPed, 'amb_creature_mammal@world_dog_howling_sitting@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
--                     Wait(Config.TreasureHunt.anim.howAnimTime)
--                 elseif roll <= 50 then
--                     TaskPlayAnim(companionPed, 'amb_creature_mammal@world_dog_sniffing_ground@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
--                     Wait(Config.TreasureHunt.anim.clueWaitTime)
--                 elseif roll <= 75 then
--                     TaskPlayAnim(companionPed, 'amb_creature_mammal@world_dog_guard_growl@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
--                     Wait(Config.TreasureHunt.anim.guaAnimTime)
--                 else
--                     TaskPlayAnim(companionPed, 'amb_creature_mammal@world_dog_digging@base', 'base', 1.0, 1.0, -1, 1, 0, false, false, false)
--                     Wait(Config.TreasureHunt.anim.clueWaitTime)
--                 end
--                 ClearPedTasksImmediately(companionPed)

--                 if Config.TreasureHunt.blipClue then
--                     ClearGpsMultiRoute()
--                     gpsRoute = nil
--                     -- Create a temporary blip
--                     local blipClue = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, targetCoords.x, targetCoords.y, targetCoords.z)
--                     Citizen.InvokeNative(0x662D364ABF16DE2F, blipClue, Config.Blip.Color_modifier)
--                     SetBlipSprite(blipClue, Config.Blip.ClueSprite, true)
--                     SetBlipScale(blipClue, Config.Blip.ClueScale)
--                     Citizen.InvokeNative(0x45FF974EEA1DCE36, blipClue, true)
--                     Citizen.InvokeNative(0x9CB1A1623062F402, blipClue, Config.Blip.ClueName)

--                     lib.notify({ title = locale('cl_treasurehunt_find'), description = locale('cl_treasurehunt_find_des'), type = 'success', duration = 5000 })

--                     CreateThread(function()
--                         Wait(Config.Blip.ClueTime)
--                         if DoesBlipExist(blipClue) then RemoveBlip(blipClue) end
--                     end)
--                 end

--                 currentHuntStep = currentHuntStep + 1

--                 if currentHuntStep > totalHuntSteps then
--                     finishTreasureHunt()
--                 else
--                     Wait(500) -- Pequeña pausa antes de continuar
--                     moveToClue(currentHuntStep)
--                 end
--                 break
--             end
--         end
--     end)
-- end

-- local function generateRandomTreasureRoute(startPos, steps)
--     local route = {}
--     local lastPos = startPos

--     for i = 1, steps do
--         local dist = math.random(Config.TreasureHunt.minDistance, Config.TreasureHunt.maxDistance)
--         local angle = math.rad(math.random(0, 360))

--         local offsetX = math.cos(angle) * dist
--         local offsetY = math.sin(angle) * dist

--         local newX = lastPos.x + offsetX
--         local newY = lastPos.y + offsetY
--         local foundGround, groundZ = GetGroundZFor_3dCoord(newX, newY, lastPos.z + 100.0, 0)

--         local newZ = foundGround and groundZ or lastPos.z
--         local newPoint = vector3(newX, newY, newZ)

--         table.insert(route, newPoint)
--         lastPos = newPoint
--     end

--     if Config.Debug then print(locale('cl_print_treasurehunt_route'), tostring(#route) .. locale('cl_print_treasurehunt_route_b')) end
--     return route
-- end

-- local function startTreasureHunt()
--     if huntInProgress then
--         lib.notify({ title = locale('cl_treasurehunt_inProgress'), type = 'error' })
--         return
--     end

--     if not companionPed or not DoesEntityExist(companionPed) or IsEntityDead(cache.ped) then
--         lib.notify({ title = locale('cl_error_treasurehunt'), description = locale('cl_error_treasurehunt_des'), type = 'error' })
--         return
--     end

--     huntInProgress = true
--     currentHuntStep = 1
--     totalHuntSteps = math.random(Config.TreasureHunt.minSteps, Config.TreasureHunt.maxSteps)

--     local cardData, cardKey = getRandomCardLocation()
--     local playerCoords = GetEntityCoords(cache.ped)

--     local cluePoints = generateRandomTreasureRoute(playerCoords, totalHuntSteps - 1)
--     table.insert(cluePoints, vector3(cardData.coords.x, cardData.coords.y, cardData.coords.z)) -- Último punto = carta

--     treasurePoints = cluePoints
--     if Config.Debug then print("Carta objetivo final: ", cardKey) end
--     moveToClue(currentHuntStep)
-- end

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    -- huntInProgress = false
    -- treasurePoints = {}
    -- currentHuntStep = 0
    -- totalHuntSteps = 0
end)