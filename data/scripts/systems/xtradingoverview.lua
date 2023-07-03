package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("callable")
include ("goods")
local UICollection = include ("uicollection")
local TradingUtility = include ("tradingutility")
local RingBuffer = include ("ringbuffer")
local FactoryMap = include ("factorymap")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
PermanentInstallationOnly = true
Unique = true

local tabbedWindow = nil
local routesTab = nil
local supplyDemandTab = nil

local sellableGoodFrames = {}
local sellableGoodIcons = {}
local sellableGoodNameLabels = {}
local sellableGoodStockLabels = {}
local sellableGoodPriceLabels = {}
local sellableGoodSizeLabels = {}
local sellableGoodStationLabels = {}
local sellableGoodPriceFactorLabels = {}
local sellableGoodOnShipLabels = {}
local sellableGoodButtons = {}
local sellableGoodButtonLeft
local sellableGoodButtonRight

local buyableGoodFrames = {}
local buyableGoodIcons = {}
local buyableGoodNameLabels = {}
local buyableGoodStockLabels = {}
local buyableGoodPriceLabels = {}
local buyableGoodSizeLabels = {}
local buyableGoodStationLabels = {}
local buyableGoodPriceFactorLabels = {}
local buyableGoodOnShipLabels = {}
local buyableGoodButtons = {}
local buyableGoodButtonLeft
local buyableGoodButtonRight

local routeIcons = {}
local routeFrames = {}
local routeStockLabels = {}
local routePriceLabels = {}
local routeCoordLabels = {}
local routeStationLabels = {}
local routeButtons = {}
local routeButtonLeft
local routeButtonRight
local routeAmountOnShipLabels = {}


local supplyDemandLines = {}

local SupplyDemandSortType =
{
    NameAscending = 1,
    DemandAscending = 2,
    SupplyAscending = 3,
    SumAscending = 4,
    PriceAscending = 5,
    NameDescending = -1,
    DemandDescending = -2,
    SupplyDescending = -3,
    SumDescending = -4,
    PriceDescending = -5,
}

local supplyDemandSortMode = SupplyDemandSortType.PriceDescending
local supplyDemandSortButtons = {}
local supplyDemandButtonLeft
local supplyDemandButtonRight


local sellable = {}
local buyable = {}

local routes = {}
local historySize = 0
local tradingData = nil


local sellablesPage = 0
local buyablesPage = 0
local routesPage = 0
local supplyDemandPage = 0

local sellableSortFunction = nil
local buyableSortFunction = nil



function seePrices(seed, rarity)
    return rarity.value >= 0
end

function seePriceFactors(seed, rarity)
    return rarity.value >= 0
end

function getHistorySize(seed, rarity)
    r = rarity.value + 1 -- 0 to 6
    
    if r >= 1 then
        return r * 3 -- 3 to 18
    else
        return 1
    end
end

function getEconomyRange(seed, rarity, permanent)
    r = rarity.value + 1 -- 0 to 6
    
    if r >= 2 then
        return (r - 1) * 5 -- 5 to 25
    else
        return 0
    end
end

function onInstalled(seed, rarity, permanent)

    historySize = getHistorySize(seed, rarity, permanent)
    economyRange = getEconomyRange(seed, rarity, permanent)

    if onServer() then
        tradingData = RingBuffer(math.max(historySize, 1))
        collectSectorData()
    end

end

function onUninstalled(seed, rarity, permanent)
end

if onServer() then

    function getUpdateInterval()
        return 0
    end

    function update()
        -- recollect during first iteration because this may be called during restoration
        -- and sector scripts get initialized after entity scripts, so economyupdater.lua might not be there yet
        -- leading to false values
        tradingData = RingBuffer(math.max(historySize, 1))
        collectSectorData()

        -- after first iteration these so we don't continue needlessly recollecting
        getUpdateInterval = nil
        update = nil
    end

end

function getName(seed, rarity)
    return "Trading Subsystem MK ${mark} /* ex: Trading Subsystem MK IV */"%_t % {mark = toRomanLiterals(rarity.value + 2)}
end

function getBasicName()
    return "Trading Subsystem /* generic name for 'Trading Subsystem' */"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/cash.png"
end

function getControlAction()
    return ControlAction.ScriptQuickAccess1
end

function getPrice(seed, rarity)
    local r = rarity.value + 1 -- 0 to 6
    return 15625 * math.pow(4, r)
        
    -- 250,000 * 4^r
    -- petty:       c     15,625
    -- common:      c     62,500
    -- uncommon:    c    250,000
    -- rare:        c  1,000,000
    -- exceptional: c  4,000,000
    -- exotic:      c 16,000,000
    -- legendary:   c 64,000,000
end

function getTooltipLines(seed, rarity, permanent)
    local lines = {}
    local bonuses = {}

    local history = getHistorySize(seed, rarity)
    local economyRange = getEconomyRange(seed, rarity, true)

    local toYesNo = function(line, value)
        if value then
            line.rtext = "Yes"%_t
            line.rcolor = ColorRGB(0.3, 1.0, 0.3)
        else
            line.rtext = "No"%_t
            line.rcolor = ColorRGB(1.0, 0.3, 0.3)
        end
    end

    table.insert(lines, {ltext = "Prices of Goods"%_t, icon = "data/textures/icons/sell.png"})
    toYesNo(lines[#lines], seePrices(seed, rarity))

    table.insert(lines, {ltext = "Price Deviations"%_t, icon = "data/textures/icons/sell.png"})
    toYesNo(lines[#lines], seePriceFactors(seed, rarity))

    table.insert(lines, {ltext = "Trade Route Detection"%_t, icon = "data/textures/icons/sell.png"})
    toYesNo(lines[#lines], history > 0)

    if economyRange > 1 then
        table.insert(lines, {ltext = "Economy Overview (Galaxy Map)"%_t, icon = "data/textures/icons/histogram.png", boosted = (permanent and economyRange > 0)})
        toYesNo(lines[#lines], permanent and economyRange > 1)
    elseif economyRange == 1 then
        table.insert(lines, {ltext = "Economy Overview (local)"%_t, icon = "data/textures/icons/histogram.png", boosted = (permanent and economyRange > 0)})
        toYesNo(lines[#lines], permanent and economyRange > 0)
    elseif economyRange == 0 then
        table.insert(lines, {ltext = "Economy Overview"%_t, icon = "data/textures/icons/histogram.png", boosted = (permanent and economyRange > 0)})
        toYesNo(lines[#lines], permanent and economyRange > 0)
    end

    if economyRange > 0 or history > 0 then
        table.insert(lines, {})
    end

    if economyRange > 0 then
        if permanent then
            table.insert(lines, {ltext = "Economy Scan Range"%_t, rtext = tostring(economyRange), icon = "data/textures/icons/histogram.png", boosted = permanent})
        else

            if economyRange > 1 then
                table.insert(bonuses, {ltext = "Economy Overview (Galaxy Map)"%_t, rtext = "Yes"%_t, icon = "data/textures/icons/histogram.png"})
            else
                table.insert(bonuses, {ltext = "Economy Overview (local)"%_t, rtext = "Yes"%_t, icon = "data/textures/icons/histogram.png"})
            end

            table.insert(bonuses, {ltext = "Economy Scan Range"%_t, rtext = tostring(economyRange), icon = "data/textures/icons/histogram.png"})
        end
    end

    if history > 0 then
        table.insert(lines, {ltext = "Trade Route Sectors"%_t, rtext = tostring(history), icon = "data/textures/icons/sell.png"})
    end

    if not permanent and #bonuses == 0 then bonuses = nil end

    return lines, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local lines = {}

    local economyRange = getEconomyRange(seed, rarity, true)
    if economyRange > 0 then
        if economyRange == 1 then
            table.insert(lines, {ltext = "Shows supply & demand of current sector"%_t})
        else
            table.insert(lines, {ltext = "Shows supply & demand of nearby sectors"%_t})
        end
    end

    local history = getHistorySize(seed, rarity)
    if history > 0 then
        table.insert(lines, {ltext = plural_t("Shows trade routes in current sector", "Shows trade routes in last ${i} sectors", history)})
    end

    if seePrices(seed, rarity) or seePriceFactors(seed, rarity) then
        table.insert(lines, {ltext = "Shows prices of all stations in sector"%_t})
    else
        table.insert(lines, {ltext = "Shows goods of all stations in sector"%_t})
    end

    return lines
end

function getComparableValues(seed, rarity)
    local base = {}
    local bonus = {}

    local history = getHistorySize(seed, rarity)
    local economyRange = getEconomyRange(seed, rarity, true)

    table.insert(base, {name = "Trade Route Sectors"%_t, key = "route_sectors", value = history, comp = UpgradeComparison.MoreIsBetter})
    table.insert(base, {name = "Economy Scan Range"%_t, key = "economy_range", value = economyRange, comp = UpgradeComparison.MoreIsBetter})
    table.insert(bonus, {name = "Economy Scan Range"%_t, key = "economy_range", value = economyRange, comp = UpgradeComparison.MoreIsBetter})

    return base, bonus
end

function gatherData()
    return TradingUtility.detectBuyableAndSellableGoods()
end

function onSectorChanged()
    collectSectorData()
end

function collectSectorData()
    if not tradingData then return end

    local sellable, buyable = gatherData()

    -- print("gathered " .. #sellable .. " sellable goods from sector " .. tostring(vec2(Sector():getCoordinates())))
    -- print("gathered " .. #buyable .. " buyable goods from sector " .. tostring(vec2(Sector():getCoordinates())))

    tradingData:insert({sellable = sellable, buyable = buyable})

    updateTradingRoutes()
end

function updateTradingRoutes()

    if historySize == 0 then
        routes = {}
        return
    end
--    print("analyzing sector history")

    local buyables = {}
    local sellables = {}
    routes = {}

    local counter = 0
    local gc = 0

    -- find best offer in buyables for every good
    for _, sectorData in ipairs(tradingData.data) do
        -- find best offer in buyable for every good
        for _, offer in pairs(sectorData.buyable) do
            local existing = buyables[offer.good.name]
            if existing == nil or offer.price < existing.price then
                buyables[offer.good.name] = offer
            end

            gc = gc + 1
        end

        -- find best offer in sellable for every good
        for _, offer in pairs(sectorData.sellable) do
            local existing = sellables[offer.good.name]
            if existing == nil or offer.price > existing.price then
                sellables[offer.good.name] = offer
            end

            gc = gc + 1
        end

        counter = counter + 1
    end

    -- match those two to find possible trading routes
    for name, offer in pairs(buyables) do

        if offer.stock > 0 then
            local sellable = sellables[name]

            if sellable ~= nil and (sellable.price > offer.price or (sellable.price == 0 and offer.price == 0)) then
                table.insert(routes, {sellable=sellable, buyable=offer})

    --            print(string.format("found trading route for %s, buy price (in sector %s): %i, sell price (in sector %s): %i", name, tostring(offer.coords), offer.price, tostring(sellable.coords), sellable.price))
            end
        end
    end

--    print("analyzed " .. counter .. " data sets with " .. gc .. " different goods")

end

function getData()
    local sellable, buyable = gatherData()

    if tradingData then
        tradingData.data[tradingData.last] = {sellable = sellable, buyable = buyable}
        updateTradingRoutes()
    end

    if callingPlayer then
        invokeClientFunction(Player(callingPlayer), "setData", sellable, buyable, routes)
    end

    return sellable, buyable, routes or {}
end
callable(nil, "getData")


local nearbyEconomyWork =
{
    coordinates = nil,
    running = false,
    productions = nil,
    lastRequested = nil
}


function onNearbyEconomyCalculated(productions, x, y, callingPlayer)

    local sx, sy = Sector():getCoordinates()
    if x ~= sx or y ~= sy then return end

    nearbyEconomyWork.running = false
    nearbyEconomyWork.productions = productions
    nearbyEconomyWork.coordinates = {x=x, y=y}

    if onServer() then
        local player = Player(callingPlayer)
        if player then
            invokeClientFunction(player, "onNearbyEconomyCalculated", productions, x, y)
        end
    else
        local now = appTime()
        nearbyEconomyWork.lastRequested = now

        refreshSupplyDemandUI()
    end
end

function getEconomyData()
    local returned = nil
    if onClient() then returned = nearbyEconomyWork.productions end

    if nearbyEconomyWork.running then return nearbyEconomyWork.productions end

    if not nearbyEconomyWork.productions then return returned end
    if not nearbyEconomyWork.lastRequested then return returned end

    local now = appTime()
    if now - nearbyEconomyWork.lastRequested > 60 then return returned end

    if not nearbyEconomyWork.coordinates then return returned end

    local x, y = Sector():getCoordinates()
    if nearbyEconomyWork.coordinates.x ~= x then return returned end
    if nearbyEconomyWork.coordinates.y ~= y then return returned end

    return nearbyEconomyWork.productions
end

function requestNearbyEconomy()

    if onClient() then
        invokeServerFunction("requestNearbyEconomy")
        return
    end

    if callingPlayer and not ControlUnit():isPlayerAPilot(callingPlayer) then
        return
    end

    local productions = getEconomyData()
    if productions then
        invokeClientFunction(Player(callingPlayer), "onNearbyEconomyCalculated", productions, x, y)
        return
    end

    -- don't start calculations again while still running
    if nearbyEconomyWork.running then return end

    local x, y = Sector():getCoordinates()

    local code = [[
        package.path = package.path .. ";data/scripts/lib/?.lua"
        package.path = package.path .. ";data/scripts/?.lua"

        local FactoryMap = include ("factorymap")

        function run(x, y, radius, callingPlayer)
            local map = FactoryMap()

            local from = {x = x - radius, y = y - radius}
            local to = {x = x + radius, y = y + radius}

            local productions = map:getProductionsMap(from, to)

            return productions, x, y, callingPlayer
        end
    ]]

    async("onNearbyEconomyCalculated", code, x, y, 50, callingPlayer)

    local now = appTime()
    nearbyEconomyWork.lastRequested = now
    nearbyEconomyWork.running = true
end
callable(nil, "requestNearbyEconomy")


if onClient() then

-- if this function returns false, the script will not be listed in the interaction window on the client,
-- even though its UI may be registered
function interactionPossible(playerIndex, option)

    local player = Player()
    if Entity().index == player.craftIndex then
        return true
    end

    return false
end

function initUI()
    local size = vec2(1000, 670)
    local res = getResolution()

    local menu = ScriptUI()
    local mainWindow = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5));
    menu:registerWindow(mainWindow, "Trading Overview"%_t);

    mainWindow.caption = "Trading Overview"%_t
    mainWindow.showCloseButton = 1
    mainWindow.moveable = 1

    -- create a tabbed window inside the main window
    tabbedWindow = mainWindow:createTabbedWindow(Rect(vec2(10, 10), size - 10))

    -- create economy tab
    supplyDemandTab = tabbedWindow:createTab("Supply & Demand"%_t, "data/textures/icons/histogram.png", "View local supply and demand"%_t)
    buildSupplyDemandGui(supplyDemandTab)

    -- create routes tab
    routesTab = tabbedWindow:createTab("Trading Routes"%_t, "data/textures/icons/trade-route.png", "View detected trading routes"%_t)
    buildRoutesGui(routesTab)

    -- create buy tab
    local buyTab = tabbedWindow:createTab("Buy"%_t, "data/textures/icons/bag.png", "Buy from stations"%_t)
    buildGui(buyTab, 1)

    -- create sell tab
    local sellTab = tabbedWindow:createTab("Sell"%_t, "data/textures/icons/sell.png", "Sell to stations"%_t)
    buildGui(sellTab, 0)

    guiInitialized = 1

end

function onShowWindow()
    invokeServerFunction("getData")
end

function setData(sellable_received, buyable_received, routes_received)

    sellable = sellable_received
    buyable = buyable_received
    routes = routes_received

    local ship = Entity()

    for _, route in pairs(routes) do
        for j, offer in pairs({route.buyable, route.sellable}) do
            offer.amountOnShip = ship:getCargoAmount(offer.good)

            -- translate argument values of station title
            for k, v in pairs(offer.titleArgs) do
                offer.titleArgs[k] = v%_t
            end
        end
    end

    for _, good in pairs(buyable) do
        good.amountOnShip = ship:getCargoAmount(good.good)

        -- translate argument values of station title
        for k, v in pairs(good.titleArgs) do
            good.titleArgs[k] = v%_t
        end
    end

    for _, good in pairs(sellable) do
        good.amountOnShip = ship:getCargoAmount(good.good)

        -- translate argument values of station title
        for k, v in pairs(good.titleArgs) do
            good.titleArgs[k] = v%_t
        end
    end


    refreshUI()
end

function sortByNameAsc(a, b) return a.good:displayName(2) < b.good:displayName(2) end
function sortByNameDes(a, b) return a.good:displayName(2) > b.good:displayName(2) end

function sortByStockAsc(a, b) return a.stock / a.maxStock < b.stock / b.maxStock end
function sortByStockDes(a, b) return a.stock / a.maxStock > b.stock / b.maxStock end

function sortByPriceAsc(a, b) return a.good.price < b.good.price end
function sortByPriceDes(a, b) return a.good.price > b.good.price end

function sortByVolAsc(a, b) return a.good.size < b.good.size end
function sortByVolDes(a, b) return a.good.size > b.good.size end

function sortByPriceFactorAsc(a, b) return a.price / a.good.price < b.price / b.good.price end
function sortByPriceFactorDes(a, b) return a.price / a.good.price > b.price / b.good.price end

function sortByStationAsc(a, b) return a.station < b.station end
function sortByStationDes(a, b) return a.station > b.station end

function sortByAmountOnShipAsc(a, b) return a.amountOnShip < b.amountOnShip end
function sortByAmountOnShipDes(a, b) return a.amountOnShip > b.amountOnShip end

function routeProfit(route)
    -- calculate route profit
    local tradableStock = math.min(route.buyable.stock, route.sellable.maxStock - route.sellable.stock);
    return (route.sellable.price - route.buyable.price) * tradableStock
end

function routesByProfit(a, b)
    -- calculate max profit
    return routeProfit(a) > routeProfit(b)
end



sellableSortFunction = sortByNameAsc
buyableSortFunction = sortByNameAsc

function refreshBuyablesUI()
    table.sort(buyable, buyableSortFunction)

    for index = 1, 15 do
        buyableGoodFrames[index]:hide()
        buyableGoodIcons[index]:hide()
        buyableGoodNameLabels[index]:hide()
        buyableGoodStockLabels[index]:hide()
        buyableGoodPriceLabels[index]:hide()
        buyableGoodSizeLabels[index]:hide()
        buyableGoodStationLabels[index]:hide()
        buyableGoodPriceFactorLabels[index]:hide()
        buyableGoodOnShipLabels[index]:hide()
        buyableGoodButtons[index]:hide()
    end

    if #buyable == 0 then
        buyableGoodNameLabels[1]:show()
        buyableGoodNameLabels[1].caption = "Couldn't detect any stations that sell specific goods."%_t
    end

    if buyablesPage > 0 then
        buyableGoodButtonLeft:show()
    else
        buyableGoodButtonLeft:hide()
    end

    if #buyable > (buyablesPage + 1) * 15 then
        buyableGoodButtonRight:show()
    else
        buyableGoodButtonRight:hide()
    end

    local index = 0
    for i, good in pairs(buyable) do

        if i > buyablesPage * 15 and i <= (buyablesPage + 1) * 15 then
            index = index + 1
            if index > 15 then break end

            local priceFactor = ""
            if good.good.price > 0 then
                priceFactor = string.format("%+i%%", round((good.price / good.good.price - 1.0) * 100))
            end

            buyableGoodNameLabels[index].caption = good.good:displayName(2)
            buyableGoodStockLabels[index].caption = math.floor(good.stock) .. " / " .. math.floor(good.maxStock)
            buyableGoodPriceLabels[index].caption = createMonetaryString(good.price)
            buyableGoodPriceFactorLabels[index].caption = priceFactor
            buyableGoodSizeLabels[index].caption = round(good.good.size, 2)
            buyableGoodIcons[index].picture = good.good.icon
            buyableGoodStationLabels[index].caption = good.station%_t % good.titleArgs
            if good.amountOnShip > 0 then
                buyableGoodOnShipLabels[index].caption = good.amountOnShip
            else
                buyableGoodOnShipLabels[index].caption = "-"
            end

            buyableGoodFrames[index]:show()
            buyableGoodIcons[index]:show()
            buyableGoodNameLabels[index]:show()
            buyableGoodStockLabels[index]:show()
            buyableGoodPriceLabels[index]:show()
            buyableGoodSizeLabels[index]:show()
            buyableGoodStationLabels[index]:show()
            buyableGoodPriceFactorLabels[index]:show()
            buyableGoodButtons[index]:show()
            buyableGoodOnShipLabels[index]:show()

            if getRarity().value < 0 then
                buyableGoodPriceLabels[index].caption = "-"
            end

            if getRarity().value < 1 then
                buyableGoodPriceFactorLabels[index].caption = "-"
            end

        end
    end



end


function refreshSellablesUI()
    table.sort(sellable, sellableSortFunction)

    for index = 1, 15 do
        sellableGoodFrames[index]:hide()
        sellableGoodIcons[index]:hide()
        sellableGoodNameLabels[index]:hide()
        sellableGoodStockLabels[index]:hide()
        sellableGoodPriceLabels[index]:hide()
        sellableGoodSizeLabels[index]:hide()
        sellableGoodStationLabels[index]:hide()
        sellableGoodPriceFactorLabels[index]:hide()
        sellableGoodOnShipLabels[index]:hide()
        sellableGoodButtons[index]:hide()
    end

    if #sellable == 0 then
        sellableGoodNameLabels[1]:show()
        sellableGoodNameLabels[1].caption = "Couldn't detect any stations that buy specific goods."%_t
    end

    if sellablesPage > 0 then
        sellableGoodButtonLeft:show()
    else
        sellableGoodButtonLeft:hide()
    end

    if #sellable > (sellablesPage + 1) * 15 then
        sellableGoodButtonRight:show()
    else
        sellableGoodButtonRight:hide()
    end

    local index = 0
    for i, good in pairs(sellable) do

        if i > sellablesPage * 15 and i <= (sellablesPage + 1) * 15 then
            index = index + 1
            if index > 15 then break end

            local priceFactor = ""
            if good.good.price > 0 then
                priceFactor = string.format("%+i%%", round((good.price / good.good.price - 1.0) * 100))
            end

            sellableGoodNameLabels[index].caption = good.good:displayName(2)
            sellableGoodStockLabels[index].caption = math.floor(good.stock) .. " / " .. math.floor(good.maxStock)
            sellableGoodPriceLabels[index].caption = createMonetaryString(good.price)
            sellableGoodPriceFactorLabels[index].caption = priceFactor
            sellableGoodSizeLabels[index].caption = round(good.good.size, 2)
            sellableGoodIcons[index].picture = good.good.icon
            sellableGoodStationLabels[index].caption = good.station%_t % good.titleArgs
            if good.amountOnShip > 0 then
                sellableGoodOnShipLabels[index].caption = good.amountOnShip
            else
                sellableGoodOnShipLabels[index].caption = "-"
            end

            sellableGoodFrames[index]:show()
            sellableGoodIcons[index]:show()
            sellableGoodNameLabels[index]:show()
            sellableGoodStockLabels[index]:show()
            sellableGoodPriceLabels[index]:show()
            sellableGoodSizeLabels[index]:show()
            sellableGoodStationLabels[index]:show()
            sellableGoodPriceFactorLabels[index]:show()
            sellableGoodOnShipLabels[index]:show()
            sellableGoodButtons[index]:show()


            if getRarity().value < 0 then
                sellableGoodPriceLabels[index].caption = "-"
            end

            if getRarity().value < 1 then
                sellableGoodPriceFactorLabels[index].caption = "-"
            end

        end
    end

end

function refreshRoutesUI()

    if historySize == 0 then
        tabbedWindow:deactivateTab(routesTab)
        return
    end

    for index = 1, 15 do
        for j = 1, 2 do
            routePriceLabels[index][j]:hide()
            routeStationLabels[index][j]:hide()
            routeCoordLabels[index][j]:hide()
            routeStockLabels[index][j]:hide()
            routeFrames[index][j]:hide()
            routeButtons[index][j]:hide()
            routeIcons[index]:hide()
            routeAmountOnShipLabels[index][j]:hide()
        end
    end

    table.sort(routes, routesByProfit)

    if #routes == 0 then
        routePriceLabels[1][1]:show()
        routePriceLabels[1][1].caption = "No trade routes detected."%_t
        routePriceLabels[1][1].font = FontType.SciFi
        routePriceLabels[2][1]:show()
        routePriceLabels[2][1].caption = "Visit more sectors to discover new trade routes."%_t
        routePriceLabels[2][1].font = FontType.SciFi
    else
        routePriceLabels[1][1].font = FontType.Normal
        routePriceLabels[2][1].font = FontType.Normal
    end

    if routesPage > 0 then
        routeButtonLeft:show()
    else
        routeButtonLeft:hide()
    end

    if #routes > (routesPage + 1) * 15 then
        routeButtonRight:show()
    else
        routeButtonRight:hide()
    end

    local index = 0
    for i, route in pairs(routes) do

        if i > routesPage * 15 and i <= (routesPage + 1) * 15 then
            index = index + 1
            if index > 15 then break end

            local profit, suffix = getReadableNumber(routeProfit(route))

            for j, offer in pairs({route.buyable, route.sellable}) do

                routePriceLabels[index][j].caption = createMonetaryString(offer.price)
                routeStationLabels[index][j].caption = offer.station%_t % offer.titleArgs
                routeCoordLabels[index][j].caption = tostring(offer.coords)
                routeIcons[index].picture = offer.good.icon
                routeIcons[index].tooltip = offer.good:displayName(2)

                if j == 1 then
                    routeAmountOnShipLabels[index][j].caption = profit .. suffix
                    routeStockLabels[index][j].caption = math.floor(offer.stock)
                else
                    routeStockLabels[index][j].caption = math.floor(offer.maxStock - offer.stock)
                    if offer.amountOnShip > 0 then
                        routeAmountOnShipLabels[index][j].caption = offer.amountOnShip
                    else
                        routeAmountOnShipLabels[index][j].caption = "-"
                    end
                end

                routePriceLabels[index][j]:show()
                routeStationLabels[index][j]:show()
                routeCoordLabels[index][j]:show()
                routeStockLabels[index][j]:show()
                routeFrames[index][j]:show()
                routeButtons[index][j]:show()
                routeAmountOnShipLabels[index][j]:show()
                routeIcons[index]:show()
            end
        end
    end
end


local SupplyDemandSortFunctions = {}
SupplyDemandSortFunctions[SupplyDemandSortType.NameAscending] = function(a, b) return goods[a.name]:good():displayName(2) < goods[b.name]:good():displayName(2) end
SupplyDemandSortFunctions[SupplyDemandSortType.DemandAscending] = function(a, b) return (a.demand or 0) < (b.demand or 0) end
SupplyDemandSortFunctions[SupplyDemandSortType.SupplyAscending] = function(a, b) return (a.supply or 0) < (b.supply or 0) end
SupplyDemandSortFunctions[SupplyDemandSortType.SumAscending] = function(a, b) return a.sum < b.sum end
SupplyDemandSortFunctions[SupplyDemandSortType.PriceAscending] = function(a, b) return a.price < b.price end

SupplyDemandSortFunctions[SupplyDemandSortType.NameDescending] = function(a, b) return goods[a.name]:good():displayName(2) > goods[b.name]:good():displayName(2) end
SupplyDemandSortFunctions[SupplyDemandSortType.DemandDescending] = function(a, b) return (a.demand or 0) > (b.demand or 0) end
SupplyDemandSortFunctions[SupplyDemandSortType.SupplyDescending] = function(a, b) return (a.supply or 0) > (b.supply or 0) end
SupplyDemandSortFunctions[SupplyDemandSortType.SumDescending] = function(a, b) return a.sum > b.sum end
SupplyDemandSortFunctions[SupplyDemandSortType.PriceDescending] = function(a, b) return a.price > b.price end

function refreshSupplyDemandUI()
    if economyRange == 0 then
        tabbedWindow:deactivateTab(supplyDemandTab)
        return
    end

    requestNearbyEconomy()

    -- reset UI
    for i = 2, #supplyDemandLines do
        supplyDemandLines[i]:hide()
    end

    for _, button in pairs(supplyDemandLines[1].buttons) do
        button.icon = "data/textures/icons/plus.png"
    end

    local buttons = supplyDemandSortButtons[supplyDemandSortMode]
    if buttons then
        buttons.button.icon = buttons.icon
    end

    -- prepare data
    -- gather
    local productions = getEconomyData()
    if not productions then return end

    -- calculate supply / demand
    local x, y = Sector():getCoordinates()

    local map = FactoryMap()
    local supplyData, demandData, sumData = map:getSupplyAndDemand(x, y, productions)

    -- sort it
    local sorted = {}
    for good, sum in pairs(sumData) do
        table.insert(sorted, {name = good, sum = sum, supply = supplyData[good], demand = demandData[good], price = map:supplyToPriceChange(sum)})
    end

    local sortFunc = SupplyDemandSortFunctions[supplyDemandSortMode or SupplyDemandSortType.NameAscending] or function(a, b) return a.sum < b.sum end
    table.sort(sorted, sortFunc)

    if supplyDemandPage > 0 then
        supplyDemandButtonLeft:show()
    else
        supplyDemandButtonLeft:hide()
    end

    if #sorted > (supplyDemandPage + 1) * (#supplyDemandLines - 1) then
        supplyDemandButtonRight:show()
    else
        supplyDemandButtonRight:hide()
    end

    -- fill UI
    local sdLower, sdUpper = map:getSupplyDemandGradients()
    local pLower, pUpper = map:getPriceGradients()

    local c = 2
    local start = supplyDemandPage * (#supplyDemandLines - 1) + 1
    for i = start, #sorted do
        local g = sorted[i]

        local supply = g.supply
        local demand = g.demand
        local sum = g.sum
        local price = g.price

        local good = goods[g.name]:good()
        local line = supplyDemandLines[c]
        line.icon.picture = good.icon
        line.nameLabel.caption = good:displayName(100)

        if supply then
            line.supplyLabel.caption = string.format("%+.1f", supply)

            local color = multilerp(supply, 0, 75, sdUpper)
            line.supplyLabel.color = ColorRGB(color.x, color.y, color.z)
        else
            line.supplyLabel.caption = "-"
            line.supplyLabel.color = ColorRGB(0.8, 0.8, 0.8)
        end

        if demand then
            line.demandLabel.caption = string.format("%+.1f", demand)

            local color = multilerp(demand, 75, 0, sdLower)
            line.demandLabel.color = ColorRGB(color.x, color.y, color.z)

        else
            line.demandLabel.caption = "-"
            line.demandLabel.color = ColorRGB(0.8, 0.8, 0.8)
        end

        line.sumLabel.caption = string.format("%+.1f", sum)
        line.priceLabel.caption = string.format("%+.1f%%", price * 100)
        line:show()

        local color
        if sum == 0 then
            color = vec3(0.5, 0.5, 0.5)
        elseif sum > 0 then
            color = multilerp(sum, 0, 75, sdUpper)
        elseif sum < 0 then
            color = multilerp(sum, -75, 0, sdLower)
        end

        line.sumLabel.color = ColorRGB(color.x, color.y, color.z)

        if price == 0 then
            color = vec3(0.5, 0.5, 0.5)
        elseif price > 0 then
            color = multilerp(price*100, 0, 30, pUpper)
        elseif price < 0 then
            color = multilerp(price*100, -30, 0, pLower)
        end

        local col = ColorRGB(color.x, color.y, color.z)
        col.value = math.max(0.5, col.value)
        if price < 0 then col.saturation = 0.7 end
        line.priceLabel.color = col

        c = c + 1
        if c > #supplyDemandLines then break end
    end

end

function refreshUI()

    refreshBuyablesUI()
    refreshSellablesUI()
    refreshRoutesUI()
    refreshSupplyDemandUI()

end

function buildGui(window, guiType)

    local buttonCaption = "Show"%_t
    local buttonCallback = ""
    local nextPageFunc = ""
    local previousPageFunc = ""

    if guiType == 1 then
        buttonCallback = "onBuyShowButtonPressed"
        nextPageFunc = "onNextBuyablesPage"
        previousPageFunc = "onPreviousBuyablesPage"
    else
        buttonCallback = "onSellShowButtonPressed"
        nextPageFunc = "onNextSellablesPage"
        previousPageFunc = "onPreviousSellablesPage"
    end

    local size = window.size

    window:createFrame(Rect(size))

    local pictureX = 270
    local nameX = 20
    local stockX = 310
    local volX = 430
    local priceX = 480
    local priceFactorLabelX = 550
    local stationLabelX = 610
    local onShipLabelX = 880
    local buttonX = 940

    -- header
    nameLabel = window:createLabel(vec2(nameX, 10), "Name"%_t, 15)
    stockLabel = window:createLabel(vec2(stockX, 10), "Stock"%_t, 15)
    volLabel = window:createLabel(vec2(volX, 10), "Vol"%_t, 15)
    priceLabel = window:createLabel(vec2(priceX, 10), "¢", 15)
    priceFactorLabel = window:createLabel(vec2(priceFactorLabelX, 10), "%", 15)
    stationLabel = window:createLabel(vec2(stationLabelX, 10), "Station"%_t, 15)
    onShipLabel = window:createLabel(vec2(onShipLabelX, 10), "You"%_t, 15)

    nameLabel.width = 250
    stockLabel.width = 90
    volLabel.width = 50
    priceLabel.width = 70
    priceFactorLabel.width = 60
    stationLabel.width = 240
    onShipLabel.width = 70

    if guiType == 1 then
        nameLabel.mouseDownFunction = "onBuyableNameLabelClick"
        stockLabel.mouseDownFunction = "onBuyableStockLabelClick"
        volLabel.mouseDownFunction = "onBuyableVolLabelClick"
        priceLabel.mouseDownFunction = "onBuyablePriceLabelClick"
        priceFactorLabel.mouseDownFunction = "onBuyablePriceFactorLabelClick"
        stationLabel.mouseDownFunction = "onBuyableStationLabelClick"
        onShipLabel.mouseDownFunction = "onBuyableOnShipLabelClick"
    else
        nameLabel.mouseDownFunction = "onSellableNameLabelClick"
        stockLabel.mouseDownFunction = "onSellableStockLabelClick"
        volLabel.mouseDownFunction = "onSellableVolLabelClick"
        priceLabel.mouseDownFunction = "onSellablePriceLabelClick"
        priceFactorLabel.mouseDownFunction = "onSellablePriceFactorLabelClick"
        stationLabel.mouseDownFunction = "onSellableStationLabelClick"
        onShipLabel.mouseDownFunction = "onSellableOnShipLabelClick"
    end

    -- footer
    local buttonLeft = window:createButton(Rect(10, size.y - 40, 60, size.y - 10), "<", previousPageFunc)
    local buttonRight = window:createButton(Rect(size.x - 60, size.y - 40, size.x - 10, size.y - 10), ">", nextPageFunc)

    if guiType == 1 then
        buyableGoodButtonLeft = buttonLeft
        buyableGoodButtonRight = buttonRight
    else
        sellableGoodButtonLeft = buttonLeft
        sellableGoodButtonRight = buttonRight
    end

    local y = 35
    for i = 1, 15 do

        local yText = y + 6

        local frame = window:createFrame(Rect(10, y, size.x - 50, 30 + y))

        local iconPicture = window:createPicture(Rect(pictureX, yText - 5, 29 + pictureX, 29 + yText - 5), "")
        local nameLabel = window:createLabel(vec2(nameX, yText), "", 15)
        local stockLabel = window:createLabel(vec2(stockX, yText), "", 15)
        local priceLabel = window:createLabel(vec2(priceX, yText), "", 15)
        local sizeLabel = window:createLabel(vec2(volX, yText), "", 15)
        local priceFactorLabel = window:createLabel(vec2(priceFactorLabelX, yText), "", 15)
        local stationLabel = window:createLabel(vec2(stationLabelX, yText), "", 15)
        local onShipLabel = window:createLabel(vec2(onShipLabelX, yText), "", 15)
        local button = window:createButton(Rect(buttonX, yText - 6, buttonX + 30, 30 + yText - 6), "", buttonCallback)

        stockLabel.font = FontType.Normal
        priceLabel.font = FontType.Normal
        sizeLabel.font = FontType.Normal
        priceFactorLabel.font = FontType.Normal
        stationLabel.font = FontType.Normal
        onShipLabel.font = FontType.Normal

        button.icon = "data/textures/icons/position-marker.png"
        iconPicture.isIcon = 1

        if guiType == 1 then
            table.insert(buyableGoodIcons, iconPicture)
            table.insert(buyableGoodFrames, frame)
            table.insert(buyableGoodNameLabels, nameLabel)
            table.insert(buyableGoodStockLabels, stockLabel)
            table.insert(buyableGoodPriceLabels, priceLabel)
            table.insert(buyableGoodSizeLabels, sizeLabel)
            table.insert(buyableGoodPriceFactorLabels, priceFactorLabel)
            table.insert(buyableGoodStationLabels, stationLabel)
            table.insert(buyableGoodOnShipLabels, onShipLabel)
            table.insert(buyableGoodButtons, button)
        else
            table.insert(sellableGoodIcons, iconPicture)
            table.insert(sellableGoodFrames, frame)
            table.insert(sellableGoodNameLabels, nameLabel)
            table.insert(sellableGoodStockLabels, stockLabel)
            table.insert(sellableGoodPriceLabels, priceLabel)
            table.insert(sellableGoodSizeLabels, sizeLabel)
            table.insert(sellableGoodPriceFactorLabels, priceFactorLabel)
            table.insert(sellableGoodStationLabels, stationLabel)
            table.insert(sellableGoodOnShipLabels, onShipLabel)
            table.insert(sellableGoodButtons, button)
        end

        frame:hide();
        iconPicture:hide();
        nameLabel:hide();
        stockLabel:hide();
        priceLabel:hide();
        sizeLabel:hide();
        stationLabel:hide();
        onShipLabel:hide()
        button:hide();

        y = y + 35
    end

end

function buildSupplyDemandGui(window)
    local nextPageFunc = "onNextSupplyDemandPage"
    local previousPageFunc = "onPreviousSupplyDemandPage"

    local size = window.size

    window:createFrame(Rect(size))

    local iconX = 10
    local nameX = iconX + 300
    local demandX = nameX + 40
    local supplyX = demandX + 40
    local sumX = supplyX + 40
    local priceX = sumX + 40

    -- footer
    supplyDemandButtonLeft = window:createButton(Rect(10, size.y - 40, 60, size.y - 10), "<", previousPageFunc)
    supplyDemandButtonRight = window:createButton(Rect(size.x - 60, size.y - 40, size.x - 10, size.y - 10), ">", nextPageFunc)

    local lister = UIVerticalLister(Rect(size), 4, 10)
    lister.marginLeft = 15
    for i = 1, 22 do
        local vsplit = UIArbitraryVerticalSplitter(lister:nextRect(20), 10, 0, 25, 350, 470, 600, 750, 900)
        if i == 1 then lister:nextRect(1) end

        local line = UICollection()
        table.insert(supplyDemandLines, line)

        line.icon = window:createPicture(vsplit:partition(0), "data/textures/icons/help.png")
        line.icon.isIcon = true

        if i == 1 then
            line.buttons = {}

            local split = UIVerticalSplitter(vsplit:partition(1), 10, 0, 0.5); split:setLeftQuadratic()
            line.nameLabel = window:createLabel(split.right, "Name"%_t, 15)
            line.nameButton = window:createButton(split.left, "", "onSortByNamePressed");
            table.insert(line.buttons, line.nameButton)

            local split = UIVerticalSplitter(vsplit:partition(2), 10, 0, 0.5); split:setRightQuadratic()
            line.demandLabel = window:createLabel(split.left, "Demand (?)"%_t, 12)
            line.demandLabel:setRightAligned()
            line.demandButton = window:createButton(split.right, "", "onSortByDemandPressed");
            table.insert(line.buttons, line.demandButton)

            local split = UIVerticalSplitter(vsplit:partition(3), 10, 0, 0.5); split:setRightQuadratic()
            line.supplyLabel = window:createLabel(split.left, "Supply (?)"%_t, 12)
            line.supplyLabel:setRightAligned()
            line.supplyButton = window:createButton(split.right, "", "onSortBySupplyPressed");
            table.insert(line.buttons, line.supplyButton)

            local split = UIVerticalSplitter(vsplit:partition(4), 10, 0, 0.5); split:setRightQuadratic()
            line.sumLabel = window:createLabel(split.left, "Diff (?)"%_t, 12)
            line.sumLabel:setRightAligned()
            line.sumButton = window:createButton(split.right, "", "onSortBySumPressed");
            table.insert(line.buttons, line.sumButton)

            local split = UIVerticalSplitter(vsplit:partition(5), 10, 0, 0.5); split:setRightQuadratic()
            line.priceLabel = window:createLabel(split.left, "Price % (?)"%_t, 12)
            line.priceLabel:setRightAligned()
            line.priceButton = window:createButton(split.right, "", "onSortByPricePressed");
            table.insert(line.buttons, line.priceButton)

            line.supplyLabel.tooltip = "Supply of goods provided by factories and other stations of nearby sectors."%_t
            line.demandLabel.tooltip = "Demand of goods required by factories and other stations of nearby sectors."%_t
            line.sumLabel.tooltip = "Difference between supply and demand. This difference determines price fluctuation of goods in this sector."%_t
            line.priceLabel.tooltip = "Price fluctuation of goods in this sector. Prices of goods are influenced by supply and demand rates."%_t

            for _, button in pairs(line.buttons) do
                button.hasFrame = false
                button.icon = "data/textures/icons/arrow-down2.png"
            end

            line.icon.tooltip = "Stations that buy or sell goods influence the supply and demand rates of those goods in nearby sectors. A factory can have an influence range of up to 25 sectors."%_t

            supplyDemandSortButtons[SupplyDemandSortType.NameAscending] = {button = line.nameButton, icon = "data/textures/icons/arrow-up2.png"}
            supplyDemandSortButtons[SupplyDemandSortType.DemandAscending] = {button = line.demandButton, icon = "data/textures/icons/arrow-up2.png"}
            supplyDemandSortButtons[SupplyDemandSortType.SupplyAscending] = {button = line.supplyButton, icon = "data/textures/icons/arrow-up2.png"}
            supplyDemandSortButtons[SupplyDemandSortType.SumAscending] = {button = line.sumButton, icon = "data/textures/icons/arrow-up2.png"}
            supplyDemandSortButtons[SupplyDemandSortType.PriceAscending] = {button = line.priceButton, icon = "data/textures/icons/arrow-up2.png"}

            supplyDemandSortButtons[SupplyDemandSortType.NameDescending] = {button = line.nameButton, icon = "data/textures/icons/arrow-down2.png"}
            supplyDemandSortButtons[SupplyDemandSortType.DemandDescending] = {button = line.demandButton, icon = "data/textures/icons/arrow-down2.png"}
            supplyDemandSortButtons[SupplyDemandSortType.SupplyDescending] = {button = line.supplyButton, icon = "data/textures/icons/arrow-down2.png"}
            supplyDemandSortButtons[SupplyDemandSortType.SumDescending] = {button = line.sumButton, icon = "data/textures/icons/arrow-down2.png"}
            supplyDemandSortButtons[SupplyDemandSortType.PriceDescending] = {button = line.priceButton, icon = "data/textures/icons/arrow-down2.png"}
        else
            line.nameLabel = window:createLabel(vsplit:partition(1), "", 12)
            line.demandLabel = window:createLabel(vsplit:partition(2), "", 15)
            line.demandLabel:setRightAligned()
            line.supplyLabel = window:createLabel(vsplit:partition(3), "", 15)
            line.supplyLabel:setRightAligned()
            line.sumLabel = window:createLabel(vsplit:partition(4), "", 15)
            line.sumLabel:setRightAligned()
            line.priceLabel = window:createLabel(vsplit:partition(5), "", 15)
            line.priceLabel:setRightAligned()
        end

        line:insert(line.icon)
        line:insert(line.nameLabel)
        line:insert(line.demandLabel)
        line:insert(line.supplyLabel)
        line:insert(line.sumLabel)
        line:insert(line.priceLabel)

        if i > 1 then
            line:hide()
        end
    end

end

function buildRoutesGui(window)
    local buttonCaption = "Show"%_t

    local buttonCallback = "onRouteShowStationPressed"
    local nextPageFunc = "onNextRoutesPage"
    local previousPageFunc = "onPreviousRoutesPage"

    local size = window.size

    window:createFrame(Rect(size))

    local fontSize = 12

    local priceX = 10
    local coordLabelX = 60
    local stockX = 150
    local stationLabelX = 200
    local onShipLabelX = 360

    -- footer
    routeButtonLeft = window:createButton(Rect(10, size.y - 40, 60, size.y - 10), "<", previousPageFunc)
    routeButtonRight = window:createButton(Rect(size.x - 60, size.y - 40, size.x - 10, size.y - 10), ">", nextPageFunc)

    local y = 35
    for i = 1, 15 do

        local yText = y + 6

        local msplit = UIVerticalSplitter(Rect(10, y, size.x - 15, 25 + y), 10, 0, 0.5)
        msplit.leftSize = 30

        local icon = window:createPicture(msplit.left, "")
        icon.isIcon = 1
        icon.picture = "data/textures/icons/circuitry.png"
        icon:hide()

        local vsplit = UIVerticalSplitter(msplit.right, 10, 0, 0.5)

        routeIcons[i] = icon
        routeFrames[i] = {}
        routePriceLabels[i] = {}
        routeCoordLabels[i] = {}
        routeStockLabels[i] = {}
        routeStationLabels[i] = {}
        routeButtons[i] = {}
        routeAmountOnShipLabels[i] = {}

        for j, rect in pairs({vsplit.left, vsplit.right}) do

            -- create UI for good + station where to get it
            local ssplit = UIVerticalSplitter(rect, 10, 0, 0.5)
            ssplit.rightSize = 30
            local x = ssplit.left.lower.x

            if i == 1 then
                -- header
                window:createLabel(vec2(x + priceX, 10), "Cr"%_t, fontSize)
                window:createLabel(vec2(x + coordLabelX, 10), "Coord"%_t, fontSize)

                if j == 1 then
                    window:createLabel(vec2(x + stationLabelX, 10), "From"%_t, fontSize)
                    window:createLabel(vec2(x + stockX, 10), "Stock"%_t, fontSize)
                    window:createLabel(vec2(x + onShipLabelX, 10), "Profit"%_t, fontSize)
                else
                    window:createLabel(vec2(x + stationLabelX, 10), "To"%_t, fontSize)
                    window:createLabel(vec2(x + stockX, 10), "Wants"%_t, fontSize)

                    window:createLabel(vec2(x + onShipLabelX, 10), "You"%_t, fontSize)
                end
            end

            local frame = window:createFrame(ssplit.left)

            local priceLabel = window:createLabel(vec2(x + priceX, yText), "", fontSize)
            local stationLabel = window:createLabel(vec2(x + stationLabelX, yText), "", fontSize)
            local stockLabel = window:createLabel(vec2(x + stockX, yText), "", fontSize)
            local coordLabel = window:createLabel(vec2(x + coordLabelX, yText), "", fontSize)
            local onShipLabel = window:createLabel(vec2(x + onShipLabelX, yText), "", fontSize)

            local button = window:createButton(ssplit.right, "", buttonCallback)
            button.icon = "data/textures/icons/position-marker.png"

            onShipLabel.font = FontType.Normal

            frame:hide();
            stockLabel:hide()
            priceLabel:hide();
            coordLabel:hide();
            stationLabel:hide();
            button:hide();
            onShipLabel:hide()

            stockLabel.font = FontType.Normal
            priceLabel.font = FontType.Normal
            coordLabel.font = FontType.Normal
            stationLabel.font = FontType.Normal

            table.insert(routeFrames[i], frame)
            table.insert(routeStockLabels[i], stockLabel)
            table.insert(routePriceLabels[i], priceLabel)
            table.insert(routeCoordLabels[i], coordLabel)
            table.insert(routeStationLabels[i], stationLabel)
            table.insert(routeButtons[i], button)
            table.insert(routeAmountOnShipLabels[i], onShipLabel)
        end


        y = y + 32
    end

end


function onRouteShowStationPressed(button_in)

    for i, buttons in pairs(routeButtons) do
        for j, button in pairs(buttons) do
            if button.index == button_in.index then
                local stationIndex
                local coords
                if j == 1 then
                    stationIndex = routes[routesPage * 15 + i].buyable.stationIndex
                    coords = routes[routesPage * 15 + i].buyable.coords
                else
                    stationIndex = routes[routesPage * 15 + i].sellable.stationIndex
                    coords = routes[routesPage * 15 + i].sellable.coords
                end

                local x, y = Sector():getCoordinates()

                if coords.x == x and coords.y == y then
                    Player().selectedObject = Sector():getEntity(stationIndex)
                else
                    GalaxyMap():setSelectedCoordinates(coords.x, coords.y)
                    GalaxyMap():show(coords.x, coords.y)
                end

                return
            end
        end
    end

end

function onNextRoutesPage()
    routesPage = routesPage + 1
    refreshUI()
end

function onPreviousRoutesPage()
    routesPage = math.max(0, routesPage - 1)
    refreshUI()
end

function onNextSupplyDemandPage()
    supplyDemandPage = supplyDemandPage + 1
    refreshSupplyDemandUI()
end

function onPreviousSupplyDemandPage()
    supplyDemandPage = math.max(0, supplyDemandPage - 1)
    refreshSupplyDemandUI()
end

function onNextSellablesPage()
    sellablesPage = sellablesPage + 1
    refreshUI()
end

function onPreviousSellablesPage()
    sellablesPage = math.max(0, sellablesPage - 1)
    refreshUI()
end

function onNextBuyablesPage()
    buyablesPage = buyablesPage + 1
    refreshUI()
end

function onPreviousBuyablesPage()
    buyablesPage = math.max(0, buyablesPage - 1)
    refreshUI()
end

function onBuyShowButtonPressed(button_in)

    for index, button in pairs(buyableGoodButtons) do
        if button.index == button_in.index then
            Player().selectedObject = Sector():getEntity(buyable[buyablesPage * 15 + index].stationIndex)
            return
        end
    end

end

function onSellShowButtonPressed(button_in)

    for index, button in pairs(sellableGoodButtons) do
        if button.index == button_in.index then
            Player().selectedObject = Sector():getEntity(sellable[sellablesPage * 15 + index].stationIndex)
            return
        end
    end

end

function setSortFunction(default, alternative, buyable)

    if buyable == 1 then
        if buyableSortFunction == default then
            buyableSortFunction = alternative
        else
            buyableSortFunction = default
        end
    else
        if sellableSortFunction == default then
            sellableSortFunction = alternative
        else
            sellableSortFunction = default
        end
    end

    refreshUI()
end

function onSortByNamePressed()
    if supplyDemandSortMode == SupplyDemandSortType.NameAscending then
        supplyDemandSortMode = SupplyDemandSortType.NameDescending
    else
        supplyDemandSortMode = SupplyDemandSortType.NameAscending
    end

    refreshSupplyDemandUI()
end

function onSortByDemandPressed()
    if supplyDemandSortMode == SupplyDemandSortType.DemandAscending then
        supplyDemandSortMode = SupplyDemandSortType.DemandDescending
    else
        supplyDemandSortMode = SupplyDemandSortType.DemandAscending
    end

    refreshSupplyDemandUI()
end

function onSortBySupplyPressed()
    if supplyDemandSortMode == SupplyDemandSortType.SupplyAscending then
        supplyDemandSortMode = SupplyDemandSortType.SupplyDescending
    else
        supplyDemandSortMode = SupplyDemandSortType.SupplyAscending
    end

    refreshSupplyDemandUI()
end

function onSortBySumPressed()
    if supplyDemandSortMode == SupplyDemandSortType.SumAscending then
        supplyDemandSortMode = SupplyDemandSortType.SumDescending
    else
        supplyDemandSortMode = SupplyDemandSortType.SumAscending
    end

    refreshSupplyDemandUI()
end

function onSortByPricePressed()
    if supplyDemandSortMode == SupplyDemandSortType.PriceAscending then
        supplyDemandSortMode = SupplyDemandSortType.PriceDescending
    else
        supplyDemandSortMode = SupplyDemandSortType.PriceAscending
    end

    refreshSupplyDemandUI()
end

function onBuyableNameLabelClick(index, button)
    setSortFunction(sortByNameAsc, sortByNameDes, 1)
end

function onBuyableStockLabelClick()
    setSortFunction(sortByStockAsc, sortByStockDes, 1)
end

function onBuyableVolLabelClick()
    setSortFunction(sortByVolAsc, sortByVolDes, 1)
end

function onBuyablePriceLabelClick()
    if getRarity().value < 1 then return end
    setSortFunction(sortByPriceAsc, sortByPriceDes, 1)
end

function onBuyablePriceFactorLabelClick()
    if getRarity().value < 2 then return end
    setSortFunction(sortByPriceFactorAsc, sortByPriceFactorDes, 1)
end

function onBuyableStationLabelClick()
    setSortFunction(sortByStationAsc, sortByStationDes, 1)
end

function onBuyableOnShipLabelClick()
    setSortFunction(sortByAmountOnShipDes, sortByAmountOnShipAsc, 1)
end


function onSellableNameLabelClick(index, button)
    setSortFunction(sortByNameAsc, sortByNameDes, 0)
end

function onSellableStockLabelClick()
    setSortFunction(sortByStockAsc, sortByStockDes, 0)
end

function onSellableVolLabelClick()
    setSortFunction(sortByVolAsc, sortByVolDes, 0)
end

function onSellablePriceLabelClick()
    if getRarity().value < 1 then return end
    setSortFunction(sortByPriceAsc, sortByPriceDes, 0)
end

function onSellablePriceFactorLabelClick()
    if getRarity().value < 2 then return end
    setSortFunction(sortByPriceFactorAsc, sortByPriceFactorDes, 0)
end

function onSellableStationLabelClick()
    setSortFunction(sortByStationAsc, sortByStationDes, 0)
end

function onSellableOnShipLabelClick()
    setSortFunction(sortByAmountOnShipDes, sortByAmountOnShipAsc, 0)
end


end

