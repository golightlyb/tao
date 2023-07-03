
-- update the buy tab (the tab where the STATION SELLS)
function Shop:updateSellGui() -- client

    if not self.guiInitialized then return end

    for _, line in pairs(self.soldItemLines) do
        line:hide()
    end

    if self.specialOfferUI then
        self.specialOfferUI:toSoldOut()
    end

    local faction = Faction()
    local buyer = Player()
    local playerCraft = buyer.craft

    if playerCraft and playerCraft.factionIndex == buyer.allianceIndex then
        buyer = buyer.alliance
    end

    if #self.soldItems == 0 then
        local topLine = self.soldItemLines[1]
        topLine.nameLabel:show()
        topLine.nameLabel.color = ColorRGB(1.0, 1.0, 1.0)
        topLine.nameLabel.bold = false
        topLine.nameLabel.caption = "We are completely sold out."%_t
    end

    for index, item in pairs(self.soldItems) do

        local line = self.soldItemLines[index]
        line:show()

        line.nameLabel.caption = item:getName()%_t
        line.nameLabel.color = item.rarity.color
        line.nameLabel.bold = false

        if item.material then
            line.materialLabel.caption = item.material.name
            line.materialLabel.color = item.material.color
        else
            line.materialLabel:hide()
        end

        if item.icon then
            line.icon.picture = item.icon
            line.icon.color = item.rarity.color
        end

        if item.displayedPrice then
            line.priceLabel.caption = item.displayedPrice
        else
            local price = self:getSellPriceAndTax(item.price, faction, buyer)
            line.priceLabel.caption = createMonetaryString(price)
        end

        if self.priceRatio < 1 then
            line.priceReductionLabel:show()
            line.priceReductionLabel.caption = "${percentage} OFF!"%_t % {percentage = tostring(round((1 - self.priceRatio) * 100)) .. "%"}
        elseif self.priceRatio > 1 then
            line.priceReductionLabel:show()
            line.priceReductionLabel.caption = "+${percentage}"%_t % {percentage = tostring(round((self.priceRatio - 1) * 100)) .. "%"}
        else
            line.priceReductionLabel:hide()
        end

        line.stockLabel.caption = item.amount
        line.techLabel.caption = item.tech or ""

        local msg, args = self:canBeBought(item, playerCraft, buyer)
        if msg then
            line.button.active = false
            line.button.tooltip = string.format(msg%_t, unpack(args or {}))
        else
            line.button.active = true
            line.button.tooltip = nil
        end
    end

    -- update the special offer frame
    local item = self.specialOffer.item
    if item then

        local specialUI = self.specialOfferUI
        specialUI:show()

        local special = self.specialOffer
        specialUI.nameLabel.caption = item:getName()%_t -- BUGFIX! original was only item.name%_t
        specialUI.nameLabel.color = item.rarity.color
        specialUI.nameLabel.bold = false

        if item.material then
            specialUI.materialLabel.caption = item.material.name
            specialUI.materialLabel.color = item.material.color
        else
            specialUI.materialLabel:hide()
        end

        if item.icon then
            specialUI.icon.picture = item.icon
            specialUI.icon.color = item.rarity.color
        end

        if item.amount then
            specialUI.stockLabel.caption = item.amount
        end

        specialUI.techLabel.caption = item.tech or ""

        specialUI.timeLeftLabel.caption = "LIMITED TIME OFFER!"%_t
        specialUI.label.caption = "SPECIAL OFFER: -30% OFF"%_t

        -- for now, specialPrice is just 70% of the regular price
        -- if this gets changed, it must be changed in <Shop:sellToPlayer> also!
        local price = self:getSellPriceAndTax(item.price, faction, buyer)
        local specialPrice = price * 0.7
        specialUI.priceLabel.caption = createMonetaryString(specialPrice)
        specialUI.priceReductionLabel.caption = "${percentage} OFF!"%_t % {percentage = "30%"}

        local msg, args = self:canBeBought(item, playerCraft, buyer)
        if msg then
            specialUI.button.active = false
            specialUI.button.tooltip = string.format(msg%_t, unpack(args or {}))
        else
            specialUI.button.active = true
            specialUI.button.tooltip = nil
        end
    end

    if self.onSellGuiUpdated then self:onSellGuiUpdated() end
end






-- for debugging only. copied from:
-- https://steamcommunity.com/sharedfiles/filedetails/?id=2853436262

local edr_buildBuyGui, edr_CreateNamespace -- extended functions
local edr_restockButton -- UI
local edr_specialOfferSeed = 0 -- restock the special offer

-- Handle the actual restocking part
if onServer() then
    edr_generateSeed = Shop.generateSeed
    function Shop:generateSeed(...)
        if self.staticSeed then
            return edr_generateSeed(self, ...)
        else
            return edr_generateSeed(self, ...) .. edr_specialOfferSeed
        end
    end

    function Shop:remoteRestock()
        edr_specialOfferSeed = edr_specialOfferSeed + 1
        self:restock()
    end

    edr_CreateNamespace = PublicNamespace.CreateNamespace
    function PublicNamespace.CreateNamespace(...)
        local result = edr_CreateNamespace(...)

        result.remoteRestock = function(...) return result.shop:remoteRestock(...) end

        callable(result, "remoteRestock")

        return result
    end
end

-- Add the button to trigger a restock
if onClient() then
    edr_buildBuyGui = Shop.buildBuyGui
    function Shop:buildBuyGui(tab, config, ...)
        edr_buildBuyGui(self, tab, config, ...)

        -- Defined within the BuildGui function in shop.lua for the Buy buttons
        local x = 720

        edr_restockButton = tab:createButton(Rect(x, 0, x + 160, 30), "", "edr_onRestockButtonPressed")
        edr_restockButton.icon = "data/textures/icons/clockwise-rotation.png"
        edr_restockButton.tooltip = "Restock the shop"%_t
    end

    function Shop:edr_onRestockButtonPressed(button)
        invokeServerFunction("remoteRestock")
    end

    edr_CreateNamespace = PublicNamespace.CreateNamespace
    function PublicNamespace.CreateNamespace(...)
        local result = edr_CreateNamespace(...)

        result.edr_onRestockButtonPressed = function(...) return result.shop:edr_onRestockButtonPressed(...) end

        return result
    end
end
