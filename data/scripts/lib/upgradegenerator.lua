scripts = {}

add("data/scripts/systems/xcore.lua", 2)
add("data/scripts/systems/xtradingoverview.lua", 1)
add("data/scripts/systems/xvaluablesdetector.lua", 1)
add("data/scripts/systems/xrefine.lua", 0.5)



function UpgradeGenerator:selectScript(x, y)

    -- we must sort the script selection first since a table with strings as keys is not deterministically sorted
    local all = {}
    local x = x or 0
    local y = y or 0
    local sectorDist2ToCenter = x * x + y * y

    for script, parameters in pairs(self.scripts) do
        local dist2ToCenter = 0
        dist2ToCenter = parameters.dist2ToCenter
        -- remove all scripts for subsystems that can not drop in this distance from center
        if not parameters.dist2ToCenter or sectorDist2ToCenter <= parameters.dist2ToCenter then
            table.insert(all, {script = script, weight = parameters.weight})
        end
    end

    table.sort(all, function(a, b) return a.script < b.script end)

    local weights = {}
    for _, p in pairs(all) do
        table.insert(weights, p.weight)
    end

    local index = getValueFromDistribution(weights, self.random)
    if all[index] == nil then return nil end
    local script = all[index].script

    return script
end