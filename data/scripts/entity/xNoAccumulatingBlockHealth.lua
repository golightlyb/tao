package.path = package.path .. ";data/scripts/entity/?.lua"

function initialize()
    local entity = Entity()
    entity:setAccumulatingBlockHealth(false)
end
