
local old_AsteroidFieldGenerator_createAsteroidFieldEx = AsteroidFieldGenerator.createAsteroidFieldEx
function AsteroidFieldGenerator:createAsteroidFieldEx(numAsteroids, fieldSize, minAsteroidSize, maxAsteroidSize, hasResources, probability)
    -- original defaults
    fieldSize       = fieldSize or 2000
    minAsteroidSize = minAsteroidSize or 5.0
    maxAsteroidSize = maxAsteroidSize or 25.0
    probability     = probability or 0.05
    
    -- scaled
    numAsteroids    = math.ceil(numAsteroids * 0.2)
    --fieldSize       = math.ceil(fieldSize * 0.8) -- slightly smaller, but not too dense
    
    -- vol sphere = 4/3 π r^3
    -- assuming roughly spherical with an average radius of (25-5)/2 == 10
    -- and a linear distripution of sizes
    -- then for a 1:5 scale resource asteroid:
    -- 5 x 4/3 x pi x 10^3 == 4/3 x pi x x^3
    -- x = cuberoot(5 x 10^3) = 17.0997594668
    -- so we need to move the average sizes up by 70%
    minAsteroidSize = minAsteroidSize * 1.7
    maxAsteroidSize = maxAsteroidSize * 1.7
    if probability > 0 then
        -- for good measure
        probability = probability * 1.05
        probability = probability + 0.005
        probability = math.max(probability, 1.0)
    end
    
    return old_AsteroidFieldGenerator_createAsteroidFieldEx(self, numAsteroids, fieldSize, minAsteroidSize, maxAsteroidSize, hasResources, probability)
end

function AsteroidFieldGenerator:generateOrganicCloud(numPoints, translation)
    numPoints = numPoints or 2500
    translation = translation or vec3()
    
    numPoints = math.floor(numPoints * 0.2) -- scaled

    local rand = random()
--    local rand = Random(Seed(123))

    local roughSize = 750 -- original 750
    roughSize = 250
    local partial = roughSize / 3

    local points = {}
    for i = 1, numPoints do
        local d = (roughSize + rand:getFloat(-partial, partial) + rand:getFloat(-partial, partial) + rand:getFloat(-partial, partial))
        table.insert(points, rand:getDirection() * d)
    end

    for i = 1, 10 do -- was 15
        local d = (roughSize + rand:getFloat(-partial, partial) + rand:getFloat(-partial, partial) + rand:getFloat(-partial, partial))
        local center = rand:getDirection() * d
        center = center * 1.5

        local radius = roughSize * rand:getFloat(0.5, 1.4)

        for _, point in pairs(points) do
            local dir = point - center
            local l = length(dir)
            dir = dir / l

            local offset = lerp(l, 0, radius, radius * 0.6, 0)
            point.x = point.x + dir.x * offset
            point.y = point.y + dir.y * offset
            point.z = point.z + dir.z * offset

        end
    end

    for i = 1, 25 do -- was 50
        local d = (roughSize + rand:getFloat(-partial, partial) + rand:getFloat(-partial, partial) + rand:getFloat(-partial, partial))
        local center = rand:getDirection() * d
        center = center * 1.5

        local radius = roughSize * 0.75

        for _, point in pairs(points) do
            local dir = point - center
            local l = length(dir)
            dir = dir / l

            local offset = lerp(l, 0, radius, radius * 0.75, 0)
            point.x = point.x + dir.x * offset
            point.y = point.y + dir.y * offset
            point.z = point.z + dir.z * offset
        end
    end

    for i = 1, numPoints do
        for j = i + 1, numPoints do

            local dir = points[i] - points[j]
            local l2 = length2(dir)
            if l2 < 80 * 80 then
                l = math.sqrt(l2)
                dir = dir / l

                local offset = 80 - l
                points[i].x = points[i].x + dir.x * offset
                points[i].y = points[i].y + dir.y * offset
                points[i].z = points[i].z + dir.z * offset

                points[j].x = points[j].x - dir.x * offset
                points[j].y = points[j].y - dir.y * offset
                points[j].z = points[j].z - dir.z * offset
            end
        end
    end

    local scale = 1.1
    for _, point in pairs(points) do
        point.x = point.x * scale + translation.x
        point.y = point.y * scale + translation.y
        point.z = point.z * scale + translation.z
    end

    return points
end

local old_AsteroidFieldGenerator_generateRing = AsteroidFieldGenerator.generateRing
function AsteroidFieldGenerator:generateRing(numPoints, radius, translation)
    -- original defaults
    numPoints   = numPoints or 2500
    radius      = radius or 500
    
    -- scaled
    numPoints   = math.ceil(numPoints * 0.2)
    radius      = math.ceil(radius * 0.5) -- smaller  but not too dense

    return old_AsteroidFieldGenerator_generateRing(self, numPoints, radius, translation)
end

local old_AsteroidFieldGenerator_generateSpikes = AsteroidFieldGenerator.generateSpikes
function AsteroidFieldGenerator:generateSpikes(numPoints, radius, translation)
    -- original defaults
    numPoints   = numPoints or 2500
    radius      = radius or 500
    
    -- scaled
    numPoints   = math.ceil(numPoints * 0.2)
    radius      = math.ceil(radius * 0.5) -- smaller but not too dense
    
    return old_AsteroidFieldGenerator_generateSpikes(self, numPoints, radius, translation)
end


function AsteroidFieldGenerator:createForestAsteroidFieldEx(numAsteroids, fieldSize, minAsteroidSize, maxAsteroidSize, hasResources, probability, position)

    numAsteroids = 250 -- the number of asteroids
    probability = probability or 0.05
    
    -- scaling
    numAsteroids = math.ceil(numAsteroids * 0.2)
    probability = math.max(probability * 5.0, 1.0)
    -- fieldSize = fieldSize * 0.5 -- smaller but not too dense

    local asteroidsWithResources = numAsteroids * probability
    if not hasResources then asteroidsWithResources = 0 end

    local mat = self:getFieldPosition()
    if position ~= nil then
        mat.position = position
    end

    local xcoord = mat.pos.x
    local ycoord = mat.pos.y
    local zcoord = mat.pos.z

    local asteroids = {}

    local counter = 0
    local angle = getFloat(0, math.pi * 2.0)
    local height = getFloat(-fieldSize / 5, fieldSize / 5)
    local distFromCenter = getFloat(0, fieldSize * 0.75)

    for i = 1, numAsteroids do
        local resources = false
            if asteroidsWithResources > 0 then
                resources = true
                asteroidsWithResources = asteroidsWithResources - 1
            end
            -- create asteroid size from those min/max values and the actual value
            local size
            local hiddenTreasure = false

            if math.random() < 0.15 then
                size = lerp(math.random(), 0, 1.0, minAsteroidSize, maxAsteroidSize);
                if resources then
                    resources = false
                    asteroidsWithResources = asteroidsWithResources + 1
                end
            else
                size = lerp(math.random(), 0, 2.5, minAsteroidSize, maxAsteroidSize);
            end

            if math.random() < (1 / 50) then
                hiddenTreasure = true
            end

            zcoord = zcoord + 40
            counter = counter + 1
            local randomHeight = math.random(4,9)

            if counter == randomHeight or counter >= 10 then

                zcoord = mat.pos.z
                counter = 0
                angle = getFloat(0, math.pi * 2.0)
                height = getFloat(-fieldSize / 5, fieldSize / 5)
                distFromCenter = getFloat(0, fieldSize * 0.75)

            end

            local asteroidPosition = vec3(math.sin(angle) * distFromCenter, height, zcoord)

            asteroidPosition = mat:transformCoord(asteroidPosition)
            local material = self:getAsteroidType()

            local asteroid = nil
            if hiddenTreasure then
                asteroid = self:createHiddenTreasureAsteroid(asteroidPosition, size, material)
            else
                asteroid = self:createSmallAsteroid(asteroidPosition, size, resources, material)
            end
            table.insert(asteroids, asteroid)
        end
    return mat, asteroids
end
