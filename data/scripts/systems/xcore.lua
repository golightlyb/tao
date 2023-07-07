package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
PermanentInstallationOnly = true
Unique = true

function getBonuses(seed, rarity, permanent)
    local bonuses = {}
    if parmanent == false then return bonuses end
    local r = rarity.value + 1 -- 0 to 6

    bonuses[StatsBonuses.HyperspaceReach]          =  4.0 + ( 2.00 * r) -- absolute from 4 to  16
    bonuses[StatsBonuses.HyperspaceCooldown]       = 10.0 + (12.50 * r) -- percent from 10 to  85%
    bonuses[StatsBonuses.ScannerReach]             =  0.0 + (50.00 * r) -- percent from  0 to 300
    bonuses[StatsBonuses.RadarReach]               =  4.0 + ( 2.00 * r) -- absolute diameter from 4 to 17
    bonuses[StatsBonuses.HiddenSectorRadarReach]   =  2.0 + ( 0.25 * r) -- absolute diameter from 2 to 3.5
    bonuses[StatsBonuses.LootCollectionRange]      = (0.5 + ( 1.00 * r)) * 1000 -- absolute range in metres from 0.5km to 6.5km
    bonuses[StatsBonuses.TransporterRange]         = (0.5 + ( 1.00 * r)) * 1000 -- absolute range in metres from 0.5km to 6.5km
    bonuses[StatsBonuses.CargoHold]                = 1000.0 -- absolute
    bonuses[StatsBonuses.ArmedTurrets]             =  7.0 + ( 2.00 * r) -- absolute from 7 to 19 (+1 arbitrary)
    bonuses[StatsBonuses.UnarmedTurrets]           =  2.0 + ( 1.00 * r) -- absolute from 2 to 8
    bonuses[StatsBonuses.PointDefenseTurrets]      =  2.0 + ( 1.00 * r) -- absolute from 2 to 8
    bonuses[StatsBonuses.AutomaticTurrets]         = 1000
    bonuses[StatsBonuses.DefenseWeapons]           = math.pow(2, 2 + r) -- absolute number 4, 8, ..., 256

    return bonuses
end

function onInstalled(seed, rarity, permanent)
    local bonuses = getBonuses(seed, rarity, permanent)

    addAbsoluteBias  (StatsBonuses.HyperspaceReach,         bonuses[StatsBonuses.HyperspaceReach])
    addBaseMultiplier(StatsBonuses.HyperspaceCooldown,     -bonuses[StatsBonuses.HyperspaceCooldown]*0.01) -- from percent
    addBaseMultiplier(StatsBonuses.ScannerReach,            bonuses[StatsBonuses.ScannerReach]*0.01) -- from percent
    addAbsoluteBias  (StatsBonuses.RadarReach,              bonuses[StatsBonuses.RadarReach])
    addAbsoluteBias  (StatsBonuses.HiddenSectorRadarReach,  bonuses[StatsBonuses.HiddenSectorRadarReach])
    addAbsoluteBias  (StatsBonuses.LootCollectionRange,     bonuses[StatsBonuses.LootCollectionRange]*0.1) -- metres to units
    addAbsoluteBias  (StatsBonuses.TransporterRange,        bonuses[StatsBonuses.TransporterRange]*0.1) -- metres to units
    addAbsoluteBias  (StatsBonuses.CargoHold,               bonuses[StatsBonuses.CargoHold])
    addAbsoluteBias  (StatsBonuses.ArmedTurrets,            bonuses[StatsBonuses.ArmedTurrets])
    addAbsoluteBias  (StatsBonuses.UnarmedTurrets,          bonuses[StatsBonuses.UnarmedTurrets])
    addAbsoluteBias  (StatsBonuses.PointDefenseTurrets,     bonuses[StatsBonuses.PointDefenseTurrets])
    addAbsoluteBias  (StatsBonuses.AutomaticTurrets,        bonuses[StatsBonuses.AutomaticTurrets])
    addAbsoluteBias  (StatsBonuses.DefenseWeapons,          bonuses[StatsBonuses.DefenseWeapons])
end

function onUninstalled(seed, rarity, permanent)
end

function getName(seed, rarity)
    return "XCore MK ${mark} /* ex: XCore MK IV */"%_t % {mark = toRomanLiterals(rarity.value + 2)}
end

function getBasicName()
    return "XCore"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/nanobot-wiring.png"
end

function getEnergy(seed, rarity, permanent)
    return 0
end

function getPrice(seed, rarity)
    local r = rarity.value + 1 -- 0 to 6
    return 15625 * math.pow(4, r)
        
    -- 250,000 * 4^r
    -- petty:       c     15,625
    -- common:      c     62,500
    -- uncommon:    c    250,000
    -- rare:        c  1,000,000
    -- exceptional: c  4,000,000
    -- exotic:      c 16,000,000
    -- legendary:   c 64,000,000
end

function getDescriptionLines(seed, rarity, permanent)
    local texts = {}
    table.insert(texts, {ltext = "The heart of every ship!"%_t})
    return texts
end

function both(targets, permanent, tooltip)
    table.insert(targets.bonuses, tooltip)
    if permanent then
      table.insert(targets.texts, tooltip)
    end
end

function getTooltipLines(seed, rarity, permanent)
    local tables = {texts={}, bonuses={}}

    local bonus = getBonuses(seed, rarity, permanent)

    both(tables, permanent, {
        ltext = "Jump Range"%_t,
        rtext = string.format("%+g", bonus[StatsBonuses.HyperspaceReach]),
        icon = "data/textures/icons/star-cycle.png",
        boosted = permanent
    })
    both(tables, permanent, {
        ltext = "Jump Cooldown"%_t,
        rtext = string.format("%+g%%", -bonus[StatsBonuses.HyperspaceCooldown]),
        icon = "data/textures/icons/star-cycle.png",
        boosted = permanent
    })
    both(tables, permanent, {
        ltext = "Scanner Range"%_t,
        rtext = string.format("%+g%%", bonus[StatsBonuses.ScannerReach]),
        icon = "data/textures/icons/signal-range.png",
        boosted = permanent
    })
    both(tables, permanent, {
        ltext = "Radar Range"%_t,
        rtext = string.format("%+g sectors", bonus[StatsBonuses.RadarReach]),
        icon = "data/textures/icons/radar-sweep.png",
        boosted = permanent
    })
    both(tables, permanent, {
        ltext = "Deep Scan Range"%_t,
        rtext = string.format("%+g sectors", bonus[StatsBonuses.HiddenSectorRadarReach]),
        icon = "data/textures/icons/radar-sweep.png",
        boosted = permanent
    })
    both(tables, permanent, {
        ltext = "Loot Collection Range"%_t,
        rtext = string.format("%+gkm", 0.001 * bonus[StatsBonuses.LootCollectionRange]),
        icon = "data/textures/icons/radar-sweep.png",
        boosted = permanent
    })
    both(tables, permanent, {
        ltext = "Transporter Range"%_t,
        rtext = string.format("%+gkm", 0.001 * bonus[StatsBonuses.TransporterRange]),
        icon = "data/textures/icons/solar-system.png",
        boosted = permanent
    })
    both(tables, permanent, {
        ltext = "Cargo Hold"%_t,
        rtext = string.format("%+i", bonus[StatsBonuses.CargoHold]),
        icon = "data/textures/icons/crate.png",
        boosted = permanent
    })
    both(tables, permanent, {
        ltext = "Unarmed Turret Slots"%_t,
        rtext = string.format("%+i", bonus[StatsBonuses.UnarmedTurrets]),
        icon = "data/textures/icons/turret.png",
        boosted = permanent
    })
    both(tables, permanent, {
        ltext = "Armed Turret Slots"%_t,
        rtext = string.format("%+i", bonus[StatsBonuses.ArmedTurrets]),
        icon = "data/textures/icons/turret.png",
        boosted = permanent
    })
    both(tables, permanent, {
        ltext = "Defensive Turret Slots"%_t,
        rtext = string.format("%+i", bonus[StatsBonuses.PointDefenseTurrets]),
        icon = "data/textures/icons/turret.png",
        boosted = permanent
    })
    both(tables, permanent, {
        ltext = "Internal Defense Weapons"%_t,
        rtext = string.format("%+i", bonus[StatsBonuses.DefenseWeapons]),
        icon = "data/textures/icons/shotgun.png",
        boosted = permanent
    })
    return tables.texts, tables.bonuses
end
