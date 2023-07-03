
function FactoryPredictor.generateMineProductions(x, y, amount)
    local random = Random(Seed(makeFastHash(GameSeed().int32, x, y)))

    local miningProductions = getMiningProductions()
    if #miningProductions == 0 then return {} end -- safeguard against infinite loops with broken data

    local productions = {}
    for i = 1, amount do
        local p = miningProductions[random:getInt(1, #miningProductions)]
        table.insert(productions, p.production)
    end

    return productions
end

function FactoryPredictor.generateFactoryProductions(x, y, amount)

    local random = Random(Seed(makeFastHash(GameSeed().int32, x, y)))

    -- generate whether or not the sector will be specialized
    local specialization = FactoryPredictor.getLocalSpecialization(x, y)
    local chain
    if specialization then
        -- if there is a specialization, then with X% probability the sector will be specialized
        if random:test(0.85) then
            if specialization == 0 then
                chain = "technology"
            elseif specialization == 1 then
                chain = "industrial"
            elseif specialization == 2 then
                chain = "military"
            elseif specialization == 3 then
                chain = "consumer"
            end
        end
    end

--    print ("chain: " .. tostring(chain))

    local probabilities = {}
    table.insert(probabilities, {weight = 5,  minLevel = 0, maxLevel = 10000})
    table.insert(probabilities, {weight = 60, minLevel = 0, maxLevel = 0})
    table.insert(probabilities, {weight = 40, minLevel = 1, maxLevel = 2})
    table.insert(probabilities, {weight = 25, minLevel = 2, maxLevel = 3})
    table.insert(probabilities, {weight = 15, minLevel = 3, maxLevel = 4})
    table.insert(probabilities, {weight = 10, minLevel = 4, maxLevel = 5})
    table.insert(probabilities, {weight = 5,  minLevel = 5, maxLevel = 10000})

    local weights = {}
    for index, levels in pairs(probabilities) do
        weights[index] = levels.weight
    end

    local selectedLevels = probabilities[getValueFromDistribution(weights, random)]
    local minLevel, maxLevel = selectedLevels.minLevel, selectedLevels.maxLevel

--    print ("min / max level: %s / %s", minLevel, maxLevel)

    -- choose a production by evaluating specialization, importance & level
    -- read all levels of all products
    local potentialGoods = {}
    local highestLevel = 0
    local spawnable = table.deepcopy(spawnableGoods)

    table.sort(spawnable, function(a, b) return a.name < b.name end )

    for i = 1, 10 do
        for _, good in pairs(spawnable) do
            if not good.importance then
                eprint("invalid good in factory predictor")
                printTable(good)
                goto continue
            end

            if not good.level then goto continue end -- if it has no level, it is not produced
            if chain and not good.chains[chain] then goto continue end -- if its chain doesn't match, return false

            if good.level >= minLevel and good.level <= maxLevel then
                table.insert(potentialGoods, good)

                -- increase max level
                highestLevel = math.max(highestLevel, good.level)
                if highestLevel < good.level then
                    highestLevel = good.level
                end
            end

            ::continue::
        end

        -- in case that the constraints are too tight, loosen them with every iteration
        if #potentialGoods > 0 then break end
        minLevel = minLevel - i
        maxLevel = maxLevel + i
    end

    -- calculate the probability that a certain production is chosen
    local probabilities = {}
    for i, good in pairs(potentialGoods) do
        -- goods are more likely to be created the more important they are
        local probability = good.importance * 2
        -- make sure that higher goods have a smaller chance of being chosen
        probability = probability + (highestLevel - good.level) * 0.5
        -- add a little more randomness, so not only the "important" factories are created
        -- also: some goods have an importance of 0 -> they would never be produced
        probability = probability + 2

        probabilities[i] = probability
    end

    local singleProductionOnly = random:test(0.25)

    -- choose produced good
    local productions = {}

    local tries = 0 -- safeguard against infinite loops with broken data
    while #productions < amount and tries < amount * 50 do
        tries = tries + 1
        if #productions == 0 then goto continue end

        -- choose produced good at random from probability table
        local i = getValueFromDistribution(probabilities, random)
        local producedGood = potentialGoods[i].name

        if not productionsByGood[producedGood] then
            -- good is not produced, skip it, nil it (so it's not selected again), and repeat
            probabilities[i] = nil
            goto continue
        end

        local numProductions = #productionsByGood[producedGood]
        if numProductions == nil or numProductions == 0 then
            -- good is not produced, skip it, nil it (so it's not selected again), and repeat
            -- print("product is invalid: " .. product .. "\n")
            probabilities[i] = nil
            goto continue
        end

        local productionIndex = random:getInt(1, numProductions)
        local production = productionsByGood[producedGood][productionIndex]
        if production then

            if production.mine then
                probabilities[i] = nil
                goto continue
            end

            table.insert(productions, production)

            if singleProductionOnly then
                for j = 2, amount do
                    table.insert(productions, production)
                end

                break
            end
        end

        ::continue::
    end

    return productions
end
