

TurretMerchant.specialOfferRarityFactors = {}
TurretMerchant.specialOfferRarityFactors[-1] = 0.00
TurretMerchant.specialOfferRarityFactors[ 0] = 0.00
TurretMerchant.specialOfferRarityFactors[ 1] = 0.00
TurretMerchant.specialOfferRarityFactors[ 2] = 1.00
TurretMerchant.specialOfferRarityFactors[ 3] = 0.50
TurretMerchant.specialOfferRarityFactors[ 4] = 0.25
TurretMerchant.specialOfferRarityFactors[ 5] = 0.00

local function xGenerateSpecific(generator, dest, x, y, r, n, t)
    local pair = {}
    pair.turret = InventoryTurret(generator:generate(x, y, nil, Rarity(r), t))
    pair.amount = n
    table.insert(dest, pair)
end

local function xGenerateAny(generator, dest, x, y, r, n)
    local pair = {}
    pair.turret = InventoryTurret(generator:generate(x, y, nil, Rarity(r)))
    pair.amount = n
    table.insert(dest, pair)
end

function TurretMerchant.shop:addItems()

    -- simply init with a 'random' seed
    local station = Entity()

    -- create all turrets
    local turrets = {}

    local x, y = Sector():getCoordinates()
    local generator = SectorTurretGenerator()
    -- SectorTurretGenerator:generate(x, y, offset_in, rarity_in, type_in, material_in)

    -- generate a few random rarer items
    if  math.random() < 0.1 then
        xGenerateAny(generator, turrets, x, y, 4, 1)
    end
    if  math.random() < 0.33 then
        xGenerateAny(generator, turrets, x, y, 3, 1)
    end
    
    for i = 1, getInt(1, 2) do
        xGenerateAny(generator, turrets, x, y, 2, 1)
    end
    
    for i = 1, getInt(1, 3) do
        xGenerateAny(generator, turrets, x, y, 1, 1)
    end
    
    -- always generate these common items...
    xGenerateSpecific(generator, turrets, x, y, 0, 4, WeaponType.XCannon)
    xGenerateSpecific(generator, turrets, x, y, 0, 4, WeaponType.XGun)
    xGenerateSpecific(generator, turrets, x, y, 0, 4, WeaponType.XMissile)
    xGenerateSpecific(generator, turrets, x, y, 0, 4, WeaponType.XMining)

    table.sort(turrets, comp)

    for _, pair in pairs(turrets) do
        TurretMerchant.shop:add(pair.turret, pair.amount)
    end
end

function TurretMerchant.shop:onSpecialOfferSeedChanged()
    local generator = SectorTurretGenerator(TurretMerchant.shop:generateSeed())

    local x, y = Sector():getCoordinates()
    local rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(rarities) do
        rarities[i] = rarity * TurretMerchant.specialOfferRarityFactors[i] -- or 1
    end

    generator.rarities = rarities

    local specialOfferTurret = InventoryTurret(generator:generate(x, y))
    TurretMerchant.shop:setSpecialOffer(specialOfferTurret)
end


