
function SectorGenerator:createStash(worldMatrix, title)
    local plan = PlanGenerator.makeContainerPlan()
    local container = self:createContainer(plan, worldMatrix, 0)
    container.title = ""
    container:addScript("stash.lua")
    container.title = title or "Secret Stash"%_t
    return container
end

function SectorGenerator:createBeacon(position, faction, text, args)
end

function SectorGenerator:createContainerField(sizeX, sizeY, circular, position, factionIndex, hackables)
end

function SectorGenerator:generateStationContainers(station, sizeX, sizeY, circular)
end

function SectorGenerator:createWreckage(faction, plan, breaks, position)
    local wreckages = {SectorGenerator:createUnstrippedWreckage(faction, plan, breaks, position)}

    for _, wreckage in pairs(wreckages) do
        --if random():test(self.chanceForCaptainLogWreckage) then
        --    wreckage:addScriptOnce("data/scripts/entity/story/captainslogs.lua")
        --end
        if random():test(1 - self.chanceForUnstrippedWreckage) then
            ShipUtility.stripWreckage(wreckage)
        end

        local deletionTimer = DeletionTimer(wreckage)
        if valid(deletionTimer) then
            deletionTimer:disable()
        end
    end

    return unpack(wreckages)
end

local function removeBulletinBoard(station)
    station:removeScript("bulletinboard.lua")
    station:removeScript("missionbulletins.lua")
    station:removeScript("story/bulletins.lua")
end

function SectorGenerator:xCreateSpacedock(faction)
    local station = self:xCreateStation(faction, StationSubType.RepairDock, "data/scripts/entity/merchants/xSpacedock.lua")
    ShipUtility.addArmedTurretsToCraft(station)
    station.crew = station.idealCrew
    return station
end

function SectorGenerator:xRefinery(faction)
    local station = self:xCreateStation(faction, StationSubType.ResourceDepot, "data/scripts/entity/merchants/xRefinery.lua")
    station.crew = station.idealCrew
    return station
end

function SectorGenerator:xOreProcessor(faction)
    local station = self:xCreateStation(faction, StationSubType.ResourceDepot, "data/scripts/entity/merchants/xOreProcessor.lua")
    station.crew = station.idealCrew
    return station
end

function SectorGenerator:xTradingpost(faction)
    local station = self:xCreateStation(faction, StationSubType.TradingPost, "data/scripts/entity/merchants/tradingpost.lua")
    station.crew = station.idealCrew
    return station
end

function SectorGenerator:addAmbientEvents()
    Sector():addScriptOnce("sector/passingships.lua")
    Sector():addScriptOnce("sector/traders.lua")
    Sector():addScriptOnce("sector/factionwar/initfactionwar.lua")
    -- TODO extras
end

function SectorGenerator:estimateAsteroidNumbers(normal, small, dense)
    normal = normal or 0
    small = small or 0
    dense = dense or 0

    -- we tweaked the generators to generate fewer asteroids but generally richer
    return math.ceil(normal * self.normalFieldAsteroids * 0.2 + small * self.smallFieldAsteroids * 0.2 + dense * self.denseFieldAsteroids * 0.2)
end

function SectorGenerator:xCreateStation(faction, styleName, scriptPath, ...)

    -- local styleName = PlanGenerator.determineStationStyleFromScriptArguments(scriptPath, ...)

    local plan = PlanGenerator.makeStationPlan(faction, styleName)
    if plan == nil then
        printlog("Error while generating a station plan for faction ".. faction.name .. ".")
        return
    end

    local position = self:findStationPositionInSector(plan.radius);
    local station
    -- has to be done like this, passing nil for a string doesn't work
    if scriptPath then
        station = Sector():createStation(faction, plan, position, scriptPath, ...)
    else
        station = Sector():createStation(faction, plan, position)
    end

    self:postStationCreation(station)
    removeBulletinBoard(station)
    
    return station
end

