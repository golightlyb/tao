
function Seller.initialize(name_in, ...)

    local entity = Entity()

    if onServer() then
        Sector():addScriptOnce("sector/traders.lua")

        Seller.sellerName = name_in or Seller.sellerName

        -- only use parameter goods if there are any, otherwise we prefer the goods we might already have in soldGoods
        local sellableGoods_in = {...}
        if #sellableGoods_in > 0 then
            Seller.soldGoods = sellableGoods_in
            Seller.updateOwnSupply()
        end

        local station = Entity()

        -- add the name as title
        if Seller.sellerName ~= "" and entity.title == "" then
            entity.title = Seller.sellerName
        end

        local seed = Sector().seed + Sector().numEntities
        math.randomseed(seed);

        -- sellers only sell
        Seller.trader.sellPriceFactor = Seller.customSellPriceFactor or math.random() * 0.2 + 0.9 -- 0.9 to 1.1

        local sold = {}

        for i, name in pairs(Seller.soldGoods) do
            local g = goods[name]
            if g == nil then
                eprint("entity/merchants/seller: Missing good " .. name)
            end
            table.insert(sold, g:good())
        end

        Seller.initializeTrading({}, sold)

        local faction = Faction()
        if valid(faction) and faction.isAIFaction then
            Sector():registerCallback("onRestoredFromDisk", "onRestoredFromDisk")
        end

        math.randomseed(appTimeMs())
    else
        Seller.requestGoods()

        if Seller.sellerIcon ~= "" and EntityIcon().icon == "" then
            EntityIcon().icon = Seller.sellerIcon
            InteractionText().text = Dialog.generateStationInteractionText(entity, random())
        end
    end

end
