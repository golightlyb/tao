
function TradingPost.generateGoods(x, y)
    if not x or not y then
        x, y = Sector():getCoordinates()
    end

    local map = FactoryMap()
    local supply, demand, sum = map:getSupplyAndDemand(x, y)

    local accumulated = {}

    for good, value in pairs(supply) do
        accumulated[good] = value
    end
    for good, value in pairs(demand) do
        accumulated[good] = (accumulated[good] or 0) + value
    end

    local existingGoods = {}
    local bought = {}
    local sold = {}

    local byWeight = {}
    for good, value in pairs(accumulated) do
        byWeight[good] = value + 10
    end

    for i = 1, 15 do
        local good = selectByWeight(byWeight)

        if good and not existingGoods[good] then
            if goods[good] then
                bought[#bought + 1] = goods[good]:good()
                sold[#sold + 1] = goods[good]:good()

                existingGoods[good] = true
            end
        end
    end

    return bought, sold
end




