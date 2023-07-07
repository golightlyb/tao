package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")

local interestingEntities = {}
local baseCooldown = 40.0
local cooldown = 40.0
local remainingCooldown = 0.0 -- no initial cooldown

local highlightDuration = 30.0
local activeTime = nil
local highlightRange = 0

local permanentlyInstalled = false
local tooltipName = "Object Detection"%_t

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
PermanentInstallationOnly = true
Unique = true

function getBonuses(seed, rarity, permanent)
    r = rarity.value + 1 -- 0 to 6
    
    -- return highlightRange, cooldown

    -- 10km to 70km, +1x to +1.7x
    return 1000 * (1 + r), highlightDuration * math.pow(1.1, 6-r)
end

function onInstalled(seed, rarity, permanent)
    if onClient() then
        local player = Player()
        if valid(player) then
            player:registerCallback("onPreRenderHud", "onPreRenderHud")
            player:registerCallback("onPreRenderHud", "sendMessageForValuables")
        end
    end

    highlightRange, cooldown = getBonuses(seed, rarity, permanent)
    permanentlyInstalled = permanent

    if onClient() then
        sendMessageForValuables()
    end
end

function onUninstalled(seed, rarity, permanent)
end

function updateClient(timeStep)
    if remainingCooldown > 0.0 then
        remainingCooldown = math.max(0, remainingCooldown - timeStep)
    end

    if activeTime then
        activeTime = activeTime - timeStep
        if activeTime <= 0.0 then
            activeTime = nil
            interestingEntities = {}
        end
    end
end

function onDetectorButtonPressed()
    -- set cooldown and activeTime on both client and server
    remainingCooldown = cooldown
    activeTime = highlightDuration

    interestingEntities = collectHighlightableObjects()

    playSound("scifi-sonar", SoundType.UI, 0.5)

    -- notify player that entities were found
    local nie = tablelength(interestingEntities)
    if nie == 1 then
        deferredCallback(3, "showNotification", "Valuable object detected."%_t)
    elseif nie > 1 then
        deferredCallback(3, "showNotification", string.format("%d valuable objects detected."%_t, nie))
    else
        deferredCallback(3, "showNotification", "Nothing found here."%_t)
    end

    interestingEntities = filterHighlightableObjects(interestingEntities)
end

function showNotification(text)
    displayChatMessage(text, "Object Detector"%_t, ChatMessageType.Information)

end

function onSectorChanged()
    if onClient() then
        sendMessageForValuables()
    end
end

function interactionPossible(playerIndex, option)
    local player = Player(playerIndex)
    if not player then return false, "" end

    local craftId = player.craftIndex
    if not craftId then return false, "" end

    if craftId ~= Entity().index then
        return false, ""
    end

    if remainingCooldown > 0.0 then
        return false, ""
    end

    return true
end

function initUI()
    ScriptUI():registerInteraction(tooltipName, "onDetectorButtonPressed", -1);
end

function getUIButtonCooldown()
    local tooltipText = ""

    if remainingCooldown > 0 then
        local duration = math.max(0.0, remainingCooldown)
        local minutes = math.floor(duration / 60)
        local seconds = duration - minutes * 60
        tooltipText = tooltipName .. ": " .. string.format("%02d:%02d", math.max(0, minutes), math.max(0.01, seconds))
    else
        tooltipText = tooltipName
    end

    return remainingCooldown / cooldown, tooltipText
end

function collectHighlightableObjects()
    local player = Player()
    if not valid(player) then return end

    local self = Entity()
    if player.craftIndex ~= self.index then return end

    local objects = {}

    -- normal entities
    for _, entity in pairs({Sector():getEntitiesByScriptValue("valuable_object")}) do
        local value = entity:getValue("highlight_color") or entity:getValue("valuable_object")

        -- docked objects are not available for the player
        if not entity.dockingParent then
            if type(value) == "string" then
                objects[entity.id] = {entity = entity, color = Color(value)}
            else
                objects[entity.id] = {entity = entity, color = Rarity(value).color}
            end
        end
    end

    -- wreckages with black boxes
    -- black box wreckages are always tagged as Petty
    for _, entity in pairs({Sector():getEntitiesByScriptValue("blackbox_wreckage")}) do
        -- docked objects are not available for the player
        if not entity.dockingParent then
            objects[entity.id] = {entity = entity, color = ColorRGB(0.3, 0.9, 0.9)}
        end
    end

    return objects
end

function filterHighlightableObjects(objects)
    -- no need to sort out if none of the found entities will be marked
    if highlightRange == 0 then
        return {}
    end

    -- remove all entities that are too far away and shouldn't be marked
    local range2 = highlightRange * highlightRange
    local center = Entity().translationf
    for id, entry in pairs(objects) do
        if valid(entry.entity) then
            if distance2(center, entry.entity.translationf) > range2 then
                objects[id] = nil
            end
        end
    end

    return objects
end

local automaticMessageDisplayed
function sendMessageForValuables()
    if automaticMessageDisplayed then return end
    if not permanentlyInstalled then return end

    local player = Player()
    if not valid(player) then return end

    local self = Entity()
    if player.craftIndex ~= self.index then return end

    local objects = collectHighlightableObjects()

    -- notify player that entities were found
    if tablelength(objects) > 0 then
        displayChatMessage("Anomalous reading."%_t, "Object Detector"%_t, ChatMessageType.Information)
        automaticMessageDisplayed = true
    end
end

function onPreRenderHud()
    if not highlightRange or highlightRange == 0 then return end
    if not permanentlyInstalled then return end

    local player = Player()
    if not player then return end
    if player.state == PlayerStateType.BuildCraft or player.state == PlayerStateType.BuildTurret then return end

    local self = Entity()
    if player.craftIndex ~= self.index then return end

    if tablelength(interestingEntities) == 0 then return end

    -- detect all objects in range
    local renderer = UIRenderer()

    local range = lerp(activeTime, highlightDuration, highlightDuration - 5, 0, 100000, true)
    local range2 = range * range
    local center = self.translationf

    local timeFactor = 1.25 * math.sin(activeTime * 10)
    for id, object in pairs(interestingEntities) do
        if not valid(object.entity) then
            interestingEntities[id] = nil
            goto continue
        end

        if distance2(object.entity.translationf, center) < range2 then
            local _, size = renderer:calculateEntityTargeter(object.entity)
            local c = lerp(math.sin(activeTime * 10), 0, 1.5, vec3(object.color.r, object.color.g, object.color.b), vec3(1, 1, 1))
            renderer:renderEntityTargeter(object.entity, ColorRGB(c.x, c.y, c.z), size + 1.5 * timeFactor);
        end

        ::continue::
    end

    renderer:display()
end

function getName(seed, rarity)
    return "Anomalous Object Detector MK ${mark} /* ex: Anomalous Object Detector MK IV */"%_t % {mark = toRomanLiterals(rarity.value + 2)}
end

function getBasicName()
    return "Anomalous Object Detector /* generic name for 'Anomalous Object Detector' */"%_t
end

function getIcon(seed, rarity)
    return "data/textures/icons/movement-sensor.png"
end

function getControlAction()
    return ControlAction.ScriptQuickAccess2
end

function getEnergy(seed, rarity, permanent)
    local r = rarity.value + 1 -- 0 to 6
    return 1000 * 1000 * math.pow(4, r)
    
    -- petty:       c      1 --   1 MW
    -- common:      c      4 --   4 MW
    -- uncommon:    c     64 --  64 MW
    -- rare:        c    256 -- 256 MW
    -- exceptional: c  1,024 --   1 GW
    -- exotic:      c  4,096 --   4 GW
    -- legendary:   c 16,384 --  16 GW
end

function getPrice(seed, rarity)
    local r = rarity.value + 1 -- 0 to 6
    return 15625 * math.pow(4, r)
        
    -- 250,000 * 4^r
    -- petty:       c     15,625
    -- common:      c     62,500
    -- uncommon:    c    250,000
    -- rare:        c  1,000,000
    -- exceptional: c  4,000,000
    -- exotic:      c 16,000,000
    -- legendary:   c 64,000,000
end

function getTooltipLines(seed, rarity, permanent)
    local texts = {}
    local bonuses = nil
    local range, cooldown = getBonuses(seed, rarity, true)

    local toYesNo = function(line, value)
        if value then
            line.rtext = "Yes"%_t
            line.rcolor = ColorRGB(0.3, 1.0, 0.3)
        else
            line.rtext = "No"%_t
            line.rcolor = ColorRGB(1.0, 0.3, 0.3)
        end
    end

    table.insert(texts, {ltext = "Claimable Asteroids"%_t, icon = "data/textures/icons/asteroid.png"})
    toYesNo(texts[#texts], true)

    table.insert(texts, {ltext = "Flight Recorders"%_t, icon = "data/textures/icons/ship.png"})
    toYesNo(texts[#texts], true)

    table.insert(texts, {ltext = "Treasures"%_t, icon = "data/textures/icons/crate.png"})
    toYesNo(texts[#texts], true)

    table.insert(texts, {}) -- empty line

    if permanent then
        table.insert(texts, {ltext = "Automatic Notification"%_t, rtext = "", icon = "data/textures/icons/mission-item.png", boosted = permanent})
        toYesNo(texts[#texts], permanent)
    end

    bonuses = {}
    table.insert(bonuses, {ltext = "Automatic Notification"%_t, rtext = "Yes", icon = "data/textures/icons/mission-item.png"})

    if range > 0 then
        rangeText = string.format("%g km"%_t, round(range / 100, 2))
        if permanent then
            table.insert(texts, {ltext = "Highlight Range"%_t, rtext = rangeText, icon = "data/textures/icons/rss.png", boosted = permanent})
        end

        table.insert(bonuses, {ltext = "Highlight Range"%_t, rtext = rangeText, icon = "data/textures/icons/rss.png"})
    end

    table.insert(texts, {ltext = "Detection Range"%_t, rtext = "Sector"%_t, icon = "data/textures/icons/rss.png"})

    if range > 0 then
        if permanent then
            table.insert(texts, {ltext = "Highlight Duration"%_t, rtext = string.format("%s", createReadableShortTimeString(highlightDuration)), icon = "data/textures/icons/hourglass.png", boosted = permanent})
        end

        table.insert(bonuses, {ltext = "Highlight Duration"%_t, rtext = string.format("%s", createReadableShortTimeString(highlightDuration)), icon = "data/textures/icons/hourglass.png"})
    end

    table.insert(texts, {ltext = "Cooldown"%_t, rtext = string.format("%s", createReadableShortTimeString(cooldown)), icon = "data/textures/icons/hourglass.png"})

    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    local texts = {}

    table.insert(texts, {ltext = "Detects interesting objects in the sector."%_t})

    if rarity > Rarity(RarityType.Petty) then
        table.insert(texts, {ltext = "Highlights objects when permanently installed."%_t})
    end

    return texts
end

function getComparableValues(seed, rarity)
    local range, cooldown = getBonuses(seed, rarity, true)

    local base = {}
    local bonus = {}
    table.insert(bonus, {name = "Highlight Range"%_t, key = "highlight_range", value = round(range / 100), comp = UpgradeComparison.MoreIsBetter})
    table.insert(bonus, {name = "Highlight Duration"%_t, key = "highlight_duration", value = round(highlightDuration), comp = UpgradeComparison.MoreIsBetter})

    table.insert(base, {name = "Detection Range"%_t, key = "detection_range", value = 1, comp = UpgradeComparison.MoreIsBetter})
    table.insert(base, {name = "Cooldown"%_t, key = "cooldown", value = cooldown, comp = UpgradeComparison.LessIsBetter})

    return base, bonus
end
