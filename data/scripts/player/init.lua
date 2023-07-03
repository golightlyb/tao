
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


    -- money, iron, titanium, naonite, trinimum, xanion, oganite, avorion
    if player:getValue("x_recieved_starting_resources") ~= 1 then
        player:setValue("x_recieved_starting_resources", 1)
        player:receive(0, 10000, 5000, 0, 0, 250, 0, 0)
    end
end -- onSever()(