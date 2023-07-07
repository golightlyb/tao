package.path = package.path .. ";data/scripts/lib/?.lua"
include ("galaxy")
include ("utility")
include ("faction")
include ("randomext")
Dialog = include("dialogutility")

-- namespace DefensePlatform
DefensePlatform = {}

-- if this function returns true the button for the script in the interaction window will be clickable.
-- If this function returns false, it can return an error message as well, which will explain why the interaction doesn't work.
function DefensePlatform.interactionPossible(playerIndex, option)
    return false
end

-- This function will be called when the entity is saved into the database.
-- The server will not save the entire script and all its values.
-- Instead it will call this function to gather all values from the script that have to be saved.
-- if you have any important values that need saving, put them into a table and return them here and the database will save them.
-- When the entity is loaded from the database, the restore() function will be called
-- with all the values that were returned by this function before.
-- function secure()
    -- return {s = "string", a = 15, b = 32, pi = 3.14159}
-- end

-- if previously there was a table returned by secure(), this function will be called when the entity is
-- restored from the database and the table returned by secure() will be given as parameter here.
-- This function is called AFTER the initialize() function.
-- function restore(data)
    -- local s = data.s
    -- local a = data.a
    -- etc.
-- end

-- this is just an example usage of how to restore an unknown number of values
--function restore(...)
--    local values = {...}
--
--    -- values is now an array containing all values that were given to us by the game.
--
--end

-- this function gets called on creation of the entity the script is attached to, on client and server
function DefensePlatform.initialize()
    local station = Entity()

    -- It is common use to have the first script that is added to a station and that sets a name to set the title of the station.
    -- In order for this to work, each script that gives a title has to check if there is not yet a title
    if station.title == "" then
        station.title = "Defense Platform"
    end
    
    if onClient() and EntityIcon().icon == "" then
        EntityIcon().icon = "data/textures/icons/pixel/guard.png"
    end
end

-- this function gets called on creation of the entity the script is attached to, on client only
-- AFTER initialize above
-- create all required UI elements for the client side
-- function initUI()
-- end

-- this functions gets called when the indicator of the station is rendered on the client
-- if you want to do any rendering calls by yourself, then this is the place to do it. Just remember that this
-- may take up a lot of performance and might slow the game down, so don't overuse it.
-- function renderUIIndicator(px, py, size)
-- end

-- this function gets called every time the window is shown on the client, ie. when a player presses F to interact and then clicked the button for our script
-- function onShowWindow()
-- end

-- this function gets called every time the window is closed on the client
-- function onCloseWindow()
-- end

-- this function gets called each tick, on client and server
-- function update(timeStep)
-- end

-- this function gets called each tick, on client only
-- function updateClient(timeStep)
-- end

-- this function gets called each tick, on server only
-- function updateServer(timeStep)
-- end

-- this function gets called whenever the ui window gets rendered, AFTER the window was rendered (client only)
-- if you want to do any rendering calls by yourself, then this is the place to do it. Just remember that this
-- may take up a lot of performance and might slow the game down, so don't overuse it.
-- function renderUI()
-- end





