

function MineCommand:calculateGatheredResources(properties)
    local resourcesPerAsteroid = 3850 -- average yield of a normal asteroid in the game
    
    -- manual tweak -- we have 0.2x as many asteroids, but they are larger
    -- but this means less time flying between them
    resourcesPerAsteroid = resourcesPerAsteroid * 3.0

    local refined = properties.refinedEfficiency * properties.refinedEfficiencyWeight * resourcesPerAsteroid
    local raw = properties.rawEfficiency * properties.rawEfficiencyWeight * resourcesPerAsteroid

    return refined, raw
end
