
goods = {}
goodsArray = {}
goodsKeyFromName = {}
spawnableGoods = {}
legalSpawnableGoods = {}
illegalSpawnableGoods = {}
uncomplicatedSpawnableGoods = {}

local xGood = {} 
local xStat = {}
local xIcon = {}








--                    pricePerSizeTimesLevel size*10  importancePerLevel Illegal/Dangerous, Basic/Consumer/Industrial/Military/Technology
xStat["XAmmunition"]        = {price=  700, size= 10, level= 4, importance= 5, law={"I","D"},   tags={"M"},         chains={"M"}}
xStat["XArmor"]             = {price=  500, size= 50, level= 4, importance= 5, law=nil,         tags={"M"},         chains={"M"}}
xStat["XBattleRobot"]       = {price= 1100, size=150, level= 5, importance= 2, law={"I"},       tags={"M"},         chains={"I","M","T"}}
xStat["XCarbs"]             = {price=   23, size= 10, level= 0, importance=10, law=nil,         tags={"B","C"},     chains={"B","C","I"}}
xStat["XChemicals"]         = {price=   12, size=200, level= 1, importance=10, law={"D"},       tags={"I"},         chains={"C","I","M","T"}}
xStat["XCivilLuxury"]       = {price=  268, size= 10, level= 2, importance= 3, law=nil,         tags={"C"},         chains={"C"}}
xStat["XCivilNormal"]       = {price=   42, size= 10, level= 2, importance= 3, law=nil,         tags={"C"},         chains={"C"}}
xStat["XCivilIllegal"]      = {price=  600, size= 10, level= 2, importance= 3, law="I",         tags={"C"},         chains={"C"}}
xStat["XElectronics"]       = {price=  200, size= 10, level= 2, importance= 2, law=nil,         tags={"T"},         chains={"C","I","M","T"}}
xStat["XComputer"]          = {price=  292, size= 10, level= 3, importance= 2, law=nil,         tags={"T"},         chains={"I","M","T"}}
xStat["XDisplay"]           = {price=  210, size= 10, level= 4, importance= 2, law=nil,         tags={"T"},         chains={"I","M","T"}}
xStat["XGas"]               = {price=    5, size=200, level= 0, importance=10, law=nil,         tags={"B"},         chains={"B","C","I","M","T"}}
xStat["XLens"]              = {price=  100, size= 10, level= 2, importance= 2, law=nil,         tags={"C","T"},     chains={"C","M","T"}}
xStat["XMedical"]           = {price=  300, size= 10, level= 2, importance=10, law=nil,         tags={"C","T"},     chains={"C","T"}}
xStat["XMetal"]             = {price=   17, size= 50, level= 1, importance=10, law=nil,         tags={"I"},         chains={"C","I","M","T"}}
xStat["XMetalAdvanced"]     = {price=  500, size=  1, level= 2, importance= 3, law=nil,         tags={"T"},         chains={"M","T"}}
xStat["XMetalPrecious"]     = {price=  500, size= 10, level= 1, importance= 4, law=nil,         tags={"C","T"},     chains={"C","I","M","T"}}
xStat["XOre"]               = {price=    3, size= 10, level= 0, importance=10, law=nil,         tags={"B"},         chains={"B","C","I","M","T"}}
xStat["XProtein"]           = {price=   37, size= 10, level= 1, importance=10, law=nil,         tags={"C"},         chains={"C"}}
xStat["XRobot"]             = {price=  800, size=150, level= 5, importance= 2, law=nil,         tags={"T"},         chains={"I","T"}}
xStat["XSystem"]            = {price=  495, size= 50, level= 5, importance= 0, law=nil,         tags={"M","T"},     chains={"M","T"}}
xStat["XUraniumOre"]        = {price=    3, size= 10, level= 0, importance=10, law=nil,         tags={"B"},         chains={"I","M","T"}}
xStat["XUraniumRefined"]    = {price=   15, size= 10, level= 1, importance= 5, law={"I"},       tags={"I"},         chains={"I","M","T"}}
xStat["XUraniumEnriched"]   = {price=  150, size= 10, level= 2, importance= 5, law={"I","D"},   tags={"I"},         chains={"I","M","T"}}
xStat["XWarhead"]           = {price=  666, size= 40, level= 5, importance= 1, law={"I","D"},   tags={"M"},         chains={"M","T"}} 
xStat["XVehicle"]           = {price=  400, size=200, level= 5, importance= 1, law=nil,         tags={"C"},         chains={"C","T"}}
xStat["XWasteToxic"]        = {price=    1, size= 10, level= 2, importance= 0, law={"D"},       tags={"I"},         chains={"I","M"}}
xStat["XWasteRadioactive"]  = {price=    1, size= 10, level= 3, importance= 0, law={"D"},       tags={"I"},         chains={"I","M"}}
xStat["XWater"]             = {price=    8, size=200, level= 0, importance=10, law=nil,         tags={"B","C","I"}, chains={"B","C","I"}}
xStat["XWire"]              = {price=   15, size= 10, level= 2, importance=10, law=nil,         tags={"I","T"},     chains={"I","M","T"}}









--
xGood["XAmmunition"]        ={name="Ammunition",        description="Crates of military-grade ammo."}
xGood["XArmor"]             ={name="Armour",            description="Large heavy armour plates for ships, stations, and vehicles."}
xGood["XBattleRobot"]       ={name="Battle Robot",      description="An autonomous killing machine."}
xGood["XCarbs"]             ={name="Carbohydrates",     description="Staple food, like potatoes or xenograin. It's dried and boxed."}
xGood["XChemicals"]         ={name="Chemicals",         description="Tanks of all sorts of refined industrial chemicals."}
xGood["XCivilLuxury"]       ={name="Luxury goods",      description="Valuable commodities keep the civies happy."}
xGood["XCivilNormal"]       ={name="Consumer goods",    description="Essential comforts for civilian life."}
xGood["XCivilIllegal"]      ={name="Contraband",        description="Forbidden (usually for a good reason) pleasures."}
xGood["XComputer"]          ={name="Computers",         description="Rack-mounted computation units."}
xGood["XDisplay"]           ={name="Displays",          description="Holoprojecting computer displays."}
xGood["XElectronics"]       ={name="Electronics",       description="A constituent component of many technological devices."}
xGood["XGas"]               ={name="Gas",               description="Tanks of pressurized gas, like oxygen or methane."}
xGood["XLens"]              ={name="Lens",              description="High-precision components used to focus light."}
xGood["XMedical"]           ={name="Medical supplies",  description="Everything from antidepressants to hemorrhoid cream."}
xGood["XMetal"]             ={name="Metal",             description="Slabs of common commodity metal, like steel or copper."}
xGood["XMetalAdvanced"]     ={name="Meta-metal",        description="Ingots of high-tech metal that can dynamically change its physical properties."}
xGood["XMetalPrecious"]     ={name="Precious metal",    description="Valuable heavy metal, like Platinum, in ingots and billets."}
xGood["XOre"]               ={name="Ore",               description="Raw metal-bearing stone."}
xGood["XProtein"]           ={name="Protein",           description="Frozen \"meat\" from fungus, plant, animal, or chemical sources."}
xGood["XRobot"]             ={name="Robot",             description="An advanced robot used in industrial settings."}
xGood["XSystem"]            ={name="Subsystem",         description="Integrated technological components, like a shield generator."}
xGood["XUraniumOre"]        ={name="Uranium ore",       description="Needs refining."}
xGood["XUraniumRefined"]    ={name="Yellowcake",        description="Refined uranium. Needs enriching."}
xGood["XUraniumEnriched"]   ={name="Refined uranium",   description="Uranium pellets and rods containing incredible energy."}
xGood["XVehicle"]           ={name="Vehicle",           description="Civilian car, truck, or small ship."}
xGood["XWarhead"]           ={name="Warhead",           description="A weapon of mass destruction."}
xGood["XWasteToxic"]        ={name="Toxic waste",       description="A hazzardous industrial byproduct."}
xGood["XWasteRadioactive"]  ={name="Radioactive waste", description="A byproduct of nuclear processing."}
xGood["XWater"]             ={name="Water",             description="A tank full of clear water."}
xGood["XWire"]              ={name="Wire",              description="A large coil of conductive wire."}









--
xIcon["XAmmunition"]        ={icon="ammo-box.png",              mesh="crate-01.obj"}
xIcon["XArmor"]             ={icon="metal-scales.png",          mesh="metal-plate.obj"}
xIcon["XBattleRobot"]       ={icon="missile-mech.png",          mesh="crate-01.obj"}
xIcon["XCarbs"]             ={icon="wheat.png",                 mesh="crate-food.obj"}
xIcon["XChemicals"]         ={icon="chemical.png",              mesh="crate-gas.obj"}
xIcon["XCivilLuxury"]       ={icon="diamond.png",               mesh="diamond.obj"}
xIcon["XCivilNormal"]       ={icon="open-book.png",             mesh="crate-01.obj"}
xIcon["XCivilIllegal"]      ={icon="captain-smuggler.png",      mesh="crate-01.obj"}
xIcon["XComputer"]          ={icon="computation-mainframe.png", mesh="crate-01.obj"}
xIcon["XDisplay"]           ={icon="checkbox-tree.png",         mesh="crate-01.obj"}
xIcon["XElectronics"]       ={icon="microchip.png",             mesh="crate-01.obj"}
xIcon["XGas"]               ={icon="bio-gas.png",               mesh="crate-gas.obj"}
xIcon["XLens"]              ={icon="high-capacity-lens",        mesh="crate-01.obj"}
xIcon["XMedical"]           ={icon="medical-supplies.png",      mesh="medical-supplies.obj"}
xIcon["XMetal"]             ={icon="i-beam.png",                mesh="metal-plate.obj"}
xIcon["XMetalAdvanced"]     ={icon="metal-bar.png",             mesh="crate-01.obj"}
xIcon["XMetalPrecious"]     ={icon="metal-bar.png",             mesh="crate-01.obj"}
xIcon["XOre"]               ={icon="rock.png",                  mesh="silicon.obj"}
xIcon["XProtein"]           ={icon="meat.png",                  mesh="crate-food.obj"}
xIcon["XRobot"]             ={icon="missile-mech.png",          mesh="crate-01.obj"}
xIcon["XSystem"]            ={icon="computation-mainframe.png", mesh="accelerator.obj"}
xIcon["XUraniumOre"]        ={icon="rock.png",                  mesh="silicon.obj"}
xIcon["XUraniumRefined"]    ={icon="powder.png",                mesh="silicon.obj"}
xIcon["XUraniumEnriched"]   ={icon="radioactive.png",           mesh="plasma-cell.obj"}
xIcon["XVehicle"]           ={icon="apc.png",                   mesh="crate-01.obj"}
xIcon["XWarhead"]           ={icon="warhead.png",               mesh="crate-01.obj"}
xIcon["XWasteToxic"]        ={icon="toxic-waste.png",           mesh="toxic-waste.obj"}
xIcon["XWasteRadioactive"]  ={icon="radioactive.png",           mesh="toxic-waste.obj"}
xIcon["XWater"]             ={icon="water.png",                 mesh="crate-liquids.obj"}
xIcon["XWire"]              ={icon="wire.png",                  mesh="crate-01.obj"}










local tmpI = "I"
local tmpD = "D"
local tmpB = "B"
local tmpC = "C"
local tmpM = "M"
local tmpT = "T"

local function xUnpackFlags(xs)
    local isBasic      = nil
    local isConsumer   = nil
    local isIndustrial = nil
    local isMilitary   = nil
    local isTechnology = nil
    
    for idx = 1, #xs do
        local c      = xs[idx]
        isBasic      = isBasic       or (c == tmpB)
        isConsumer   = isConsumer    or (c == tmpC)
        isIndustrial = isIndustrial  or (c == tmpI)
        isMilitary   = isMilitary    or (c == tmpM)
        isTechnology = isTechnology  or (c == tmpT)
    end
    
    return {
        basic      = isBasic,
        consumer   = isConsumer,
        industrial = isIndustrial,
        military   = isMilitary,
        technology = isTechnology,
    }
end

for key, val in pairs(xGood) do
    local g = xGood[key]
    local s = xStat[key]
    local i = xIcon[key]
    
    if g == nil or s == nil or i == nil then
        eprint("Missing table for good " .. key)
    end
    
    local _size = 0.1 * s.size
    local _price = _size * s.price * math.pow(2, s.level)
    _price = _price * 2 -- rebalance ours vanilla avorion
    
    local isIllegal   = nil
    local isDangerous = nil
    
    if s.law ~= nil then
        for idx = 1, #s.law do
            local c      = s.law[idx]
            isIllegal    = isIllegal     or (c == tmpI)
            isDangerous  = isDangerous   or (c == tmpD)
        end
    end
    
    if isIllegal then _price = _price * 2.0 end
    _price = math.floor(_price + 0.5)
    
    goods[key] = {
        name            = g.name,
        plural          = g.name,
        description     = g.description,
        icon            = "data/textures/icons/" .. i.icon,
        mesh            = "data/meshes/trading-goods/" .. i.mesh,
        price           = _price,
        size            = _size,
        level           = s.level,
        importance      = s.importance,
        illegal         = isIllegal,
        dangerous       = isDangerous,
        tags            = xUnpackFlags(s.tags),
        chains          = xUnpackFlags(s.chains),
    }
end



goods["Scrap Metal"]    = {name="Scrap Metal",      plural="Scrap Metal",       description="Please recycle!", icon="data/textures/icons/scrap-metal.png", mesh="", price=1, size=1, level=0, importance=1, illegal=false, dangerous=false, tags={basic=true}, chains={basic=true,consumer=true,industrial=true,military=true,technology=true}, }

goods["Scrap Iron"]     = {name="Scrap (Iron)",     plural="Scrap (Iron)",        description="Scrap Iron that can be refined into Iron.", icon="data/textures/icons/scrap-metal.png", mesh="", price=4, size=0.04, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,iron=true,scrap=true}, chains={}, }
goods["Scrap Titanium"] = {name="Scrap (Titanium)", plural="Scrap (Titanium)",    description="Scrap Titanium that can be refined into Titanium.", icon="data/textures/icons/scrap-metal.png", mesh="", price=5, size=0.04, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,scrap=true,titanium=true}, chains={}, }
goods["Scrap Naonite"]  = {name="Scrap (Naonite)",  plural="Scrap (Naonite)",     description="Scrap Naonite that can be refined into Naonite.", icon="data/textures/icons/scrap-metal.png", mesh="", price=7, size=0.04, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,naonite=true,scrap=true}, chains={}, }
goods["Scrap Trinium"]  = {name="Scrap (Trinium)",  plural="Scrapp (Trinium)",     description="Scrap Trinium that can be refined into Trinium.", icon="data/textures/icons/scrap-metal.png", mesh="", price=10, size=0.04, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,scrap=true,trinium=true}, chains={}, }
goods["Scrap Xanion"]   = {name="Scrap (Xanion)",   plural="Scrap (Xanion)",      description="Scrap Xanion that can be refined into Xanion.", icon="data/textures/icons/scrap-metal.png", mesh="", price=13, size=0.04, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,scrap=true,xanion=true}, chains={}, }
goods["Scrap Ogonite"]  = {name="Scrap (Ogonite)",  plural="Scrap (Ogonite)",     description="Scrap Ogonite that can be refined into Ogonite.", icon="data/textures/icons/scrap-metal.png", mesh="", price=18, size=0.04, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,ogonite=true,scrap=true}, chains={}, }
goods["Scrap Avorion"]  = {name="Scrap (Avorion)",  plural="Scrap (Avorion)",     description="Scrap Avorion that can be refined into Avorion.", icon="data/textures/icons/scrap-metal.png", mesh="", price=24, size=0.04, level=nil, importance=0, illegal=false, dangerous=false, tags={avorion=true,basic=true,scrap=true}, chains={}, }

goods["Iron Ore"]       = {name="Ore (Iron)",       plural="Ore (Iron)",        description="Iron ore that can be refined into Iron.", icon="data/textures/icons/rock.png", mesh="", price=2, size=0.025, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,iron=true,ore=true}, chains={}, }
goods["Titanium Ore"]   = {name="Ore (Titanium)",   plural="Ore (Titanium)",    description="Titanium ore that can be refined into Titanium.", icon="data/textures/icons/rock.png", mesh="", price=3, size=0.025, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,ore=true,titanium=true}, chains={}, }
goods["Naonite Ore"]    = {name="Ore (Naonite)",    plural="Ore (Naonite)",     description="Naonite ore that can be refined into Naonite.", icon="data/textures/icons/rock.png", mesh="", price=4, size=0.025, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,naonite=true,ore=true}, chains={}, }
goods["Trinium Ore"]    = {name="Ore (Trinium)",    plural="Ore (Trinium)",     description="Trinium ore that can be refined into Trinium.", icon="data/textures/icons/rock.png", mesh="", price=5, size=0.025, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,ore=true,trinium=true}, chains={}, }
goods["Xanion Ore"]     = {name="Ore (Xanion)",     plural="Ore (Xanion)",      description="Xanion ore that can be refined into Xanion.", icon="data/textures/icons/rock.png", mesh="", price=7, size=0.025, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,ore=true,xanion=true}, chains={}, }
goods["Ogonite Ore"]    = {name="Ore (Ogonite)",    plural="Ore (Ogonite)",     description="Ogonite ore that can be refined into Ogonite.", icon="data/textures/icons/rock.png", mesh="", price=9, size=0.025, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,ogonite=true,ore=true}, chains={}, }
goods["Avorion Ore"]    = {name="Ore (Avorion)",    plural="Ore (Avorion)",     description="Avorion ore that can be refined into Avorion.", icon="data/textures/icons/rock.png", mesh="", price=12, size=0.025, level=nil, importance=0, illegal=false, dangerous=false, tags={avorion=true,basic=true,ore=true}, chains={}, }


-- shouldn't appear but helps Avorion not to crash
--[[
goods["Rift Avorion Ore"] = {name="Rift Avorion Ore", plural="Rift Avorion Ore", description="", icon="data/textures/icons/rift-rock.png", mesh="", price=12, size=0.05, level=nil, importance=0, illegal=false, dangerous=false, tags={avorion=true,basic=true,ore=true,rich=true}, chains={}, }
goods["Rift Iron Ore"] = {name="Rift Iron Ore", plural="Rift Iron Ore", description="", icon="data/textures/icons/rift-rock.png", mesh="", price=2, size=0.05, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,iron=true,ore=true,rich=true}, chains={}, }
goods["Rift Naonite Ore"] = {name="Rift Naonite Ore", plural="Rift Naonite Ore", description="", icon="data/textures/icons/rift-rock.png", mesh="", price=4, size=0.05, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,naonite=true,ore=true,rich=true}, chains={}, }
goods["Rift Ogonite Ore"] = {name="Rift Ogonite Ore", plural="Rift Ogonite Ore", description="", icon="data/textures/icons/rift-rock.png", mesh="", price=9, size=0.05, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,ogonite=true,ore=true,rich=true}, chains={}, }
goods["Rift Research Data"] = {name="Rift Research Data", plural="Rift Research Data", description="", icon="data/textures/icons/info-chip.png", mesh="", price=5000, size=0.5, level=nil, importance=0, illegal=false, dangerous=false, tags={mission_relevant=true,rare=true,technology=true}, chains={}, }
goods["Rift Titanium Ore"] = {name="Rift Titanium Ore", plural="Rift Titanium Ore", description="", icon="data/textures/icons/rift-rock.png", mesh="", price=3, size=0.05, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,ore=true,rich=true,titanium=true}, chains={}, }
goods["Rift Trinium Ore"] = {name="Rift Trinium Ore", plural="Rift Trinium Ore", description="", icon="data/textures/icons/rift-rock.png", mesh="", price=5, size=0.05, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,ore=true,rich=true,trinium=true}, chains={}, }
goods["Rift Xanion Ore"] = {name="Rift Xanion Ore", plural="Rift Xanion Ore", description="", icon="data/textures/icons/rift-rock.png", mesh="", price=7, size=0.05, level=nil, importance=0, illegal=false, dangerous=false, tags={basic=true,ore=true,rich=true,xanion=true}, chains={}, }
--]]

table.sort(goods, function (a, b) return a.name < b.name end)
for name, good in pairs(goods) do
    good.good = tableToGood
    table.insert(goodsArray, good)
    goodsKeyFromName[good.name] = name
end




for _, good in pairs(goodsArray) do
    if not (good.tags.trinium or good.tags.xanion or good.tags.ogonite or good.tags.avorion) then
        if not good.illegal then
            table.insert(legalSpawnableGoods, good)
        end

        if not good.suspicious
                and not good.illegal
                and not good.dangerous
                and not good.stolen then
            table.insert(uncomplicatedSpawnableGoods, good)
        end

        table.insert(spawnableGoods, good)
    end

    if good.illegal then
        table.insert(illegalSpawnableGoods, good)
    end
end