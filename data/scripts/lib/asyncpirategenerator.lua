

function AsyncPirateGenerator:createScaledRavager(position)
    --if random():test(0.2) then
    --    return self:createScaledCarrier(position)
    --end

    local scaling = self:getScaling()
    return self:create(position, 6.0 * scaling, "Ravager"%_T)
end


function AsyncPirateGenerator:createRavager(position)
    --if random():test(0.2) then
    --    return self:createCarrier(position)
    --end
    return self:create(position, 6.0, "Ravager"%_T)
end
