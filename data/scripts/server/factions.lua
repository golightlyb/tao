
function initializeAIFaction(faction, baseName, stateFormName)

    local seed = Server().seed + faction.index
    local random = Random(seed)

    local language = Language(random:createSeed())
    faction:setLanguage(language)

    local possibleStateForms = {}
    for k, v in pairs(FactionStateFormType) do
        table.insert(possibleStateForms, v)
    end

    local stateFormType = FactionStateFormType.Vanilla
    if random:test(0.9) then
        stateFormType = randomEntry(random, possibleStateForms)
    end

    local stateForm = StateForms[stateFormType] or StateForms[FactionStateFormType.Vanilla]
    local subtype = {}
    faction:setValue("state_form_type", stateFormType)

    if baseName then
        faction.baseName = baseName
    else
        faction.baseName = language:getName()

        local subtypes = {}
        for _, subtype in pairs(stateForm.subtypes) do
            subtypes[subtype] = subtype.p
        end

        subtype = selectByWeight(random, subtypes)
        faction.stateForm = subtype.name
    end

    if stateFormName then
        faction.stateForm = stateFormName
    end

    local traitPairs =
    {
        aggressive = {name = "aggressive"%_T, opposite = "peaceful"%_T},
        peaceful = {name = "peaceful"%_T, opposite = "aggressive"%_T},
        brave = {name = "brave"%_T, opposite = "careful"%_T},
        careful = {name = "careful"%_T, opposite = "brave"%_T},
        greedy = {name = "greedy"%_T, opposite = "generous"%_T},
        generous = {name = "generous"%_T, opposite = "greedy"%_T},
        honorable = {name = "honorable"%_T, opposite = "opportunistic"%_T},
        opportunistic = {name = "opportunistic"%_T, opposite = "honorable"%_T},
        mistrustful = {name = "mistrustful"%_T, opposite = "trusting"%_T},
        trusting = {name = "trusting"%_T, opposite = "mistrustful"%_T},
        unforgiving = {name = "unforgiving"%_T, opposite = "forgiving"%_T},
        forgiving = {name = "forgiving"%_T, opposite = "unforgiving"%_T},
    }

    -- assign traits
    for _, traitData in pairs(stateForm.traits) do
        local trait = traitPairs[traitData.name]

        local value = random:getInt(traitData.from, traitData.to)
        value = value + (subtype[traitData.name] or 0)
        value = math.max(-4, math.min(4, value))

        SetFactionTrait(faction, trait.name, trait.opposite, value / 4)
    end

    -- initial relations
    local initialRelations = random:getInt(-10000, 20000)
    if stateForm.badInitialRelations then
        initialRelations = -800000
    end

    local variation = random:getInt(0, 8)
    if variation == 0 then initialRelations = random:getInt(-40000, -25000) end -- random bad relations
    if variation == 1 then initialRelations = random:getInt(25000, 40000) end -- random good relations

    -- difficulty ranges from -3 (easiest) to 3 (hardest)
    local playerDelta = GameSettings().initialRelations * -15000
    local initialRelationsToPlayer = initialRelations + playerDelta

    if variation ~= 1 then
        -- except for the random good relations factions, initial relations to players
        -- get worse towards the center of the galaxy
        local maxWorsened = 40000 - playerDelta;
        local dimensions = Balancing_GetDimensions()

        local hx, hy = faction:getHomeSectorCoordinates()
        local worsening = lerp(length(vec2(hx, hy)), 0, 350, maxWorsened, 0)

        initialRelationsToPlayer = initialRelations - worsening
    end

    faction.initialRelationsToPlayer = math.max(-80000, initialRelationsToPlayer)
    faction.initialRelations = math.max(-80000, initialRelations)


    -- armament
    local turretGenerator = SectorTurretGenerator(seed)
    turretGenerator.coaxialAllowed = false

    local x, y = faction:getHomeSectorCoordinates()

    local armed1 = turretGenerator:generateArmed(x, y, 0, Rarity(RarityType.Common))
    local armed2 = turretGenerator:generateArmed(x, y, 0, Rarity(RarityType.Common))
    local unarmed1 = turretGenerator:generate(x, y, 0, Rarity(RarityType.Common), WeaponType.XMining)

    if armed1 ~= nil then faction:getInventory():add(armed1, false) end
    if armed2 ~= nil then faction:getInventory():add(armed2, false) end
    if unarmed1 ~= nil then faction:getInventory():add(unarmed1, false) end

    FactionPacks.tryApply(faction)
end

function initializePlayer(player)

    local galaxy = Galaxy()
    local server = Server()

    local random = Random(server.seed)

    -- get a random angle, fixed for the server seed
    local angle = random:getFloat(2.0 * math.pi)


    -- for each player registered, add a small amount on top of this angle
    -- this way, all players are near each other
    local home = nil
    local faction

    local distFromCenter = 450.0
    local distBetweenPlayers = 1 + random:getFloat(0, 1) -- distance between the home sectors of different players

    local tries = {}

    for i = 1, 3000 do
        -- we're looking at a distance of 450, so the perimeter is ~1413
        -- with every failure we walk a distance of 3 on the perimeter, so we're finishing a complete round about every 500 failing iterations
        -- every failed round we reduce the radius by several sectors to cover a bigger area.
        local offset = math.floor(i / 500) * 5

        local coords =
        {
            x = math.cos(angle) * (distFromCenter - offset),
            y = math.sin(angle) * (distFromCenter - offset),
        }

        table.insert(tries, coords)

        -- try to place the player in the area of a faction
        faction = galaxy:getLocalFaction(coords.x, coords.y)
        if faction then
            -- found a faction we can place the player to - stop looking if we don't need different start sectors
            if server.sameStartSector then
                home = coords
                break
            end

            -- in case we need different starting sectors: keep looking
            if galaxy:sectorExists(coords.x, coords.y) then
                angle = angle + (distBetweenPlayers / distFromCenter)
            else
                home = coords
                break
            end
        else
            angle = angle + (3 / distFromCenter)
        end
    end

    if not home then
        home = randomEntry(tries)
        faction = galaxy:getLocalFaction(home.x, home.y)
    end

    player:setHomeSectorCoordinates(home.x, home.y)
    player:setReconstructionSiteCoordinates(home.x, home.y)
    player:setRespawnSiteCoordinates(home.x, home.y)

    -- make sure the player has an early ally
    if not faction then
        faction = galaxy:getNearestFaction(home.x, home.y)
    end

    faction:setValue("enemy_faction", -1) -- this faction won't participate in faction wars
    galaxy:setFactionRelations(faction, player, 85000)
    player:setValue("start_ally", faction.index)
    player:setValue("gates2.0", true)

    local random = Random(SectorSeed(home.x, home.y) + player.index)
    local settings = GameSettings()

    -- create turret generator
    local generator = SectorTurretGenerator()


    local upgrade = SystemUpgradeTemplate("data/scripts/systems/xcore.lua", Rarity(RarityType.Petty), Seed(1))
    player:getInventory():add(upgrade, true)
    

    if settings.fullBuildingUnlocked then
        player.maxBuildableMaterial = Material(MaterialType.Avorion)
    else
        player.maxBuildableMaterial = Material(MaterialType.Iron)
    end

    if settings.unlimitedProcessingPower or settings.fullBuildingUnlocked then
        player.maxBuildableSockets = 0
    else
        player.maxBuildableSockets = 4
    end
end
