
function WeaponGenerator.generateXMining(rand, dps, tech, material, rarity)
    local r = rarity.value + 1 -- 0 to 6
    local m = material.value
    local weapon = Weapon()
    weapon:setBeam()

    --weapon.smaterial = material
    weapon.continuousBeam = true
    weapon.fireDelay = 0.2
    weapon.damage = dps * weapon.fireDelay * 0.5
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.MiningLaser
    weapon.name = "XMining /* Weapon Name*/"%_T
    weapon.prefix = "XMining /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/mining-laser.png" -- previously mining.png
    weapon.sound = "mining"

    WeaponGenerator.XSetDamage(weapon, DamageType.Energy, 0, 1, 200, 0)
    weapon.stoneRefinedEfficiency = 0
    weapon.metalRefinedEfficiency = 0
    weapon.stoneRawEfficiency = 0
    weapon.metalRawEfficiency = 0
    --weapon.stoneRawEfficiency = 0.95 * math.pow(0.99, 6-r) * math.pow(0.99, 6-m)
    --weapon.metalRawEfficiency = 0.95 * math.pow(0.99, 6-r) * math.pow(0.99, 6-m)

    weapon.bshape = BeamShape.Straight
    weapon.bouterColor = ColorARGB(0.20, 0.00, 0.00, 0.00)
    weapon.binnerColor = ColorARGB(1.00, 0.00, 0.85, 1.00)
    weapon.bwidth = 1.0
    weapon.bauraWidth = 0.2
    weapon.banimationSpeed = 4

    -- base values adjusted by number of barrels and size later
    weapon.recoil       = 0.0
    weapon.accuracy     = 1.0
    weapon.reach        = 200.0 + (50 * m) -- 2km
    
    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

function WeaponGenerator.adaptXMining(weapon, barrels, size)
    
    -- recalculate reach / speed
    weapon.reach      = weapon.reach * math.pow(1.1, size)
    weapon.bwidth     = weapon.bwidth * math.pow(1.1, size)
    weapon.bauraWidth = weapon.bauraWidth * math.pow(1.1, size)
    
    -- recalculate weapon damage.
    weapon.damage = weapon.damage * math.pow(1.15, size)
end

function WeaponGenerator.generateXGun(rand, dps, tech, material, rarity)
    local r = rarity.value + 1 -- 0 to 6
    local m = material.value
    local weapon = Weapon()
    weapon:setProjectile()

    weapon.fireDelay = 0.3 * math.pow(0.99, (m+m+r)/3.0)
    weapon.fireRate = 1.0 / weapon.fireDelay
    weapon.damage = dps * 0.3 -- x firedelay (unadjusted)
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.ChainGun
    weapon.name = "XGun /* Weapon Name*/"%_T
    weapon.prefix = "XGun /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/chaingun.png" -- previously minigun.png
    weapon.sound = "pd-chaingun"

    weapon.impactParticles = ImpactParticles.Physical
    weapon.impactSound = 1
    weapon.impactExplosion = false
    WeaponGenerator.XSetDamage(weapon, DamageType.Physical, 1, 1, 1, 0)

    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(200, 0.26, 1)

    -- base values adjusted by number of barrels and size later
    weapon.psize        = 0.05
    weapon.shotsFired   = 1
    weapon.recoil       = 100.0
    weapon.accuracy     = 0.975 * math.pow(0.995, 6-r)
    weapon.reach        = 300.0 * math.pow(1.05, m) -- 3km
    weapon.pvelocity    = 300.0 * math.pow(1.05, r)
    weapon.pmaximumTime = weapon.reach / weapon.pvelocity
    
    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

function WeaponGenerator.adaptXGun(weapon, barrels, size)

    -- a bigger gun is more accurate
    weapon.accuracy = weapon.accuracy * math.pow(0.995, 4-math.max(size, 4))
    
    -- but gun with more barrels is slightly less accurate
    weapon.accuracy = weapon.accuracy * math.pow(0.995, (barrels - 1)) -- x1, x0.995, x0.990025, x0.985074875
    
    -- normalise fireDelay regardless of no. of barrels
    weapon.fireDelay       = weapon.fireDelay * barrels
    
    -- then, a gun with more barrels shoots a bit faster (but not linearly)
     -- delay x1.0, x0.7, x0.49, 0.2401 instead of x0.5, 0.25, 0.125
    weapon.fireDelay       = weapon.fireDelay * math.pow(0.7, barrels - 1)
    
    -- but a bigger gun shots a little bit slower
    weapon.fireDelay       = weapon.fireDelay * math.pow(1.1, size-1)
    weapon.fireRate        = 1.0 / weapon.fireDelay

    -- a bigger gun has bigger projectiles and recoil
    weapon.psize           = weapon.psize  * math.pow(1.2, size)
    weapon.recoil          = weapon.recoil * math.pow(1.2, size)
    
    -- recalculate reach / speed
    weapon.reach = weapon.reach * math.pow(1.1, size)
    weapon.pmaximumTime = weapon.reach / weapon.pvelocity
    
    -- recalculate weapon damage.
    weapon.damage = weapon.damage * math.pow(1.15, size)
end

function WeaponGenerator.generateXCannon(rand, dps, tech, material, rarity)
    local r = rarity.value + 1 -- 0 to 6
    local m = material.value
    local weapon = Weapon()
    weapon:setProjectile()
   
    weapon.damage = dps
    weapon.fireDelay = 1.0 -- controlled by cooling, not ROF
    weapon.fireRate  = 1.0 -- controlled by cooling, not ROF
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.Cannon
    weapon.name = "XCannon /* Weapon Name*/"%_T
    weapon.prefix = "XCannon /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/cannon.png"
    weapon.sound = "cannon"

    weapon.impactParticles = ImpactParticles.Explosion
    weapon.impactSound = 1
    weapon.impactExplosion = true
    WeaponGenerator.XSetDamage(weapon, DamageType.Physical, 1, 1.5, 1.5, 0)

    weapon.pcolor = ColorHSV(60, 0.7, 1)
    
    -- base values adjusted by number of barrels and size later
    weapon.psize           = 0.5
    weapon.shotsFired      = 1
    weapon.recoil          = 2000.0
    weapon.accuracy        = 0.99 * math.pow(0.995, 6-r)
    weapon.reach           = 1000.0  * math.pow(1.05, m)  * math.pow(1.03, r) -- 10km
    weapon.pvelocity       = 200.0 * math.pow(1.05, m) * math.pow(1.03, r)
    weapon.pmaximumTime    = weapon.reach / weapon.pvelocity
    weapon.explosionRadius = 1.5 * math.pow(1.1, m) -- 15m

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)
    
    return weapon
end

function WeaponGenerator.adaptXCannon(weapon, barrels, size)
    -- a cannon with more barrels shoots multiple shots at once
    weapon.shotsFired = weapon.shotsFired * barrels
    
    -- a bigger cannon is more accurate
    weapon.accuracy = weapon.accuracy * math.pow(0.995, 10-size)
    
    -- change the ROF for stats balancing (true ROF is controlled by cooling)
    weapon.fireRate  = 1.0 / barrels
    weapon.fireDelay = 1.0 / weapon.fireRate
    
    -- a bigger gun has bigger projectiles and recoil
    weapon.psize  = weapon.psize  * math.pow(1.2, size)
    weapon.recoil = weapon.recoil * math.pow(1.2, size)
    
    -- a bigger gun and better materials give a bigger explosion
    weapon.explosionRadius = weapon.explosionRadius * math.pow(1.2, math.min(size-2, 0))

    -- recalculate reach / speed
    weapon.reach = weapon.reach * math.pow(1.1, size)
    weapon.pmaximumTime = weapon.reach / weapon.pvelocity
    
    -- recalculate weapon damage
    weapon.damage = weapon.damage * math.pow(1.25, size)
end

function WeaponGenerator.generateXMissile(rand, dps, tech, material, rarity)
    local r = rarity.value + 1 -- 0 to 6
    local m = material.value
    local weapon = Weapon()
    weapon:setProjectile()

    weapon.fireDelay = 0.2
    weapon.fireRate = 1.0 / weapon.fireDelay
    weapon.damage = dps * 0.2 -- x firedelay (unadjusted)
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.RocketLauncher
    weapon.name = "XMissile /* Weapon Name*/"%_T
    weapon.prefix = "XMisile /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/rocket-launcher.png" -- previously minigun.png
    weapon.sound = "launcher"

    weapon.impactParticles = ImpactParticles.Explosion
    weapon.impactSound = 1
    weapon.impactExplosion = true
    WeaponGenerator.XSetDamage(weapon, DamageType.Physical, 1, 1, 0.5, 0)
    weapon.seeker = true

    weapon.pcolor = ColorHSV(239, 0.6, 1)

    -- base values adjusted by number of barrels and size later
    weapon.psize        = 1.0
    weapon.shotsFired   = 1
    weapon.recoil       = 500.0
    weapon.accuracy     = 0.7 -- seeker, but high to break up when coming out of silo
    weapon.reach        = 1000.0 + (100 * m) -- 10km plus 1km per material
    weapon.pvelocity    = 100.0
    weapon.pmaximumTime = weapon.reach / weapon.pvelocity
    
    local explosionRadiusMetres = 1.0 + (0.3 * r) + (0.2 * m)
    weapon.explosionRadius = 0.5 * math.pow(1.1, m) -- 5m
    
    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

function WeaponGenerator.adaptXMissile(weapon, barrels, size)
    -- a bigger missile launcher mostly fires for longer, rather than
    -- increasing damage
end

function WeaponGenerator.generateXDisruptor(rand, dps, tech, material, rarity)
    local r = rarity.value + 1 -- 0 to 6
    local m = material.value
    local weapon = Weapon()
    weapon:setProjectile()

    weapon.fireDelay = 0.15
    weapon.fireRate = 1.0 / weapon.fireDelay
    weapon.damage = dps * 0.25 -- x firedelay (unadjusted)
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.PlasmaGun
    weapon.name = "XDisruptor /* Weapon Name*/"%_T
    weapon.prefix = "XDisruptor /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/plasma-bolt.png" -- previously minigun.png
    weapon.sound = "ion-cannon"

    weapon.impactParticles = ImpactParticles.Energy
    WeaponGenerator.XSetDamage(weapon, DamageType.Plasma, 1.0, 0.5, 0, 0)
    weapon.impactSound = 1
    weapon.pshape = ProjectileShape.Plasma

    weapon.pcolor = ColorHSV(328, 1.0, 0.25)

    -- base values adjusted by number of barrels and size later
    weapon.psize        = 1.0
    weapon.shotsFired   = 1
    weapon.recoil       = 500.0
    weapon.accuracy     = 1.0
    weapon.reach        = 1000.0 + (100 * m) -- 10km plus 1km per material
    weapon.pvelocity    = 450.0 * math.pow(1.05, m) * math.pow(1.03, r)
    weapon.pmaximumTime = weapon.reach / weapon.pvelocity
    
    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

function WeaponGenerator.adaptXDisruptor(weapon, shieldDamageMultiplier, size)
    weapon.shieldDamageMultiplier = weapon.shieldDamageMultiplier * shieldDamageMultiplier

    -- a bigger gun has bigger projectiles and recoil
    weapon.psize  = weapon.psize  * math.pow(1.2, size)
    weapon.recoil = weapon.recoil * math.pow(1.2, size)

    -- recalculate reach / speed
    weapon.reach = weapon.reach * math.pow(1.1, size)
    weapon.pmaximumTime = weapon.reach / weapon.pvelocity
    
    -- recalculate weapon damage
    weapon.damage = weapon.damage * math.pow(1.25, size)
end

generatorFunction[WeaponType.XGun]       = WeaponGenerator.generateXGun
generatorFunction[WeaponType.XCannon]    = WeaponGenerator.generateXCannon
generatorFunction[WeaponType.XMissile]   = WeaponGenerator.generateXMissile
generatorFunction[WeaponType.XDisruptor] = WeaponGenerator.generateXDisruptor
generatorFunction[WeaponType.XMining]    = WeaponGenerator.generateXMining

function WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)
    local m = material.value
    local r = rarity.value + 1 -- 0 to 6
    local dpsFactor = math.pow(1.2, m) * math.pow(1.05, r)

    weapon.tech         = tech
    weapon.material     = material
    weapon.rarity       = rarity
    weapon.damage       = weapon.damage       * dpsFactor
    weapon.shieldRepair = weapon.shieldRepair * dpsFactor
    weapon.hullRepair   = weapon.hullRepair   * dpsFactor
end

function WeaponGenerator.XSetDamage(weapon, damageType, shield, hull, stone, shieldPenetration)
    weapon.damageType = damageType
    weapon.shieldDamageMultiplier = shield
    weapon.hullDamageMultiplier = hull
    weapon.stoneDamageMultiplier = stone
    weapon.shieldPenetration = shieldPenetration
end



