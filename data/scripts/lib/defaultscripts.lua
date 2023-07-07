function AddDefaultStationScripts(station)
    if not valid(station) then return end
    station:addScriptOnce("data/scripts/entity/startbuilding.lua")
    station:addScriptOnce("data/scripts/entity/entercraft.lua")
    station:addScriptOnce("data/scripts/entity/exitcraft.lua")

    station:addScriptOnce("data/scripts/entity/crewboard.lua")
    station:addScriptOnce("data/scripts/entity/backup.lua")
    station:addScriptOnce("data/scripts/entity/bulletinboard.lua")
    --station:addScriptOnce("data/scripts/entity/story/bulletins.lua") -- removed
    station:addScriptOnce("data/scripts/entity/regrowdocks.lua")
    station:addScriptOnce("data/scripts/entity/missionbulletins.lua")

    station:addScriptOnce("data/scripts/entity/transfercrewgoods.lua")
    station:addScriptOnce("data/scripts/entity/utility/transportmode.lua")
end
