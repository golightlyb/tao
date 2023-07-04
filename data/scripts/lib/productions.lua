
productions = {}
productionsByGood = {}

function formatFactoryName(production, size)
    size = size or ""

    local args = {size = size}
    local factoryName = "Factory ${size}"%_t
    
    if production ~= nil then
        local result = goods[production.results[1].name]

        if result then
            local good = result:good()
            if good then
                factoryName = production.factory
                args.good = good.name
                args.prefix = (good.name .. " /* prefix */")
                args.plural = good.plural
            end
        end
    end

    return factoryName, args
end

for i, production in pairs(productions) do
    production.index = i

        -- TODO
    if (string.match(production.factory, " Mine") and not string.match(production.factory, "Mineral"))
            or string.match(production.factory, "Oil Rig") then
        production.mine = true
    end

    for _, result in pairs(production.results) do
        local collection = productionsByGood[result.name]

        if not collection then
            collection = {}
            productionsByGood[result.name] = collection
        end

        table.insert(collection, production)
    end

end

