-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function interactionPossible(playerIndex, option)

    local player = Player(playerIndex)
    local self = Entity()

    local craft = player.craft
    if craft == nil then return false end

    local dist = craft:getNearestDistance(self)

    if dist <= math.max(craft.transporterRange, 20.0) then
        return true
    end

    return false, "You're not close enough to open the object."%_t
end


function checkForLaserBossHint()
end

function claim()

    local receiver, ship, player = getInteractingFaction(callingPlayer, AlliancePrivilege.AddItems, AlliancePrivilege.AddResources)
    if not receiver then return end

    local craft = player.craft
    if craft == nil then return false end
    
    local entity = Entity()
    local dist = ship:getNearestDistance(entity)
    if dist > math.max(craft.transporterRange, 20.0) then
        player:sendChatMessage("", ChatMessageType.Error, "You're not close enough to open the object."%_t)
        return
    end

    local sector = Sector()

    if not data.empty then
        receiveMoney(receiver)
        receiveUpgrade(receiver)

        -- small chance to drop building knowledge
        if random():getFloat() < 1 / 20 then
            receiveBuildingKnowledge(player)
        end
    end

    -- send callback that stash is opened
    local player = Player(callingPlayer)
    sector:sendCallback("onStashOpened", entity.id, player.index)
    player:sendCallback("onStashOpened", entity.id, player.index)
    entity:sendCallback("onStashOpened", entity.id, player.index)

    -- terminate script and remove entity from object detection
    terminate()
    entity:setValue("valuable_object", nil)
end
callable(nil, "claim")




