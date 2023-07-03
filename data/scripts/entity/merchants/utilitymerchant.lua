local BuildingKnowledgeUT = include("buildingknowledgeutility")

local function getNameByRarity(rarity)
    if rarity.value == 1 then
        return "Dangerous Cargo Transport License"%_t
    elseif rarity.value == 2 then
        return "Stolen Cargo Transport License"%_t
    elseif rarity.value == 3 then
        return "Illegal Cargo Transport License"%_t
    end
end

local function makeLicenseTooltip(item)
    local tooltip = Tooltip()

    tooltip.icon = item.icon
    tooltip.rarity = item.rarity

    local factionIndex = item:getValue("faction")
    local name = Faction(factionIndex).name

    local title = getNameByRarity(item.rarity)
    local description1 = "License for transporting special cargo"%_t
    local description2 = "Only valid in designated territory"%_t

    local headLineSize = 25
    local headLineFont = 15
    local line = TooltipLine(headLineSize, headLineFont)
    line.ctext = title
    line.ccolor = item.rarity.tooltipFontColor
    tooltip:addLine(line)
    tooltip:addLine(TooltipLine(18, 14))

    local line = TooltipLine(18, 14)
    line.ltext = "Dangerous Cargo"%_t
    line.icon = "data/textures/icons/crate.png"
    line.iconColor = ColorRGB(1.0, 1.0, 0.3)
    if item.rarity.value >= 1 then
        line.rtext = "Yes"%_t
        line.rcolor = ColorRGB(0.3, 1.0, 0.3)
    else
        line.rtext = "No"%_t
        line.rcolor = ColorRGB(1.0, 0.3, 0.3)
    end
    tooltip:addLine(line)

    local line = TooltipLine(18, 14)
    line.ltext = "Stolen Cargo"%_t
    line.icon = "data/textures/icons/crate.png"
    line.iconColor = ColorRGB(1.0, 0.3, 1.0)
    if item.rarity.value >= 2 then
        line.rtext = "Yes"%_t
        line.rcolor = ColorRGB(0.3, 1.0, 0.3)
    else
        line.rtext = "No"%_t
        line.rcolor = ColorRGB(1.0, 0.3, 0.3)
    end
    tooltip:addLine(line)

    local line = TooltipLine(18, 14)
    line.ltext = "Illegal Cargo"%_t
    line.icon = "data/textures/icons/crate.png"
    line.iconColor = ColorRGB(1.0, 0.3, 0.3)
    if item.rarity.value >= 3 then
        line.rtext = "Yes"%_t
        line.rcolor = ColorRGB(0.3, 1.0, 0.3)
    else
        line.rtext = "No"%_t
        line.rcolor = ColorRGB(1.0, 0.3, 0.3)
    end
    tooltip:addLine(line)

    tooltip:addLine(TooltipLine(18, 14))


    local line = TooltipLine(18, 14)
    line.ltext = "Territory"%_t
    line.rtext = "${faction:" .. tostring(factionIndex) .. "}"
    tooltip:addLine(line)

    tooltip:addLine(TooltipLine(18, 14))
    tooltip:addLine(TooltipLine(18, 14))

    local dLine1 = TooltipLine(18, 14)
    dLine1.ltext = description1
    tooltip:addLine(dLine1)

    local dLine2 = TooltipLine(18, 14)
    dLine2.ltext = description2
    tooltip:addLine(dLine2)

    return tooltip
end

function createLicense(rarity, faction)
    local license = VanillaInventoryItem()
    if rarity.value == 1 then
        license.name = "Dangerous Cargo Transport License"%_t
        license.price = 100 * 1000
    elseif rarity.value == 2 then
        license.name = "Stolen Cargo Transport License"%_t
        license.price = 500 * 1000
    elseif rarity.value == 3 then
        license.name = "Illegal Cargo Transport License"%_t
        license.price = 1 * 1000 * 1000
    end

    license.rarity = rarity
    license:setValue("subtype", "CargoLicense")
    license:setValue("isCargoLicense", true)
    license:setValue("faction", faction.index)
    license.icon = "data/textures/icons/crate.png"
    license.iconColor = rarity.color
    license:setTooltip(makeLicenseTooltip(license))

    return license
end

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
        
        UtilityMerchant.add(createLicense(Rarity(3), faction), getInt(1, 2))
        UtilityMerchant.add(createLicense(Rarity(2), faction), getInt(1, 2))
        UtilityMerchant.add(createLicense(Rarity(1), faction), getInt(1, 2))
        
        local player = Player()
        local item = BuildingKnowledgeUT.getLocalKnowledge()
        --if player.maxBuildableMaterial < item then
        UtilityMerchant.add(item, getInt(1, 2))
        --end
    end
end

function UtilityMerchant.initialize()
    UtilityMerchant.shop:initialize("Utility Merchant"%_t)
end

function UtilityMerchant.initUI()
    UtilityMerchant.shop:initUI("Trade Equipment"%_t, "Utility Merchant"%_t, "Utilities"%_t, "data/textures/icons/bag_satellite.png", {showSpecialOffer = false})
end
