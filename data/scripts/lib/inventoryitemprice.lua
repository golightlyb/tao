
function ArmedObjectPrice(object)
    -- local type = WeaponTypes.getTypeOfItem(object) or WeaponType.XGun

    local dps = object.dps * (1.0 + object.shieldDamageMultiplier) * (1.0 + object.hullDamageMultiplier)
    dps = dps + object.hullRepairRate + object.shieldRepairRate
    -- dps = dps + object.holdingForce / 10000
    
    local r = object.rarity.value + 1 -- 0 to 6
    local m = object.material.value -- 0 to 6
    
    local dpsValue = dps
    if dpsValue > 1000 then
        dpsValue = 1000 + math.sqrt(dpsValue - 1000)
    end
    --            (1000 to ~1500) x (1 to 128) x () x (1 to 128) x (1 to 3.16) gives 1k to 77 million
    local value = (1000 + (dpsValue * 0.5)) * math.pow(4, r/2) * math.pow(2, m) * math.sqrt(object.slots)
    
    if object.seeker then
        value = value * 1.25 -- to 92-odd million
    end
    value = math.min(value, 99999999)
    
    return value
end


