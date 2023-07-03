

function Factory.updateClient(timeStep)
    if EntityIcon().icon == "" then

        local title = Entity().title

        if production then
            if production.factoryStyle == "Mine" then
                EntityIcon().icon = "data/textures/icons/pixel/mine.png"
            elseif production.factoryStyle == "Ranch" then
                EntityIcon().icon = "data/textures/icons/pixel/ranch.png"
            elseif production.factoryStyle == "Farm" then
                EntityIcon().icon = "data/textures/icons/pixel/farm.png"
            else
                EntityIcon().icon = "data/textures/icons/pixel/factory.png"
            end
        end
    end

    Factory.updateStepDone = true
end

Factory.trader.getMaxStock = function(self, good)
    if good == nil then
        eprint("Factory.trader.getMaxStock called with nil good")
        return 1
    end
    if good.size == nil then
        eprint("Factory.trader.getMaxStock called with invalid good")
        printTable(good)
        return 1
    end
    
    if not requiredSpaceRatioByGood then
        -- fill cache
        local spaceByGood = {}
        local requiredSpaceForOneProduction = 0

        for _, productionPart in pairs({production.ingredients, production.results, production.garbages}) do
            for _, productionGood in pairs(productionPart) do
                -- if the good does not exist in the goods index for some reason, assume it has size 1
                local size = 1
                if goods[productionGood.name] then
                    size = goods[productionGood.name].size
                end

                local space = size * productionGood.amount

                spaceByGood[productionGood.name] = space
                requiredSpaceForOneProduction = requiredSpaceForOneProduction + space
            end
        end

        requiredSpaceRatioByGood = {}
        for name, space in pairs(spaceByGood) do
            -- the ratio of the total space that is used for the given good
            requiredSpaceRatioByGood[name] = space / requiredSpaceForOneProduction
        end
    end

    local ratio = requiredSpaceRatioByGood[good.name]
    if not ratio then
        return 0
    end

    local maxStock = Entity().maxCargoSpace * ratio / good.size
    if maxStock > 100 then
        -- round to 100
        return math.min(50000, round(maxStock / 100) * 100)
    else
        -- not very much space already, don't round
        return math.floor(maxStock)
    end
end

function Factory.setProduction(production_in, size)

    if size == nil then
        local distanceFromCenter = length(vec2(Sector():getCoordinates()))
        local probabilities = {}

        probabilities[1] = 1.0

        if distanceFromCenter < 450 then
            probabilities[2] = 0.5
        end

        if distanceFromCenter < 400 then
            probabilities[3] = 0.35
        end

        if distanceFromCenter < 350 then
            probabilities[4] = 0.25
        end

        if distanceFromCenter < 300 then
            probabilities[5] = 0.15
        end

        size = getValueFromDistribution(probabilities)
    end

    factorySize = size or 1
    Factory.maxNumProductions = 1 + factorySize
    production = production_in

    -- make lists of all items that will be sold/bought
    local bought = {}

    -- ingredients are bought
    for i, ingredient in pairs(production.ingredients) do
        local g = goods[ingredient.name]
        if g ~= nil then
            table.insert(bought, g:good())
        end
    end

    -- results and garbage are sold
    local sold = {}

    for i, result in pairs(production.results) do
        local g = goods[result.name]
        if g ~= nil then
            table.insert(sold, g:good())
        end
    end

    for i, garbage in pairs(production.garbages) do
        local g = goods[garbage.name]
        if g ~= nil then
            table.insert(sold, g:good())
        end
    end

    local station = Entity()

    -- set title
    if station.title == "" then
        Factory.updateTitle()

        station:setValue("factory_type", "factory")

        if production.mine then
            station:setValue("factory_type", "mine")
            station:addScriptOnce("data/scripts/entity/merchants/consumer.lua", "Mine /*station type*/"%_T, unpack(ConsumerGoods.Mine()))
        end
    end

    Factory.refreshProductionTime()

    Factory.initializeTrading(bought, sold)
    Factory.updateOwnSupply()
end