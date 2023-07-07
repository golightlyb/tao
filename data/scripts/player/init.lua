
if onServer() then
    local player = Player()

    player:removeScript("background/tutorialstarter.lua")
    player:removeScript("background/exodussectorgenerator.lua")
    player:removeScript("background/storystarter.lua")
    player:removeScript("events/spawnasteroidboss.lua")
    player:removeScript("story/spawnrandombosses.lua")
    player:removeScript("story/spawnguardian.lua")
    player:removeScript("background/storyquestutility.lua")
    
    player:removeScript("internal/dlc/blackmarket/player/missions/intro/intromissionutility.lua")
    player:removeScript("internal/dlc/blackmarket/player/background/syndicateframeworkmission.lua")
    player:removeScript("internal/dlc/blackmarket/player/background/revealblackmarkets.lua")
    player:removeScript("internal/dlc/blackmarket/player/background/blackmarketeventstarter.lua")
    player:removeScript("internal/dlc/rift/player/story/riftstorycampaign.lua")
    
    player:addScriptOnce("xTrimGoods.lua")
end -- onSever()(
