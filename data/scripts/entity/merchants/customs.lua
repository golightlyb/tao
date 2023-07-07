package.path = package.path .. ";data/scripts/lib/?.lua"

include ("stringutility")
include ("goods")
include ("utility")
include ("randomext")
include ("merchantutility")
include ("stringutility")
include ("callable")
include ("relations")
local TradingAPI = include ("tradingmanager")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace Customs
Customs = {}
Customs = TradingAPI:CreateNamespace()

local itemStart = 0
local numStolenItems = 0
local pageLabel
local playerCargos = {}

function Customs.interactionPossible(playerIndex, option)
    return true
end

function Customs.initialize()
    if onServer() then
        local station = Entity()
        if station.title == "" then
            station.title = "Customs"%_t
        end
        station:addScriptOnce("data/scripts/entity/merchants/customslicense.lua")
    end
    
    if onClient() then
        if EntityIcon().icon == "" then
            EntityIcon().icon = "data/textures/icons/pixel/crate.png"
        end
    end
end

function Customs.initializationFinished()
    -- use the initilizationFinished() function on the client since in initialize() we may not be able to access Sector scripts on the client
    if onClient() then
        local ok, r = Sector():invokeFunction("radiochatter", "addSpecificLines", Entity().id.string,
        {
            "Please be ready to present your cargo manifest and tax information."%_t,
            "We pay a flat fee for recovered stolen goods. Valid license holders only."%_t,
        })
    end
end

function Customs.initUI()
    local station = Entity()

    local res = getResolution()
    local size = vec2(950, 600)

    local menu = ScriptUI()
    local window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))

    window.caption = "Customs"%_t
    window.showCloseButton = 1
    window.moveable = 1
    menu:registerWindow(window, "Customs"%_t, 10);

    -- create a tabbed window inside the main window
    local tabbedWindow = window:createTabbedWindow(Rect(vec2(10, 10), size - 10))

    local sellTab = tabbedWindow:createTab("Deposit"%_t, "data/textures/icons/sell.png", "Deposit Stolen Goods"%_t)
    Customs.buildSellGui(sellTab)
    Customs.trader.guiInitialized = true
end

function Customs.onShowWindow()
    local buyer = Player()
    local ship = buyer.craft
    if ship.factionIndex == buyer.allianceIndex then
        buyer = buyer.alliance
    end

    -- read cargos and sort
    local cargos = {}
    for good, amount in pairs(ship:getCargos()) do
        table.insert(cargos, {good = good, amount = amount})
    end

    function comp(a, b) return a.good.name < b.good.name end
    table.sort (cargos, comp)

    for _, line in pairs(Customs.trader.boughtLines) do
        line:hide();
        line.number.text = "0"
    end

    Customs.trader.boughtGoods = {}
    local faction = Faction()
    local boughtGoods = Customs.trader.boughtGoods
    local i = 1
    local itemOffset = 0
    local stolenGoods = {}

    for _, p in pairs(cargos) do
        local good, amount = p.good, p.amount

        if good.stolen then
            table.insert(stolenGoods, p)
            if i - 1 < itemStart then
                goto continue
            end

            if i - itemStart <= #Customs.trader.boughtLines then
                -- do sell lines
                local line = Customs.trader.boughtLines[i - itemStart]
                line:show()
                line.icon.picture = good.icon
                line.name.caption = good:displayName(2)
                line.price.caption = createMonetaryString(round(Customs.getStolenBuyPrice(good.name)))
                line.size.caption = round(good.size, 2)
                line.you.caption = amount
                line.stock.caption = "   -"

                boughtGoods[i - itemStart] = good
            end

            ::continue::

            i = i + 1
        end
    end

    -- if the player has no stolen goods
    if #stolenGoods == 0 then
        -- the sell stolen goods tab
        local line = Customs.trader.boughtLines[1]
        line:show()
        line.name.caption = "You have no stolen goods on you."%_t
        line.price.caption = ""
        line.you.caption = ""
        line.stock.caption = ""
        line.size.caption = ""
        line.icon:hide()
        line.button:hide()
        line.number:hide()
    end
    
    -- update page label caption
    numStolenItems = i - 1

    local itemEnd = math.min(numStolenItems, itemStart + 13)
    local itemStartText = math.min(itemStart + 1, itemEnd)
    --pageLabel.caption = itemStartText .. " - " .. itemEnd .. " / " .. numStolenItems
end

function Customs.onPageLeftButtonPressed()
    local itemsPerPage = 13

    local page = itemStart / itemsPerPage
    page = math.min(page - 1, math.ceil(numStolenItems / itemsPerPage) - 1)
    page = math.max(page, 0)
    itemStart = page * itemsPerPage
    
    Customs.onShowWindow()
end

function Customs.onPageRightButtonPressed()
    local itemsPerPage = 13

    local page = itemStart / itemsPerPage
    page = math.min(page + 1, math.ceil(numStolenItems / itemsPerPage) - 1)
    page = math.max(page, 0)
    itemStart = page * itemsPerPage

    Customs.onShowWindow()
end

function Customs.onSellTextEntered(textBox)
    local self = Customs.trader

    local enteredNumber = tonumber(textBox.text)
    if enteredNumber == nil then
        enteredNumber = 0
    end

    local newNumber = enteredNumber

    local goodIndex = nil
    for i, line in pairs(self.boughtLines) do
        if line.number.index == textBox.index then
            goodIndex = i
            break
        end
    end
    if goodIndex == nil then return end

    local good = self.boughtGoods[goodIndex]
    if not good then
        print ("good with index " .. goodIndex .. " isn't bought")
        printEntityDebugInfo();
        return
    end

    local ship = Player().craft
    local msg

    -- make sure the player does not sell more than he has in his cargo bay
    local amountOnPlayerShip = ship:getCargoAmount(good)
    if amountOnPlayerShip == nil then return end --> no cargo bay

    if amountOnPlayerShip < newNumber then
        newNumber = amountOnPlayerShip
        if newNumber == 0 then
            msg = "You don't have any of this!"%_t
        end
    end

    if msg then
        self:sendError(nil, msg)
    end

    -- maximum number of sellable things is the amount the player has on his ship
    if newNumber ~= enteredNumber then
        textBox.text = newNumber
    end
end

function Customs.onSellButtonPressed(button)
    local self = Customs.trader

    local shipIndex = Player().craftIndex
    local goodIndex = nil

    for i, line in ipairs(self.boughtLines) do
        if line.button.index == button.index then
            goodIndex = i
        end
    end

    if goodIndex == nil then
        return
    end

    local amount = self.boughtLines[goodIndex].number.text
    if amount == "" then
        amount = 0
    else
        amount = tonumber(amount)
    end

    local good = self.boughtGoods[goodIndex]
    if not good then
        print ("internal error, good with index " .. goodIndex .. " of sell button not found.")
        printEntityDebugInfo()
        return
    end

    invokeServerFunction("buyIllegalGood", good.name, amount)
end

function Customs.buyIllegalGood(goodName, amount)

    if anynils(goodName, amount) then return end

    local seller, ship, player = getInteractingFaction(callingPlayer, AlliancePrivilege.AddResources, AlliancePrivilege.SpendItems)
    if not seller then return end

    local self = Customs.trader

    -- check if the specific good from the player can be bought
    local cargos = ship:findCargos(goodName)
    local good = nil
    local msg

    for g, amount in pairs(cargos) do
        local ok
        ok, msg = self:isBoughtBySelf(g)

        if ok and g.stolen then
            good = g
            break
        end
    end

    msg = msg or "You don't have any %s to sell!"%_t
    if not good then
        self:sendError(seller, msg, goodName)
        return
    end

    local station = Entity()
    local stationFaction = Faction()

    -- make sure the player does not sell more than he has in his cargo bay
    local amountOnShip = ship:getCargoAmount(good)

    if amountOnShip < amount then
        amount = amountOnShip

        if amountOnShip == 0 then
            self:sendError(seller, "You don't have any %s on your ship."%_t, good:displayName(0))
        end
    end

    if amount == 0 then
        return
    end

    -- begin transaction
    -- calculate price
    local price = Customs.getStolenBuyPrice(goodName) * amount
    local relativeRelationsChangePrice = Customs.getStolenRelationBuyPrice(goodName) * amount

    if not noDockCheck then
        -- test the docking last so the player can know what he can buy from afar already
        local errors = {}
        errors[EntityType.Station] = "You must be docked to the station to trade."%_T
        errors[EntityType.Ship] = "You must be closer to the ship to trade."%_T
        if not CheckShipDocked(seller, ship, station, errors) then
            return
        end
    end

    local x, y = Sector():getCoordinates()

    local toDescription = Format("\\s(%1%:%2%) %3% deposited %4% stolen %5% with customs for %6% Credits."%_T,
            x, y, ship.name, amount, good:pluralForm(amount), createMonetaryString(price))

    -- give money to ship faction
    seller:receive(toDescription, price)

    -- give tax to station owner
    receiveTransactionTax(station, price * self.tax)

    -- log tax
    local tax = round(price * self.tax)
    if tax > 0 then
        self.stats.moneyGainedFromTax = self.stats.moneyGainedFromTax + tax
    end

    -- remove goods from ship
    ship:removeCargo(good, amount)
    -- the goods just disappear, since they are being sold to "a shady figure"

    -- trading (non-military) ships get higher relation gain
    local relationsChange = GetRelationChangeFromMoney(relativeRelationsChangePrice)
    --if ship:getNumArmedTurrets() <= 1 then
    --    relationsChange = relationsChange * 1.5
    --end

    changeRelations(seller, stationFaction, relationsChange, RelationChangeType.Commerce, nil, nil, station)

    invokeClientFunction(Player(callingPlayer), "onShowWindow")
end
callable(Customs, "buyIllegalGood")

function Customs.receiveGoods()
    Customs.onShowWindow()
end

function Customs.trader:isBoughtBySelf(good)
    local original = goods[goodsKeyFromName[good.name] ]
    
    if not original then
        return false, "You can't sell ${displayPlural} here."%_t % {displayPlural = good:displayName(2)}
    end

    return true
end

Customs.oldBuyFromShip = Customs.buyFromShip
function Customs.buyFromShip(...)
    Customs.oldBuyFromShip(...)
    invokeClientFunction(Player(callingPlayer), "onShowWindow")
end

-- price for which goods are bought from players
function Customs.getStolenBuyPrice(goodName)
    local good = goods[goodsKeyFromName[goodName] ]
    if not good then return 0 end
    return 10 * good.size
end

function Customs.getStolenRelationBuyPrice(goodName)
    local good = goods[goodsKeyFromName[goodName] ]
    if not good then return 0 end
    return good.price
end


