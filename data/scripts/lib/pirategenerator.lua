function PirateGenerator.createScaledRavager(position)
    --if random():test(0.2) then
    --    return generator.createScaledCarrier(position)
    --end

    local scaling = PirateGenerator.getScaling()
    return PirateGenerator.create(position, 6.0 * scaling, "Ravager"%_T)
end

function PirateGenerator.createRavager(position)
    --if random():test(0.2) then
    --    return PirateGenerator.createCarrier(position)
    --end

    return PirateGenerator.create(position, 6.0, "Ravager"%_T)
end

