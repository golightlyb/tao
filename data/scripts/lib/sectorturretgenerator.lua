




function SectorTurretGenerator:generateArmed(x, y, offset_in, rarity_in, material_in)

    local offset = offset_in or 0
    local sector = math.floor(length(vec2(x, y))) + offset
    local types = Balancing_GetWeaponProbability(sector, 0)

    types[WeaponType.RepairBeam] = nil
    types[WeaponType.MiningLaser] = nil
    types[WeaponType.SalvagingLaser] = nil
    types[WeaponType.RawSalvagingLaser] = nil
    types[WeaponType.RawMiningLaser] = nil
    types[WeaponType.ForceGun] = nil
    
    types[WeaponType.XMining] = nil

    local weaponType = getValueFromDistribution(types, self.random)

    return self:generate(x, y, offset_in, rarity_in, weaponType, material_in, self.coaxialAllowed)
end

