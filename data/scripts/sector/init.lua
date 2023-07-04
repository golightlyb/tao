
if onServer() then
    local sector = Sector()
    sector:removeScript("sector/xsotanswarm.lua")
    sector:removeScript("internal/dlc/blackmarket/sector/background/blackmarketstorybulletin.lua")
    sector:addScriptOnce("sector/background/xMaterialDrops.lua")
end

