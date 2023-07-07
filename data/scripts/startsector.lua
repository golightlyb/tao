function SectorTemplate.contents(x, y)
    local seed = Seed(string.join({GameSeed(), x, y, "startsector"}, "-"))
    math.randomseed(seed);

    local random = random()
    local contents = {ships = 3, stations = 4, seed = tostring(seed)}

    contents.xSpacedock = 1
    contents.xRefinery  = 1
    contents.xFactories = 1
    contents.xTraders   = 1
    contents.defenders  = 3
    contents.defensePlatforms = 6
    
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
        local mat = generator:createSmallAsteroidField()
        if i <= 2 then generator:createStash(mat) end
        
        local s = generator:xDefensePlatform(faction)
        s.position = mat
    end

    -- local station = generator:xCreateSpacedock(faction)

    -- create an asteroid field with a resource trader inside it, the player will spawn here and immediately have something to mine
    local mat = generator:createAsteroidField()
    local s = generator:xDefensePlatform(faction)
    s.position = mat
    
    --local station = generator:createStation(faction, "data/scripts/entity/merchants/resourcetrader.lua");
    --local station = generator:createEquipmentDock(faction)
    --station:removeScript("data/scripts/entity/merchants/fightermerchant.lua")
    
    local station1 = generator:xCreateSpacedock(faction)
    local station2 = generator:xRefinery(faction)
    local station3 = generator:xOreProcessor(faction)
    local station4 = generator:xTradingpost(faction)
    
    --local station = generator:createStation(faction, "data/scripts/entity/merchants/resourcetrader.lua");
    --station.position = mat

    -- create a big asteroid
    --local mat = generator:createAsteroidField()
    --local asteroid = generator:createClaimableAsteroid()
    --asteroid.position = mat

    for i = 1, 3 do
        ShipGenerator.createDefender(faction, generator:getPositionInSector())
    end

    generator:createGates()

    -- Sector():addScriptOnce("data/scripts/sector/eventscheduler.lua", "events/pirateattack.lua")
    Sector():addScript("data/scripts/sector/background/respawnresourceasteroids.lua")

    generator:addAmbientEvents()
    Sector():removeScript("factionwar/initfactionwar.lua")

    Sector():addScript("data/scripts/sector/neutralzone.lua")

    Placer.resolveIntersections()
    generator:deleteObjectsFromDockingPositions()

    return {defenders = 3}
end


