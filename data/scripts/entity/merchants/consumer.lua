
function Consumer.initialize(name_in, ...)

    local entity = Entity()

    if onServer() then
        Sector():addScriptOnce("sector/traders.lua")

        Consumer.consumerName = name_in or Consumer.consumerName

        -- only use parameter goods if there are any, otherwise we prefer the goods we might already have in consumedGoods
        local consumedGoods_in = {...}
        if #consumedGoods_in > 0 then
            Consumer.consumedGoods = consumedGoods_in
        end
        Consumer.updateOwnSupply()

        local station = Entity()

        -- add the name as a category
        if Consumer.consumerName ~= "" and entity.title == "" then
            entity.title = Consumer.consumerName
        end


        local seed = Sector().seed + Sector().numEntities
        math.randomseed(seed);

        -- consumers only buy
        Consumer.trader.buyPriceFactor = math.random() * 0.2 + 0.9 -- 0.9 to 1.1

        local bought = {}

        for i, name in pairs(Consumer.consumedGoods) do
            local g = goods[name]
            if g ~= nil then
                table.insert(bought, g:good())
            end
        end

        Consumer.initializeTrading(bought, {})

        local faction = Faction()
        if faction then
            if faction.isAIFaction then
                Sector():registerCallback("onRestoredFromDisk", "onRestoredFromDisk")
            end

            if not _restoring then
                if faction.isAlliance or faction.isPlayer then
                    Consumer.trader.buyFromOthers = false
                end
            end
        end

        math.randomseed(appTimeMs())
    else
        Consumer.requestGoods()

        if Consumer.consumerIcon ~= "" and EntityIcon().icon == "" then
            EntityIcon().icon = Consumer.consumerIcon
            InteractionText().text = Dialog.generateStationInteractionText(entity, random())
        end
    end

end




