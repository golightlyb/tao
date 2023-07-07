
local SectorTurretGenerator = include("sectorturretgenerator")


function CreativeMode.onStolenCargoChecked()
end

-- bugfix for missing include
function CreativeMode.onAddGunsPressed()
    if onClient() then
        invokeServerFunction("onAddGunsPressed")
        return
    end

    local player = Player(callingPlayer)
    if not player.craft then return end

    local craftFaction = Faction(player.craft.factionIndex)

    local x, y = player:getSectorCoordinates()

    for j = 1, 10 do
        local turret = SectorTurretGenerator():generate(x, y)
        craftFaction:getInventory():add(InventoryTurret(turret))
    end
end
callable(CreativeMode, "onAddGunsPressed")


function CreativeMode.onGoodsButtonPressed(button, stolen, amount)
    if onClient() then
        amount = 1

        local keyboard = Keyboard()
        if keyboard:keyPressed(KeyboardKey.LShift) or keyboard:keyPressed(KeyboardKey.RShift) then
            amount = 10
        elseif keyboard:keyPressed(KeyboardKey.LControl) or keyboard:keyPressed(KeyboardKey.RControl) then
            amount = 100
        end
        invokeServerFunction("onGoodsButtonPressed", button.tooltip, CreativeMode.stolenCargoCheckBox.checked, amount)
        return
    end

    local player = Player(callingPlayer)
    local craft = player.craft
    if not craft then return end

    local name = button -- passed from the client
    local good = goods[goodsKeyFromName[name]]:good()
    good.stolen = stolen

    craft:addCargo(good, amount)
end
callable(CreativeMode, "onGoodsButtonPressed")
