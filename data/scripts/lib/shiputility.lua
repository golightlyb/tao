local AttackWeapons =
{
    WeaponType.XGun,
    WeaponType.XMissile
}
ShipUtility.AttackWeapons = AttackWeapons

--[[
local DefenseWeapons =
{
    WeaponType.PointDefenseChainGun,
    WeaponType.PointDefenseLaser,
    WeaponType.AntiFighter,
}
ShipUtility.DefenseWeapons = DefenseWeapons
--]]

local AntiShieldWeapons =
{
    WeaponType.XDisruptor
}
ShipUtility.AntiShieldWeapons = AntiShieldWeapons

local AntiHullWeapons =
{
    WeaponType.XCannon
}
ShipUtility.AntiHullWeapons = AntiHullWeapons

local ArtilleryWeapons =
{
    WeaponType.XCannon
}
ShipUtility.ArtilleryWeapons = ArtilleryWeapons

-- weapons that can have their range increased a lot without looking too strange
local LongRangeWeapons =
{
    WeaponType.XCannon,
    WeaponType.XMissile
}
ShipUtility.LongRangeWeapons = LongRangeWeapons

function ShipUtility.addTurretsToCraft(entity, turret, numTurrets, maxNumTurrets)

    local maxNumTurrets = maxNumTurrets or 6
    if maxNumTurrets == 0 then return end

    turret = copy(turret)
    -- turret.coaxial = false -- this can lead to the turret's name still containing "Coax", so make sure to only pass non-coaxial turrets!

    local wantedTurrets = math.max(1, round(numTurrets / turret.slots))
    local values = {entity:getTurretPositionsLineOfSight(turret, numTurrets)}

    local c = 1;
    numTurrets = tablelength(values) / 2 -- divide by 2 since getTurretPositions returns 2 values per turret

    -- limit the turrets of the ships to maxNumTurrets
    numTurrets = math.min(numTurrets, maxNumTurrets)

    local strengthFactor = wantedTurrets / numTurrets
    if numTurrets > 0 and strengthFactor > 1.0 then
        entity.damageMultiplier = math.max(entity.damageMultiplier, strengthFactor)
    end

    for i = 1, numTurrets do
        local position = values[c]; c = c + 1;
        local part = values[c]; c = c + 1;

        if part ~= nil then
            entity:addTurret(turret, position, part)
        end
    end
end

function ShipUtility.addCIWSEquipment(craft)
    ShipUtility.addSpecializedEquipment(craft, {WeaponType.XGun}, nil, 0.5) -- TODO
    ShipUtility.addSpecializedEquipment(craft, {WeaponType.XGun}, nil, 0.5)

    craft:setTitle("${toughness}CIWS ${class}"%_T, {toughness = "", class = ShipUtility.getMilitaryNameByVolume(craft.volume)})
    craft:setValue("is_armed", true)

    craft:addScript("icon.lua", "data/textures/icons/pixel/anti-carrier.png")
end

function ShipUtility.addAntiTorpedoEquipment(craft)
    ShipUtility.addSpecializedEquipment(craft, {WeaponType.XMissile}, nil, 1.0)

    craft:setValue("is_armed", true)
end

function ShipUtility.addBossAntiTorpedoEquipment(craft, numTurrets, color, reach)
    numTurrets = numTurrets or 4

    local x, y = Sector():getCoordinates()
    local generator = SectorTurretGenerator()
    generator.coaxialAllowed = false
    local turret = generator:generate(x, y, -30, Rarity(RarityType.Exceptional), WeaponType.XMissile) -- TODO
    local weapons = {turret:getWeapons()}
    turret:clearWeapons()
    for _, weapon in pairs(weapons) do
        turret:addWeapon(weapon)
    end
    turret.crew = Crew()
    ShipUtility.addTurretsToCraft(craft, turret, numTurrets, numTurrets)
end

function ShipUtility.addBossAntiFighterEquipment(craft, numTurrets, color, reach)
    return ShipUtility.addAntiTorpedoEquipment(craft, numTurrets, color, reach)
end

function ShipUtility.addPersecutorEquipment(craft)
    local weaponTypes = AttackWeapons
    local torpedoTypes = PersecutorTorpedoes

    ShipUtility.addSpecializedEquipment(craft, weaponTypes, torpedoTypes, 1.5, 1)

    local launcher = TorpedoLauncher(craft)
    if launcher.numTorpedoes == 0 then
        ShipUtility.addSpecializedEquipment(craft, nil, {TorpedoUtility.WarheadType.Nuclear}, 0, 1) -- TODO
    end

    craft:setTitle("${toughness}Persecutor ${class}"%_T, {toughness = "", class = ShipUtility.getMilitaryNameByVolume(craft.volume)})
    craft:setValue("is_armed", true)

    craft:addScript("icon.lua", "data/textures/icons/pixel/persecutor.png")
end

function ShipUtility.addFlagShipEquipment(craft)
    local weaponTypes = AttackWeapons
    local torpedoTypes = PersecutorTorpedoes

    ShipUtility.addSpecializedEquipment(craft, {WeaponType.XMissile, WeaponType.XCannon}, nil, 1, nil) -- TODO
    ShipUtility.addSpecializedEquipment(craft, weaponTypes, torpedoTypes, 3, 1)

    craft:setTitle("${toughness}Flagship"%_T, {toughness = ""})
    craft:setValue("is_armed", true)

    craft:addScript("icon.lua", "data/textures/icons/pixel/flagship.png")
end

function ShipUtility.addCarrierEquipment(craft, fighters)
    craft:setTitle("${toughness}Carrier ${class}"%_T, {toughness = "", class = ShipUtility.getMilitaryNameByVolume(craft.volume)})
    craft:setValue("is_armed", true)
    craft:addScript("icon.lua", "data/textures/icons/pixel/carrier.png")
end

function ShipUtility.addSpecializedEquipment(craft, weaponTypes, torpedoTypes, turretfactor, torpedofactor, turretRange)

    turretfactor = turretfactor or 1
    torpedofactor = torpedofactor or 0
    weaponTypes = weaponTypes or {}
    torpedoTypes = torpedoTypes or {}

    local faction = Faction(craft.factionIndex)
    local x, y

    -- let the torpedo and turret generator seeds be based on the home sector of a faction
    -- this makes sure that factions always have the same kinds of weapons
    if faction then
        x, y = faction:getHomeSectorCoordinates()
    else
        x, y = Sector():getCoordinates()
    end

    local seed = SectorSeed(x, y)

    if #weaponTypes > 0 and turretfactor > 0 then
        local turrets = Balancing_GetEnemySectorTurrets(Sector():getCoordinates()) * turretfactor + 2

        -- select a weapon out of the weapon types that can be used in this sector
        local weaponProbabilities = Balancing_GetWeaponProbability(x, y)
        local tmp = weaponTypes
        weaponTypes = {}

        for _, type in pairs(tmp) do
            if weaponProbabilities[type] and weaponProbabilities[type] > 0 then
                table.insert(weaponTypes, type)
            end
        end

        local weaponType = randomEntry(random(), weaponTypes)

        -- equip turrets
        local generator = SectorTurretGenerator(seed)
        generator.maxRarity = Rarity(RarityType.Rare)
        generator.coaxialAllowed = false

        local rarity = generator.maxRarity -- TODO

        if weaponType then
            local turret = generator:generate(x, y, 0, rarity, weaponType)

            if turretRange then
                turret:setRange(turretRange)
            end

            ShipUtility.addTurretsToCraft(craft, turret, turrets)
        end
    end

    if #torpedoTypes > 0 and torpedofactor > 0 then
        local torpedoes = Balancing_GetEnemySectorTurrets(Sector():getCoordinates()) * torpedofactor + 1

        -- select a torpedo out of the torpedo types that can be used in this sector
        local generator = TorpedoGenerator(seed)
        local torpedoProbabilities = generator:getWarheadProbability(x, y)
        local tmp = torpedoTypes
        torpedoTypes = {}

        for _, type in pairs(tmp) do
            if torpedoProbabilities[type] and torpedoProbabilities[type] > 0 then
                table.insert(torpedoTypes, type)
            end
        end

        if #torpedoTypes > 0 then
            local torpedoType = randomEntry(random(), torpedoTypes)

            -- equip torpedoes
            local torpedo = generator:generate(x, y, 0, nil, torpedoType, nil)
            ShipUtility.addTorpedoesToCraft(craft, torpedo, torpedoes)
        end
    end
end
