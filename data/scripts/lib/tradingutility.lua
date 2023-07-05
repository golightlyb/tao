scripts =
{
    "/consumer.lua",
    "/seller.lua",
    --"/turretfactoryseller.lua",
    --"/turretfactorysupplier.lua",
    "/factory.lua",
    "/tradingpost.lua",
    --"/planetarytradingpost.lua",
    --"/casino.lua",
    --"/habitat.lua",
    --"/biotope.lua"
}

function TradingUtility.isScriptAConsumer(script)
    return script == "/consumer.lua"
end

function TradingUtility.spawnTrader(trade, namespace, immediateTransaction)
    local sector = Sector()

    -- don't spawn helpless ships in war zones
    if sector:getValue("war_zone") then return end

    -- don't spawn if player wrongly controlled too many ships
    if sector:getValue("no_trade_zone") then return end

    --print ("spawning trader...")

    -- find a position rather outside the sector
    -- this is the position where the trader spawns
    local tradingFaction = Galaxy():getNearestFaction(sector:getCoordinates())

    local eradicatedFactions = getGlobal("eradicated_factions") or {}
    if eradicatedFactions[tradingFaction.index] == true then return end

    -- factions at war with each other don't trade
    if not immediateTransaction
        and tradingFaction:getRelations(trade.station.factionIndex) < -40000 then

        return
    end

    local g = GetGood(trade.name)
    if not g then
        print ("lib/tradingutility: invalid good: '" .. trade.name .. "'")
        return
    end

    local good = g:good()

    local x, y = sector:getCoordinates()
    local maxValue = Balancing_GetSectorRichnessFactor(x, y, 50) * 750000

    -- still allow some high-value transports
    if math.random() < 0.2 then
        maxValue = maxValue * (1 + math.random() * 4)
    end

    local maxAmount = maxValue / good.price

    local amount = trade.amount or 100 + math.random() * 1000
    amount = math.ceil(math.min(maxAmount, amount))

    if not immediateTransaction then
        local pos = random():getDirection() * 1500
        local matrix = MatrixLookUpPosition(normalize(-pos), vec3(0, 1, 0), pos)

        local onGenerated = function (ship)
            if not valid(trade.station) then
                Sector():deleteEntity(ship)
                return
            end

            ship:setValue("trade_partner", trade.station.id.string)

            -- if the trader buys, he has no cargo, if he sells, add cargo
            if trade.tradeType == TradeType.SellToStation then
                ship:addCargo(good, amount)
                ship:addScript("merchants/tradeship.lua", trade.station.id, trade.script)
                -- print ("creating a trader for " .. trade.station.title .. " to sell " .. amount .. " " .. trade.name)
            elseif trade.tradeType == TradeType.BuyFromStation then
                ship:addScript("merchants/tradeship.lua", trade.station.id, trade.script, trade.name, amount)
                -- print ("creating a trader for " .. trade.station.title .. " to buy " .. amount .. " " .. trade.name)
            end
        end

        -- create the trader
        local generator = AsyncShipGenerator(namespace, onGenerated)
        generator:createFreighterShip(tradingFaction, matrix)
    else
        -- do transaction immediately
        if trade.tradeType == TradeType.SellToStation then
            local error = trade.station:invokeFunction(trade.script, "buyGoods", good, amount, tradingFaction.index)

            if error ~= 0 then
                print ("buy error: " .. error)
            end

            -- print ("immediate sell to station transaction")
        elseif trade.tradeType == TradeType.BuyFromStation then
            local error = trade.station:invokeFunction(trade.script, "sellGoods", good, amount, tradingFaction.index)

            if error ~= 0 then
                print ("sell error: " .. error)
            end
            -- print ("immediate buy from station transaction")
        end
    end

end
