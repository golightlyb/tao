
function SectorGenerator:createStash(worldMatrix, title)
    local plan = PlanGenerator.makeContainerPlan()
    local container = self:createContainer(plan, worldMatrix, 0)
    container.title = ""
    container:addScript("stash.lua")
    container.title = title or "Secret Stash"%_t
    return container
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

function SectorGenerator:createEquipmentDock(faction)
    local station = self:createStation(faction, "data/scripts/entity/merchants/equipmentdock.lua");

    station:addScript("data/scripts/entity/merchants/turretmerchant.lua")
    --station:addScript("data/scripts/entity/merchants/fightermerchant.lua")
    station:addScript("data/scripts/entity/merchants/utilitymerchant.lua")
    station:addScript("data/scripts/entity/merchants/consumer.lua", "Equipment Dock"%_t, unpack(ConsumerGoods.EquipmentDock()))

    local x, y = Sector():getCoordinates()
    local dist2 = x * x + y * y
    --if dist2 < 380 * 380 then
        station:addScript("data/scripts/entity/merchants/torpedomerchant.lua")
    --end

    ShipUtility.addArmedTurretsToCraft(station)

    return station
end


function SectorGenerator:createMilitaryBase(faction)
    local station = self:createStation(faction, "data/scripts/entity/merchants/militaryoutpost.lua");
    station:addScript("data/scripts/entity/merchants/consumer.lua", "Military Outpost"%_t, unpack(ConsumerGoods.MilitaryOutpost()))
    ShipUtility.addArmedTurretsToCraft(station)
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

    return math.ceil(normal * self.normalFieldAsteroids * 0.2 + small * self.smallFieldAsteroids * 0.2 + dense * self.denseFieldAsteroids * 0.2)
end


