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
