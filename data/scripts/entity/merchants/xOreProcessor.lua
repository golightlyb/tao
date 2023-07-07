package.path = package.path .. ";data/scripts/lib/?.lua"
include ("utility")
include ("randomext")
include ("faction")
include ("goods")
include ("productions")
local ConsumerGoods = include ("consumergoods")
-- local ShopAPI = include ("shop")
local Dialog = include("dialogutility")
--local BuildingKnowledgeUT = include("buildingknowledgeutility")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace XOreProcessor
XOreProcessor = {}
-- XRefinery = ShopAPI.CreateNamespace()

-- TODO this is just a type of factory that also has consumer goods, so remove.

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function XOreProcessor.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, -10000)
end

function XOreProcessor.initialize()
    local station = Entity()
    if station.title == "" then
        station.title = "Ore Processor"%_t
    end

    if onServer() then
        local production = productions[productionIndexOreProcessor]
        station:addScriptOnce("data/scripts/entity/merchants/factory.lua", production, nil, 0)
        station:addScriptOnce("data/scripts/entity/merchants/consumer.lua", "Ore Processor"%_t, unpack(ConsumerGoods.XOreProcessor()))
    end
    
    -- XRefinery.shop:initialize(station.translatedTitle)

    if onClient() and EntityIcon().icon == "" then
        EntityIcon().icon = "data/textures/icons/pixel/asteroid.png"
        InteractionText(station.index).text = Dialog.generateStationInteractionText(station, random())
    end
end

