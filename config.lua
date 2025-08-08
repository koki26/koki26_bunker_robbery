Config = {}

-- Required items to enter the bunker (will be removed upon entry)
Config.RequiredItems = {
    'thermite',  
    'lockpick',
}

-- Doba lootování v ms
Config.LootTime = 25000

-- Loot tabulka
Config.LootTable = {
    { item = "spring", amount = 50 },
    { item = "zasobnikak", amount = function() return math.random(1,3) end },
    { item = "pazba", amount = function() return math.random(1,3) end },
    { item = "teloak", amount = function() return math.random(1,3) end },
    { item = "hlavenak", amount = function() return math.random(1,3) end },
    { item = "zasobnikm4", amount = function() return math.random(1,3) end },
    { item = "pazbam4", amount = function() return math.random(1,3) end },
    { item = "telom4", amount = function() return math.random(1,3) end },
    { item = "hlavenm4", amount = function() return math.random(1,3) end },
    { item = "zasobniksmg", amount = function() return math.random(1,3) end },
    { item = "pazbasmg", amount = function() return math.random(1,3) end },
    { item = "telosmg", amount = function() return math.random(1,3) end },
    { item = "hlavensmg", amount = function() return math.random(1,3) end },
    { item = "zasobnikuzi", amount = function() return math.random(1,3) end },
    { item = "pazbauzi", amount = function() return math.random(1,3) end },
    { item = "telouzi", amount = function() return math.random(1,3) end },
    { item = "hlavenuzi", amount = function() return math.random(1,3) end },
    { item = "zasobnikpistol", amount = function() return math.random(1,3) end },
    { item = "telopistol", amount = function() return math.random(1,3) end },
    { item = "hlavenpistol", amount = function() return math.random(1,3) end },
    { item = "zasobniktec9", amount = function() return math.random(1,3) end },
    { item = "telotec9", amount = function() return math.random(1,3) end },
    { item = "hlaventec9", amount = function() return math.random(1,3) end },
    { item = "zasobnikshotgun", amount = function() return math.random(1,3) end },
    { item = "pazbashotgun", amount = function() return math.random(1,3) end },
    { item = "teloshotgun", amount = function() return math.random(1,3) end },
    { item = "hlavenshotgun", amount = function() return math.random(1,3) end },
    { item = "zasobnikpdw", amount = function() return math.random(1,3) end },
    { item = "pazbapdw", amount = function() return math.random(1,3) end },
    { item = "telopdw", amount = function() return math.random(1,3) end },
    { item = "hlavenpdw", amount = function() return math.random(1,3) end },
    { item = "zasobnikheavy", amount = function() return math.random(1,3) end },
    { item = "teloheavy", amount = function() return math.random(1,3) end },
    { item = "hlavenheavy", amount = function() return math.random(1,3) end },
    { item = "zasobnikvintage", amount = function() return math.random(1,3) end },
    { item = "telovintage", amount = function() return math.random(1,3) end },
    { item = "hlavenvintage", amount = function() return math.random(1,3) end },
}

-- Loot points v bunkru
Config.LootPoints = {
    { coords = vector3(839.6719, -3244.6289, -98.6992), heading = 5.9121 },
    { coords = vector3(838.1159, -3245.2844, -98.6992), heading = 8.0828 },
    { coords = vector3(836.7773, -3243.4473, -98.6992), heading = 111.8363 },
    { coords = vector3(835.2924, -3245.0466, -98.6991), heading = 343.4700 },
    { coords = vector3(882.6683, -3202.2874, -98.1962), heading = 230.6639 },
    { coords = vector3(901.6740, -3219.2036, -98.2422), heading = 106.6166 },
    { coords = vector3(905.5775, -3211.7869, -98.2216), heading = 136.1427 },
}

-- Guards
Config.Guards = {
    { model = `s_m_y_swat_01`, weapon = `WEAPON_CARBINERIFLE`, coords = vector3(851.0200, -3234.2517, -98.6992), w = 90.0 },
    { model = `s_m_y_swat_01`, weapon = `WEAPON_CARBINERIFLE`, coords = vector3(840.2629, -3233.2932, -98.6992), w = 90.0 },
    { model = `s_m_y_swat_01`, weapon = `WEAPON_CARBINERIFLE`, coords = vector3(827.0953, -3241.2371, -98.9348), w = 90.0 },
    { model = `s_m_y_swat_01`, weapon = `WEAPON_CARBINERIFLE`, coords = vector3(891.1151, -3197.6692, -98.1962), w = 90.0 },
    { model = `s_m_y_swat_01`, weapon = `WEAPON_CARBINERIFLE`, coords = vector3(896.0952, -3223.3643, -98.2557), w = 90.0 },
    { model = `s_m_y_swat_01`, weapon = `WEAPON_CARBINERIFLE`, coords = vector3(909.0442, -3224.9119, -98.2766), w = 90.0 },
}

-- Entry/exit
Config.BunkerEntry = vector3(479.2058, -1326.5245, 29.2075)
Config.BunkerExit = { xyz = vector3(896.4258, -3245.7129, -98.2428), w = 78.6706 }

-- Bunker interior (kde teleportovat hráče po vstupu)
Config.BunkerInterior = { xyz = vector3(895.0,-3240.0,-98.2), w = 0.0 }

-- Track active robberies
Config.BunkerRobberyInProgress = {}

-- Police jobs
Config.PoliceJobs = {  -- List of police job names
    'police',
    'sheriff'
}

Config.PoliceEntry = vector3(479.2058, -1326.5245, 29.2075)  -- Separate police entry point
Config.PoliceExit = { xyz = vector3(896.4258, -3245.7129, -98.2428), w = 80.0 }  -- Police exit in bunker
Config.MinPoliceOnline = 0

-- Cooldowns
Config.CooldownTime = 30 * 60 * 1000 -- 30 minutes in milliseconds