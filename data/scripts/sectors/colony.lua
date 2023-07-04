
-- this function returns what relevant contents there will be in the sector (exact)
function SectorTemplate.contents(x, y)
    local seed = Seed(string.join({GameSeed(), x, y, "colony"}, "-"))
    math.randomseed(seed);

    local random = random()

    local contents = {ships = 0, stations = 0, seed = tostring(seed)}

    contents.shipyards              = 0
    contents.resourceDepots         = 0
    contents.repairDocks            = 0
    contents.equipmentDocks         = 0
    contents.factories              = 0
    contents.tradingPosts           = 0
    contents.turretFactories        = 0
    contents.turretFactorySuppliers = 0
    contents.fighterFactories       = 0
    contents.neighborTradingPosts   = 0
    contents.headquarters           = 0
    contents.casinos                = 0
    contents.biotopes               = 0
    contents.habitats               = 0
    contents.researchStations       = 0
    contents.travelHubs             = 0
    contents.militaryOutposts       = 0

    local sx = x + random:getInt(-15, 15)
    local sy = y + random:getInt(-15, 15)

    local faction, otherFaction
    if onServer() then
        faction = Galaxy():getLocalFaction(x, y) or Galaxy():getNearestFaction(x, y)

        otherFaction = Galaxy():getNearestFaction(sx, sy)
        if faction:getRelations(otherFaction.index) < -20000 then otherFaction = nil end

        -- create headquarters
        local hx, hy = faction:getHomeSectorCoordinates()

        if hx == x and hy == y then
            --contents.headquarters = 1
        end
    end
    
    local defendersFactor
    if Galaxy():isCentralFactionArea(x, y) then
        defendersFactor = 1.5
    else
        defendersFactor = 0.75
    end

    contents.defenders  = round(6 * defendersFactor)
    contents.ships      = contents.defenders
    contents.stations   = 0

    if onServer() then
        contents.faction = faction.index

        if otherFaction then
            contents.neighbor = otherFaction.index
        end
    end

    local generator = SectorGenerator(x, y)
    contents.asteroidEstimation = generator:estimateAsteroidNumbers(1, 2.5)

    return contents, random, faction, otherFaction
end

-- player is the player who triggered the creation of the sector (only set in start sector, otherwise nil)
function SectorTemplate.generate(player, seed, x, y)
    local contents, random, faction, otherFaction = SectorTemplate.contents(x, y)

    local generator = SectorGenerator(x, y)

    -- create stations
    --generator:createShipyard(faction);
    --generator:createStation(faction, "data/scripts/entity/merchants/resourcetrader.lua");
    --generator:createRepairDock(faction);

    -- create several factories
    -- local productions = FactoryPredictor.generateFactoryProductions(x, y, 3, false)

    local containerStations = {}
    for _, production in pairs(productions) do
        --local station = generator:createStation(faction, "data/scripts/entity/merchants/factory.lua", production);
        --table.insert(containerStations, station)
    end

    -- maybe create some asteroids
    local numFields = random:getInt(0, 1)
    for i = 1, numFields do
        local pos = generator:createEmptyAsteroidField();
        if random:test(0.4) then generator:createEmptyBigAsteroid(pos) end
    end

    numFields = random:getInt(0, 1)
    for i = 1, numFields do
        local pos = generator:createAsteroidField();
        if random:test(0.4) then generator:createBigAsteroid(pos) end
    end

    -- create defenders
    for i = 1, contents.defenders do
        ShipGenerator.createDefender(faction, generator:getPositionInSector())
    end

    local numSmallFields = random:getInt(0, 5)
    for i = 1, numSmallFields do
        generator:createSmallAsteroidField()
    end

    if SectorTemplate.gates(x, y) then generator:createGates() end

    if random:test(generator:getWormHoleProbability()) then generator:createRandomWormHole() end

    Sector():addScriptOnce("data/scripts/sector/eventscheduler.lua", "events/pirateattack.lua")

    generator:addAmbientEvents()
    Placer.resolveIntersections()
end
