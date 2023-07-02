
function PlanGenerator.makeAsyncCarrierPlan(callback, values, faction, volume, styleName, material, sync)
    return PlanGenerator.makeAsyncShipPlan(callback, values, faction, volume, styleName, material, sync)
end

function PlanGenerator.makeCarrierPlan(faction, volume, styleName, material)
    return PlanGenerator.makeAsyncCarrierPlan(nil, nil, faction, volume, styleName, material, true)
end


function PlanGenerator.makeXsotanCarrierPlan(volume, material)
    return PlanGenerator.makeXotanShipPlan(volume, material)
end
