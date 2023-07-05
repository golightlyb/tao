

local function starts_with(str, start)
   return str:sub(1, #start) == start
end

-- special version of getMaxStock for factories
-- fix not looking up good properly
Factory.trader.getMaxStock = function(self, good)
    if not requiredSpaceRatioByGood then
        -- fill cache
        local spaceByGood = {}
        local requiredSpaceForOneProduction = 0

        for _, productionPart in pairs({production.ingredients, production.results, production.garbages}) do
            for _, productionGood in pairs(productionPart) do
                -- if the good does not exist in the goods index for some reason, assume it has size 1
                local size = 1
                local g = goods[productionGood.name]
                if g then
                    size = g.size
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

    -- fix, because it's called both with ID and with name
    name = good.name
    if not starts_with(name, "X") then
        name = GoodIDFromName(name)
    end
    local ratio = requiredSpaceRatioByGood[name]
    if not ratio then
        eprint("factory: missing good ratio for "..name)
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



-- BUGFIX: factory getting reinitialised
local old_Factory_setProduction = Factory.setProduction
function Factory.setProduction(production_in, size)
    local station = Entity()
    station:setValue("factory_production_initialized", true)
    old_Factory_setProduction(production_in, size)
end

