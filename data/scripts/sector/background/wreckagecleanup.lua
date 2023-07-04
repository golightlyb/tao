
maxWreckages = 35 -- 25 for scrapyard, plus 10 for extras
local reallyMaxWreckages = 50 -- never go above this even for wreckages not on a timer

function WreckageCleanUp.updateServer()

    local wreckages = {}
    local numWreckages = 0

    -- first cull, using time left
    for _, wreckage in pairs({Sector():getEntitiesByType(EntityType.Wreckage)}) do
        local timer = DeletionTimer(wreckage)

        if valid(timer) and timer.enabled then
            table.insert(wreckages, {wreckage = wreckage, timeLeft = timer.timeLeft})
            numWreckages = numWreckages + 1
        end
    end

    if numWreckages > maxWreckages then
        table.sort(wreckages, function(a, b) return a.timeLeft < b.timeLeft end)

        local sector = Sector()
        local toRemove = numWreckages - maxWreckages
        for i = 1, toRemove do
            sector:deleteEntity(wreckages[i].wreckage)
        end
    end
    
    
    local wreckages = {}
    local numWreckages = 0
    
    -- second cull, using smallest volume
    ws = Sector():getEntitiesByType(EntityType.Wreckage
    if #ws > reallyMaxWreckages then
        table.sort(ws, function(a, b) return a.volume < b.volume end)
        local sector = Sector()
        local toRemove = #ws - reallyMaxWreckages
        for i = 1, toRemove do
            sector:deleteEntity(ws[i])
        end
    end
end
