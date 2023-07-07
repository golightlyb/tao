package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"


local SpawnUtility = include ("player/cmd/spawnpirates")

function getDescription()
    return "Spawns some pirates for target practice."
end

function getHelp()
    return "Usage: /spawnpirates --now"
end

function execute(sender, commandName, ...)
    local args = {...}

    if (#args == 1) and (args[1] == "--now") then
        Player(sender):addScriptOnce("cmd/spawnpirates.lua") 
        -- if CmdSpawnPirates then CmdSpawnPirates.respawn() end
        Player(sender):invokeFunction("cmd/spawnpirates.lua", "respawn")
    else
        Player(sender):sendChatMessage("/spawnpirates", 0, getHelp())
    end

    return 0, "", ""
end



