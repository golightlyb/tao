
-- player is the player who triggered the creation of the sector (only set in start sector, otherwise nil)
function SectorTemplate.generate(player, seed, x, y)
    local contents, random = SectorTemplate.contents(x, y)

    local generator = SectorGenerator(x, y)

    -- create filled asteroids
    local numFields = random:getInt(0, 2)

    for i = 1, numFields do
        generator:createAsteroidField(0.1);
    end

    for i = 1, contents.resourceAsteroids do
        local position = generator:createAsteroidField()
        generator:createBigAsteroid(position)
    end

    local numSmallFields = random:getInt(1, 5)
    for i = 1, numSmallFields do
        generator:createSmallAsteroidField()
    end

    -- create empty asteroids
    local numFields = random:getInt(1, 2)

    for i = 1, numFields do
        generator:createEmptyAsteroidField();
    end

    local numAsteroids = random:getInt(1, 2)
    for i = 1, numAsteroids do
        generator:createEmptyBigAsteroid();
    end

    local numSmallFields = random:getInt(1, 2)
    for i = 1, numSmallFields do
        generator:createEmptySmallAsteroidField()
    end

    for i = 1, contents.claimableAsteroids do
        local mat = generator:createAsteroidField()
        local asteroid = generator:createClaimableAsteroid()
        asteroid.position = mat
    end

    -- OperationExodus.tryGenerateBeacon(generator)

    if random:test(generator:getWormHoleProbability()) then generator:createRandomWormHole() end

    Sector():addScriptOnce("data/scripts/sector/eventscheduler.lua", "events/pirateattack.lua")
    Sector():addScriptOnce("data/scripts/sector/background/respawnresourceasteroids.lua")

    generator:addOffgridAmbientEvents()
    Placer.resolveIntersections()
end