package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("galaxy")
include ("randomext")
include ("stringutility")
include ("player")
include ("relations")
local Placer = include ("placer")
local AsyncPirateGenerator = include ("asyncpirategenerator")
local UpgradeGenerator = include ("upgradegenerator")
local SectorTurretGenerator = include ("sectorturretgenerator")
local SpawnUtility = include ("spawnutility")

-- namespace CmdSpawnPirates
CmdSpawnPirates = {}

if onServer() then

    function CmdSpawnPirates.initialize()
    end

    function CmdSpawnPirates.respawn()
        local sector = Sector()
        
        -- local generator = PirateGenerator -- (PirateAttack, PirateAttack.onPiratesGenerated)
        --local faction = generator:getPirateFaction()
        -- local controller = Galaxy():getControllingFaction(x, y)
        
        -- create attacking ships
        local dir = normalize(vec3(getFloat(-1, 1), getFloat(-1, 1), getFloat(-1, 1)))
        local up = vec3(0, 1, 0)
        local right = normalize(cross(dir, up))
        local pos = dir * 100

        local distance = 50

        local generator = AsyncPirateGenerator(CmdSpawnPirates,CmdSpawnPirates.onPiratesGenerated)
        generator:startBatch()
        
        generator:createScaledRaider(MatrixLookUpPosition(-dir, up, pos + right * distance))
        generator:createScaledBandit(MatrixLookUpPosition(-dir, up, pos + right * -distance))
        generator:createScaledPirate(MatrixLookUpPosition(-dir, up, pos + right * -distance * 2.0))
        generator:createScaledOutlaw(MatrixLookUpPosition(-dir, up, pos + right * distance * 2.0))
        generator:endBatch()

        sector:broadcastChatMessage("Server"%_t, 2, "Pirates are attacking the sector!"%_t)
        AlertAbsentPlayers(2, "Pirates are attacking sector \\s(%1%:%2%)!"%_t, sector:getCoordinates())
        
        -- terminate()
    end
    
    function CmdSpawnPirates.onPiratesGenerated(generated)
        Placer.resolveIntersections(generated)

        -- add enemy buffs
        -- SpawnUtility.addEnemyBuffs(generated)
    end
end
