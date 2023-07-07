

local old_TradingManager_initializeTrading = TradingManager.initializeTrading
function TradingManager:initializeTrading(boughtGoodsIn, soldGoodsIn, policiesIn)

    if not policiesIn then
        policiesIn = {
            -- we use illegal as a standin for "military goods".
            sellsIllegal = true,
            buysIllegal  = true,

            sellsStolen = false,
            buysStolen = false,

            sellsSuspicious = false,
            buysSuspicious = false,
        }
    end

    old_TradingManager_initializeTrading(self, boughtGoodsIn, soldGoodsIn, policiesIn)
end

--[[
function TradingManager:updateBoughtGoodGui(index, good, price)
    if not self.guiInitialized then return end

    local maxAmount = self:getMaxStock(good)
    local amount = self:getNumGoods(good.name)

    if not index then
        for i, g in pairs(self.boughtGoods) do
            if g.name == good.name then
                index = i
                break
            end
        end
    end

    if not index then return end

    local line = self.boughtLines[index]
    if not line then return end

    line.name.caption = good:displayName(100)
    line.name.color = good.color
    local description = good.displayDescription
    if description == "" then
        line.name.tooltip = nil
        line.icon.tooltip = nil
    else
        line.name.tooltip = description
        line.icon.tooltip = description
    end
    line.stock.caption = amount .. "/" .. maxAmount
    line.price.caption = createMonetaryString(price)
    line.size.caption = round(good.size, 2)
    line.icon.picture = good.icon

    local ownCargo = 0
    local ship = Entity(Player().craftIndex)
    if ship then
        ownCargo = ship:getCargoAmount(good)
    end
    if ownCargo == 0 then
        ownCargo = "-"
        line.you.tooltip = nil
    else
        line.you.tooltip = "You can sell ${amount} more of this."%_t % {amount = ownCargo}
    end
    line.you.caption = tostring(ownCargo)

    line:show()
end

function TradingManager:updateSoldGoodGui(index, good, price)

    if not self.guiInitialized then return end

    local maxAmount = self:getMaxStock(good)
    local amount = self:getNumGoods(good.name)

    if not index then
        for i, g in pairs(self.soldGoods) do
            if g.name == good.name then
                index = i
                break
            end
        end
    end

    if not index then return end

    local line = self.soldLines[index]
    if not line then return end

    line.icon.picture = good.icon
    line.name.caption = good:displayName(100)
    line.name.color = good.color
    local description = good.displayDescription
    if description == "" then
        line.name.tooltip = nil
        line.icon.tooltip = nil
    else
        line.name.tooltip = description
        line.icon.tooltip = description
    end
    line.stock.caption = amount .. "/" .. maxAmount
    line.price.caption = createMonetaryString(price)
    line.size.caption = round(good.size, 2)

    for i, good in pairs(self.soldGoods) do
        local line = self.soldLines[i]

        local ownCargo = 0
        local ship = Entity(Player().craftIndex)
        if ship then
            ownCargo = math.floor((ship.freeCargoSpace or 0) / good.size)
        end

        if ownCargo == 0 then ownCargo = "-" end
        line.you.caption = tostring(ownCargo)
        line.you.tooltip = "You can buy ${amount} more of this."%_t % {amount = ownCargo}
    end

    line:show()

end
--]]


---- updated UI with left/right page buttons

function TradingManager:onPageLeftButtonPressed()
end

function TradingManager:onPageRightButtonPressed()
end

function TradingManager:buildGui(window, guiType)

    local buttonCaption = ""
    local buttonCallback = ""
    local textCallback = ""

    if guiType == 1 then
        buttonCaption = "Buy"%_t
        buttonCallback = "onBuyButtonPressed"
        textCallback = "onBuyTextEntered"
    else
        buttonCaption = "Sell"%_t
        buttonCallback = "onSellButtonPressed"
        textCallback = "onSellTextEntered"
    end

    local size = window.size
    local pos = window.lower

--    window:createFrame(Rect(size))

    local pictureX = 270
    local nameX = 10
    local stockX = 310
    local volX = 460
    local priceX = 530
    local youX = 630
    local textBoxX = 720
    local buttonX = 790

    local buttonSize = 70

    -- header
    window:createLabel(vec2(nameX, 0), "NAME"%_t, 15)
    window:createLabel(vec2(stockX, 0), "STOCK"%_t, 15)

    local l = window:createLabel(Rect(priceX, 0, youX - 10, 35), "¢", 15)
    l:setTopRightAligned()

    local l = window:createLabel(Rect(volX, 0, priceX - 10, 35), "VOL"%_t, 15)
    l:setTopRightAligned()

    if guiType == 1 then
        local label = window:createLabel(Rect(youX, 0, textBoxX - 20, 35), "MAX"%_t, 15)
        label:setTopRightAligned()
    else
        local l = window:createLabel(Rect(youX, 0, textBoxX - 20, 35), "YOU"%_t, 15)
        l:setTopRightAligned()
    end

    -- NEW
    -- buttons and labels for page turning
    window:createButton(Rect(10, size.y - 40, 70, size.y - 10), "<", "onPageLeftButtonPressed")
    window:createButton(Rect(size.x - 70, size.y - 40, size.x - 10, size.y - 10), ">", "onPageRightButtonPressed")

    pageLabel = window:createLabel(vec2(), "", 20)
    pageLabel.lower = window.lower + vec2(0, size.y - 10)
    pageLabel.upper = window.lower + vec2(size.x, size.y - 40)
    pageLabel.centered = 1
    
    local y = 30
    for i = 1, 13 do

        local yText = y + 6

        local frame = window:createFrame(Rect(0, y, textBoxX - 10, 30 + y))

        local icon = window:createPicture(Rect(pictureX, yText - 5, 29 + pictureX, 29 + yText - 5), "")
        local nameLabel = window:createLabel(vec2(nameX, yText), "", 15)
        local stockLabel = window:createLabel(vec2(stockX, yText), "", 15)
        local priceLabel = window:createLabel(Rect(priceX, yText, youX - 10, yText + 35), "", 15)
        local sizeLabel = window:createLabel(Rect(volX, yText, priceX - 10, yText + 35), "", 15)
        local youLabel = window:createLabel(Rect(youX, yText, textBoxX - 20, yText + 35), "", 15)
        local numberTextBox = window:createTextBox(Rect(textBoxX, yText - 6, 60 + textBoxX, 30 + yText - 6), textCallback)
        local button = window:createButton(Rect(buttonX, yText - 6, window.size.x, 30 + yText - 6), buttonCaption, buttonCallback)

        priceLabel:setTopRightAligned()
        sizeLabel:setTopRightAligned()
        youLabel:setTopRightAligned()

        nameLabel.width = pictureX - nameX
        nameLabel.shortenText = true

        button.maxTextSize = 16

        numberTextBox.text = "0"
        numberTextBox.allowedCharacters = "0123456789"
        numberTextBox.clearOnClick = 1

        icon.isIcon = 1

        local show = function (self)
            self.icon:show()
            self.frame:show()
            self.name:show()
            self.stock:show()
            self.price:show()
            self.size:show()
            self.number:show()
            self.button:show()
            self.you:show()
        end
        local hide = function (self)
            self.icon:hide()
            self.frame:hide()
            self.name:hide()
            self.stock:hide()
            self.price:hide()
            self.size:hide()
            self.number:hide()
            self.button:hide()
            self.you:hide()
        end

        local line = {icon = icon, frame = frame, name = nameLabel, stock = stockLabel, price = priceLabel, you = youLabel, size = sizeLabel, number = numberTextBox, button = button, show = show, hide = hide}
        line:hide()

        if guiType == 1 then
            table.insert(self.soldLines, line)
        else
            table.insert(self.boughtLines, line)
        end

        y = y + 35
    end

end


---- fix looking up goods

old_TradingManager_getNumGoods = TradingManager.getNumGoods
function TradingManager:getNumGoods(name)
    name = GetGoodID(name) -- not name!
    return old_TradingManager_getNumGoods(self, name)
end

old_TradingManager_getMaxGoods = TradingManager.getMaxGoods
function TradingManager:getMaxGoods(name)
    name = GetGood(name).name
    return old_TradingManager_getMaxGoods(self, name)
end

local old_TradingManager_getGoodSize = TradingManager.getGoodSize
function TradingManager:getGoodSize(name)
    name = GetGood(name).name
    return old_TradingManager_getGoodSize(self, name)
end

local old_TradingManager_increaseGoods = TradingManager.increaseGoods
function TradingManager:increaseGoods(name, delta)
    name = GetGood(name).name
    return old_TradingManager_increaseGoods(self, name, delta)
end

local old_TradingManager_decreaseGoods = TradingManager.decreaseGoods
function TradingManager:decreaseGoods(name, amount)
    name = GetGood(name).name
    return old_TradingManager_decreaseGoods(self, name, amount)
end

function TradingManager:updateOrganizeGoodsBulletins(timeStep)
end

function TradingManager:updateDeliveryBulletins(timeStep)
end

function PublicNamespace.CreateNamespace()
    local result = {}

    local trader = PublicNamespace.CreateTradingManager()
    result.trader = trader
    result.updateDeliveryBulletins = function(...) return trader:updateDeliveryBulletins(...) end
    result.updateOrganizeGoodsBulletins = function(...) return trader:updateOrganizeGoodsBulletins(...) end
    result.getSellPrice = function(...) return trader:getSellPrice(...) end
    result.getBuyPrice = function(...) return trader:getBuyPrice(...) end
    result.getGoodByName = function(...) return trader:getGoodByName(...) end
    result.getSoldGoodByName = function(...) return trader:getSoldGoodByName(...) end
    result.getBoughtGoodByName = function(...) return trader:getBoughtGoodByName(...) end
    result.getMaxStock = function(...) return trader:getMaxStock(...) end
    result.getGoodSize = function(...) return trader:getGoodSize(...) end
    result.getMaxGoods = function(...) return trader:getMaxGoods(...) end
    result.getNumGoods = function(...) return trader:getNumGoods(...) end
    result.getStock = function(...) return trader:getStock(...) end
    result.getSoldGoods = function(...) return trader:getSoldGoods(...) end
    result.getBoughtGoods = function(...) return trader:getBoughtGoods(...) end
    result.getBuyPriceFactor = function(...) return trader.buyPriceFactor end
    result.getSellPriceFactor = function(...) return trader.sellPriceFactor end
    result.setBuyPriceFactor = function(...) return trader:setBuyPriceFactor(...) end
    result.setSellPriceFactor = function(...) return trader:setSellPriceFactor(...) end
    result.useUpBoughtGoods = function(...) return trader:useUpBoughtGoods(...) end
    result.decreaseGoods = function(...) return trader:decreaseGoods(...) end
    result.increaseGoods = function(...) return trader:increaseGoods(...) end
    result.sellToShip = function(...) return trader:sellToShip(...) end
    result.buyFromShip = function(...) return trader:buyFromShip(...) end
    
    result.onSellButtonPressed = function(...) return trader:onSellButtonPressed(...) end
    result.onBuyButtonPressed = function(...) return trader:onBuyButtonPressed(...) end
    result.onSellTextEntered = function(...) return trader:onSellTextEntered(...) end
    result.onBuyTextEntered = function(...) return trader:onBuyTextEntered(...) end
    result.buildGui = function(...) return trader:buildGui(...) end
    result.buildSellGui = function(...) return trader:buildSellGui(...) end
    result.buildBuyGui = function(...) return trader:buildBuyGui(...) end
    result.updateSoldGoodAmount = function(...) return trader:updateSoldGoodAmount(...) end
    result.updateBoughtGoodAmount = function(...) return trader:updateBoughtGoodAmount(...) end
    result.receiveGoods = function(...) return trader:receiveGoods(...) end
    result.sendGoods = function(...) return trader:sendGoods(...) end
    result.requestGoods = function(...) return trader:requestGoods(...) end
    result.initializeTrading = function(...) return trader:initializeTrading(...) end
    result.getInitialGoods = function(...) return trader:getInitialGoods(...) end
    result.simulatePassedTime = function(...) return trader:simulatePassedTime(...) end

    result.secureTradingGoods = function(...) return trader:secureTradingGoods(...) end
    result.restoreTradingGoods = function(...) return trader:restoreTradingGoods(...) end
    result.sendError = function(...) return trader:sendError(...) end
    result.buyGoods = function(...) return trader:buyGoods(...) end
    result.sellGoods = function(...) return trader:sellGoods(...) end
    result.getBuysFromOthers = function(...) return trader:getBuysFromOthers(...) end
    result.getSellsToOthers = function(...) return trader:getSellsToOthers(...) end
    result.setBuysFromOthers = function(...) return trader:setBuysFromOthers(...) end
    result.setSellsToOthers = function(...) return trader:setSellsToOthers(...) end

    result.setUseUpGoodsEnabled = function(enabled) trader.useUpGoodsEnabled = enabled end
    result.getBuyGoodsErrorMessage = function(enabled) trader.getBuyGoodsErrorMessage = enabled end
    result.getSellGoodsErrorMessage = function(enabled) trader.getSellGoodsErrorMessage = enabled end
    result.getTax = function() return trader:getTax() end
    result.getFactionPaymentFactor = function() return trader:getFactionPaymentFactor() end

    -- added
    result.onPageRightButtonPressed = function(...) return trader:onPageRightButtonPressed(...) end
    result.onPageLeftButtonPressed = function(...) return trader:onPageLeftButtonPressed(...) end
    
    -- the following comment is important for a unit test
    -- Dynamic Namespace result
    callable(result, "sendGoods")
    callable(result, "sellToShip")
    callable(result, "buyFromShip")

    return result
end

