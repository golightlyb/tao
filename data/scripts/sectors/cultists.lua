
-- this function returns what relevant contents there will be in the sector (exact)
function SectorTemplate.contents(x, y)
    local seed = Seed(string.join({GameSeed(), x, y, "cultists"}, "-"))
    math.randomseed(seed)

    local random = random()

    local contents = {ships = 0, stations = 0, seed = tostring(seed)}
    contents.ships = random:getInt(6, 12)

    contents.asteroidEstimation = 25
    contents.asteroidCultists = true

    return contents, random
end

