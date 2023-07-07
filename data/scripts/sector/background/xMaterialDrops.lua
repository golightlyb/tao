
package.path = package.path .. ";data/scripts/lib/?.lua"

include ("utility")
include ("relations")
include ("stringutility")
include ("goods")

-- namespace MaterialDrops
MaterialDrops = {}

-- This script generates our non-vanilla drops from mining and salvaging.
-- These drop no matter the source of damage i.e. does not need mining laser
-- and, if there's inventory space, always appears directly in inventory
-- rather than as a floating object to be collected.

if onServer() then

    local ores = {"XIronOre", "XTitaniumOre", "XNaoniteOre", "XTriniumOre", "XXanionOre", "XOgoniteOre", "XAvorionOre"}
    local scraps = {"XScrapIron", "XScrapTitanium", "XScrapNaonite", "XScrapTrinium", "XScrapXanion", "XScrapOgonite", "XScrapAvorion"}

    local function create(reciever, id, quantity, isStolen)
        if quantity < 1 then return end
        isStolen = isStolen or false
        local good = goods[id]
        if good == nil then
            eprint("xMaterialDrops: could not create good with id")
            eprint(id)
            return
        end
        local NewGood = TradingGood(good.name, good.plural, good.description, good.icon, good.price, good.size)
        NewGood.stolen = isStolen
        NewGood.dangerous = good.dangerous
        NewGood.illegal = good.illegal
        
        local toStore = quantity * good.size
        
        local free = (reciever.freeCargoSpace or 0)
        if toStore < free then
            reciever:addCargo(NewGood, quantity)
        else
            -- only drop the cargo if it's the player to avoid AI leaving
            -- performance-impacting loot everywhere
            local recieverFaction = Faction(reciever.factionIndex)
            local recieverIsPlayer = (recieverFaction and recieverFaction.isPlayer)
            local at = reciever.translationf
            Sector():dropCargo(at, reciever, nil, NewGood, 0, quantity)
        end
    end
    
    function MaterialDrops.onBlockDestroyed(entityIndex, blockIndex, block, inflictor, damage, damageType)
        if not entityIndex then return end

        local entity =  Sector():getEntity(entityIndex)
        local inflictor = Sector():getEntity(inflictor)
        local reservedFor = nil

        if not entity then return end
        if not inflictor then return end
        if not block then return end
        
        local reciever = inflictor
        
        --local at = inflictor.translationf
        local volume = block.volume
        local harvestable = block.harvestableResources

        if entity.isShip or entity.isStation or entity.isWreckage then
            if harvestable > 0 then
                create(reciever, scraps[block.material.value+1], harvestable * 0.1)
            end
            create(reciever,"XScrapMetal", volume/100, inflictorIsPlayer)

        elseif entity.isAsteroid then
            if harvestable > 0 then
                create(reciever, ores[block.material.value+1], harvestable)
            end
            
            create(reciever, "XOre",        volume/10)
            create(reciever, "XUraniumOre", volume/100)
        end
    end
    
    function MaterialDrops.initialize()
        local sector = Sector()
        sector:registerCallback("onBlockDestroyed", "onBlockDestroyed")
    end
end
return MaterialDrops
