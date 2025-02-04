-- ************************************************************************************************************
--
-- vfw51_waypoint_settings.lua: waypoint set up for mission
--
-- the WaypointSettings table holds key/value where the key is a group name pattern and the value is a Lua
-- file name, relative to src/waypoints in the mission directory, that specifies the route points to use for
-- the group. a group matches a group pattern if the name includes the text in the pattern. only the first
-- match is applied.
--
-- the waypoints file is a Lua file that defines a single table "RouteData" that contains the key/value
-- pairs from the "points" table in a helicopter or plane group from the .miz mission file for the desired
-- waypoint setup.
--
-- note that group names are unique across coalitions.
--
-- ************************************************************************************************************

WaypointSettings = {
--[[
    ["Group"] = "group_wpts.lua"
]]
}