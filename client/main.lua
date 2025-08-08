ESX = nil
local lootedPoints = {}
local inBunker = false
local selectedCrew = {}
local lootZones = {}
local exitZone = nil
local robberyCooldown = false
local cooldownEndTime = 0

-- ESX init
CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(0)
        print([[
    ^8___________________________________________________________
    ^3
        
    $$$$$$$\                                $$\                                     $$\       $$\                       $$\                 $$\       $$\  $$$$$$\   $$$$$$\  
    $$  __$$\                               $$ |                                    $$ |      $$ |                      $$ |                $$ |      \__|$$  __$$\ $$  __$$\ 
    $$ |  $$ | $$$$$$\ $$\    $$\  $$$$$$\  $$ | $$$$$$\   $$$$$$\   $$$$$$\   $$$$$$$ |      $$$$$$$\  $$\   $$\       $$ |  $$\  $$$$$$\  $$ |  $$\ $$\ \__/  $$ |$$ /  \__|
    $$ |  $$ |$$  __$$\\$$\  $$  |$$  __$$\ $$ |$$  __$$\ $$  __$$\ $$  __$$\ $$  __$$ |      $$  __$$\ $$ |  $$ |      $$ | $$  |$$  __$$\ $$ | $$  |$$ | $$$$$$  |$$$$$$$\  
    $$ |  $$ |$$$$$$$$ |\$$\$$  / $$$$$$$$ |$$ |$$ /  $$ |$$ /  $$ |$$$$$$$$ |$$ /  $$ |      $$ |  $$ |$$ |  $$ |      $$$$$$  / $$ /  $$ |$$$$$$  / $$ |$$  ____/ $$  __$$\ 
    $$ |  $$ |$$   ____| \$$$  /  $$   ____|$$ |$$ |  $$ |$$ |  $$ |$$   ____|$$ |  $$ |      $$ |  $$ |$$ |  $$ |      $$  _$$<  $$ |  $$ |$$  _$$<  $$ |$$ |      $$ /  $$ |
    $$$$$$$  |\$$$$$$$\   \$  /   \$$$$$$$\ $$ |\$$$$$$  |$$$$$$$  |\$$$$$$$\ \$$$$$$$ |      $$$$$$$  |\$$$$$$$ |      $$ | \$$\ \$$$$$$  |$$ | \$$\ $$ |$$$$$$$$\  $$$$$$  |
    \_______/  \_______|   \_/     \_______|\__| \______/ $$  ____/  \_______| \_______|      \_______/  \____$$ |      \__|  \__| \______/ \__|  \__|\__|\________| \______/ 
                                                          $$ |                                          $$\   $$ |                                                            
                                                          $$ |                                          \$$$$$$  |                                                                                                                 \__|                                           \______/                                                             
    ^8___________________________________________________________
    ^2
    > ESX Bunker Robbery System
    > Developed by ^1koki26
    > Version: ^51.0.0^2 | ^6https://github.com/koki26
    ^8___________________________________________________________^0
    ]])
    end
end)


RegisterNetEvent('esx_bunker_robbery:updateCooldown', function(isActive, duration)
    robberyCooldown = isActive
    if isActive and duration then
        cooldownEndTime = GetGameTimer() + duration
    end
end)

-- Teleport handler
RegisterNetEvent('esx_bunker_robbery:clientTeleport', function(coords, heading, isEntering)
    local ped = PlayerPedId()
    local isCop = isPolice()
    
    -- Convert to vector3 if needed
    local targetCoords = type(coords) == 'table' and vector3(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3]) or coords
    
    -- Teleport with validation
    SetEntityCoords(ped, targetCoords.x, targetCoords.y, targetCoords.z)
    SetEntityHeading(ped, heading or 0.0)
    
    -- Update state and show notification
    inBunker = isEntering
    ESX.ShowNotification(isEntering and "Byl jsi teleportován do bunkru" or "Opustil jsi bunkr")
    
    if isEntering then
        lootedPoints = {}
        if not isCop then -- Only setup loot and guards for non-police
            setupLootTargets()
            TriggerEvent('esx_bunker_robbery:spawnGuards')
            if source == GetPlayerServerId(PlayerId()) then
                TriggerServerEvent('esx_bunker_robbery:startRobbery')
            end
        end
        setupExitTarget() -- Create exit target for everyone
    else
        cleanupBunker()
    end
end)

CreateThread(function()
    while not ESX do Wait(100) end
    while not exports.ox_target do Wait(100) end
    
    -- Police entry target
    exports['ox_target']:addBoxZone({
        coords = Config.PoliceEntry,
        size = vec3(1.5,1.5,1.5),
        rotation = 0.0,
        debug = false,
        options = {
            {
                name = 'police_bunker_entry',
                icon = 'fas fa-shield-alt',
                label = 'Vstoupit do bunkru (Policie)',
                distance = 2.0,
                canInteract = function()
                    return isPolice() and not inBunker
                end,
                onSelect = function()
                    -- Police can always enter, regardless of robbery status
                    TriggerEvent('esx_bunker_robbery:clientTeleport', Config.BunkerInterior.xyz, Config.BunkerInterior.w, true)
                end
            }
        }
    })
end)

CreateThread(function()
    while true do
        Wait(5000)
        if not inBunker and not robberyCooldown then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - Config.BunkerEntry)
            
            if distance < 20.0 then
                ESX.TriggerServerCallback('esx_bunker_robbery:getCooldown', function(isCooldown, remaining)
                    if isCooldown then
                        ESX.ShowNotification(('Bunker je momentálně uzavřen! Počkejte prosím %d sekund.'):format(remaining), 'inform')
                    end
                end)
            end
        end
    end
end)

-- Bunker entry target
CreateThread(function()
    while not ESX do Wait(100) end
    
    -- Wait for ox_target to be ready
    while not exports.ox_target do Wait(100) end
    
    exports['ox_target']:addBoxZone({
        coords = Config.BunkerEntry,
        size = vec3(1.5,1.5,1.5),
        rotation = 0.0,
        debug = false,
        options = {
            {
                name = 'start_bunker_robbery',
                icon = 'fas fa-lock',
                label = 'Vykrást bunker',
                distance = 2.0,
                canInteract = function()
                    return not isPolice()
                end,
                onSelect = openCrewSelectionMenu
            }
        }
    })
end)

-- Crew selection menu
function openCrewSelectionMenu()
    -- First check police count
    ESX.TriggerServerCallback('esx_bunker_robbery:canStartRobbery', function(canStart, message)
        if not canStart then
            if message then
                ESX.ShowNotification(message, 'error')
            end
            return
        end
        
        -- Then check if player has required items
        ESX.TriggerServerCallback('esx_bunker_robbery:checkItems', function(hasItems, missingItems)
            if not hasItems then
                -- Get item labels from server
                ESX.TriggerServerCallback('esx_bunker_robbery:getItemLabels', function(itemLabels)
                    local missingItemNames = {}
                    for itemName, _ in pairs(missingItems) do
                        table.insert(missingItemNames, itemLabels[itemName] or itemName)
                    end
                    ESX.ShowNotification(('Chybí ti potřebné předměty: %s'):format(table.concat(missingItemNames, ', ')), 'error')
                end, missingItems)
                return
            end

            -- Player has all items, show crew selection menu
            ESX.TriggerServerCallback('esx_bunker_robbery:getItemLabels', function(itemLabels)
                local players = ESX.Game.GetPlayers()
                local requiredItemsText = ""
                
                -- Build required items text with labels
                for i, itemName in ipairs(Config.RequiredItems) do
                    if i == 1 then
                        requiredItemsText = "• "..(itemLabels[itemName] or itemName)
                    else
                        requiredItemsText = requiredItemsText.."\n• "..(itemLabels[itemName] or itemName)
                    end
                end

                local options = {
                    {
                        title = 'Výběr členů týmu',
                        description = 'Vyberte spoluhráče pro misi',
                        icon = 'users',
                        iconColor = '#3498db',
                        disabled = true
                    },
                    {
                        title = '──────────',
                        disabled = true
                    },
                    {
                        title = 'POTŘEBNÉ VYBAVENÍ',
                        description = requiredItemsText,
                        icon = 'toolbox',
                        iconColor = '#f39c12',
                        disabled = true
                    },
                    {
                        title = '──────────',
                        disabled = true
                    }
                }

                -- Add player options
                for _, player in ipairs(players) do
                    local serverId = GetPlayerServerId(player)
                    if serverId ~= GetPlayerServerId(PlayerId()) then
                        local isSelected = table.contains(selectedCrew, serverId)
                        local playerPed = GetPlayerPed(player)
                        local playerName = GetPlayerName(player)
                        
                        table.insert(options, {
                            title = playerName,
                            description = isSelected and 'Vybraný do týmu' or 'Klikněte pro výběr',
                            icon = isSelected and 'user-check' or 'user',
                            iconColor = isSelected and '#2ecc71' or '#7f8c8d',
                            args = { playerId = serverId },
                            event = 'esx_bunker_robbery:toggleCrewMember',
                            metadata = {
                                { label = 'ID', value = serverId },
                                { label = 'Vzdálenost', value = math.floor(#(GetEntityCoords(PlayerPedId()) - GetEntityCoords(playerPed))) .. 'm' }
                            }
                        })
                    end
                end

                -- Add confirm button
                table.insert(options, {
                    title = '──────────',
                    disabled = true
                })
                
                table.insert(options, {
                    title = 'POTVRDIT VÝBĚR',
                    description = #selectedCrew > 0 and ('Vybraní členové: ' .. #selectedCrew) or 'Musíte vybrat alespoň jednoho hráče',
                    icon = 'check-circle',
                    iconColor = #selectedCrew > 0 and '#2ecc71' or '#e74c3c',
                    disabled = #selectedCrew == 0,
                    event = 'esx_bunker_robbery:confirmCrewSelection'
                })

                lib.registerContext({
                    id = 'bunker_crew_selection',
                    title = 'BUNKER MISSION',
                    options = options,
                    menu = 'bunker_main_menu'
                })

                lib.showContext('bunker_crew_selection')
            end, Config.RequiredItems)
        end)
    end)
end

-- Add these new events
RegisterNetEvent('esx_bunker_robbery:toggleCrewMember', function(data)
    local serverId = data.playerId
    if table.contains(selectedCrew, serverId) then
        for i = #selectedCrew, 1, -1 do
            if selectedCrew[i] == serverId then
                table.remove(selectedCrew, i)
            end
        end
    else
        table.insert(selectedCrew, serverId)
    end
    openCrewSelectionMenu() -- Refresh menu
end)

RegisterNetEvent('esx_bunker_robbery:confirmCrewSelection', function()
    if #selectedCrew > 0 then
        startBunkerRobbery() 
    else
        ESX.ShowNotification('Musíš vybrat alespoň jednoho hráče!', 'error')
    end
end)

function table.contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

function startBunkerRobbery()
    if inBunker then return ESX.ShowNotification("Už jsi v bunkru!") end
    
    ESX.TriggerServerCallback('esx_bunker_robbery:canStartRobbery', function(canStart, message)
        if not canStart then
            if message then
                ESX.ShowNotification(message, 'error')
            else
                ESX.ShowNotification('Cannot start robbery right now', 'error')
            end
            return
        end
        
        -- Check cooldown again right before starting
        ESX.TriggerServerCallback('esx_bunker_robbery:getCooldown', function(isCooldown, remaining)
            if isCooldown then
                ESX.ShowNotification(('Bunker je momentálně uzavřen! Počkejte prosím %d sekund.'):format(remaining), 'error')
                return
            end
            
            -- Check items one final time before removing them
            ESX.TriggerServerCallback('esx_bunker_robbery:checkItems', function(hasItems, missingItems)
                if not hasItems then
                    ESX.TriggerServerCallback('esx_bunker_robbery:getItemLabels', function(itemLabels)
                        local missingItemNames = {}
                        for itemName, _ in pairs(missingItems) do
                            table.insert(missingItemNames, itemLabels[itemName] or itemName)
                        end
                        ESX.ShowNotification(('Chybí ti potřebné předměty: %s'):format(table.concat(missingItemNames, ', ')), 'error')
                    end, missingItems)
                    return
                end
                
                -- Send dispatch alert
                local data = exports['cd_dispatch']:GetPlayerInfo()
                TriggerServerEvent('cd_dispatch:AddNotification', {
                    job_table = {'police'}, 
                    coords = Config.PoliceEntry,
                    title = '10-68 - Vykrádání Bunkru',
                    message = 'Místní kamery zaznamenaly osobu, která se pokouší proniknout do bunkru na '..data.street, 
                    flash = 0,
                    unique_id = data.unique_id,
                    sound = 1,
                    blip = {
                        sprite = 527, -- Different sprite for bunker robbery
                        scale = 1.2, 
                        colour = 1, -- Red color
                        flashes = true, 
                        text = '911 - Vykrádání Bunkru',
                        time = 5,
                        radius = 0,
                    }
                })
                
                -- FINALLY remove items and start robbery
                TriggerServerEvent('esx_bunker_robbery:removeRequiredItems')
                
                -- Teleport self first
                TriggerEvent('esx_bunker_robbery:clientTeleport', Config.BunkerInterior.xyz, Config.BunkerInterior.w, true)
                
                -- Then teleport crew with slight delay
                if #selectedCrew > 0 then
                    Wait(500)
                    TriggerServerEvent('esx_bunker_robbery:teleportCrew', selectedCrew, Config.BunkerInterior.xyz, Config.BunkerInterior.w, true)
                end
            end)
        end)
    end)
end

-- Spawn guards
RegisterNetEvent('esx_bunker_robbery:spawnGuards', function()
    if isPolice() then 
        print("Police entered - not spawning guards")
        return 
    end
    
    print("Attempting to spawn guards...")
    
    for _, guard in pairs(Config.Guards) do
        -- Load model
        RequestModel(guard.model)
        local timeout = 0
        while not HasModelLoaded(guard.model) and timeout < 100 do 
            Wait(10)
            timeout = timeout + 1
        end
        
        if not HasModelLoaded(guard.model) then
            print("Failed to load guard model: " .. guard.model)
            return
        end
        
        -- Create ped
        local npc = CreatePed(4, guard.model, guard.coords.x, guard.coords.y, guard.coords.z, guard.w or 0.0, true, false)
        if not DoesEntityExist(npc) then
            print("Failed to create guard ped")
            return
        end
        
        -- Arm the guard
        GiveWeaponToPed(npc, guard.weapon, 250, false, true)
        SetPedRelationshipGroupHash(npc, `HATES_PLAYER`)
        SetPedCombatAttributes(npc, 46, true) -- Always fight
        SetPedCombatAbility(npc, 2) -- Professional
        SetPedCombatMovement(npc, 2) -- Will advance to attack
        TaskCombatPed(npc, PlayerPedId(), 0, 16)
        SetPedAlertness(npc, 3)
        SetPedAccuracy(npc, 65)
        SetEntityAsMissionEntity(npc, true, true)
    end
end)

-- Loot points
function setupLootTargets()
    -- Clean up existing loot zones if any
    for _, zone in pairs(lootZones) do
        exports['ox_target']:removeZone(zone)
    end
    lootZones = {}

    for i, loot in ipairs(Config.LootPoints) do
        local zoneId = exports['ox_target']:addBoxZone({
            coords = loot.coords,
            size = vec3(1.0, 1.0, 1.0),
            rotation = loot.heading or 0.0,
            debug = false,
            options = {
                {
                    name = 'loot_bunker_'..i,
                    icon = 'fas fa-box',
                    label = 'Vykrást zásobu',
                    distance = 2.5,
                    canInteract = function()
                        return not lootedPoints[i]
                    end,
                    onSelect = function()
                        local playerPed = PlayerPedId()
                        TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)

                        if exports.ox_lib:progressBar({
                            duration = Config.LootTime,
                            label = "Vykrádáš zásobu...",
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                move = true,
                                car = true,
                                combat = true
                            },
                            anim = {
                                scenario = "PROP_HUMAN_BUM_BIN",
                            }
                        }) then
                            lootedPoints[i] = true
                            TriggerServerEvent('esx_bunker_robbery:giveLoot', GetPlayerServerId(PlayerId()))
                        end
                        ClearPedTasks(playerPed)
                    end
                }
            }
        })
        table.insert(lootZones, zoneId)
    end
end

function isPolice()
    local playerData = ESX.GetPlayerData()
    for _, job in ipairs(Config.PoliceJobs) do
        if playerData.job.name == job then
            return true
        end
    end
    return false
end

function cleanupBunker()
    for _, zone in pairs(lootZones) do
        exports['ox_target']:removeZone(zone)
    end
    
    inBunker = false
    lootedPoints = {}
    lootZones = {}
    -- Don't remove exitZone here
end

-- Exit
function setupExitTarget()
    if exitZone then
        exports['ox_target']:removeZone(exitZone)
    end

    exitZone = exports['ox_target']:addBoxZone({
        coords = Config.BunkerExit.xyz,
        size = vec3(1.5,1.5,1.5),
        rotation = Config.BunkerExit.w,
        debug = false,
        options = {
            {
                name='exit_bunker_robbery',
                icon='fas fa-door-open',
                label='Opustit bunker',
                distance=2.0,
                canInteract = function()
                    return not isPolice() and inBunker
                end,
                onSelect=function()
                    local playerId = GetPlayerServerId(PlayerId())
                    -- Leader should always trigger endRobbery
                    TriggerServerEvent('esx_bunker_robbery:endRobbery')
                    TriggerEvent('esx_bunker_robbery:clientTeleport', Config.BunkerEntry, 0.0, false)
                end
            },
            {
                name='police_exit_bunker',
                icon='fas fa-shield-alt',
                label='Opustit bunker (Policie)',
                distance=2.0,
                canInteract = function()
                    return isPolice() and inBunker
                end,
                onSelect=function()
                    TriggerEvent('esx_bunker_robbery:clientTeleport', Config.PoliceEntry, 0.0, false)
                end
            }
        }
    })
end