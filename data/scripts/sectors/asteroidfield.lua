
-- player is the player who triggered the creation of the sector (only set in start sector, otherwise nil)
function SectorTemplate.generate(player, seed, x, y)
    local contents, random = SectorTemplate.contents(x, y)

    local generator = SectorGenerator(x, y)

    local numFields = random:getInt(2, 5)
    for i = 1, numFields do
        local position = generator:createAsteroidField(0.075);
        if random:test(0.35) then generator:createBigAsteroid(position) end
    end

    for i = 1, 5 - numFields do
        local position = generator:createEmptyAsteroidField();
        if random:test(0.5) then generator:createEmptyBigAsteroid(position) end
    end

    local numSmallFields = random:getInt(8, 15)
    for i = 1, numSmallFields do
        local mat = generator:createSmallAsteroidField()

        if random:test(0.2) then generator:createStash(mat) end
    end

    for i = 1, contents.claimableAsteroids do
        local mat = generator:createAsteroidField()
        local asteroid = generator:createClaimableAsteroid()
        asteroid.position = mat
    end

    if contents.pirateEncounter then
        -- create wave encounters
        local encounters = {
            -- "data/scripts/events/waveencounters/fakestashwaves.lua",
            "data/scripts/events/waveencounters/hiddentreasurewaves.lua",
            "data/scripts/events/waveencounters/mothershipwaves.lua",
            "data/scripts/events/waveencounters/pirateambushpreparation.lua",
            "data/scripts/events/waveencounters/pirateasteroidwaves.lua",
            "data/scripts/events/waveencounters/pirateinitiation.lua",
            "data/scripts/events/waveencounters/pirateking.lua",
            "data/scripts/events/waveencounters/piratemeeting.lua",
            "data/scripts/events/waveencounters/pirateprovocation.lua",
            "data/scripts/events/waveencounters/pirateshidingtreasures.lua",
            "data/scripts/events/waveencounters/piratestationwaves.lua",
            "data/scripts/events/waveencounters/piratestreasurehunt.lua",
            "data/scripts/events/waveencounters/piratetraitorwaves.lua",
        }

        Sector():addScript("data/scripts/events/waveencounters/respawnwaveencounters.lua", randomEntry(random, encounters))
    end

    -- OperationExodus.tryGenerateBeacon(generator)

    if random:test(generator:getWormHoleProbability()) then generator:createRandomWormHole() end

    Sector():addScriptOnce("data/scripts/sector/eventscheduler.lua", "events/pirateattack.lua")
    Sector():addScript("data/scripts/sector/background/respawnresourceasteroids.lua")

    generator:addOffgridAmbientEvents()
    Placer.resolveIntersections()
end
