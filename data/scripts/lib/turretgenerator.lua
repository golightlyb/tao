
local function bucket(num) -- group 52 tech levels into buckets of size 5
	return math.floor((num / 5) + 0.5) * 5
end

local function bucketToMark(num) -- group 52 tech levels into buckets of size 5
	return math.floor((num / 5) + 0.5)
end

function TurretGenerator.generateTurret(rand, type, dps, tech, material, rarity, coaxialAllowed)
    tech = bucket(tech)
    if rarity == nil then
        local index = rand:getValueOfDistribution(32, 32, 16, 8, 4, 1)
        rarity = Rarity(index - 1)
    end

    if coaxialAllowed == nil then coaxialAllowed = true end

    local gen = generatorFunction[type]
    if gen == nil then return nil end
    return gen(rand, dps, tech, material, rarity, coaxialAllowed)
end

function TurretGenerator.createWeaponPlaces(rand, numWeapons)
    local dist = 0.4

    if numWeapons == 1 then
        return vec3(0, 0, 0)
    elseif numWeapons == 2 then
        return vec3(dist * 0.5, 0, 0), vec3(-dist * 0.5, 0, 0)
    elseif numWeapons == 3 then
        return vec3(dist, 0, 0), vec3(0, 0, 0), vec3(-dist, 0, 0)
    elseif numWeapons == 4 then
        return vec3(dist * 1.5, 0, 0), vec3(dist * 0.5, 0, 0), vec3(dist * 0.5, 0, 0), vec3(dist * 1.5, 0, 0)
    elseif numWeapons == 5 then
        return vec3(dist * 2, 0, 0), vec3(dist * 1, 0, 0), vec3(0, 0, 0), vec3(dist * 1, 0, 0), vec3(dist * 2, 0, 0)
    end
end

local function xGetBarrelAdjective(turret, wtype)
    if turret.shotsPerFiring > 1 then
        if turret.shotsPerFiring == 2 then
            return "", "(2-gun)  /* weapon 'barrel' name part */"%_T
        elseif turret.shotsPerFiring == 3 then
            return "", "(3-gun)  /* weapon 'barrel' name part */"%_T
        elseif turret.shotsPerFiring == 4 then
            return "", "(4-gun)  /* weapon 'barrel' name part */"%_T
        elseif turret.shotsPerFiring == 5 then
            return "", "(5-gun)  /* weapon 'barrel' name part */"%_T
        else
            return "", "(gun array)  /* weapon 'barrel' name part */"%_T
        end
    else
        if turret.numVisibleWeapons == 2 then
            return "Twin-linked  /* weapon 'barrel' name part */"%_T, ""
        elseif turret.numVisibleWeapons == 3 then
            return "Tri-linked  /* weapon 'barrel' name part */"%_T, ""
        elseif turret.numVisibleWeapons == 4 then
            return "Quad-linked  /* weapon 'barrel' name part */"%_T, ""
        elseif turret.numVisibleWeapons > 4 then
            return ""%_T, "array  /* weapon 'barrel' name part */"
        end
    end
    return "", ""
end

local function xMakeTitleParts(turret, wtype, size, techBucket)
    local mark = " MK " .. toRomanLiterals(math.floor((techBucket + 0.5)/5))
    local quality = ""
    local barrelPrefix, barrelSuffix = xGetBarrelAdjective(turret, wtype)
    local prefix = ""
    local suffix = ""
    if turret.coaxial ~= true then
        suffix = "Turret  /* weapon if not coax */"
    end
    suffix = suffix .. mark
    prefix = barrelPrefix .. prefix
    if barrelSuffix then
        suffix = suffix .. "  " .. barrelSuffix
    end
    return quality, prefix, suffix
end

local function xMakeTitle(turret, wtype, size, techBucket, name)
    local quality, prefix, suffix = xMakeTitleParts(turret, wtype, size, techBucket)
    return Format("%1%%2%%3%%4%%5%%6%%7% /* [outer-adjective][barrel][coax][dmg-adjective][multishot][name][serial], e.g. Enduring Dual Coaxial E-Tri-Cannon T-F */"%_T, quality, prefix, "", "", "", name, suffix)
end

scales[WeaponType.XMining] = { --                                 P  C  UC R  X  XO L
    {from =  0, to = 20, size =  2.0, usedSlots=1, multiByRarity={1, 1, 1, 1, 2, 2, 3}},
    {from = 21, to = 31, size =  3.0, usedSlots=1, multiByRarity={1, 1, 1, 2, 2, 3, 3}},
    {from = 31, to = 41, size =  4.0, usedSlots=1, multiByRarity={1, 1, 2, 2, 3, 3, 4}},
    {from = 41, to = 52, size =  5.0, usedSlots=1, multiByRarity={1, 2, 2, 3, 3, 4, 5}},
}

scales[WeaponType.XGun] = { --                                    P  C  UC R  X  XO L
    {from =  0, to = 20, size =  1.0, usedSlots=1, multiByRarity={1, 1, 1, 1, 2, 2, 3}},
    {from = 21, to = 31, size =  2.0, usedSlots=1, multiByRarity={1, 1, 1, 2, 2, 3, 3}},
    {from = 31, to = 41, size =  3.0, usedSlots=1, multiByRarity={1, 1, 2, 2, 3, 3, 4}},
    {from = 41, to = 52, size =  4.0, usedSlots=1, multiByRarity={1, 2, 2, 3, 3, 4, 5}},
}

scales[WeaponType.XCannon] = { --                                 P  C  UC R  X  XO L
    {from =  0, to =  8, size =  2.0, usedSlots=4, multiByRarity={1, 1, 1, 1, 2, 2, 2}},
    {from =  9, to = 16, size =  3.0, usedSlots=4, multiByRarity={1, 1, 1, 2, 2, 2, 3}},
    {from = 17, to = 24, size =  4.0, usedSlots=4, multiByRarity={1, 1, 2, 2, 2, 3, 3}},
    {from = 25, to = 34, size =  6.0, usedSlots=4, multiByRarity={1, 2, 2, 2, 3, 3, 4}},
    {from = 35, to = 46, size =  8.0, usedSlots=4, multiByRarity={2, 2, 2, 3, 3, 4, 4}},
    {from = 46, to = 52, size = 10.0, usedSlots=4, multiByRarity={2, 2, 3, 3, 4, 4, 5}},
}

scales[WeaponType.XMissile] = { --                                 P  C  UC R  X  XO L
    {from =  0, to = 16, size =  2.0, usedSlots=2, multiByRarity={ 2, 2, 3, 3, 4, 4, 4}},
    {from = 17, to = 32, size =  3.0, usedSlots=2, multiByRarity={ 4, 4, 6, 6, 8, 8, 8}},
    {from = 33, to = 46, size =  4.0, usedSlots=2, multiByRarity={ 8, 8,12,12,16,16,20}},
    {from = 46, to = 52, size =  5.0, usedSlots=2, multiByRarity={12,12,14,14,16,16,24}},
}

scales[WeaponType.XDisruptor] = { --                                   P     C     UC    R     X     XO    L
    {from =  0, to = 16, size =  2.0, usedSlots=3, shieldDmgByRarity={1.00, 1.25, 1.50, 2.00, 2.50, 3.00, 3.50}},
    {from = 17, to = 32, size =  3.0, usedSlots=3, shieldDmgByRarity={1.25, 1.50, 2.00, 2.50, 3.00, 3.50, 4.00}},
    {from = 33, to = 46, size =  4.0, usedSlots=3, shieldDmgByRarity={1.50, 2.00, 2.50, 3.00, 3.50, 4.00, 4.50}},
    {from = 46, to = 52, size =  5.0, usedSlots=3, shieldDmgByRarity={2.00, 2.50, 3.00, 3.50, 4.00, 4.50, 5.00}},
}

function TurretGenerator.scale(rand, turret, type, tech, turnSpeedFactor, coaxialPossible)
    if coaxialPossible == nil then coaxialPossible = true end -- avoid coaxialPossible = coaxialPossible or true, as it will set it to true if "false" is passed

    local scale, lvl = TurretGenerator.getScale(type, tech)

    turret.coaxial = coaxialPossible

    turret.size = scale.size
    turret.slots = scale.usedSlots
    turret.turningSpeed = turnSpeedFactor -- lerp(turret.size, 0.5, 10.0, 1.0, 0.1) *  turnSpeedFactor
    
    local weapons = {turret:getWeapons()}
    for _, weapon in pairs(weapons) do
        weapon.localPosition = weapon.localPosition * (2.0 * scale.size)
    end

    turret:clearWeapons()
    for _, weapon in pairs(weapons) do
        turret:addWeapon(weapon)
    end

    return lvl
end

local function xSetTurretGunners(turret, num)
    local crew = Crew()
    crew:add(num, CrewMan(CrewProfessionType.Gunner))
    turret.crew = crew
end

local function xSetTurretMiners(turret, num)
    local crew = Crew()
    crew:add(num, CrewMan(CrewProfessionType.Miner))
    turret.crew = crew
end

local xMiningSizeAdjectives = {}
xMiningSizeAdjectives[ 2] = "Small"
xMiningSizeAdjectives[ 3] = "Medium"
xMiningSizeAdjectives[ 4] = "Large"
xMiningSizeAdjectives[ 5] = "X-Large"

function TurretGenerator.generateXMining(rand, dps, tech, material, rarity, coaxialAllowed)
    local wtype = WeaponType.XMining
    local turret = TurretTemplate()
    local scale, lvl = TurretGenerator.getScale(wtype, tech)
    
    local r = rarity.value + 1 -- 0 to 6
    local m = material.value
    local barrels = scale.multiByRarity[r+1]
    
    xSetTurretMiners(turret, 1.0 + math.ceil(0.5 * scale.size * barrels))
    
    -- generate weapons
    local weapon = WeaponGenerator.generateXMining(rand, dps, tech, material, rarity)
    WeaponGenerator.adaptXMining(weapon, barrels, scale.size)
    TurretGenerator.attachWeapons(rand, turret, weapon, barrels)
    
    local percentage = math.floor(weapon.stoneDamageMultiplier * 100)
    turret:addDescription("%s%% Damage to Stone"%_T, string.format("%+i", percentage))
    
    --local shootingTime = (math.sqrt(barrels) + 5.0) / math.sqrt(barrels) -- 6, 4.94, 4.6, 4.5, 4.4
    --local coolingTime = 1.0 * barrels
    --TurretGenerator.createStandardCooling(turret, coolingTime, shootingTime)
    
    TurretGenerator.scale(1.0, turret, wtype, tech, 1.0, false)
    turret.slotType = TurretSlotType.Unarmed
    turret:updateStaticStats()

    local name = xMiningSizeAdjectives[scale.size] .. " " .. "Harvesting Laser  /* weapon name */"%_T
    turret.title = xMakeTitle(turret, wtype, scale.size, tech, name)
    return turret
end

local xGunCaliberAdjectives = {}
xGunCaliberAdjectives[ 1] = "20mm"
xGunCaliberAdjectives[ 2] = "32mm"
xGunCaliberAdjectives[ 3] = "45mm"
xGunCaliberAdjectives[ 4] = "60mm"

function TurretGenerator.generateXGun(rand, dps, tech, material, rarity, coaxialAllowed)
    local wtype = WeaponType.XGun
    local turret = TurretTemplate()
    local scale, lvl = TurretGenerator.getScale(wtype, tech)
    
    local r = rarity.value + 1 -- 0 to 6
    local m = material.value
    local barrels = scale.multiByRarity[r+1]
    
    xSetTurretGunners(turret, math.ceil(0.5 * scale.size * barrels))

    dps = 2.0 * dps -- spends about half the time cooling
    
    -- generate weapons
    local weapon = WeaponGenerator.generateXGun(rand, dps, tech, material, rarity)
    WeaponGenerator.adaptXGun(weapon, barrels, scale.size)
    TurretGenerator.attachWeapons(rand, turret, weapon, barrels)
    
    local shootingTime = 3.0 * math.pow(0.95, barrels - 1)
    local coolingTime = 3.0 * math.pow(1.1, scale.size)
    TurretGenerator.createStandardCooling(turret, coolingTime, shootingTime)
    
    TurretGenerator.scale(1.0, turret, wtype, tech, 1.0, true)
    turret.slotType = TurretSlotType.Armed
    turret:updateStaticStats()

    local name = xGunCaliberAdjectives[scale.size] .. " " .. "Autocannon  /* weapon name */"%_T
    turret.title = xMakeTitle(turret, wtype, scale.size, tech, name)
    return turret
end

local xCannonCaliberAdjectives = {}
xCannonCaliberAdjectives[ 2] = "3.9\""
xCannonCaliberAdjectives[ 3] = "5.25\""
xCannonCaliberAdjectives[ 4] = "7.5\""
xCannonCaliberAdjectives[ 6] = "12\""
xCannonCaliberAdjectives[ 8] = "16\""
xCannonCaliberAdjectives[10] = "20\""

function TurretGenerator.generateXCannon(rand, dps, tech, material, rarity, coaxialAllowed)
    local wtype = WeaponType.XCannon
    local turret = TurretTemplate()
    local scale, lvl = TurretGenerator.getScale(wtype, tech)
    
    local r = rarity.value + 1 -- 0 to 6
    local m = material.value
    local barrels = scale.multiByRarity[r+1]
    
    xSetTurretGunners(turret, (2.0 * scale.size) + barrels)
    dps = dps * 12.5 -- due to single shot with long time spent cooling
    
    -- generate weapons
    local weapon = WeaponGenerator.generateXCannon(rand, dps, tech, material, rarity)
    WeaponGenerator.adaptXCannon(weapon, barrels, scale.size)
    TurretGenerator.attachWeapons(rand, turret, weapon, barrels)
    
    local shootingTime = (1.0 / barrels) - 0.01 -- needs -0.01 to prevent unwanted additional shot
    local coolingTime = 1.5 + (0.5 * math.pow(1.1, scale.size) * math.pow(1.5, barrels - 1)) * math.pow(0.95, r)
    TurretGenerator.createStandardCooling(turret, coolingTime, shootingTime)

    local turnspeed = 0.5 * math.pow(0.95, barrels - 1) * math.pow(0.95, scale.size)
    TurretGenerator.scale(1.0, turret, wtype, tech, turnspeed, false)
    turret.slotType = TurretSlotType.Armed
    turret:updateStaticStats()

    local name = xCannonCaliberAdjectives[scale.size] .. " " .. "Artillery  /* weapon name */"%_T
    turret.title = xMakeTitle(turret, wtype, scale.size, tech, name)
    return turret
end

local xMissileAdjectives = {}
xMissileAdjectives[ 2] = "2x"
xMissileAdjectives[ 3] = "3x"
xMissileAdjectives[ 4] = "4x"
xMissileAdjectives[ 6] = "6x"
xMissileAdjectives[ 8] = "8x"
xMissileAdjectives[12] = "12x"
xMissileAdjectives[12] = "14x"
xMissileAdjectives[16] = "16x"
xMissileAdjectives[20] = "20x"
xMissileAdjectives[24] = "Superlaunching"

function TurretGenerator.generateXMissile(rand, dps, tech, material, rarity, coaxialAllowed)
    local wtype = WeaponType.XMissile
    local turret = TurretTemplate()
    local scale, lvl = TurretGenerator.getScale(wtype, tech)
    local r = rarity.value + 1 -- 0 to 6
    local m = material.value
    local barrels = scale.multiByRarity[r+1] -- silos
    
    xSetTurretGunners(turret, scale.size + barrels)
    dps = dps * 15.0 -- due to long time spent cooling and no damage bonus due to size

    -- generate weapons    
    local weapon = WeaponGenerator.generateXMissile(rand, dps, tech, material, rarity)
    WeaponGenerator.adaptXMissile(weapon, barrels, scale.size)
    TurretGenerator.attachWeapons(rand, turret, weapon, 1)
    
    local shootingTime = weapon.fireDelay * barrels
    local coolingTime = 5.0 + (0.5 * scale.size * math.pow(1.1, barrels))
    TurretGenerator.createStandardCooling(turret, coolingTime, shootingTime)
    
    TurretGenerator.scale(1.0, turret, wtype, tech, 1.0, true)
    turret.slotType = TurretSlotType.Armed
    turret:updateStaticStats()

    local name = xMissileAdjectives[barrels] .. " " .. "Micro-Missile Launcher  /* weapon name */"%_T
    turret.title = xMakeTitle(turret, wtype, scale.size, tech, name)
    return turret
end


local xDisruptorAdjectives = {}
xDisruptorAdjectives[0] = "20 MegaKelvin"
xDisruptorAdjectives[1] = "25 MegaKelvin"
xDisruptorAdjectives[2] = "30 MegaKelvin"
xDisruptorAdjectives[3] = "40 MegaKelvin"
xDisruptorAdjectives[4] = "50 MegaKelvin"
xDisruptorAdjectives[5] = "60 MegaKelvin"
xDisruptorAdjectives[6] = "70 MegaKelvin"
xDisruptorAdjectives[7] = "80 MegaKelvin"
xDisruptorAdjectives[8] = "90 MegaKelvin"
xDisruptorAdjectives[9] = "100 MegaKelvin"

function TurretGenerator.generateXDisruptor(rand, dps, tech, material, rarity, coaxialAllowed)
    local wtype = WeaponType.XDisruptor
    local turret = TurretTemplate()
    local scale, lvl = TurretGenerator.getScale(wtype, tech)
    
    local r = rarity.value + 1 -- 0 to 6
    local m = material.value
    local shieldDmg = scale.shieldDmgByRarity[r+1]
    
    xSetTurretGunners(turret, math.floor(scale.size * shieldDmg))

    dps = 6.0 * dps -- spends about 5x the time cooling
    
    -- generate weapons
    local weapon = WeaponGenerator.generateXDisruptor(rand, dps, tech, material, rarity)
    WeaponGenerator.adaptXDisruptor(weapon, shieldDmg, scale.size)
    TurretGenerator.attachWeapons(rand, turret, weapon, 1.0)
    
    local shootingTime = (weapon.fireDelay * 4.0)
    local coolingTime = 5.0 * math.pow(1.1, scale.size-2) * math.pow(0.975, m) * math.pow(0.975, r)
    TurretGenerator.createStandardCooling(turret, coolingTime, shootingTime)
    
    TurretGenerator.scale(1.0, turret, wtype, tech, 1.0, true)
    turret.slotType = TurretSlotType.Armed
    turret:updateStaticStats()

    local name = xDisruptorAdjectives[r + scale.size - 2] .. " " .."Disruptor  /* weapon name */"%_T
    turret.title = xMakeTitle(turret, wtype, scale.size, tech, name)
    return turret
end

generatorFunction[WeaponType.XMining]    = TurretGenerator.generateXMining
generatorFunction[WeaponType.XGun]       = TurretGenerator.generateXGun
generatorFunction[WeaponType.XCannon]    = TurretGenerator.generateXCannon
generatorFunction[WeaponType.XMissile]   = TurretGenerator.generateXMissile
generatorFunction[WeaponType.XDisruptor] = TurretGenerator.generateXDisruptor

