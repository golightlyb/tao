function SectorTemplate.contents(x, y)
    local seed = Seed(string.join({GameSeed(), x, y, "startsector"}, "-"))
    math.randomseed(seed);

    local random = random()
    local contents = {ships = 0, stations = 0, seed = tostring(seed)}

    contents.mines = 1
    contents.equipmentDocks = 1
    -- contents.resourceDepots = 1
    -- contents.shipyards = 1
    -- contents.repairDocks = 1

    contents.defenders = 2

    contents.ships = contents.defenders
    contents.stations = 2

    return contents, random
end

-- player is the player who triggered the creation of the sector (only set in start sector, otherwise nil)
function SectorTemplate.generate(player, seed, x, y)
    math.randomseed(seed)

    local generator = SectorGenerator(x, y)

    -- create an early ally of the player
    local faction = Galaxy():getNearestFaction(x, y)

    -- create asteroid fields
    local numSmallFields = 5
    for i = 1, numSmallFields do
        generator:createSmallAsteroidField()
    end

    --generator:createShipyard(faction)
    --generator:createRepairDock(faction)
    local station = generator:createEquipmentDock(faction)
    station:removeScript("data/scripts/entity/merchants/fightermerchant.lua")

    -- create an asteroid field with a resource trader inside it, the player will spawn here and immediately have something to mine
    local mat = generator:createAsteroidField()
    station.position = mat
    
    --local station = generator:createStation(faction, "data/scripts/entity/merchants/resourcetrader.lua");
    --station.position = mat

    -- create a big asteroid
    --local mat = generator:createAsteroidField()
    --local asteroid = generator:createClaimableAsteroid()
    --asteroid.position = mat

    for i = 1, 2 do
        ShipGenerator.createDefender(faction, generator:getPositionInSector())
    end

    generator:createGates()

    Sector():addScriptOnce("data/scripts/sector/eventscheduler.lua", "events/pirateattack.lua")
    Sector():addScript("data/scripts/sector/background/respawnresourceasteroids.lua")

    generator:addAmbientEvents()
    Sector():removeScript("factionwar/initfactionwar.lua")

    Sector():addScript("data/scripts/sector/neutralzone.lua")

    Placer.resolveIntersections()
    generator:deleteObjectsFromDockingPositions()

    return {defenders = 1}
end


