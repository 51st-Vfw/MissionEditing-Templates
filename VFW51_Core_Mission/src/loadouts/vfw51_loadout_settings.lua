-- ************************************************************************************************************
--
-- vfw51_loadout_settings.lua: loadout set up for mission
--
-- the LoadoutSettings table is keyed by a group pattern and has values of arrays of tables. a given group
-- matches the group pattern if the group name includes text in the pattern.
--
-- each table in the array that provides the value may have the following keys,
--
--   group_num      value of variable InjectGroupNum when evaluating loadout file (optional, default 1)
--   per_unit       true => evaluate loadout file per unit, false => per group (optional, default false)
--   filename       name of loadout file to evaluate, relative to src/loadouts in the mission directory
--
-- prior to evaluating the Lua file given by filename, the following variables will be set up:
--
--   InjectGroupNum     set to the value in group_num (default 1 if group_num is not given)
--   InjectUnitNum      set to the unit number if per_unit is true (default 1 if per_unit is false or nil)
--
-- the loadout file is a Lua file that defines a table that specifies changes to the units in the group
-- matching the group pattern. this file may define,
--
--   LoadoutData        defines loadout information to be injected in the "payload" key
--   PropertyData       defines parameter information to be injected in the "AddPropAircraft" key
--
-- these definitions may use InjectGroupNum and InjectUnitNum as needed. in addition, in LoadoutSettings
-- the loadout CLSID "INV-SMOKE-COALITION" will be replaced by a smoke pod in the color of the unit's
-- coalition.
--
-- note that group names are unique across coalitions.
--
-- ************************************************************************************************************

LoadoutSettings = {
--[[
    ["Group"] = {
        [1] = {
            ["group_num"] = 1,
            ["per_unit"] = false,
            ["file"]  = "group_loadout.lua"
        },
    }
]]
}
