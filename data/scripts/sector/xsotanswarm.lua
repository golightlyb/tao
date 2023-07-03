if onServer() then

function XsotanSwarm.getUpdateInterval()
    return 60
end

function XsotanSwarm.initialize()
end

function XsotanSwarm.canHappenInThisSector()
    return false
end

function XsotanSwarm.updateServer()
end

function XsotanSwarm.onPlayerEntered(playerIndex, sectorChangeType)
end

function XsotanSwarm.onPlayerLeft(playerIndex, sectorChangeType)
end

function XsotanSwarm.addWrapperMissionToPlayers()
end

function XsotanSwarm.spawnBackgroundXsotan()
end

function XsotanSwarm.spawnHenchmenXsotan(num)
end

function XsotanSwarm.spawnLevel2()
end

function XsotanSwarm.spawnLevel3()
end

function XsotanSwarm.spawnLevel4()
end

function XsotanSwarm.spawnLevel5()
end

function XsotanSwarm.spawnEndBoss(position, scale)
end

function XsotanSwarm.attachMax(plan, attachment, dimStr)
end

function XsotanSwarm.attachMin(plan, attachment, dimStr)
end


function XsotanSwarm.getAllSpawnedShips()
end

function XsotanSwarm.generateUpgrade()
end

function XsotanSwarm.countAliveXsotan()
    return 0
end

function XsotanSwarm.miniBossSlain()
    return false
end

function XsotanSwarm.onDestroyed(index)
end

function XsotanSwarm.onXsotanSwarmEventFailed()
end

function XsotanSwarm.onXsotanSwarmEventWon()
end

end

if onClient() then
function XsotanSwarm.showBossBar(entity, small)
end
end

-- for testing: Make end boss spawn immediately
function XsotanSwarm.setSpawnEndBossImmediately()
end
