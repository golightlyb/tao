
productions = {}
productionsByGood = {}


-- special ordering
table.insert(productions, {factory="Ore Processor ${size}", factoryStyle="Factory", ingredients={{name="XOre", amount=100, optional=0}}, results={{name="XMetal", amount=10}}, garbages={{name="XScrapMetal", amount=25}}})

productionIndexOreProcessor = 1


for i, production in pairs(productions) do
    production.index = i

    if production._isMine then
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

