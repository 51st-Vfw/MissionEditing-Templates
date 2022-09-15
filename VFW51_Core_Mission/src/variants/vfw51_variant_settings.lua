-- ************************************************************************************************************
--
-- vfw51_variant_settings.lua: mission variant set up for mission
--
-- the VariantSettings table holds two key/value pairs,
--
--   "moments" : <table>        Defines the "moments" (times) that the variants may use
--   "variants" : <table>       Defines the target variants to create
--
-- the key/value pairs in the "moments" table associate a moment name with a time,
--
--   <moment_name> : <string>   Define <moment_name> as the time from <string>. The time is formatted
--                              as "<[H]H>:<MM>" (e.g., "16:30") using a 24-hour clock. the <moment_name>
--                              "base" is reserved.
--
-- the key/value pairs in the "variants" table define each of the variants that the build will construct.
-- each variant specifies a change to the time, weather, and options in the base mission.
--
--   <variant_name> : <table>   Associates <variant_name> with the changes outlined in <table>. the
--                              <variant_name> "base" is reserved.
--
-- key/value pairs in the <variant_name> table include,
--
--   "moment" : <string>        Sets the time in the variant according to the moment named by <string>.
--                              a moment name of "base" or nil indicates no changes to the time in the base
--                              mission.
--   "wx" : <string>            Sets the weather in the variant according to the weather file named
--                              by <string>. This file should be located in src/variants. a wx file of
--                              "base" or nil indicates no changes to the weather in the base mission.
--   "options" : <string>       Sets the mission options in the variant according to the file named by
--                              <string>. This file should be located in src/variants. an options of "base"
--                              or nil indicates no changes to the options in the base mission.
--
-- the weather file is a Lua file that defines a single table "WxData" that contains the key/value pairs from
-- the "weather" table in the mission file for the desired weather setup.
--
-- the options file is a Lua file that defines a single table "OptionsData" that contains the key/value
-- pairs from the "options" table in the mission file for the desired options setup.
--
-- the extract script may be used to extract options and weather in the proper format using the --wx and --opt
-- arguments.
--
-- ************************************************************************************************************

VariantSettings = {
    ["moments"] = {
        ["morning"] = "09:00",
        ["afternoon"] = "13:00",
        ["night"] = "22:00"
    },
    ["variants"] = {
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