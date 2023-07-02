
function FactoryMap:initialize()
    self.seed = GameSeed()

    self.productionScripts = {
        "data/scripts/entity/merchants/factory.lua"
    }
    self.consumerScripts = {
        "data/scripts/entity/merchants/consumer.lua",
        --"data/scripts/entity/merchants/habitat.lua",
        --"data/scripts/entity/merchants/biotope.lua",
        --"data/scripts/entity/merchants/casino.lua",
    }
    self.sellerScripts = {
        "data/scripts/entity/merchants/seller.lua",
--        "data/scripts/entity/merchants/turretfactoryseller.lua", -- turret factories are ignored since they're randomized and only "count" for needs of turret builders
    }
end

function FactoryMap:predictConsumptions(x, y, contents)

    local habitats = contents.habitats or 0
    local biotopes = contents.biotopes or 0
    local casinos = contents.casinos or 0
    local equipmentDocks = contents.equipmentDocks or 0
    local shipyards = contents.shipyards or 0
    local repairDocks = contents.repairDocks or 0
    local militaryOutposts = contents.militaryOutposts or 0
    local researchStations = contents.researchStations or 0
    local travelHubs = contents.travelHubs or 0
    local mines = contents.mines or 0

    local consumptions = {}

    for i = 1, habitats do
        table.insert(consumptions, {goods = ConsumerGoods.Habitat()})
    end
    for i = 1, biotopes do
        table.insert(consumptions, {goods = ConsumerGoods.Biotope()})
    end
    for i = 1, casinos do
        table.insert(consumptions, {goods = ConsumerGoods.Casino()})
    end
    for i = 1, equipmentDocks do
        table.insert(consumptions, {goods = ConsumerGoods.EquipmentDock()})
    end
    for i = 1, shipyards do
        table.insert(consumptions, {goods = ConsumerGoods.Shipyard()})
    end
    for i = 1, repairDocks do
        table.insert(consumptions, {goods = ConsumerGoods.RepairDock()})
    end
    for i = 1, militaryOutposts do
        table.insert(consumptions, {goods = ConsumerGoods.MilitaryOutpost()})
    end
    for i = 1, researchStations do
        table.insert(consumptions, {goods = ConsumerGoods.ResearchStation()})
    end
    for i = 1, travelHubs do
        table.insert(consumptions, {goods = ConsumerGoods.TravelHub()})
    end
    for i = 1, mines do
        table.insert(consumptions, {goods = ConsumerGoods.Mine()})
    end

    if #consumptions == 0 then return nil end

    return consumptions
end


function FactoryMap:predictSellers(x, y, contents)
    -- vanilla Avorion didn't implement this
    return nil
end

function FactoryMap:predictProductions(x, y, contents)
    -- TODO
    return nil
end

--[[
function FactoryMap:predictProductions(x, y, contents)

    local factories = contents.factories or 0
    local mines = contents.mines or 0

    if factories == 0 and mines == 0 then return {} end

    local totalProductions = {}
    if factories > 0 then
        totalProductions = FactoryPredictor.generateFactoryProductions(x, y, factories)
    end

    if mines > 0 then
        local mineProductions = FactoryPredictor.generateMineProductions(x, y, mines)
        for _, mine in pairs(mineProductions) do
            table.insert(totalProductions, mine)
        end
    end

    if #totalProductions == 0 then return nil end

    return totalProductions
end
--]]

