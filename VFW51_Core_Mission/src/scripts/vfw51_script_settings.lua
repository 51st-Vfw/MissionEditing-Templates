-- **********************************************************************************************
--
-- vfw51_script_settings.lua: script resource set up for mission
--
-- the ScriptSettings table has two keys/value pairs:
--
--     "framework" : <array>    array of framework script filenames
--     "mission" : <array>      array of mission script filenames
--
-- filenames in the arrays are relative to src/scripts and should identify .lua files that
-- provide scripting. the scripts are loaded in the order in which they appear in the array
-- with all scripts in "framework" loaded first.
--
-- **********************************************************************************************

ScriptSettings = {
    ["framework"] = {
        [1] = "Moose_.lua",
        [2] = "mist_4_5_107.lua",
        [3] = "skynet-iads-compiled.lua",
        [4] = "51stMapSOP.lua"
    },
    ["mission"] = {
        [1] = "mission_globals.lua",
    }
}