
local function carriersPossible()
    return false
end


function AsyncShipGenerator:createCarrier(faction, position, fighters)
    self:createMilitaryShip(faction, position)
end


function AsyncShipGenerator:createCIWSShip(faction, position, volume)
    self:createMilitaryShip(faction, position)
end
