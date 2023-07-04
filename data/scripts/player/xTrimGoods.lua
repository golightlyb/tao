package.path = package.path .. ";data/scripts/lib/?.lua"

include ("utility")

-- namespace TrimDrops
TrimDrops = {}
local playerShip

-- This script removes the vanilla "___ Ore" or "Scrap ___" items, because
-- they have to exist for Avorion not to crash, but we don't use them in our
-- overhaul.


function TrimDrops.onCargoChanged(objectIndex, delta, tg)
    if delta <= 0 then return end
    local player = Player()
    local entity = player.craft
    if valid(entity) then
        name = tg.name
        if name == "Iron Ore" or name == "Titanium Ore" or name == "Naonite Ore" or name == "Trinium Ore" or name == "Xanion Ore" or name == "Ogonite Ore" or name == "Avorion Ore" then
            entity:removeCargo(tg.name, delta)
        elseif name == "Scrap Iron" or name == "Scrap Titanium" or name == "Scrap Naonite" or name == "Scrap Trinium" or name == "Scrap Xanion" or name == "Scrap Ogonite" or name == "Scrap Avorion" then
            entity:removeCargo(tg.name, delta)
        end
    end
end

function TrimDrops.initialize()        
    local player = Player()
    player:registerCallback("onShipChanged", "onShipChanged")
    local entity = player.craft

    if valid(entity) then
        entity:registerCallback("onCargoChanged", "onCargoChanged")
        playerShip = entity.index
    else
        playerShip = Uuid()
    end
end

function TrimDrops.onShipChanged(playerIndex, craftIndex)
    local sector = Sector()
    local oldShip = sector:getEntity(playerShip)
    local oldFactionIndex

    if oldShip then
        oldShip:unregisterCallback("onCargoChanged", "onCargoChanged")
        oldFactionIndex = oldShip.factionIndex
    end

    playerShip = craftIndex
    local ship = sector:getEntity(craftIndex)
    if not ship then return end

    ship:registerCallback("onCargoChanged", "onCargoChanged")
end
