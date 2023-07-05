--local BuildingKnowledgeUT = include("buildingknowledgeutility")


function UtilityMerchant.shop:addItems()

    local x, y = Sector():getCoordinates()

    local faction = Faction()

    if faction then
        local item = UsableInventoryItem("reinforcementstransmitter.lua", Rarity(RarityType.Exotic), faction.index)
        UtilityMerchant.add(item, getInt(1, 2))

        local hx, hy = faction:getHomeSectorCoordinates()

        local item = UsableInventoryItem("factionmapsegment.lua", Rarity(RarityType.Exotic), faction.index, hx, hy, x, y)
        UtilityMerchant.add(item, getInt(2, 3))
        local item = UsableInventoryItem("factionmapsegment.lua", Rarity(RarityType.Exceptional), faction.index, hx, hy, x, y)
        UtilityMerchant.add(item, getInt(2, 3))
        local item = UsableInventoryItem("factionmapsegment.lua", Rarity(RarityType.Rare), faction.index, hx, hy, x, y)
        UtilityMerchant.add(item, getInt(2, 3))
        local item = UsableInventoryItem("factionmapsegment.lua", Rarity(RarityType.Uncommon), faction.index, hx, hy, x, y)
        UtilityMerchant.add(item, getInt(2, 3))
    end
end

function UtilityMerchant.initialize()
    UtilityMerchant.shop:initialize("Utility Merchant"%_t)
end

function UtilityMerchant.initUI()
    local e = Entity()
    UtilityMerchant.shop:initUI("Trade Equipment", "Utility Merchant"%_t, "Utilities"%_t, "data/textures/icons/bag_satellite.png", {showSpecialOffer = false})
end


