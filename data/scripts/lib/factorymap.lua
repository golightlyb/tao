
function FactoryMap:initialize()
    self.seed = GameSeed()

    self.productionScripts = {
        "data/scripts/entity/merchants/factory.lua"
    }
    self.consumerScripts = {
        "data/scripts/entity/merchants/consumer.lua",
        "data/scripts/entity/merchants/habitat.lua",
        "data/scripts/entity/merchants/biotope.lua",
        "data/scripts/entity/merchants/casino.lua",
    }
    self.sellerScripts = {
        "data/scripts/entity/merchants/seller.lua",
--        "data/scripts/entity/merchants/turretfactoryseller.lua", -- turret factories are ignored since they're randomized and only "count" for needs of turret builders
    }
end

function FactoryMap:predictConsumptions(x, y, contents)

    local consumptions = {}

    for i = 1, (contents.xSpacedock or 0) do
        table.insert(consumptions, {goods = ConsumerGoods.XSpacedock()})
    end
    for i = 1, (contents.xRefinery or 0) do
        table.insert(consumptions, {goods = ConsumerGoods.XRefinery()})
    end
    
    if #consumptions == 0 then return nil end

    return consumptions
end


function FactoryMap:predictSellers(x, y, contents)
    -- vanilla Avorion didn't implement this
    return nil
end

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


