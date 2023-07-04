-- this function returns what relevant contents there will be in the sector (exact)
function SectorTemplate.contents(x, y)
    local seed = Seed(string.join({GameSeed(), x, y, "factoryfield"}, "-"))
    math.randomseed(seed);

    local random = random()

    local contents = {ships = 0, stations = 0, seed = tostring(seed)}
    contents.factories = random:getInt(5, 6)

    local sx = x + random:getInt(-15, 15)
    local sy = y + random:getInt(-15, 15)

    local faction, otherFaction
    if onServer() then
        faction = Galaxy():getLocalFaction(x, y) or Galaxy():getNearestFaction(x, y)

        otherFaction = Galaxy():getNearestFaction(sx, sy)
        if not valid(faction) or not valid(otherFaction) then return end
        if faction:getRelations(otherFaction.index) < -20000 then otherFaction = nil end
    end

    -- create a trader from maybe another faction

    -- create defenders
    local defendersFactor
    if Galaxy():isCentralFactionArea(x, y) then
        defendersFactor = 1.5
    else
        defendersFactor = 0.75
    end

    contents.defenders = round(6 * defendersFactor)

    contents.ships      = contents.defenders
    contents.stations   = contents.factories

    if onServer() then
        contents.faction = faction.index

        if otherFaction then
            contents.neighbor = otherFaction.index
        end
    end

    local generator = SectorGenerator(x, y)
    contents.asteroidEstimation = generator:estimateAsteroidNumbers(2, 2.5)

    return contents, random, faction, otherFaction
end

-- player is the player who triggered the creation of the sector (only set in start sector, otherwise nil)
function SectorTemplate.generate(player, seed, x, y)
    local contents, random, faction, otherFaction = SectorTemplate.contents(x, y)

    local generator = SectorGenerator(x, y)

    -- create a trading post
    --if contents.tradingPosts then
    --    generator:createStation(faction, "data/scripts/entity/merchants/tradingpost.lua");
    --end

    -- create several factories
    local productions = FactoryPredictor.generateFactoryProductions(x, y, contents.factories, false)
    -- create defenders
    for i = 1, contents.defenders do
        ShipGenerator.createDefender(faction, generator:getPositionInSector())
    end

    -- maybe create some asteroids
    local numFields = random:getInt(0, 2)
    for i = 1, numFields do
        generator:createEmptyAsteroidField();
    end

    numFields = random:getInt(0, 2)
    for i = 1, numFields do
        generator:createAsteroidField();
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
