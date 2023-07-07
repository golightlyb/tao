function WeaponTypes.getRandom(rand)
    return rand:getInt(WeaponType.XMining, WeaponType.XDisruptor)
end

-- XMining: dual purpose miner and salvager; mines both stone and hulls, no damage vs shields

-- Type       | Name           | Damage   | ROF    | burst  | cooldown  | range  | recoil | notes
-- XGun       | autocannon     | physical | medium | short  | short     | short  | medium | coaxial only, limited max size
-- XCannon    | artillery      | physical | v. low | single | v. long   | long   | high   | explosion, multishot, bonus vs hull
-- XMissile   | micro-missile  | physical | high   | short  | xx long   | medium | medium | seeking

-- XLaser     | laser          | energy   | beam   | medium | medium    | medium | none   |
-- XDisruptor | disruptor      | plasma   | high   | short  | xx long   | short  | none   | coaxial only, limited min size, multishot, bonus vs shields
-- XLance     | particle lance | electric | beam   | medium | xxxx long | long   | none   | coaxial only, size 10 only, high bonus vs shields, weak vs stone

-- physical damage can be reduced by deflector subsystems (-20% energy each)
-- energy damage can be reduced by polariser subsystems (-20% energy each)
-- electrical damage can be reduced

-- XLaser: energy, strong vs deflector and technical blocks
-- XDisruptor: energy, burst fire with long cooldown, medium damage, strong vs shields, coaxial only

-- XPDGun: point-defense chaingun, cheap, decent accuracy, poor range.
-- XPDLaser: point-defense laser, good accuracy and very good range, no damage vs shields.
-- XPDFlak: point-defense cannon with area of effect explosion. Poor accuracy but decent range.

WeaponTypes.addType("XMining",             "XMining /* Weapon Type */"%_t,                unarmed)

WeaponTypes.addType("XGun",                "XGun /* Weapon Type */"%_t,                   armed)
WeaponTypes.addType("XCannon",             "XCannon /* Weapon Type */"%_t,                armed)
WeaponTypes.addType("XMissile",            "XMissile /* Weapon Type */"%_t,               armed)
WeaponTypes.addType("XDisruptor",          "XDisruptor /* Weapon Type */"%_t,             armed)

--WeaponTypes.addType("XLaser",              "XLaser /* Weapon Type */"%_t,                 armed)
--WeaponTypes.addType("XDisruptor",          "XDisruptor /* Weapon Type */"%_t,             armed)

--WeaponTypes.addType("XPDGun",              "XPDGun /* Weapon Type */"%_t,                 defensive)
--WeaponTypes.addType("XPDLaser",            "XPDLaser /* Weapon Type */"%_t,               defensive)
--WeaponTypes.addType("XPDFlak",             "XPDLaser /* Weapon Type */"%_t,               defensive)



