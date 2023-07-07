

maxWreckages = 100 -- original 150 (but didn't get called at all!!!)

-- rather than only delete wreckages back to the limit, and repeatedly have
-- to search for candidates as new wreckages take us just over this limit,
-- instead we cull back a bit futher so we don't have to do this for a
-- while.
local cullTo = 50

function WreckageCleanUp.getUpdateInterval()
    -- run more frequently
    return 5 -- original 15
end

-- score deletion candidates:
--   - less time left = prefer to delete
--   - smaller = prefer to delete
local function lessThan(a, b)
    local scoreA = a.timeLeft * a.wreckage.volume
    local scoreB = b.timeLeft * b.wreckage.volume
    return scoreA < scoreB
end

function WreckageCleanUp.updateServer()
    local sector = Sector()
    local existing = {sector:getEntitiesByType(EntityType.Wreckage)}
    if not existing then return end
 
    local numWreckages = 0
    for _, w in pairs(existing) do
        numWreckages = numWreckages + 1
    end
    
    --print("WreckageCleanUp: there are "..numWreckages.." wreckages.")
 
    --print("WreckageCleanUp: (start) numWreckages is "..numWreckages.." and maxWreckages is "..maxWreckages)
    
    if numWreckages < maxWreckages then
        -- optimisation: exit early
        return
    end
    
    -- collect candidates for deletion
    local candidates = {}
    for _, w in pairs(existing) do
        local timer = DeletionTimer(w)

        if valid(timer) and timer.enabled then
            -- TODO could optimise with a fixed size table?
            -- Don't know how Lua represents stuff internally.
            table.insert(candidates, {wreckage=w, timeLeft = timer.timeLeft})
        end
    end
    
    local toRemove = #candidates - cullTo
    
    --print("WreckageCleanup: "..#candidates.." candidates for deletion, and "..toRemove.." to delete")
    if toRemove == 0 then return end
    
    table.sort(candidates, lessThan)
    
    for i = 1, toRemove do
        sector:deleteEntity(candidates[i].wreckage)
    end
    
    print("WreckageCleanup: removed "..toRemove.." wreckages ("..#candidates.." candidates, "..numWreckages.." total wreckages, and "..maxWreckages.." wreckage limit)")
end


