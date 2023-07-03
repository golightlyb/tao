

function SectorSpecifics:addBaseTemplates()
    -- first position is reserved, it's used for faction's home sectors. don't change this
    self:addTemplate("sectors/colony")
    --self:addTemplate("sectors/asteroidfieldminer")
    --self:addTemplate("sectors/loneconsumer")
    --self:addTemplate("sectors/lonescrapyard")
    --self:addTemplate("sectors/loneshipyard")
    --self:addTemplate("sectors/lonetrader")
    --self:addTemplate("sectors/lonetradingpost")
    --self:addTemplate("sectors/lonewormhole")
    --self:addTemplate("sectors/factoryfield")
    --self:addTemplate("sectors/miningfield")
    --self:addTemplate("sectors/gates")
    --self:addTemplate("sectors/ancientgates")
    --self:addTemplate("sectors/neutralzone")

    --self:addTemplate("sectors/pirateasteroidfield")
    --self:addTemplate("sectors/piratefight")
    --self:addTemplate("sectors/piratestation")

    --self:addTemplate("sectors/asteroidfield")
    --self:addTemplate("sectors/smallasteroidfield")
    --self:addTemplate("sectors/defenderasteroidfield")
    --self:addTemplate("sectors/wreckagefield")
    --self:addTemplate("sectors/smugglerhideout")
    --self:addTemplate("sectors/wreckageasteroidfield")

    --self:addTemplate("sectors/xsotanasteroids")
end

function SectorSpecifics:addMoreTemplates()
end


function SectorSpecifics:fillSectorView(view, gatesMap, withContent)

    local x, y = self.coordinates.x, self.coordinates.y
    local contents = self.generationTemplate.contents(x, y)

    view:setCoordinates(x, y)

    if self.gates and gatesMap then
        local connections = gatesMap:getConnectedSectors(self.coordinates)

        local gateDestinations = {}
        for _, connection in pairs(connections) do
            table.insert(gateDestinations, ivec2(connection.x, connection.y))
        end

        view:setGateDestinations(unpack(gateDestinations))
    end

    if not self.offgrid then
        view.factionIndex = self.factionIndex
    end

    if withContent then
        -- this should be perfectly safe and avoids loading the predictor at entry level, causing potential slowdowns
        local FactoryPredictor = include ("factorypredictor")

        local stations = contents.stations - (contents.neighborTradingPosts or 0)
        view.influence = view:calculateInfluence(stations)
        view.numStations = contents.stations
        view.numShips = contents.ships
        if contents.asteroidEstimation then
            view.numAsteroids = contents.asteroidEstimation
        end
        if contents.wreckageEstimation then
            view.numWrecks = contents.wreckageEstimation
        end

        local titles = {}

        --[[
        for i = 1, (contents.shipyards or 0) do table.insert(titles, NamedFormat("Shipyard"%_t, {})) end
        for i = 1, (contents.repairDocks or 0) do table.insert(titles, NamedFormat("Repair Dock"%_t, {})) end
        for i = 1, (contents.scrapyards or 0) do table.insert(titles, NamedFormat("Scrapyard"%_t, {})) end
        for i = 1, (contents.resourceDepots or 0) do table.insert(titles, NamedFormat("Resource Depot"%_t, {})) end
        for i = 1, (contents.equipmentDocks or 0) do table.insert(titles, NamedFormat("Equipment Dock"%_t, {})) end
        for i = 1, (contents.turretFactories or 0) do table.insert(titles, NamedFormat("Turret Factory"%_t, {})) end
        for i = 1, (contents.turretFactorySuppliers or 0) do table.insert(titles, NamedFormat("Turret Factory Supplier"%_t, {})) end
        for i = 1, (contents.fighterFactories or 0) do table.insert(titles, NamedFormat("Fighter Factory"%_t, {})) end
        for i = 1, (contents.headquarters or 0) do table.insert(titles, NamedFormat("Headquarter"%_t, {})) end
        for i = 1, (contents.casinos or 0) do table.insert(titles, NamedFormat("Casino"%_t, {})) end
        for i = 1, (contents.biotopes or 0) do table.insert(titles, NamedFormat("Biotope"%_t, {})) end
        for i = 1, (contents.habitats or 0) do table.insert(titles, NamedFormat("Habitat"%_t, {})) end
        for i = 1, (contents.researchStations or 0) do table.insert(titles, NamedFormat("Research Station"%_t, {})) end
        for i = 1, (contents.militaryOutposts or 0) do table.insert(titles, NamedFormat("Military Outpost"%_t, {})) end
        for i = 1, (contents.resistanceOutposts or 0) do table.insert(titles, NamedFormat("Resistance Outpost"%_t, {})) end
        for i = 1, (contents.planetaryTradingPosts or 0) do table.insert(titles, NamedFormat("Planetary Trading Post"%_t, {})) end
        for i = 1, (contents.smugglersMarkets or 0) do table.insert(titles, NamedFormat("Smuggler's Market"%_t, {})) end
        for i = 1, (contents.tradingPosts or 0) do table.insert(titles, NamedFormat("Trading Post"%_t, {})) end
        for i = 1, (contents.neighborTradingPosts or 0) do table.insert(titles, NamedFormat("Trading Post"%_t, {})) end
        for i = 1, (contents.travelHubs or 0) do table.insert(titles, NamedFormat("Travel Hub"%_t, {})) end
        for i = 1, (contents.riftResearchCenters or 0) do table.insert(titles, NamedFormat("Rift Research Center"%_t, {})) end
        ]]--

        local factories = contents.factories or 0
        if factories > 0 then
            local productions = FactoryPredictor.generateFactoryProductions(x, y, factories)
            for i = 1, factories do
                local production = productions[i]
                local str, args = formatFactoryName(production)

                table.insert(titles, NamedFormat(str, args))
            end
        end

        local mines = contents.mines or 0
        if mines > 0 then
            local productions = FactoryPredictor.generateMineProductions(x, y, mines)
            for i = 1, mines do
                local production = productions[i]
                local str, args = formatFactoryName(production)

                table.insert(titles, NamedFormat(str, args))
            end
        end

        if #titles ~= contents.stations then
            eprint ("mismatch: %i %i; contains stations unaccounted for", x, y)
        end

        view:setStationTitles(unpack(titles))
    end
end

-- returns all regular sector templates that will have stations
function SectorSpecifics.getRegularStationSectors()
    local destinations = {}

    destinations["sectors/colony"] = true
    destinations["sectors/loneconsumer"] = true
    destinations["sectors/loneshipyard"] = true
    destinations["sectors/lonetrader"] = true
    destinations["sectors/lonetradingpost"] = true
    destinations["sectors/factoryfield"] = true
    destinations["sectors/miningfield"] = true
    destinations["sectors/neutralzone"] = true

    return destinations
end
