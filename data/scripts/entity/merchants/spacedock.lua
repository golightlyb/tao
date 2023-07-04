package.path = package.path .. ";data/scripts/lib/?.lua"
include ("utility")
include ("randomext")
include ("faction")
local ConsumerGoods = include ("consumergoods")
local ShopAPI = include ("shop")
local UpgradeGenerator = include("upgradegenerator")
local Dialog = include("dialogutility")
local BuildingKnowledgeUT = include("buildingknowledgeutility")

-- Don't remove or alter the following comment, it tells the game the namespace this script lives in. If you remove it, the script will break.
-- namespace Spacedock
Spacedock = {}
Spacedock = ShopAPI.CreateNamespace()

-- The Spacedock is a combined Equipment Dock, repair dock, and (TODO)
-- ship founder (with a simpler UI).

Spacedock.rarityFactors = {}

Spacedock.specialOfferRarityFactors = {}
Spacedock.specialOfferRarityFactors[-1] = 0.00
Spacedock.specialOfferRarityFactors[ 0] = 0.00
Spacedock.specialOfferRarityFactors[ 1] = 0.00 -- uncommon
Spacedock.specialOfferRarityFactors[ 2] = 1.00 -- rare
Spacedock.specialOfferRarityFactors[ 3] = 0.50 -- exceptional
Spacedock.specialOfferRarityFactors[ 4] = 0.25 -- exotic
Spacedock.specialOfferRarityFactors[ 5] = 0.00 -- legendary

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function Spacedock.interactionPossible(playerIndex, option)
    return CheckFactionInteraction(playerIndex, -10000)
end

local function sortSystems(a, b)
    if a.rarity.value == b.rarity.value then
        if a.script == b.script then
            return a.price > b.price
        else
            return a.script < b.script
        end
    end

    return a.rarity.value > b.rarity.value
end

local function xGenerateSpecific(generator, dest, x, y, r, script)
    local rarity = Rarity(r)
    local seed = generator:getUpgradeSeed(x, y, script, rarity)
    system = SystemUpgradeTemplate(script, rarity, seed)
    table.insert(dest, system)
end

local function xGenerateAny(generator, dest, x, y, r)
    local prototype = generator:generateSectorSystem(x, y, Rarity(r))
    local script = prototype.script
    local rarity = prototype.rarity
    local seed = generator:getUpgradeSeed(x, y, script, rarity)
    system = SystemUpgradeTemplate(script, rarity, seed)
    table.insert(dest, system)
end

function Spacedock.shop:addItems()

    local systems = {}
    Spacedock.addStaticOffers(systems)

    local generator = UpgradeGenerator()
    local x, y = Sector():getCoordinates()

    -- generate a few random rarer items
    if  math.random() < 0.1 then
        xGenerateAny(generator, systems, x, y, 4)
    end
    if  math.random() < 0.33 then
        xGenerateAny(generator, systems, x, y, 3)
    end
    
    for i = 1, getInt(1, 2) do
        xGenerateAny(generator, systems, x, y, 2)
    end
    
    for i = 1, getInt(1, 3) do
        xGenerateAny(generator, systems, x, y, 1)
    end
    
    -- always generate these common items...
    xGenerateSpecific(generator, systems, x, y, 0, "data/scripts/systems/xcore.lua")
    xGenerateSpecific(generator, systems, x, y, 0, "data/scripts/systems/xtradingoverview.lua")
    xGenerateSpecific(generator, systems, x, y, 0, "data/scripts/systems/xvaluablesdetector.lua")
    
    table.sort(systems, sortSystems)

    for _, system in pairs(systems) do
        Spacedock.shop:add(system, 1)
    end
end

-- adds most commonly used upgrades
function Spacedock.addStaticOffers(systems)
    return
end

-- sets the special offer that gets updated every 20 minutes
function Spacedock.shop:onSpecialOfferSeedChanged()
    local generator = UpgradeGenerator(Spacedock.shop:generateSeed())

    local x, y = Sector():getCoordinates()
    local rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(rarities) do
        rarities[i] = rarity * Spacedock.specialOfferRarityFactors[i] -- or 1
    end

    local prototype = generator:generateSystem(nil, rarities)

    local script = prototype.script
    local rarity = prototype.rarity
    local seed = generator:getUpgradeSeed(x, y, script, rarity)

    Spacedock.shop:setSpecialOffer(SystemUpgradeTemplate(script, rarity, seed))
end

function Spacedock.initialize()
    local station = Entity()
    if station.title == "" then
        station.title = "Spacedock"%_t
    end

    if onServer() then
        Sector():registerCallback("onPlayerArrivalConfirmed", "onPlayerArrivalConfirmed")

        station:addScriptOnce("data/scripts/entity/merchants/turretmerchant.lua")
        station:addScriptOnce("data/scripts/entity/merchants/torpedomerchant.lua")
        station:addScriptOnce("data/scripts/entity/merchants/utilitymerchant.lua")
        station:addScriptOnce("data/scripts/entity/merchants/consumer.lua", "Spacedock"%_t, unpack(ConsumerGoods.Spacedock()))
        station:addScriptOnce("data/scripts/entity/merchants/repairdock.lua")
        station:addScriptOnce("data/scripts/entity/merchants/customs.lua")
        
        -- station:addScriptOnce("data/scripts/entity/merchants/buildingknowledgemerchant.lua")
        -- station:addScriptOnce("data/scripts/entity/merchants/cargotransportlicensemerchant.lua")
    end
    
    Spacedock.shop:initialize(station.translatedTitle)

    if onClient() and EntityIcon().icon == "" then
        EntityIcon().icon = "data/textures/icons/pixel/shipyard2.png"
        InteractionText(station.index).text = Dialog.generateStationInteractionText(station, random())
    end
    
    station:setValue("remove_permanent_upgrades", true)
    station:setValue("build_advanced_blocks", true)
end

function Spacedock.initUI()
    local station = Entity()
    Spacedock.shop:initUI("Trade Equipment"%_t, station.translatedTitle, "Subsystems"%_t, "data/textures/icons/bag_circuitry.png")
end

function Spacedock.onPlayerArrivalConfirmed(playerIndex)
    Player(playerIndex):sendChatMessage("", ChatMessageType.Information, "There's a spacedock in this sector."%_T)
end

