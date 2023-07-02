
function TurretMerchant.shop:addItems()

    -- simply init with a 'random' seed
    local station = Entity()

    -- create all turrets
    local turrets = {}

    local x, y = Sector():getCoordinates()
    local generator = SectorTurretGenerator()
    generator.rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(generator.rarities) do
        generator.rarities[i] = rarity * TurretMerchant.rarityFactors[i] or 1
    end

    for i = 1, 13 do
        local generated = generator:generate(x, y)
        if generated == nil then goto continue end
        do 
            local turret = InventoryTurret(generated)

            local amount = 1

            local pair = {}
            pair.turret = turret
            pair.amount = amount

            if turret.rarity.value == 1 then -- uncommon weapons may be more than one
                if math.random() < 0.3 then
                    pair.amount = pair.amount + 1
                end
            elseif turret.rarity.value == 0 then -- common weapons may be some more than one
                if math.random() < 0.5 then
                    pair.amount = pair.amount + 1
                end
                if math.random() < 0.5 then
                    pair.amount = pair.amount + 1
                end
            end

            if pair.turret ~= nil then
                table.insert(turrets, pair)
            end
        end
        ::continue::
    end

    table.sort(turrets, comp)

    for _, pair in pairs(turrets) do
        TurretMerchant.shop:add(pair.turret, pair.amount)
    end
end


-- sets the special offer that gets updated every 20 minutes
function TurretMerchant.shop:onSpecialOfferSeedChanged()
    return
end
