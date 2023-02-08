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
--   <moment_name> : <string>   Define <moment_name> as the time from <string>. The time is formatted as
--                              "<[H]H>:<MM>" (e.g., "16:30") using a 24-hour clock. the <moment_name>
--                              "base" is reserved.
--
-- the key/value pairs in the "variants" table define each of the variants that the build will construct.
-- each variant specifies a change to the time, weather, and options in the base mission.
--
--   <variant_name> : <table>   Associates <variant_name> with the changes to the base mission <table>
--                              describes. the <variant_name> "base" is reserved.
--
-- key/value pairs in the <variant_name> table include,
--
--   "moment" : <string>        Sets the time in the variant according to the moment named by <string>. if
--                              this key/value pair is not defined or the moment name is "base", the variant
--                              uses the time from the base mission.
--   "wx" : <string>            Sets the weather in the variant according to the weather file named by
--                              <string>. This file should be located in src/variants. if this key/value
--                              pair is not defined or the weather file is "base", the variant uses the 
--                              weather from the base mission.
--   "options" : <string>       Sets the mission options in the variant according to the file named by
--                              <string>. This file should be located in src/variants. if this key/value
--                              pair is not defined or the options file is "base", the variant uses the 
--                              options from the base mission.
--   "redact" : <table>         Removes all triggers and scripting along with selected objects (trigger zones,
--                              helicopters, planes, ships, statics, and vehicles) whose names match a
--                              pattern.
--
-- the weather file is a Lua file that defines a single table "WxData" that contains the key/value pairs from
-- the "weather" table in the mission file for the desired weather setup.
--
-- the options file is a Lua file that defines a single table "OptionsData" that contains the key/value pairs
-- from the "forcedOptions" table in the mission file for the desired options setup.
--
-- key/value pairs in the "redact" table include,
--
--   "objects" : <array>        Array of patterns to determine if a given group (helicopters, planes, ships,
--                              statics, or vehicles) should be redacted from the mission.
--   "zones" : <array>          Array of patterns to determine if a given trigger zone should be redacted from
--                              the mission.
--   "uncertain" : <table>      Replaces groups with a circular zone of a given radius. The zone is randomly
--                              offset from the group location so the group is somewhere within the zone.
--                              <table> is keyed by a <string> that holds the name of a group with a value
--                              <integer> that specifies the radius of the uncertainity region in nautical
--                              miles.
--   "drawings" : <names>       Redacts drawings on any layer (Red, Blue, Neutral, Common, or Author) that
--                              appears in the comma-separated list <names>. <names> is case-insensitive.
--
-- patterns in the "objects" and "zones" arrays are formatted as follows: "[type]<pattern>". where [type] is
-- an optional pattern type:
--
--   "+"                        Whitelist pattern: items matching the pattern are not redacted
--   "-"                        Blacklist pattern: items matching the pattern are redacted
--
-- and <pattern> is the non-regex pattern to look for in the item name. the special <pattern> "*" is treated
-- as matching any name. Note that [type] is not optional if the <pattern> itself begins with either "+" or
-- "-". a <pattern> matches a name if the name contains the pattern string (case is ignored).
--
-- patterns in the array are checked in order, stopping when the first matching pattern is found. typically,
-- "-*" and "+*" are used as the last pattern to supress or force a match.
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
        ["redacted"] = {
            ["redact"] = {
                ["objects"] = {
                    [1] = "+[rm]",
                    [2] = "-ground",
                },
                ["zones"] = {
                    [1] = "--p2"
                },
                ["uncertain"] = {
                    ["Roosevelt Carrier Group"] = 10
                },
                ["drawings"] = "red,blue,neutral,common,author"
            }
        },
        ["dawn"] = {
            ["wx"] = "base",
            ["moment"] = "morning",
            ["options"] = "opt_sop.lua"
        },
        ["night-ovc"] = {
            ["wx"] = "wx_overcast_rain_1.lua",
            ["moment"] = "night"
        },
]]
  }
}