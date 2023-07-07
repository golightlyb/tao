package.path = package.path .. ";data/scripts/lib/?.lua"
include ("utility")
include ("randomext")
include ("faction")
local ShopAPI = include ("shop")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace CustomsLicense
CustomsLicense = {}
CustomsLicense = ShopAPI.CreateNamespace()

CustomsLicense.interactionThreshold = -30000

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function CustomsLicense.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, CustomsLicense.interactionThreshold)
end

local function getNameByRarity(rarity)
    if rarity.value == 1 then
        return "Dangerous Cargo Transport License"%_t
    elseif rarity.value == 2 then
        return "Stolen Cargo Transport License"%_t
    elseif rarity.value == 3 then
        return "Illegal Military Cargo Transport License"%_t
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
    line.ltext = "Illegal Military Cargo"%_t
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
        license.price = 100 * 1000
    elseif rarity.value == 2 then
        license.price = 500 * 1000
    elseif rarity.value == 3 then
        license.price = 1 * 1000 * 1000
    end
    license.name = getNameByRarity(rarity)

    license.rarity = rarity
    license:setValue("subtype", "CargoLicense")
    license:setValue("isCargoLicense", true)
    license:setValue("faction", faction.index)
    license.icon = "data/textures/icons/crate.png"
    license.iconColor = rarity.color
    license:setTooltip(makeLicenseTooltip(license))

    return license
end

function CustomsLicense.shop:addItems()

    local x, y = Sector():getCoordinates()

    local faction = Faction()

    if faction then
        CustomsLicense.add(createLicense(Rarity(3), faction), 99)
        CustomsLicense.add(createLicense(Rarity(2), faction), 99)
        CustomsLicense.add(createLicense(Rarity(1), faction), 99)
    end
end


function CustomsLicense.initialize(_label, _removeSellBuyBack)
    CustomsLicense.shop:initialize("License Merchant"%_t)
end

function CustomsLicense.initUI()
    CustomsLicense.shop:initUI("Cargo Licenses", "License Merchant"%_t, "Licenses"%_t, "data/textures/icons/cargo-scrambler.png", {showSpecialOffer = false})
    CustomsLicense.shop.tabbedWindow:deactivateTab(CustomsLicense.shop.sellTab)
    CustomsLicense.shop.tabbedWindow:deactivateTab(CustomsLicense.shop.buyBackTab)
end


