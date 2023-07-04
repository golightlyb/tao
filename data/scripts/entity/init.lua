if onServer() then

    local entity = Entity()

    if entity.type == EntityType.Station or entity.type == EntityType.Ship then
        entity:addScriptOnce("entity/xNoAccumulatingBlockHealth.lua")
    end

end
