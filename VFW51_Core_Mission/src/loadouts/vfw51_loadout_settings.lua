-- ************************************************************************************************************
--
-- vfw51_loadout_settings.lua: loadout set up for mission
--
-- the LoadoutSettings table holds key/value where the key is a group name pattern and the value is a Lua
-- file name, relative to src/loadouts in the mission directory, that specifies the loadouts to use for
-- each unit in the group. a group matches a group pattern if the name includes the text in the pattern.
--
-- the loadout file is a Lua file that defines a single table "LoadoutData" that contains the key/value
-- pairs from the "payload" table in a helicopter or plane group from the .miz mission file for the desired
-- loadout setup.
--
-- the loadout CLSID "INV-SMOKE-COALITION" will be replaced by smoke the color of the coalition.
--
-- note that group names are unique across coalitions.
--
-- ************************************************************************************************************

LoadoutSettings = {
--[[
    ["Group"] = "group_loadout.lua"
]]
}
