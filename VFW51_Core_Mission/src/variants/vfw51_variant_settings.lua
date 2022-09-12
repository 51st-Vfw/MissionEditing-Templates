-- ************************************************************************************************************
--
-- vfw51_config_variants.lua: mission variant set up for mission
--
-- the VariantSettings table holds two key/value pairs,
--
--   "moments" : <table>        Defines the "moments" (times) that the variants may use
--   "targets" : <table>        Defines the target variant to emit
--
-- the key/value pairs in the moments table associate a moment name with a time,
--
--   <moment_name> : <string>   Define <moment_name> as the time from <string>. The time is formatted
--                              as "<[H]H>:<MM>" (e.g., "16:30") using a 24-hour clock. the <moment_name>
--                              "base" is reserved.
--
-- the key/value pairs in the targets table define each of the variants that the variantinator tool will
-- construct. each target specifies a change to the time and weather in the base mission.
--
--   <target_name> : <table>    Associates <target_name> with the changes outlined in <table>. the
--                              <target_name> "base" is reserved.
--
-- key/value pairs in the <target_name> table include,
--
--   "moment" : <string>        Sets the time in the variant according to the moment named by <string>.
--                              a moment name of "base" or nil indicates the time from the base mission.
--   "wx" : <string>            Sets the weather in the variant according to the weather file named
--                              by <string>. This file should be located in src/variants. a wx file of
--                              "base" or nil indicates the weather from the base mission.
--   "options" : <string>       Sets the mission options in the variant according to the file named by
--                              <string>. This file should be located in src/variants. an options of "base"
--                              or nil indicates the options from the base mission.
--
-- the weather file is a Lua file that defines a single table "WxData" that contains the key/value pairs from
-- the "weather" table in the mission file for the desired weather setup.
--
-- ************************************************************************************************************

VariantSettings = {
    ["moments"] = {
        ["morning"] = "09:00",
        ["afternoon"] = "13:00",
        ["night"] = "22:00"
    },
    ["targets"] = {
--[[
        ["dawn"] = {
            ["wx"] = "base",
            ["moment"] = "morning",
            ["options"] = "opt_base_sop.lua"
        },
        ["night-ovc"] = {
            ["wx"] = "wx_overcast_rain_1.lua",
            ["moment"] = "night"
        },
]]
  }
}