

TradingPost.trader.supplyDemandInfluence = 1.0 -- original 0.5
TradingPost.trader.stockInfluence = 1.0 -- original 1.0

function TradingPost.initialize()

    local station = Entity()
    if station.title == "" then
        station.title = "Trading Post"%_t
    end

    if onServer() then
        Sector():addScriptOnce("sector/traders.lua")

        -- for large stations it's possible that the generator sacrifices cargo bay for generators etc.
        local cargoBay = CargoBay()
        if TradingPost.trader.minimumCargoBay and station.aiOwned then
            if cargoBay.cargoHold < TradingPost.trader.minimumCargoBay then
                cargoBay.fixedSize = true
                cargoBay.cargoHold = TradingPost.trader.minimumCargoBay
            end
        else
            cargoBay.fixedSize = false
        end

        local faction = Faction()
        if not _restoring then
            math.randomseed(Sector().seed + Sector().numEntities);

            -- make lists of all items that will be sold/bought
            local bought, sold = TradingPost.generateGoods()

            TradingPost.trader.buyPriceFactor = 0.8
            TradingPost.trader.sellPriceFactor = 1.1

            TradingPost.initializeTrading(bought, sold)

            if faction and (faction.isAlliance or faction.isPlayer) then
                TradingPost.trader.buyFromOthers = false
            end

            math.randomseed(appTimeMs())
        end

        if faction and faction.isAIFaction then
            Sector():registerCallback("onRestoredFromDisk", "onRestoredFromDisk")
        end
    else
        TradingPost.requestGoods()
        if EntityIcon().icon == "" then
            EntityIcon().icon = "data/textures/icons/pixel/trade.png"
            InteractionText(station.index).text = Dialog.generateStationInteractionText(station, random())
        end

    end

    if onServer() then
    -- station:addScriptOnce("data/scripts/entity/merchants/cargotransportlicensemerchant.lua")
        station:addScriptOnce("data/scripts/entity/merchants/customs.lua")
    end
end

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

        -- don't list illegal (miltary) goods, even if there's demand for them
        if good and not existingGoods[good] and not goods[good].illegal then
            if goods[good] then
                bought[#bought + 1] = goods[good]:good()
                sold[#sold + 1] = goods[good]:good()

                existingGoods[good] = true
            else
                eprint("entity/merchants/tradingpost: invalid good "..good)
            end
        end
    end

    return bought, sold
end







