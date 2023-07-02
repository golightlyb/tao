

-- this function returns what relevant contents there will be in the sector (exact)
function SectorTemplate.contents(x, y)
    local seed = Seed(string.join({GameSeed(), x, y, "lonescrapyard"}, "-"))
    math.randomseed(seed);

    local random = random()

    local contents = {ships = 0, stations = 0, seed = tostring(seed)}

    local defendersFactor
    if Galaxy():isCentralFactionArea(x, y) then
        defendersFactor = 1.5
    else
        defendersFactor = 0.75
    end

    contents.defenders = round(3 * defendersFactor)
    contents.ships = contents.defenders
    contents.scrapyards = 1
    contents.stations   = 1

    local generator = SectorGenerator(x, y)
    contents.asteroidEstimation = generator:estimateAsteroidNumbers(0, 2)
    contents.wreckageEstimation = 25

    return contents, random
end

-- player is the player who triggered the creation of the sector (only set in start sector, otherwise nil)
function SectorTemplate.generate(player, seed, x, y)
    local contents, random = SectorTemplate.contents(x, y)

    local generator = SectorGenerator(x, y)

    local faction = Galaxy():getLocalFaction(x, y) or Galaxy():getNearestFaction(x, y)

    --for i = 0, random:getInt(200, 250) do
    for i = 0, random:getInt(20, 25) do
        generator:createWreckage(faction);
    end

    local numSmallFields = random:getInt(1, 3)
    for i = 1, numSmallFields do
        generator:createSmallAsteroidField()
    end

    -- create the scrapyard
    generator:createStation(faction, "data/scripts/entity/merchants/scrapyard.lua")
    -- TODO change this

    for i = 1, contents.defenders do
        ShipGenerator.createDefender(faction, generator:getPositionInSector())
    end

    if SectorTemplate.gates(x, y) then generator:createGates() end

    if random:test(generator:getWormHoleProbability()) then generator:createRandomWormHole() end

    Sector():addScriptOnce("data/scripts/sector/eventscheduler.lua", "events/pirateattack.lua")

    generator:addAmbientEvents()
    Placer.resolveIntersections()
end
