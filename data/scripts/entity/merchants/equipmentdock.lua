
function EquipmentDock.shop:addItems()

    local systems = {}
    EquipmentDock.addStaticOffers(systems)

    local generator = UpgradeGenerator()
    local x, y = Sector():getCoordinates()
    local rarities = generator:getSectorRarityDistribution(x, y)

    for i, rarity in pairs(rarities) do
        rarities[i] = rarity * EquipmentDock.rarityFactors[i] or 1
    end

    local counter = 0
    while counter < 9 do
        local prototype = generator:generateSectorSystem(x, y, nil, rarities)
	if prototype == nil then goto continue end
	if prototype.script == nil then goto continue end

        do
            local script = prototype.script
            local rarity = prototype.rarity
            local seed = generator:getUpgradeSeed(x, y, script, rarity)

            local system = SystemUpgradeTemplate(script, rarity, seed)
            if system ~= nil then
                if system.name ~= "" then
                    table.insert(systems, system)
                end
            end
        end

        ::continue::
        counter = counter + 1
    end

    table.sort(systems, sortSystems)

    for _, system in pairs(systems) do
        EquipmentDock.shop:add(system, getInt(1, 2))
    end
end

-- adds most commonly used upgrades
function EquipmentDock.addStaticOffers(systems)
    return
end

-- sets the special offer that gets updated every 20 minutes
function EquipmentDock.shop:onSpecialOfferSeedChanged()
    return
end
