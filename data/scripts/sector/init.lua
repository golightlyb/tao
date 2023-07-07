
if onServer() then
    local sector = Sector()
    sector:removeScript("sector/xsotanswarm.lua")
    sector:removeScript("internal/dlc/blackmarket/sector/background/blackmarketstorybulletin.lua")
    sector:addScriptOnce("sector/background/xMaterialDrops.lua")
    
    -- BUGFIX: wreckagecleanup was never actually added!
    sector:addScriptOnce("sector/background/wreckagecleanup.lua")
end


