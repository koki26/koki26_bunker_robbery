ESX = nil
local activeRobberies = {}
local crewRelationships = {} -- Track leader and their crew
local robberyCooldown = false -- Track cooldown state
local cooldownTimer = nil -- Track cooldown timer
local lastRobberyTime = 0 -- Track when last robbery started

TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

function IsPlayerPolice(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return false end
    
    for _, job in ipairs(Config.PoliceJobs) do
        if xPlayer.job.name == job then
            return true
        end
    end
    return false
end

-- Helper functions
function CountPoliceOnline()
    local count = 0
    local players = ESX.GetPlayers()
    
    for _, playerId in ipairs(players) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer and table.contains(Config.PoliceJobs, xPlayer.job.name) then
            count = count + 1
        end
    end
    
    return count
end

function GetLeaderForCrewMember(crewMemberId)
    for leaderId, crew in pairs(crewRelationships) do
        if table.contains(crew, crewMemberId) then
            return leaderId
        end
    end
    return nil
end

function GetCrewForLeader(leaderId)
    return crewRelationships[leaderId] or {}
end

function StartCooldown()
    if robberyCooldown then return end
    
    robberyCooldown = true
    lastRobberyTime = os.time()
    
    if cooldownTimer then
        ClearTimeout(cooldownTimer)
    end
    
    cooldownTimer = SetTimeout(Config.CooldownTime, function()
        robberyCooldown = false
        print("[^2INFO^7] Bunker robbery cooldown has ended")
        TriggerClientEvent('esx_bunker_robbery:updateCooldown', -1, false)
    end)
    
    -- Notify all clients about cooldown start
    TriggerClientEvent('esx_bunker_robbery:updateCooldown', -1, true, Config.CooldownTime)
end

-- TeleportCrew event
RegisterNetEvent('esx_bunker_robbery:teleportCrew', function(crewMembers, coords, heading, isEntering)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    -- Track relationships when entering
    if isEntering then
        crewRelationships[src] = crewMembers
    end
    
    for _, serverId in ipairs(crewMembers) do
        local target = ESX.GetPlayerFromId(serverId)
        if target then
            TriggerClientEvent('esx_bunker_robbery:clientTeleport', serverId, coords, heading, isEntering)
            print(("[^2INFO^7] Teleporting %s to bunker"):format(target.getName()))
        end
    end
end)

-- Robbery events
RegisterNetEvent('esx_bunker_robbery:startRobbery', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    -- Prevent police from starting robberies
    if IsPlayerPolice(src) then
        TriggerClientEvent('esx:showNotification', src, 'Jako policista nemůžeš začít loupež!', 'error')
        return
    end
    
    -- Check minimum police online
    if CountPoliceOnline() < Config.MinPoliceOnline then
        TriggerClientEvent('esx:showNotification', src, 
            ('Potřebuješ alespoň %d policistů ve městě, aby jsi mohl začít loupež!'):format(Config.MinPoliceOnline), 
            'error')
        return
    end
    
    if robberyCooldown then
        local remaining = (lastRobberyTime + (Config.CooldownTime/1000)) - os.time()
        TriggerClientEvent('esx:showNotification', src, ('Bunker je momentálně uzavřen! Počkejte prosím %d sekund.'):format(math.floor(remaining)), 'error')
        return
    end
    
    if activeRobberies[src] then
        TriggerClientEvent('esx:showNotification', src, 'Už máte probíhající loupež!', 'error')
        return
    end
    
    -- Check if another robbery is already active
    if next(activeRobberies) ~= nil then
        TriggerClientEvent('esx:showNotification', src, 'Loupež bunkru již probíhá!', 'error')
        return
    end
    
    -- Start the robbery
    activeRobberies[src] = true
    TriggerClientEvent('esx:showNotification', src, 'Loupež bunkru začala!', 'success')
    
    -- Log the start
    print(("[^2INFO^7] Bunker robbery started by %s"):format(xPlayer.getName()))
end)

RegisterNetEvent('esx_bunker_robbery:endRobbery', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    -- End the robbery
    activeRobberies[src] = nil
    
    -- Start cooldown when the robbery ends
    StartCooldown()
    
    -- Clean up crew relationships
    crewRelationships[src] = nil
    
    -- Teleport crew out
    local crew = GetCrewForLeader(src)
    for _, memberId in ipairs(crew) do
        local member = ESX.GetPlayerFromId(memberId)
        if member then
            TriggerClientEvent('esx_bunker_robbery:clientTeleport', memberId, Config.BunkerEntry, 0.0, false)
        end
    end
    
    print(("[^2INFO^7] Robbery ended by %s"):format(xPlayer.getName()))
end)

ESX.RegisterServerCallback('esx_bunker_robbery:canStartRobbery', function(source, cb)
    -- Check police count first
    if CountPoliceOnline() < Config.MinPoliceOnline then
        cb(false, ('Potřebuješ alespoň %d policistů ve městě, aby jsi mohl začít loupež!'):format(Config.MinPoliceOnline))
        return
    end
    
    if robberyCooldown then
        local remaining = (lastRobberyTime + (Config.CooldownTime/1000)) - os.time()
        cb(false, ('Bunker je momentálně uzavřen! Počkejte prosím %d sekund.'):format(math.floor(remaining)))
        return
    end
    
    if next(activeRobberies) ~= nil then
        cb(false, 'Loupež bunkru již probíhá!')
        return
    end
    
    cb(true)
end)

ESX.RegisterServerCallback('esx_bunker_robbery:getCooldown', function(source, cb)
    if robberyCooldown then
        local remaining = (lastRobberyTime + (Config.CooldownTime/1000)) - os.time()
        cb(true, math.max(0, math.floor(remaining)))
    else
        cb(false)
    end
end)

-- Helper function for table.contains if not already defined
function table.contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

ESX.RegisterServerCallback('esx_bunker_robbery:checkItems', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then cb(false, {}) return end
    
    local missingItems = {}
    
    for _, itemName in ipairs(Config.RequiredItems) do
        if xPlayer.getInventoryItem(itemName).count < 1 then
            missingItems[itemName] = true
        end
    end
    
    cb(next(missingItems) == nil, missingItems) -- true if no missing items
end)

ESX.RegisterServerCallback('esx_bunker_robbery:getItemLabels', function(source, cb, items)
    local labels = {}
    for _, itemName in pairs(items) do
        labels[itemName] = ESX.GetItemLabel(itemName) or itemName
    end
    cb(labels)
end)

RegisterNetEvent('esx_bunker_robbery:removeRequiredItems')
AddEventHandler('esx_bunker_robbery:removeRequiredItems', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    for _, itemName in ipairs(Config.RequiredItems) do
        xPlayer.removeInventoryItem(itemName, 1)
    end
end)

-- Loot distribution
RegisterNetEvent('esx_bunker_robbery:giveLoot', function(recipientId)
    local recipient = ESX.GetPlayerFromId(recipientId)
    if not recipient then return end

    local loot = Config.LootTable[math.random(#Config.LootTable)]
    local amount = type(loot.amount) == "function" and loot.amount() or loot.amount

    if loot.item == "money" then
        recipient.addMoney(amount)
        recipient.showNotification(("Obdržel jsi $%s z loupeže!"):format(amount))
    else
        recipient.addInventoryItem(loot.item, amount)
        recipient.showNotification(("Obdržel jsi %sx %s z loupeže!"):format(amount, ESX.GetItemLabel(loot.item)))
    end
end)