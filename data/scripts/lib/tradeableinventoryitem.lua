
local function new(item, index, owner)
    local obj = setmetatable({item = item, index = index}, TradeableInventoryItem)

    -- initialize the item
    obj.price = 0
    obj.name = item.name
    obj.rarity = obj.item.rarity
    obj.material = obj:getMaterial()
    obj.icon = obj:getIcon()
    obj.tech = obj:getTech()
    obj.sellable = obj:getSellable()
    obj.good = "FIXME"
    obj.goodsPrice = obj:getPrice()
    obj.displayedPrice = createMonetaryString(obj.goodsPrice)

    if owner and index then
        obj.amount = owner:getInventory():amount(index)
    elseif index and type(index) == "number" then
        obj.amount = index
    else
        obj.amount = 1
    end

    return obj
end


