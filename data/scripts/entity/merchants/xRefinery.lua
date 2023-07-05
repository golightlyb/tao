package.path = package.path .. ";data/scripts/lib/?.lua"
include ("utility")
include ("randomext")
include ("faction")
local ConsumerGoods = include ("consumergoods")
-- local ShopAPI = include ("shop")
local Dialog = include("dialogutility")
--local BuildingKnowledgeUT = include("buildingknowledgeutility")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace XRefinery
XRefinery = {}
-- XRefinery = ShopAPI.CreateNamespace()

-- not an ore processor

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function XRefinery.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, -10000)
end

--[[
function XRefinery.shop:addItems()
    local x, y = Sector():getCoordinates()
    local faction = Faction()
    if faction then
        local item = BuildingKnowledgeUT.getLocalKnowledge()
        XRefinery.add(item, 1)
    end
end
--]]

function XRefinery.initialize()
    local station = Entity()
    if station.title == "" then
        station.title = "Refinery"%_t
    end

    if onServer() then
        station:addScriptOnce("data/scripts/entity/merchants/consumer.lua", "Spacedock"%_t, unpack(ConsumerGoods.XRefinery()))
        station:addScriptOnce("data/scripts/entity/merchants/refinery.lua")
        station:addScriptOnce("data/scripts/entity/merchants/buildingknowledgemerchant.lua")
    end
    
    -- XRefinery.shop:initialize(station.translatedTitle)

    if onClient() and EntityIcon().icon == "" then
        EntityIcon().icon = "data/textures/icons/pixel/resources.png"
        InteractionText(station.index).text = Dialog.generateStationInteractionText(station, random())
    end
end

--[[
function XRefinery.initUI()
    local station = Entity()
    XRefinery.shop:initUI("Building Knowledge"%_t, station.translatedTitle, "Items"%_t, "data/textures/icons/maximize.png")
end
--]]


