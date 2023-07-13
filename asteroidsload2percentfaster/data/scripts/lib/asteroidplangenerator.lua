
-- optimised asteroid plan generator
-- v2: additional constant folding

--[[
generating an asteroid field looks like this:

* 60 millisecs AsteroidFieldGenerator:generateOrganicCloud
* 400 millisecs setting up each asteroid, where 99% of the time is spent in
   createSmallAsteroid..
   
Of that 400 millisecs section, which accounts for about 85% of the total time,
each asteroid created takes the following steps:

-- A: AsteroidPlanGenerator:makeSmallAsteroidPlan
-- B: set its position and rotation
-- C: set the descriptor and move plan
-- D: if not resources then desc:removeComponent(ComponentType.MineableMaterial)
-- E: set title
-- F: sector:createEntity(desc)

The times for a single asteroid look like (typical):

-- A took 0.129500 ms
-- B took 0.006100 ms
-- C took 0.086900 ms
-- D took 0.004200 ms
-- E took 0.000200 ms
-- F took 1.277100 ms

Sadly, F is the biggest part, and its a builtin function which cannot be
optimised further by a mod.

Our changes change this reading to (typical):

A took 0.095400 ms <-- we've improved this by about 30%

Sadly, that's only saving about 0.03 millisecs per 1.5 millisecs, so we have
hardly saved anything - about 1.7% of the total asteroid field generation
time.

But it was a lot of work experimenting with different things, so I hope you
enjoy the nearly 2% faster asteroids!!!

Other optimisations I tried:
----------------------------
* Replacing random() calls with a fast random number based on the golden ratio:

    function fastrandom(n)
        local golden = 0x9E3779B1
        return (n * golden) % 0xFFFFFFFF
    end
    -- for 0..1, divide by 0xFFFFFFFF

This had no observable effect (I might revisit this later now that I've
identified the critical sections) or, if anything, made it slower.
--]]

-- cache frequently used values
local m_ = Matrix()
local v000 = vec3( 0,  0,  0)
local vM00 = vec3(-1,  0,  0)
local vP00 = vec3( 1,  0,  0)
local v0P0 = vec3( 0,  1,  0)
local v0M0 = vec3( 0, -1,  0)
local v00P = vec3( 0,  0,  1)
local v00M = vec3( 0,  0, -1)
local vPPP = vec3( 1,  1,  1)
local m_vM00_v0P0 = MatrixLookUp(vM00, v0P0)
local m_vP00_v0P0 = MatrixLookUp(vP00, v0P0)
local m_vM00_v0M0 = MatrixLookUp(vM00, v0M0)
local m_v00M_v0M0 = MatrixLookUp(v00M, v0M0)
local m_v00P_v0M0 = MatrixLookUp(v00P, v0M0)
local m_vM00_v00P = MatrixLookUp(vM00, v00P)
local m_vP00_v00M = MatrixLookUp(vP00, v00M)
local m_vP00_v0M0 = MatrixLookUp(vP00, v0M0)
local m_v00M_v0P0 = MatrixLookUp(v00M, v0P0)
local m_v00P_v0P0 = MatrixLookUp(v00P, v0P0)
local m_vM00_v00M = MatrixLookUp(vM00, v00M)
local m_vP00_v00P = MatrixLookUp(vP00, v00P)

function AsteroidPlanGenerator:makeDefaultAsteroidPlan(size, material, flags)

    material = material or Material(0)
    flags = flags or {}

    local plan = BlockPlan()
    
    local planAddBlock = plan.addBlock -- lua optimisation
    local vec3 = vec3 -- lua optimisation

    local color = material.blockColor

    local from = flags.from or 0.1
    local to = flags.to or 0.5

    local center = flags.center or self.Stone
    local border = flags.border or self.Stone
    local edge = flags.edge or self.StoneEdge
    local corner = flags.corner or self.StoneCorner

    local ls = vec3(getFloat(from, to), getFloat(from, to), getFloat(from, to))
    local us = vec3(getFloat(from, to), getFloat(from, to), getFloat(from, to))
    local s = vPPP - ls - us

    local hls = ls * 0.5
    local hus = us * 0.5
    local hs = s * 0.5
    
    local ci = planAddBlock(plan, v000, s, -1, -1, color, material, m_, center)

    local p_hsy_p_husy =  hs.y + hus.y
    local m_hsy_m_hlsy = -hs.y - hls.y
    local p_hsx_p_husx =  hs.x + hus.x
    local m_hsx_m_hlsx = -hs.x - hls.x
    local p_hsz_p_husz =  hs.z + hus.z
    local m_hsz_m_hlsz = -hs.z - hls.z
    
    -- top bottom
    planAddBlock(plan, vec3(0, p_hsy_p_husy, 0), vec3(s.x, us.y, s.z), ci, -1, color, material, m_, border)
    planAddBlock(plan, vec3(0, m_hsy_m_hlsy, 0), vec3(s.x, ls.y, s.z), ci, -1, color, material, m_, border)

    -- left right
    planAddBlock(plan, vec3(p_hsx_p_husx, 0, 0), vec3(us.x, s.y, s.z), ci, -1, color, material, m_, border)
    planAddBlock(plan, vec3(m_hsx_m_hlsx, 0, 0), vec3(ls.x, s.y, s.z), ci, -1, color, material, m_, border)

    -- front back
    planAddBlock(plan, vec3(0, 0, p_hsz_p_husz), vec3(s.x, s.y, us.z), ci, -1, color, material, m_, border)
    planAddBlock(plan, vec3(0, 0, m_hsz_m_hlsz), vec3(s.x, s.y, ls.z), ci, -1, color, material, m_, border)
    
    -- top left right
    planAddBlock(plan, vec3(p_hsx_p_husx, p_hsy_p_husy, 0), vec3(us.x, us.y, s.z), ci, -1, color, material, m_vM00_v0P0, edge)
    planAddBlock(plan, vec3(m_hsx_m_hlsx, p_hsy_p_husy, 0), vec3(ls.x, us.y, s.z), ci, -1, color, material, m_vP00_v0P0, edge)

    -- top front back
    planAddBlock(plan, vec3(0, p_hsy_p_husy, p_hsz_p_husz), vec3(s.x, us.y, us.z), ci, -1, color, material, m_v00M_v0P0, edge)
    planAddBlock(plan, vec3(0, p_hsy_p_husy, m_hsz_m_hlsz), vec3(s.x, us.y, ls.z), ci, -1, color, material, m_v00P_v0P0, edge)

    -- bottom left right
    planAddBlock(plan, vec3(p_hsx_p_husx, m_hsy_m_hlsy, 0), vec3(us.x, ls.y, s.z), ci, -1, color, material, m_vM00_v0M0, edge)
    planAddBlock(plan, vec3(m_hsx_m_hlsx, m_hsy_m_hlsy, 0), vec3(ls.x, ls.y, s.z), ci, -1, color, material, m_vP00_v0M0, edge)

    -- bottom front back
    planAddBlock(plan, vec3(0, m_hsy_m_hlsy, p_hsz_p_husz), vec3(s.x, ls.y, us.z), ci, -1, color, material, m_v00M_v0M0, edge)
    planAddBlock(plan, vec3(0, m_hsy_m_hlsy, m_hsz_m_hlsz), vec3(s.x, ls.y, ls.z), ci, -1, color, material, m_v00P_v0M0, edge)

    -- middle left right
    planAddBlock(plan, vec3(p_hsx_p_husx, 0, m_hsz_m_hlsz), vec3(us.x, s.y, ls.z), ci, -1, color, material, m_vM00_v00M, edge)
    planAddBlock(plan, vec3(m_hsx_m_hlsx, 0, m_hsz_m_hlsz), vec3(ls.x, s.y, ls.z), ci, -1, color, material, m_vP00_v00M, edge)

    -- middle front back
    planAddBlock(plan, vec3(p_hsx_p_husx, 0, p_hsz_p_husz), vec3(us.x, s.y, us.z), ci, -1, color, material, m_vM00_v00P, edge)
    planAddBlock(plan, vec3(m_hsx_m_hlsx, 0, p_hsz_p_husz), vec3(ls.x, s.y, us.z), ci, -1, color, material, m_vP00_v00P, edge)

    -- top edges
    -- left right
    planAddBlock(plan, vec3(p_hsx_p_husx, p_hsy_p_husy, m_hsz_m_hlsz), vec3(us.x, us.y, ls.z), ci, -1, color, material, m_vM00_v0P0, corner)
    planAddBlock(plan, vec3(m_hsx_m_hlsx, p_hsy_p_husy, m_hsz_m_hlsz), vec3(ls.x, us.y, ls.z), ci, -1, color, material, m_vP00_v00M, corner)

    -- front back
    planAddBlock(plan, vec3(p_hsx_p_husx, p_hsy_p_husy, p_hsz_p_husz), vec3(us.x, us.y, us.z), ci, -1, color, material, m_vM00_v00P, corner)
    planAddBlock(plan, vec3(m_hsx_m_hlsx, p_hsy_p_husy, p_hsz_p_husz), vec3(ls.x, us.y, us.z), ci, -1, color, material, m_vP00_v0P0, corner)

    -- bottom edges
    -- left right
    planAddBlock(plan, vec3(p_hsx_p_husx, m_hsy_m_hlsy, -hs.z - hls.z), vec3(us.x, ls.y, ls.z), ci, -1, color, material, m_v00P_v0M0, corner)
    planAddBlock(plan, vec3(m_hsx_m_hlsx, m_hsy_m_hlsy, -hs.z - hls.z), vec3(ls.x, ls.y, ls.z), ci, -1, color, material, m_vP00_v0M0, corner)

    -- front back
    planAddBlock(plan, vec3(p_hsx_p_husx, m_hsy_m_hlsy, p_hsz_p_husz), vec3(us.x, ls.y, us.z), ci, -1, color, material, m_vM00_v0M0, corner)
    planAddBlock(plan, vec3(m_hsx_m_hlsx, m_hsy_m_hlsy, p_hsz_p_husz), vec3(ls.x, ls.y, us.z), ci, -1, color, material, m_v00M_v0M0, corner)

    local scaleFromX = flags.scaleFromX or 0.3
    local scaleFromY = flags.scaleFromY or 0.3
    local scaleFromZ = flags.scaleFromZ or 0.3

    local scaleToX = flags.scaleToX or 1.5
    local scaleToY = flags.scaleToY or 1.5
    local scaleToZ = flags.scaleToZ or 1.5

    plan:scale(vec3(getFloat(scaleFromX, scaleToX), getFloat(scaleFromY, scaleToY), getFloat(scaleFromZ, scaleToZ)))

    local r = size * 2.0 / plan.radius
    plan:scale(vec3(r, r, r))

    plan.convex = true

    return plan
end