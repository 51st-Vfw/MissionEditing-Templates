-- **********************************************************************************************
--
-- vfw51_briefing_settings.lua: briefing panel set up for mission
--
-- the BriefingSettings table has three key/value pairs,
--
--     "blue" : <array>         array of blue coalition briefing image filenames
--     "red" : <array>          array of red coalition briefing image filenames
--     "neuutral" : <array>     array of neutral coalition briefing image filenames
--
-- filenames in the arrays are relative to src/briefing and should identify .png or .jpg files
-- that provide images for the briefing panel in the DCS UI. the images are presented in the
-- UI in the order in which they appear in the arrays.
--
-- **********************************************************************************************

BriefingSettings = {
    ["blue"] = {
        [1] = "51st_VFW_Logo.png"
    },
    ["red"] = {
    },
    ["neutral"] = {
    }
}