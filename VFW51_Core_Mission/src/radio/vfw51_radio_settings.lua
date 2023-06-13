
-- ************************************************************************************************************
--
-- vfw51_radio_settings.lua: radio set up for mission
--
-- The RadioDefaults table defines how to set the default frequency for the primary radio on startup. This
-- table is an array where each element of the array is a table with the following key/value pairs:
--
--     "c" : <string>       coalition to match, "*" matches any coalition
--     "p" : <string>       airframe/name/callsign pattern to match (see below)
--     "f" : <number>       default frequency (MHz)
--     "d" : <string>       default modulation (0 AM, 1 FM)
-- 
-- The RadioPresets[Warbird]<Blue|Red> tables define how to set the frequency for a preset on one of the
-- three radios for a warbird or non-warbird unit in blue or read coalitions. the assigned frequency value
-- may depend on the airframe, unit name, and callsign of the aircraft being set up. the tables contain the
-- following key/value pairs:
--
--     <string> : <array>|<number>      assigns the frequency for the radio/preset combo identified by
--                                      <string> according to a <array> or <number>.
--
-- the key (a string) identifies the specific radio (1 is UHF, 2 is VHF AM, and 3 is VHF FM) and preset
-- button (1-20) that the value applies to. the value may be an array or a number.
--
-- a number value specifies a fixed preset frequency (in MHz) to use, with zero indicating the default
-- frequency appropriate for the radio.
--
-- an array value specifies a variable preset frequency (in MHz) that depends on unit properties
-- (specifically, airframe, unit name, and unit callsign) with an table indicating the default frequency
-- appropriate for the radio.
--
-- each element of the array is a table with the following key/value pairs,
--
--     "p" : <string>       airframe/name/callsign pattern to match
--     "f" : <number>       preset frequency (MHz), 0 for default freqency appropriate for the radio
--     "d" : <string>       descriptive string
--     "s": <string>        short descriptive string, for the A-10C II's ARC-210 COMM page
--                          13 characters maximum, only applicable on radio 1
--
-- the "p" string is of the form "<a>:<n>:<c>" (e.g., "F-16C_50:*:Uzi"), where
--
--     <a>      unit airframe name (may not contain ":"), "*" matches any airframe
--     <n>      unit name pattern (may not contain ":"), "*" matches any name
--     <c>      unit callsign pattern (may not contain ":"), "*" matches any callsign
--
-- each element in the array is tested against the "p" pattern in the array the frequency and description
-- for the preset is given by the last element that specifies "f" or "d" and where the unit matches "p".
--
-- the RadioSettings table provides templates to inject into the main mission table for a unit in order to
-- configure its presets.
--
-- ************************************************************************************************************

RadioDefaults = {
    [1] = { ["c"] = "*", ["p"] = "*:*:*", ["f"] = 270.00, ["m"] = 0 }
}

-- NOTE: the tables are set up to align with 51st VFW comms SOPs and should need minimal edits for use in
-- NOTE: a mission that follows SOPs. The primary changes may be around the carrier setups for F-14 and
-- NOTE: FA-18C airframes and the depature ATIS/tower for all airframes. generally, only the RadioPresets
-- NOTE: tables require changes if the mission follows the SOP comms ladders.

RadioPresetsBlue = {

    -----------------------------------------------------------------------------------------------------------
    -- RadioPresetsBlue / Radio 1 : Left, Red, or UHF Radio (225MHz to 390MHz)
    -----------------------------------------------------------------------------------------------------------

    ["$RADIO_1_01"] = {
        [1] = { ["p"] = "*:*:*",             ["f"] = 270.00,                        ["d"] = "Tac Common" },
    },
    ["$RADIO_1_02"] = {
        [1] = { ["p"] = "*:*:*",             ["f"] = 275.00,                        ["d"] = "Strike Common" }
    },
    ["$RADIO_1_03"] = {
        [1] = { ["p"] = "*:*:*",             ["f"] =   0.00, ["s"] = "Dept ATIS",   ["d"] = "Departure ATIS (UHF)" }
    },
    ["$RADIO_1_04"] = {
        [1] = { ["p"] = "*:*:*",             ["f"] =   0.00, ["s"] = "Dept Tower",  ["d"] = "Departure Tower (UHF)" }
    },
    ["$RADIO_1_05"] = {
        [1] = { ["p"] = "*:*:*",             ["f"] = 240.00, ["s"] = "AI AWACS",    ["d"] = "AWACS Overlord 1-1 (AI)" }
     },
    ["$RADIO_1_06"] = {
        [1] = { ["p"] = "*:*:*",             ["f"] =   0.00,                        ["d"] = "AAR #1" },
        [2] = { ["p"] = "A-10C_2:*:*",       ["f"] = 251.00, ["s"] = "Texaco 1-1",  ["d"] = "AAR Texaco 1-1 (51Y)" },
        [3] = { ["p"] = "F-16C_50:*:*",      ["f"] = 251.00,                        ["d"] = "AAR Texaco 1-1 (51Y)" },
        [4] = { ["p"] = "F-14B:*:*",         ["f"] = 253.00,                        ["d"] = "AAR Arco 1-1 (53Y)" },
        [5] = { ["p"] = "FA-18C_hornet:*:*", ["f"] = 253.00,                        ["d"] = "AAR Arco 1-1 (53Y)" }
    },
    ["$RADIO_1_07"] = {
        [1] = { ["p"] = "*:*:*",             ["f"] =   0.00,                        ["d"] = "AAR #2" },
        [2] = { ["p"] = "A-10C_2:*:*",       ["f"] = 252.00, ["s"] = "Texaco 2-1",  ["d"] = "AAR Texaco 2-1 (52Y)" },
        [3] = { ["p"] = "F-16C_50:*:*",      ["f"] = 252.00,                        ["d"] = "AAR Texaco 2-1 (52Y)" },
        [4] = { ["p"] = "F-14B:*:*",         ["f"] = 254.00,                        ["d"] = "AAR Arco 2-1 (54Y)" },
        [5] = { ["p"] = "FA-18C_hornet:*:*", ["f"] = 254.00,                        ["d"] = "AAR Arco 2-1 (54Y)" }
    },
    ["$RADIO_1_08"] = {
        [1] = { ["p"] = "*:*:*",             ["f"] = 238.00, ["s"] = "AI JTAC",     ["d"] = "JTAC/AFAC Darknight 1-1 (UHF, AI)" }
    },
    ["$RADIO_1_09"] = {
        [1] = { ["p"] = "*:*:*",             ["f"] = 238.10, ["s"] = "HUMAN JTAC",  ["d"] = "JTAC/AFAC (UHF, Human)" },
     },
    ["$RADIO_1_10"] = {
        [1] = { ["p"] = "F-14B:*:*",         ["f"] = 271.40,                        ["d"] = "CVN-71 ATC" },
        [2] = { ["p"] = "FA-18C_hornet:*:*", ["f"] = 271.40,                        ["d"] = "CVN-71 ATC" }
    },                      
    ["$RADIO_1_11"] = {                     
        [1] = { ["p"] = "F-14B:*:*",         ["f"] = 271.60,                        ["d"] = "CVN-71 AWACS Magic 1-1" },
        [2] = { ["p"] = "FA-18C_hornet:*:*", ["f"] = 271.60,                        ["d"] = "CVN-71 AWACS Magic 1-1" }
    },                      
    ["$RADIO_1_12"] = {                     
        [1] = { ["p"] = "F-14B:*:*",         ["f"] = 271.80,                        ["d"] = "CVN-71 Tanker Shell 1-1 (121Y)" },
        [2] = { ["p"] = "FA-18C_hornet:*:*", ["f"] = 271.80,                        ["d"] = "CVN-71 Tanker Shell 1-1 (121Y)" }
    },                      
    ["$RADIO_1_13"] = { },                      
    ["$RADIO_1_14"] = { },                      
    ["$RADIO_1_15"] = {
        [1] = { ["p"] = "F-14B:*:*",         ["f"] = 275.40,                        ["d"] = "CVN-75 ATC" },
        [2] = { ["p"] = "FA-18C_hornet:*:*", ["f"] = 275.40,                        ["d"] = "CVN-75 ATC" }
    },                      
    ["$RADIO_1_16"] = {                     
        [1] = { ["p"] = "F-14B:*:*",         ["f"] = 275.60,                        ["d"] = "CVN-75 AWACS Magic 5-1" },
        [2] = { ["p"] = "FA-18C_hornet:*:*", ["f"] = 275.60,                        ["d"] = "CVN-75 AWACS Magic 5-1" }
    },                      
    ["$RADIO_1_17"] = {
        [1] = { ["p"] = "F-14B:*:*",         ["f"] = 275.80,                        ["d"] = "CVN-75 Tanker Shell 5-1 (125Y)" },
        [2] = { ["p"] = "FA-18C_hornet:*:*", ["f"] = 275.80,                        ["d"] = "CVN-75 Tanker Shell 5-1 (125Y)" }
    },
    ["$RADIO_1_18"] = { },
    ["$RADIO_1_19"] = { },
    ["$RADIO_1_20"] = {
        [1] = { ["p"] = "*:*:*",             ["f"] = 243.00,                        ["d"] = "Guard (UHF)" }
    },


    -----------------------------------------------------------------------------------------------------------
    -- RadioPresetsBlue / Radio 2 : Right, Green, or VHF Radio (118MHz to 150MHz)
    -----------------------------------------------------------------------------------------------------------

    ["$RADIO_2_01"] = {
        [ 1] = { ["p"] = "*:*:*",                        ["f"] =   0.00, ["d"] = "Intraflight" },
        [ 2] = { ["p"] = "A-10C_2:*:*",                  ["f"] = 241.25 },
        [ 3] = { ["p"] = "A-10C_2:*:Hawg",               ["f"] = 241.25 },
        [ 4] = { ["p"] = "A-10C_2:*:Pig",                ["f"] = 241.75 },
        [ 5] = { ["p"] = "F-16C_50:*:Cowboy",            ["f"] = 138.25 },
        [ 6] = { ["p"] = "F-16C_50:*:Lobo",              ["f"] = 138.75 },
        [ 7] = { ["p"] = "F-14B:*:Dodge1",               ["f"] = 140.25 },
        [ 8] = { ["p"] = "F-14B:*:Dodge2",               ["f"] = 140.75 },
        [ 9] = { ["p"] = "FA-18C_hornet:*:Enfield",      ["f"] = 254.00 },
        [10] = { ["p"] = "FA-18C_hornet:*:Springfield",  ["f"] = 254.00 }
    },
    ["$RADIO_2_02"] = { },
    ["$RADIO_2_03"] = {
        [1] = { ["p"] = "*:*:*",                         ["f"] =   0.00, ["d"] = "Departure ATIS (VHF)" }
    },
    ["$RADIO_2_04"] = {
        [1] = { ["p"] = "*:*:*",                         ["f"] =   0.00, ["d"] = "Departure Tower (VHF)" }
    },
    ["$RADIO_2_05"] = {
        [1] = { ["p"] = "F-14B:*:*",                     ["f"] = 240.00, ["d"] = "AWACS Overlord 1-1 (AI)" },
        [2] = { ["p"] = "FA-18C_hornet:*:*",             ["f"] = 240.00, ["d"] = "AWACS Overlord 1-1 (AI)" }
    },
    ["$RADIO_2_06"] = {
        [1] = { ["p"] = "F-14B:*:*",                     ["f"] = 253.00, ["d"] = "AAR Arco 1-1 (53Y)" },
        [2] = { ["p"] = "FA-18C_hornet:*:*",             ["f"] = 253.00, ["d"] = "AAR Arco 1-1 (53Y)" }
    },
    ["$RADIO_2_07"] = {
        [1] = { ["p"] = "F-14B:*:*",                     ["f"] = 254.00, ["d"] = "AAR Arco 2-1 (54Y)" },
        [2] = { ["p"] = "FA-18C_hornet:*:*",             ["f"] = 254.00, ["d"] = "AAR Arco 2-1 (54Y)" }
    },
    ["$RADIO_2_08"] = {
        [1] = { ["p"] = "*:*:*",                         ["f"] = 138.00, ["d"] = "JTAC/AFAC Darknight 1-1 (VHF, AI)" },
        [2] = { ["p"] = "A-10C_2:*:*",                   ["f"] = 238.00, ["d"] = "JTAC/AFAC Darknight 1-1 (UHF, AI)" }
    },
    ["$RADIO_2_09"] = {
        [1] = { ["p"] = "*:*:*",                         ["f"] = 138.10, ["d"] = "JTAC/AFAC (VHF, Human)" },
        [2] = { ["p"] = "A-10C_2:*:*",                   ["f"] = 238.10, ["d"] = "JTAC/AFAC (UHF, Human)" }
    },
    ["$RADIO_2_10"] = {
        [1] = { ["p"] = "F-14B:*:*",                     ["f"] = 271.40, ["d"] = "CVN-71 ATC" },
        [2] = { ["p"] = "FA-18C_hornet:*:*",             ["f"] = 271.40, ["d"] = "CVN-71 ATC" }
    },
    ["$RADIO_2_11"] = {
        [1] = { ["p"] = "F-14B:*:*",                     ["f"] = 271.60, ["d"] = "CVN-71 AWACS Magic 1-1" },
        [2] = { ["p"] = "FA-18C_hornet:*:*",             ["f"] = 271.60, ["d"] = "CVN-71 AWACS Magic 1-1" }
    },
    ["$RADIO_2_12"] = {
        [1] = { ["p"] = "F-14B:*:*",                     ["f"] = 271.80, ["d"] = "CVN-71 Tanker Shell 1-1 (121Y)" },
        [2] = { ["p"] = "FA-18C_hornet:*:*",             ["f"] = 271.80, ["d"] = "CVN-71 Tanker Shell 1-1 (121Y)" }
    },
    ["$RADIO_2_13"] = { },
    ["$RADIO_2_14"] = { },
    ["$RADIO_2_15"] = {
        [1] = { ["p"] = "F-14B:*:*",                     ["f"] = 275.40, ["d"] = "CVN-75 ATC" },
        [2] = { ["p"] = "FA-18C_hornet:*:*",             ["f"] = 275.40, ["d"] = "CVN-75 ATC" }
    },
    ["$RADIO_2_16"] = {
        [1] = { ["p"] = "F-14B:*:*",                     ["f"] = 275.60, ["d"] = "CVN-75 AWACS Magic 5-1" },
        [2] = { ["p"] = "FA-18C_hornet:*:*",             ["f"] = 275.60, ["d"] = "CVN-75 AWACS Magic 5-1" }
    },
    ["$RADIO_2_17"] = {
        [1] = { ["p"] = "F-14B:*:*",                     ["f"] = 275.80, ["d"] = "CVN-75 Tanker Shell 5-1 (125Y)" },
        [2] = { ["p"] = "FA-18C_hornet:*:*",             ["f"] = 275.80, ["d"] = "CVN-75 Tanker Shell 5-1 (125Y)" }
    },
    ["$RADIO_2_18"] = { },
    ["$RADIO_2_19"] = { },
    ["$RADIO_2_20"] = {
        [1] = { ["p"] = "*:*:*",                         ["f"] = 121.50, ["d"] = "Guard (VHF)" },
        [2] = { ["p"] = "A-10C_2:*:*",                   ["f"] = 243.00, ["d"] = "Guard (UHF)" }
    },


    -----------------------------------------------------------------------------------------------------------
    -- RadioPresetsBlue / Radio 3 : FM Radio (20MHz to 59MHz (RU) or 30MHz to 87MHz (NATO))
    -----------------------------------------------------------------------------------------------------------

    ["$RADIO_3_01"] = 30.000,
    ["$RADIO_3_02"] = 31.000,
    ["$RADIO_3_03"] = 32.000,
    ["$RADIO_3_04"] = 33.000,
    ["$RADIO_3_05"] = 34.000,
    ["$RADIO_3_06"] = 35.000,
    ["$RADIO_3_07"] = 36.000,
    ["$RADIO_3_08"] = 37.000,
    ["$RADIO_3_09"] = 38.000,
    ["$RADIO_3_10"] = 39.000,
    ["$RADIO_3_11"] = 40.000,
    ["$RADIO_3_12"] = 41.000,
    ["$RADIO_3_13"] = 42.000,
    ["$RADIO_3_14"] = 43.000,
    ["$RADIO_3_15"] = 44.000,
    ["$RADIO_3_16"] = 45.000,
    ["$RADIO_3_17"] = 46.000,
    ["$RADIO_3_18"] = 47.000,
    ["$RADIO_3_19"] = 48.000,
    ["$RADIO_3_20"] = 49.000,
    ["$RADIO_3_21"] = 50.000,
    ["$RADIO_3_22"] = 51.000,
    ["$RADIO_3_23"] = 52.000,
    ["$RADIO_3_24"] = 53.000,
    ["$RADIO_3_25"] = 54.000,
    ["$RADIO_3_26"] = 55.000,
    ["$RADIO_3_27"] = 56.000,
    ["$RADIO_3_28"] = 57.000,
    ["$RADIO_3_29"] = 58.000,
    ["$RADIO_3_30"] = 59.000,
}

RadioPresetsWarbirdBlue = {

    -----------------------------------------------------------------------------------------------------------
    -- RadioPresetsWarbirdBlue / Axis Radios
    -----------------------------------------------------------------------------------------------------------

    ["$RADIO_FuG16_01"] = 39.000,
    ["$RADIO_FuG16_02"] = 38.400,
    ["$RADIO_FuG16_03"] = 41.000,
    ["$RADIO_FuG16_04"] = 42.000,
    ["$RADIO_FuG16_BASE"] = 38.400,
}

RadioPresetsRed =
{
    -----------------------------------------------------------------------------------------------------------
    -- RadioPresetsRed / Radio 1 : Left, Red, or UHF Radio (225MHz to 390MHz)
    -----------------------------------------------------------------------------------------------------------

    ["$RADIO_1_01"] = {
        [1] = { ["p"] = "*:*:*", ["f"] = 270.00, ["d"] = "Tac Common" }
    },
    ["$RADIO_1_02"] = { },
    ["$RADIO_1_03"] = { },
    ["$RADIO_1_04"] = { },
    ["$RADIO_1_05"] = { },
    ["$RADIO_1_06"] = { },
    ["$RADIO_1_07"] = { },
    ["$RADIO_1_08"] = { },
    ["$RADIO_1_09"] = { },
    ["$RADIO_1_10"] = { },
    ["$RADIO_1_11"] = { },
    ["$RADIO_1_12"] = { },
    ["$RADIO_1_13"] = { },
    ["$RADIO_1_14"] = { },
    ["$RADIO_1_15"] = { },
    ["$RADIO_1_16"] = { },
    ["$RADIO_1_17"] = { },
    ["$RADIO_1_18"] = { },
    ["$RADIO_1_19"] = { },
    ["$RADIO_1_20"] = { },


    -----------------------------------------------------------------------------------------------------------
    -- RadioPresetsRed / Radio 2 : Right, Green, or VHF Radio (118MHz to 150MHz)
    -----------------------------------------------------------------------------------------------------------

    ["$RADIO_2_01"] = {
        [1] = { ["p"] = "*:*:*", ["f"] = 138.00, ["d"] = "Intraflight" }
    },
    ["$RADIO_2_02"] = { },
    ["$RADIO_2_03"] = { },
    ["$RADIO_2_04"] = { },
    ["$RADIO_2_05"] = { },
    ["$RADIO_2_06"] = { },
    ["$RADIO_2_07"] = { },
    ["$RADIO_2_08"] = { },
    ["$RADIO_2_09"] = { },
    ["$RADIO_2_10"] = { },
    ["$RADIO_2_11"] = { },
    ["$RADIO_2_12"] = { },
    ["$RADIO_2_13"] = { },
    ["$RADIO_2_14"] = { },
    ["$RADIO_2_15"] = { },
    ["$RADIO_2_16"] = { },
    ["$RADIO_2_17"] = { },
    ["$RADIO_2_18"] = { },
    ["$RADIO_2_19"] = { },
    ["$RADIO_2_20"] = { },


    -----------------------------------------------------------------------------------------------------------
    -- RadioPresetsRed / Radio 3 : FM Radio (20MHz to 59MHz (RU) or 30MHz to 87MHz (NATO))
    -----------------------------------------------------------------------------------------------------------

    ["$RADIO_3_01"] = 30.000,
    ["$RADIO_3_02"] = 31.000,
    ["$RADIO_3_03"] = 32.000,
    ["$RADIO_3_04"] = 33.000,
    ["$RADIO_3_05"] = 34.000,
    ["$RADIO_3_06"] = 35.000,
    ["$RADIO_3_07"] = 36.000,
    ["$RADIO_3_08"] = 37.000,
    ["$RADIO_3_09"] = 38.000,
    ["$RADIO_3_10"] = 39.000,
    ["$RADIO_3_11"] = 40.000,
    ["$RADIO_3_12"] = 41.000,
    ["$RADIO_3_13"] = 42.000,
    ["$RADIO_3_14"] = 43.000,
    ["$RADIO_3_15"] = 44.000,
    ["$RADIO_3_16"] = 45.000,
    ["$RADIO_3_17"] = 46.000,
    ["$RADIO_3_18"] = 47.000,
    ["$RADIO_3_19"] = 48.000,
    ["$RADIO_3_20"] = 49.000,
    ["$RADIO_3_21"] = 50.000,
    ["$RADIO_3_22"] = 51.000,
    ["$RADIO_3_23"] = 52.000,
    ["$RADIO_3_24"] = 53.000,
    ["$RADIO_3_25"] = 54.000,
    ["$RADIO_3_26"] = 55.000,
    ["$RADIO_3_27"] = 56.000,
    ["$RADIO_3_28"] = 57.000,
    ["$RADIO_3_29"] = 58.000,
    ["$RADIO_3_30"] = 59.000,
}

RadioPresetsWarbirdRed = {

    -----------------------------------------------------------------------------------------------------------
    -- RadioPresetsWarbirdRed / Axis Radios
    -----------------------------------------------------------------------------------------------------------

    ["$RADIO_FuG16_01"] = 39.000,
    ["$RADIO_FuG16_02"] = 38.400,
    ["$RADIO_FuG16_03"] = 41.000,
    ["$RADIO_FuG16_04"] = 42.000,
    ["$RADIO_FuG16_BASE"] = 38.400,
}


---------------------------------------------------------------------------------------------------------------
-- Radio Settings
---------------------------------------------------------------------------------------------------------------

-- RadioSettings define how each airframe type maps it's radio configuration to the presets defined above.
-- this defines a template for the "Radio" key to apply to the Lua mission file.

RadioSettings =
{
    -----------------------------------------------------------------------------------------------------------
    -- prop planes
    -----------------------------------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------------------------------
    -- warbirds
    ["blue Bf-109K-4"] = {
        type = "Bf-109K-4",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 38-42MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1] = RadioPresetsWarbirdBlue["$RADIO_FuG16_01"],
                    [2] = RadioPresetsWarbirdBlue["$RADIO_FuG16_02"],
                    [3] = RadioPresetsWarbirdBlue["$RADIO_FuG16_03"],
                    [4] = RadioPresetsWarbirdBlue["$RADIO_FuG16_04"],
                    [5] = RadioPresetsWarbirdBlue["$RADIO_FuG16_BASE"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red Bf-109K-4"] = {
        type = "Bf-109K-4",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 38-42MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1] = RadioPresetsWarbirdRed["$RADIO_FuG16_01"],
                    [2] = RadioPresetsWarbirdRed["$RADIO_FuG16_02"],
                    [3] = RadioPresetsWarbirdRed["$RADIO_FuG16_03"],
                    [4] = RadioPresetsWarbirdRed["$RADIO_FuG16_04"],
                    [5] = RadioPresetsWarbirdRed["$RADIO_FuG16_BASE"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue FW-190D9"] = {
        type = "FW-190D9",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 38-42MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1] = RadioPresetsWarbirdBlue["$RADIO_FuG16_01"],
                    [2] = RadioPresetsWarbirdBlue["$RADIO_FuG16_02"],
                    [3] = RadioPresetsWarbirdBlue["$RADIO_FuG16_03"],
                    [4] = RadioPresetsWarbirdBlue["$RADIO_FuG16_04"],
                    [5] = RadioPresetsWarbirdBlue["$RADIO_FuG16_BASE"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red FW-190D9"] = {
        type = "FW-190D9",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 38-42MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1] = RadioPresetsWarbirdRed["$RADIO_FuG16_01"],
                    [2] = RadioPresetsWarbirdRed["$RADIO_FuG16_02"],
                    [3] = RadioPresetsWarbirdRed["$RADIO_FuG16_03"],
                    [4] = RadioPresetsWarbirdRed["$RADIO_FuG16_04"],
                    [5] = RadioPresetsWarbirdRed["$RADIO_FuG16_BASE"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue FW-190A8"] = {
        type = "FW-190A8",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 38-42MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1] = RadioPresetsWarbirdBlue["$RADIO_FuG16_01"],
                    [2] = RadioPresetsWarbirdBlue["$RADIO_FuG16_02"],
                    [3] = RadioPresetsWarbirdBlue["$RADIO_FuG16_03"],
                    [4] = RadioPresetsWarbirdBlue["$RADIO_FuG16_04"],
                    [5] = RadioPresetsWarbirdBlue["$RADIO_FuG16_BASE"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red FW-190A8"] = {
        type = "FW-190A8",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 38-42MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1] = RadioPresetsWarbirdRed["$RADIO_FuG16_01"],
                    [2] = RadioPresetsWarbirdRed["$RADIO_FuG16_02"],
                    [3] = RadioPresetsWarbirdRed["$RADIO_FuG16_03"],
                    [4] = RadioPresetsWarbirdRed["$RADIO_FuG16_04"],
                    [5] = RadioPresetsWarbirdRed["$RADIO_FuG16_BASE"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue I-16"] = {
        type = "I-16",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red I-16"] = {
        type = "I-16",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue MosquitoFBMkVI"] = {
        type = "MosquitoFBMkVI",
        coalition = "blue",
        country = nil,
        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [1]
            --HF (range 5.5-10MHz) with modulation selection box (but no modulation selection in the ME)
            [2] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1] = 9.255,
                    [2] = 8,
                    [3] = 7.71,
                    [4] = 6.872,
                    [5] = 5.955,
                    [6] = 5.85,
                    [7] = 5.75,
                    [8] = 5.65,
                }, -- end of ["channels"]
            }, -- end of [2]
            --HF (range 3-5.5MHz) with modulation selection box (but no modulation selection in the ME)
            [3] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1] = 5.25,
                    [2] = 5,
                    [3] = 4.75,
                    [4] = 4.5,
                    [5] = 4.25,
                    [6] = 3.25,
                    [7] = 3.012,
                    [8] = 3.011,
                }, -- end of ["channels"]
            }, -- end of [3]
            --LF/MF (range 0.2-0.5MHz) with modulation selection box (but no modulation selection in the ME)
            [4] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1] = 0.444,
                    [2] = 0.421,
                    [3] = 0.303,
                    [4] = 0.3,
                    [5] = 0.27,
                    [6] = 0.26,
                    [7] = 0.25,
                    [8] = 0.24,
                }, -- end of ["channels"]
            }, -- end of [4]
        }, -- end of ["Radio"]
    },

    ["red MosquitoFBMkVI"] = {
        type = "MosquitoFBMkVI",
        coalition = "red",
        country = nil,
        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                    [5]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [1]
            --HF (range 5.5-10MHz) with modulation selection box (but no modulation selection in the ME)
            [2] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1] = 9.255,
                    [2] = 8,
                    [3] = 7.71,
                    [4] = 6.872,
                    [5] = 5.955,
                    [6] = 5.85,
                    [7] = 5.75,
                    [8] = 5.65,
                }, -- end of ["channels"]
            }, -- end of [2]
            --HF (range 3-5.5MHz) with modulation selection box (but no modulation selection in the ME)
            [3] = 
            {
                ["modulations"] =
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1] = 5.25,
                    [2] = 5,
                    [3] = 4.75,
                    [4] = 4.5,
                    [5] = 4.25,
                    [6] = 3.25,
                    [7] = 3.012,
                    [8] = 3.011,
                }, -- end of ["channels"]
            }, -- end of [3]
            --LF/MF (range 0.2-0.5MHz) with modulation selection box (but no modulation selection in the ME)
            [4] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1] = 0.444,
                    [2] = 0.421,
                    [3] = 0.303,
                    [4] = 0.3,
                    [5] = 0.27,
                    [6] = 0.26,
                    [7] = 0.25,
                    [8] = 0.24,
                }, -- end of ["channels"]
            }, -- end of [4]
        }, -- end of ["Radio"]
    },

    ["blue P-47D-30"] = {
        type = "P-47D-30",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --Radio Beacon Finder Base frequency (range 100-200MHz)
            [2] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["red P-47D-30"] = {
        type = "P-47D-30",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --Radio Beacon Finder Base frequency (range 100-200MHz)
            [2] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["blue P-47D-30bl1"] = {
        type = "P-47D-30bl1",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --Radio Beacon Finder Base frequency (range 100-200MHz)
            [2] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["red P-47D-30bl1"] = {
        type = "P-47D-30bl1",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --Radio Beacon Finder Base frequency (range 100-200MHz)
            [2] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["blue P-47D-40"] = {
        type = "P-47D-40",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --Radio Beacon Finder Base frequency (range 100-200MHz)
            [2] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["red P-47D-40"] = {
        type = "P-47D-40",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --Radio Beacon Finder Base frequency (range 100-200MHz)
            [2] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["blue P-51D-25-NA"] = {
        type = "P-51D",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --Radio Beacon Finder Base frequency (range 100-200MHz)
            [2] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["red P-51D-25-NA"] = {
        type = "P-51D",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --Radio Beacon Finder Base frequency (range 100-200MHz)
            [2] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["blue P-51D-30-NA"] = {
        type = "P-51D-30-NA",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --Radio Beacon Finder Base frequency (range 100-200MHz)
            [2] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["red P-51D-30-NA"] = {
        type = "P-51D-30-NA",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --Radio Beacon Finder Base frequency (range 100-200MHz)
            [2] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["blue TF-51D"] = {
        type = "TF-51D",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --Radio Beacon Finder Base frequency (range 100-200MHz)
            [2] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["red TF-51D"] = {
        type = "TF-51D",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --Radio Beacon Finder Base frequency (range 100-200MHz)
            [2] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["blue SpitfireLFMkIX"] = {
        type = "SpitfireLFMkIX",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red SpitfireLFMkIX"] = {
        type = "SpitfireLFMkIX",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                    [5]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue SpitfireLFMkIXCW"] = {
        type = "SpitfireLFMkIXCW",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red SpitfireLFMkIXCW"] = {
        type = "SpitfireLFMkIXCW",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --VHF (range 100-156MHz) without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                    [5]  = 108.9,
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    -----------------------------------------------------------------------------------------------------------
    --tourist planes

    ["blue Christen Eagle II"] = {
        type = "Christen Eagle II",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --V/UHF with modulation selection box (but no modulation selection in ME)
            [1] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = RadioPresetsBlue["$RADIO_2_05"],
                    [6]  = RadioPresetsBlue["$RADIO_2_06"],
                    [7]  = RadioPresetsBlue["$RADIO_2_07"],
                    [8]  = RadioPresetsBlue["$RADIO_2_08"],
                    [9]  = RadioPresetsBlue["$RADIO_2_09"],
                    [10] = RadioPresetsBlue["$RADIO_2_10"],
                    [11] = RadioPresetsBlue["$RADIO_2_11"],
                    [12] = RadioPresetsBlue["$RADIO_2_12"],
                    [13] = RadioPresetsBlue["$RADIO_2_13"],
                    [14] = RadioPresetsBlue["$RADIO_2_14"],
                    [15] = RadioPresetsBlue["$RADIO_2_15"],
                    [16] = RadioPresetsBlue["$RADIO_2_16"],
                    [17] = RadioPresetsBlue["$RADIO_2_17"],
                    [18] = RadioPresetsBlue["$RADIO_2_18"],
                    [19] = RadioPresetsBlue["$RADIO_2_19"],
                    [20] = RadioPresetsBlue["$RADIO_2_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red Christen Eagle II"] = {
        type = "Christen Eagle II",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --V/UHF with modulation selection box (but no modulation selection in ME)
            [1] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                    [5]  = RadioPresetsRed["$RADIO_2_05"],
                    [6]  = RadioPresetsRed["$RADIO_2_06"],
                    [7]  = RadioPresetsRed["$RADIO_2_07"],
                    [8]  = RadioPresetsRed["$RADIO_2_08"],
                    [9]  = RadioPresetsRed["$RADIO_2_09"],
                    [10] = RadioPresetsRed["$RADIO_2_10"],
                    [11] = RadioPresetsRed["$RADIO_2_11"],
                    [12] = RadioPresetsRed["$RADIO_2_12"],
                    [13] = RadioPresetsRed["$RADIO_2_13"],
                    [14] = RadioPresetsRed["$RADIO_2_14"],
                    [15] = RadioPresetsRed["$RADIO_2_15"],
                    [16] = RadioPresetsRed["$RADIO_2_16"],
                    [17] = RadioPresetsRed["$RADIO_2_17"],
                    [18] = RadioPresetsRed["$RADIO_2_18"],
                    [19] = RadioPresetsRed["$RADIO_2_19"],
                    [20] = RadioPresetsRed["$RADIO_2_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue Yak-52"] = {
        type = "Yak-52",
        coalition = "blue",
        country = nil,

        --ARK-15M ADF (Range 0.1-1.795MHz)
        ["Radio"] = 
        {
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1] = 0.625,
                    [2] = 0.303,
                    [3] = 0.289,
                    [4] = 0.591,
                    [5] = 0.408,
                    [6] = 0.803,
                    [7] = 0.443,
                    [8] = 0.215,
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red Yak-52"] = {
        type = "Yak-52",
        coalition = "red",
        country = nil,

        --ARK-15M ADF (Range 0.1-1.795MHz)
        ["Radio"] = 
        {
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1] = 0.625,
                    [2] = 0.303,
                    [3] = 0.289,
                    [4] = 0.591,
                    [5] = 0.408,
                    [6] = 0.803,
                    [7] = 0.443,
                    [8] = 0.215,
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    -----------------------------------------------------------------------------------------------------------
    --jets
    -----------------------------------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------------------------------
    --ww2

    --["blue Me-262"] = {}, --ED plz

    --["red Me-262"] = {}, --ED plz

    --["blue Meteor F.3"] = {}, --ED plz

    --["red Meteor F.3"] = {}, --ED plz

    -----------------------------------------------------------------------------------------------------------
    --korea

    ["blue F-86F Sabre"] = {
        type = "F-86F Sabre",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --UHF without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red F-86F Sabre"] = {
        type = "F-86F Sabre",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --UHF without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    --["blue MiG-15Bis"] = {}, --no presets

    --["red MiG-15Bis"] = {}, --no presets

    -----------------------------------------------------------------------------------------------------------
    --cold war

    ["blue AJS37"] = {
        type = "AJS37",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --V/UHF (down to 103MHz) with modulation selection box (but no modulation selection in the ME)
            [1] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                    [27] = 0,
                    [28] = 0,
                    [29] = 0,
                    [30] = 0,
                    [31] = 0,
                    [32] = 0,
                    [33] = 0,
                    [34] = 0,
                    [35] = 0,
                    [36] = 0,
                    [37] = 0,
                    [38] = 0,
                    [39] = 0,
                    [40] = 0,
                    [41] = 1,
                    [42] = 1,
                    [43] = 1,
                    [44] = 1,
                    [45] = 1,
                    [46] = 0,
                    [47] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                    [21] = RadioPresetsBlue["$RADIO_2_01"],
                    [22] = RadioPresetsBlue["$RADIO_2_02"],
                    [23] = RadioPresetsBlue["$RADIO_2_03"],
                    [24] = RadioPresetsBlue["$RADIO_2_04"],
                    [25] = RadioPresetsBlue["$RADIO_2_05"],
                    [26] = RadioPresetsBlue["$RADIO_2_06"],
                    [27] = RadioPresetsBlue["$RADIO_2_07"],
                    [28] = RadioPresetsBlue["$RADIO_2_08"],
                    [29] = RadioPresetsBlue["$RADIO_2_09"],
                    [30] = RadioPresetsBlue["$RADIO_2_10"],
                    [31] = RadioPresetsBlue["$RADIO_2_11"],
                    [32] = RadioPresetsBlue["$RADIO_2_12"],
                    [33] = RadioPresetsBlue["$RADIO_2_13"],
                    [34] = RadioPresetsBlue["$RADIO_2_14"],
                    [35] = RadioPresetsBlue["$RADIO_2_15"],
                    [36] = RadioPresetsBlue["$RADIO_2_16"],
                    [37] = RadioPresetsBlue["$RADIO_2_17"],
                    [38] = RadioPresetsBlue["$RADIO_2_18"],
                    [39] = RadioPresetsBlue["$RADIO_2_19"],
                    [40] = RadioPresetsBlue["$RADIO_2_20"],
                    [41] = 30,
                    [42] = 31,
                    [43] = 32,
                    [44] = 33,
                    [45] = 34,
                    [46] = 127.5,
                    [47] = 243,
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red AJS37"] = {
        type = "AJS37",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --V/UHF (down to 103MHz) with modulation selection box (but no modulation selection in the ME)
            [1] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                    [27] = 0,
                    [28] = 0,
                    [29] = 0,
                    [30] = 0,
                    [31] = 0,
                    [32] = 0,
                    [33] = 0,
                    [34] = 0,
                    [35] = 0,
                    [36] = 0,
                    [37] = 0,
                    [38] = 0,
                    [39] = 0,
                    [40] = 0,
                    [41] = 1,
                    [42] = 1,
                    [43] = 1,
                    [44] = 1,
                    [45] = 1,
                    [46] = 0,
                    [47] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                    [21] = RadioPresetsRed["$RADIO_2_01"],
                    [22] = RadioPresetsRed["$RADIO_2_02"],
                    [23] = RadioPresetsRed["$RADIO_2_03"],
                    [24] = RadioPresetsRed["$RADIO_2_04"],
                    [25] = RadioPresetsRed["$RADIO_2_05"],
                    [26] = RadioPresetsRed["$RADIO_2_06"],
                    [27] = RadioPresetsRed["$RADIO_2_07"],
                    [28] = RadioPresetsRed["$RADIO_2_08"],
                    [29] = RadioPresetsRed["$RADIO_2_09"],
                    [30] = RadioPresetsRed["$RADIO_2_10"],
                    [31] = RadioPresetsRed["$RADIO_2_11"],
                    [32] = RadioPresetsRed["$RADIO_2_12"],
                    [33] = RadioPresetsRed["$RADIO_2_13"],
                    [34] = RadioPresetsRed["$RADIO_2_14"],
                    [35] = RadioPresetsRed["$RADIO_2_15"],
                    [36] = RadioPresetsRed["$RADIO_2_16"],
                    [37] = RadioPresetsRed["$RADIO_2_17"],
                    [38] = RadioPresetsRed["$RADIO_2_18"],
                    [39] = RadioPresetsRed["$RADIO_2_19"],
                    [40] = RadioPresetsRed["$RADIO_2_20"],
                    [41] = 30,
                    [42] = 31,
                    [43] = 32,
                    [44] = 33,
                    [45] = 34,
                    [46] = 127.5,
                    [47] = 243,
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue A-4E-C"] = {
        type = "A-4E-C",
        coalition = "blue",
        country = nil,
        
        ["Radio"] =
        {
            --UHF with modulation selection box (but no modulation selection in the ME)
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
        },
    },

    ["red A-4E-C"] = {
        type = "A-4E-C",
        coalition = "red",
        country = nil,
        
        ["Radio"] =
        {
            --UHF with modulation selection box (but no modulation selection in the ME)
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
        },
    },

    ["blue F-5E-3"] = {
        type = "F-5E-3",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --UHF without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red F-5E-3"] = {
        type = "F-5E-3",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --UHF without modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue MiG-19P"] = {
        type = "MiG-19P",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --VHF (down to 100MHz) with modulation selection box (but no modulation selection in the ME)
            [1] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = RadioPresetsBlue["$RADIO_2_05"],
                    [6]  = RadioPresetsBlue["$RADIO_2_06"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red MiG-19P"] = {
        type = "MiG-19P",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --VHF (down to 100MHz) with modulation selection box (but no modulation selection in the ME)
            [1] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                    [5]  = RadioPresetsRed["$RADIO_2_05"],
                    [6]  = RadioPresetsRed["$RADIO_2_06"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue MiG-21Bis"] = {
        type = "MiG-21Bis",
        coalition = "blue",
        country = nil,

        ["Radio"] = {
            --V/UHF with modulation selection box (but no modulation selection in the ME)
            [1] = {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red MiG-21Bis"] = {
        type = "MiG-21Bis",
        coalition = "red",
        country = nil,

        ["Radio"] = {
            --V/UHF with modulation selection box (but no modulation selection in the ME)
            [1] = {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue Mirage-F1CE"] = {
        type = "Mirage-F1CE",
        coalition = "blue",
        country = nil,

        ["Radio"] =
        {
            --V/UHF without modulation selection box
            [1] =
            {
                ["modulations"] =
                {
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = RadioPresetsBlue["$RADIO_2_05"],
                    [6]  = RadioPresetsBlue["$RADIO_2_06"],
                    [7]  = RadioPresetsBlue["$RADIO_2_07"],
                    [8]  = RadioPresetsBlue["$RADIO_2_08"],
                    [9]  = RadioPresetsBlue["$RADIO_2_09"],
                    [10] = RadioPresetsBlue["$RADIO_2_10"],
                    [11] = RadioPresetsBlue["$RADIO_2_11"],
                    [12] = RadioPresetsBlue["$RADIO_2_12"],
                    [13] = RadioPresetsBlue["$RADIO_2_13"],
                    [14] = RadioPresetsBlue["$RADIO_2_14"],
                    [15] = RadioPresetsBlue["$RADIO_2_15"],
                    [16] = RadioPresetsBlue["$RADIO_2_16"],
                    [17] = RadioPresetsBlue["$RADIO_2_17"],
                    [18] = RadioPresetsBlue["$RADIO_2_18"],
                    [19] = RadioPresetsBlue["$RADIO_2_19"],
                    [20] = RadioPresetsBlue["$RADIO_2_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --UHF without modulation selection box
            [2] =
            {
                ["modulations"] =
                {
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [2]
        },
    },

    ["red Mirage-F1CE"] = {
        type = "Mirage-F1CE",
        coalition = "red",
        country = nil,

        ["Radio"] =
        {
            --V/UHF without modulation selection box
            [1] =
            {
                ["modulations"] =
                {
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                    [5]  = RadioPresetsRed["$RADIO_2_05"],
                    [6]  = RadioPresetsRed["$RADIO_2_06"],
                    [7]  = RadioPresetsRed["$RADIO_2_07"],
                    [8]  = RadioPresetsRed["$RADIO_2_08"],
                    [9]  = RadioPresetsRed["$RADIO_2_09"],
                    [10] = RadioPresetsRed["$RADIO_2_10"],
                    [11] = RadioPresetsRed["$RADIO_2_11"],
                    [12] = RadioPresetsRed["$RADIO_2_12"],
                    [13] = RadioPresetsRed["$RADIO_2_13"],
                    [14] = RadioPresetsRed["$RADIO_2_14"],
                    [15] = RadioPresetsRed["$RADIO_2_15"],
                    [16] = RadioPresetsRed["$RADIO_2_16"],
                    [17] = RadioPresetsRed["$RADIO_2_17"],
                    [18] = RadioPresetsRed["$RADIO_2_18"],
                    [19] = RadioPresetsRed["$RADIO_2_19"],
                    [20] = RadioPresetsRed["$RADIO_2_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --UHF without modulation selection box
            [2] =
            {
                ["modulations"] =
                {
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [2]
        },
    },

    -----------------------------------------------------------------------------------------------------------
    --modern

    --["blue A-10C"] = {}, --no presets

    --["red A-10C"] = {}, --no presets

    ["blue A-10C_2"] = {
        type = "A-10C_2",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            [1] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                    [21] = 54,
                    [22] = 32.5,
                    [23] = 42,
                    [24] = 37.5,
                    [25] = 54,
                }, -- end of ["channels"]
            }, -- end of [1]
            [2] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = RadioPresetsBlue["$RADIO_2_05"],
                    [6]  = RadioPresetsBlue["$RADIO_2_06"],
                    [7]  = RadioPresetsBlue["$RADIO_2_07"],
                    [8]  = RadioPresetsBlue["$RADIO_2_08"],
                    [9]  = RadioPresetsBlue["$RADIO_2_09"],
                    [10] = RadioPresetsBlue["$RADIO_2_10"],
                    [11] = RadioPresetsBlue["$RADIO_2_11"],
                    [12] = RadioPresetsBlue["$RADIO_2_12"],
                    [13] = RadioPresetsBlue["$RADIO_2_13"],
                    [14] = RadioPresetsBlue["$RADIO_2_14"],
                    [15] = RadioPresetsBlue["$RADIO_2_15"],
                    [16] = RadioPresetsBlue["$RADIO_2_16"],
                    [17] = RadioPresetsBlue["$RADIO_2_17"],
                    [18] = RadioPresetsBlue["$RADIO_2_18"],
                    [19] = RadioPresetsBlue["$RADIO_2_19"],
                    [20] = RadioPresetsBlue["$RADIO_2_20"],
                }, -- end of ["channels"]
            }, -- end of [2]
            [3] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_3_01"],
                    [2]  = RadioPresetsBlue["$RADIO_3_02"],
                    [3]  = RadioPresetsBlue["$RADIO_3_03"],
                    [4]  = RadioPresetsBlue["$RADIO_3_04"],
                    [5]  = RadioPresetsBlue["$RADIO_3_05"],
                    [6]  = RadioPresetsBlue["$RADIO_3_06"],
                    [7]  = RadioPresetsBlue["$RADIO_3_07"],
                    [8]  = RadioPresetsBlue["$RADIO_3_08"],
                    [9]  = RadioPresetsBlue["$RADIO_3_09"],
                    [10] = RadioPresetsBlue["$RADIO_3_10"],
                    [11] = RadioPresetsBlue["$RADIO_3_11"],
                    [12] = RadioPresetsBlue["$RADIO_3_12"],
                    [13] = RadioPresetsBlue["$RADIO_3_13"],
                    [14] = RadioPresetsBlue["$RADIO_3_14"],
                    [15] = RadioPresetsBlue["$RADIO_3_15"],
                    [16] = RadioPresetsBlue["$RADIO_3_16"],
                    [17] = RadioPresetsBlue["$RADIO_3_17"],
                    [18] = RadioPresetsBlue["$RADIO_3_18"],
                    [19] = RadioPresetsBlue["$RADIO_3_19"],
                    [20] = RadioPresetsBlue["$RADIO_3_20"],
                }, -- end of ["channels"]
            }, -- end of [3]
        }, -- end of ["Radio"]
    },

    ["red A-10C_2"] = {
        type = "A-10C_2",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            [1] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                    [21] = 54,
                    [22] = 32.5,
                    [23] = 42,
                    [24] = 37.5,
                    [25] = 54,
                }, -- end of ["channels"]
            }, -- end of [1]
            [2] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = RadioPresetsBlue["$RADIO_2_05"],
                    [6]  = RadioPresetsBlue["$RADIO_2_06"],
                    [7]  = RadioPresetsBlue["$RADIO_2_07"],
                    [8]  = RadioPresetsBlue["$RADIO_2_08"],
                    [9]  = RadioPresetsBlue["$RADIO_2_09"],
                    [10] = RadioPresetsBlue["$RADIO_2_10"],
                    [11] = RadioPresetsBlue["$RADIO_2_11"],
                    [12] = RadioPresetsBlue["$RADIO_2_12"],
                    [13] = RadioPresetsBlue["$RADIO_2_13"],
                    [14] = RadioPresetsBlue["$RADIO_2_14"],
                    [15] = RadioPresetsBlue["$RADIO_2_15"],
                    [16] = RadioPresetsBlue["$RADIO_2_16"],
                    [17] = RadioPresetsBlue["$RADIO_2_17"],
                    [18] = RadioPresetsBlue["$RADIO_2_18"],
                    [19] = RadioPresetsBlue["$RADIO_2_19"],
                    [20] = RadioPresetsBlue["$RADIO_2_20"],
                }, -- end of ["channels"]
            }, -- end of [2]
            [3] = 
            {
                ["modulations"] = 
                {
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_3_01"],
                    [2]  = RadioPresetsBlue["$RADIO_3_02"],
                    [3]  = RadioPresetsBlue["$RADIO_3_03"],
                    [4]  = RadioPresetsBlue["$RADIO_3_04"],
                    [5]  = RadioPresetsBlue["$RADIO_3_05"],
                    [6]  = RadioPresetsBlue["$RADIO_3_06"],
                    [7]  = RadioPresetsBlue["$RADIO_3_07"],
                    [8]  = RadioPresetsBlue["$RADIO_3_08"],
                    [9]  = RadioPresetsBlue["$RADIO_3_09"],
                    [10] = RadioPresetsBlue["$RADIO_3_10"],
                    [11] = RadioPresetsBlue["$RADIO_3_11"],
                    [12] = RadioPresetsBlue["$RADIO_3_12"],
                    [13] = RadioPresetsBlue["$RADIO_3_13"],
                    [14] = RadioPresetsBlue["$RADIO_3_14"],
                    [15] = RadioPresetsBlue["$RADIO_3_15"],
                    [16] = RadioPresetsBlue["$RADIO_3_16"],
                    [17] = RadioPresetsBlue["$RADIO_3_17"],
                    [18] = RadioPresetsBlue["$RADIO_3_18"],
                    [19] = RadioPresetsBlue["$RADIO_3_19"],
                    [20] = RadioPresetsBlue["$RADIO_3_20"],
                }, -- end of ["channels"]
            }, -- end of [3]
        }, -- end of ["Radio"]
    },

    ["blue F-14A-135-GR"] = {
        type = "F-14A-135-GR",
        coalition = "blue",
        country = nil,

        ["Radio"] =
        {
            --UHF without modulation selection box
            [1] =
            {
                ["modulations"] =
                {
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --V/UHF (down to 30MHz) with modulation selection box (but no modulation selection in the ME)
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                    [26] = 1,
                    [27] = 1,
                    [28] = 1,
                    [29] = 1,
                    [30] = 1,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = RadioPresetsBlue["$RADIO_2_05"],
                    [6]  = RadioPresetsBlue["$RADIO_2_06"],
                    [7]  = RadioPresetsBlue["$RADIO_2_07"],
                    [8]  = RadioPresetsBlue["$RADIO_2_08"],
                    [9]  = RadioPresetsBlue["$RADIO_2_09"],
                    [10] = RadioPresetsBlue["$RADIO_2_10"],
                    [11] = RadioPresetsBlue["$RADIO_2_11"],
                    [12] = RadioPresetsBlue["$RADIO_2_12"],
                    [13] = RadioPresetsBlue["$RADIO_2_13"],
                    [14] = RadioPresetsBlue["$RADIO_2_14"],
                    [15] = RadioPresetsBlue["$RADIO_2_15"],
                    [16] = RadioPresetsBlue["$RADIO_2_16"],
                    [17] = RadioPresetsBlue["$RADIO_2_17"],
                    [18] = RadioPresetsBlue["$RADIO_2_18"],
                    [19] = RadioPresetsBlue["$RADIO_2_19"],
                    [20] = RadioPresetsBlue["$RADIO_2_20"],
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                    [27] = 0,
                    [28] = 0,
                    [29] = 0,
                    [30] = 0,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["red F-14A-135-GR"] = {
        type = "F-14A-135-GR",
        coalition = "red",
        country = nil,

        ["Radio"] =
        {
            --UHF without modulation selection box
            [1] =
            {
                ["modulations"] =
                {
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --V/UHF (down to 30MHz) with modulation selection box (but no modulation selection in the ME)
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                    [26] = 1,
                    [27] = 1,
                    [28] = 1,
                    [29] = 1,
                    [30] = 1,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                    [5]  = RadioPresetsRed["$RADIO_2_05"],
                    [6]  = RadioPresetsRed["$RADIO_2_06"],
                    [7]  = RadioPresetsRed["$RADIO_2_07"],
                    [8]  = RadioPresetsRed["$RADIO_2_08"],
                    [9]  = RadioPresetsRed["$RADIO_2_09"],
                    [10] = RadioPresetsRed["$RADIO_2_10"],
                    [11] = RadioPresetsRed["$RADIO_2_11"],
                    [12] = RadioPresetsRed["$RADIO_2_12"],
                    [13] = RadioPresetsRed["$RADIO_2_13"],
                    [14] = RadioPresetsRed["$RADIO_2_14"],
                    [15] = RadioPresetsRed["$RADIO_2_15"],
                    [16] = RadioPresetsRed["$RADIO_2_16"],
                    [17] = RadioPresetsRed["$RADIO_2_17"],
                    [18] = RadioPresetsRed["$RADIO_2_18"],
                    [19] = RadioPresetsRed["$RADIO_2_19"],
                    [20] = RadioPresetsRed["$RADIO_2_20"],
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                    [27] = 0,
                    [28] = 0,
                    [29] = 0,
                    [30] = 0,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["blue F-14B"] = {
        type = "F-14B",
        coalition = "blue",
        country = nil,

        ["Radio"] =
        {
            --UHF without modulation selection box
            [1] =
            {
                ["modulations"] =
                {
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --V/UHF (down to 30MHz) with modulation selection box (but no modulation selection in the ME)
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                    [26] = 1,
                    [27] = 1,
                    [28] = 1,
                    [29] = 1,
                    [30] = 1,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = RadioPresetsBlue["$RADIO_2_05"],
                    [6]  = RadioPresetsBlue["$RADIO_2_06"],
                    [7]  = RadioPresetsBlue["$RADIO_2_07"],
                    [8]  = RadioPresetsBlue["$RADIO_2_08"],
                    [9]  = RadioPresetsBlue["$RADIO_2_09"],
                    [10] = RadioPresetsBlue["$RADIO_2_10"],
                    [11] = RadioPresetsBlue["$RADIO_2_11"],
                    [12] = RadioPresetsBlue["$RADIO_2_12"],
                    [13] = RadioPresetsBlue["$RADIO_2_13"],
                    [14] = RadioPresetsBlue["$RADIO_2_14"],
                    [15] = RadioPresetsBlue["$RADIO_2_15"],
                    [16] = RadioPresetsBlue["$RADIO_2_16"],
                    [17] = RadioPresetsBlue["$RADIO_2_17"],
                    [18] = RadioPresetsBlue["$RADIO_2_18"],
                    [19] = RadioPresetsBlue["$RADIO_2_19"],
                    [20] = RadioPresetsBlue["$RADIO_2_20"],
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                    [27] = 0,
                    [28] = 0,
                    [29] = 0,
                    [30] = 0,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["red F-14B"] = {
        type = "F-14B",
        coalition = "red",
        country = nil,

        ["Radio"] =
        {
            --UHF without modulation selection box
            [1] =
            {
                ["modulations"] =
                {
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --V/UHF (down to 30MHz) with modulation selection box (but no modulation selection in the ME)
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                    [26] = 1,
                    [27] = 1,
                    [28] = 1,
                    [29] = 1,
                    [30] = 1,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                    [5]  = RadioPresetsRed["$RADIO_2_05"],
                    [6]  = RadioPresetsRed["$RADIO_2_06"],
                    [7]  = RadioPresetsRed["$RADIO_2_07"],
                    [8]  = RadioPresetsRed["$RADIO_2_08"],
                    [9]  = RadioPresetsRed["$RADIO_2_09"],
                    [10] = RadioPresetsRed["$RADIO_2_10"],
                    [11] = RadioPresetsRed["$RADIO_2_11"],
                    [12] = RadioPresetsRed["$RADIO_2_12"],
                    [13] = RadioPresetsRed["$RADIO_2_13"],
                    [14] = RadioPresetsRed["$RADIO_2_14"],
                    [15] = RadioPresetsRed["$RADIO_2_15"],
                    [16] = RadioPresetsRed["$RADIO_2_16"],
                    [17] = RadioPresetsRed["$RADIO_2_17"],
                    [18] = RadioPresetsRed["$RADIO_2_18"],
                    [19] = RadioPresetsRed["$RADIO_2_19"],
                    [20] = RadioPresetsRed["$RADIO_2_20"],
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                    [27] = 0,
                    [28] = 0,
                    [29] = 0,
                    [30] = 0,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },
    
    ["blue FA-18C_hornet"] = {
        type = "FA-18C_hornet",
        coalition = "blue",
        country = nil,

        ["Radio"] =
        {
            --V/UHF (down to 30MHz) with modulation selection box
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --V/UHF (down to 30MHz) with modulation selection box
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = RadioPresetsBlue["$RADIO_2_05"],
                    [6]  = RadioPresetsBlue["$RADIO_2_06"],
                    [7]  = RadioPresetsBlue["$RADIO_2_07"],
                    [8]  = RadioPresetsBlue["$RADIO_2_08"],
                    [9]  = RadioPresetsBlue["$RADIO_2_09"],
                    [10] = RadioPresetsBlue["$RADIO_2_10"],
                    [11] = RadioPresetsBlue["$RADIO_2_11"],
                    [12] = RadioPresetsBlue["$RADIO_2_12"],
                    [13] = RadioPresetsBlue["$RADIO_2_13"],
                    [14] = RadioPresetsBlue["$RADIO_2_14"],
                    [15] = RadioPresetsBlue["$RADIO_2_15"],
                    [16] = RadioPresetsBlue["$RADIO_2_16"],
                    [17] = RadioPresetsBlue["$RADIO_2_17"],
                    [18] = RadioPresetsBlue["$RADIO_2_18"],
                    [19] = RadioPresetsBlue["$RADIO_2_19"],
                    [20] = RadioPresetsBlue["$RADIO_2_20"],
                }, -- end of ["channels"]
            }, -- end of [2]
        },
    },

    ["red FA-18C_hornet"] = {
        type = "FA-18C_hornet",
        coalition = "red",
        country = nil,

        ["Radio"] =
        {
            --V/UHF (down to 30MHz) with modulation selection box
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --V/UHF (down to 30MHz) with modulation selection box
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                    [5]  = RadioPresetsRed["$RADIO_2_05"],
                    [6]  = RadioPresetsRed["$RADIO_2_06"],
                    [7]  = RadioPresetsRed["$RADIO_2_07"],
                    [8]  = RadioPresetsRed["$RADIO_2_08"],
                    [9]  = RadioPresetsRed["$RADIO_2_09"],
                    [10] = RadioPresetsRed["$RADIO_2_10"],
                    [11] = RadioPresetsRed["$RADIO_2_11"],
                    [12] = RadioPresetsRed["$RADIO_2_12"],
                    [13] = RadioPresetsRed["$RADIO_2_13"],
                    [14] = RadioPresetsRed["$RADIO_2_14"],
                    [15] = RadioPresetsRed["$RADIO_2_15"],
                    [16] = RadioPresetsRed["$RADIO_2_16"],
                    [17] = RadioPresetsRed["$RADIO_2_17"],
                    [18] = RadioPresetsRed["$RADIO_2_18"],
                    [19] = RadioPresetsRed["$RADIO_2_19"],
                    [20] = RadioPresetsRed["$RADIO_2_20"],
                }, -- end of ["channels"]
            }, -- end of [2]
        },
    },

    ["blue F-16C"] = {
        type = "F-16C_50",
        coalition = "blue",
        country = nil,
        ["Radio"] =
        {
            --UHF with modulation selection box (but no modulation selection in the ME)
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --VHF (down to 30MHz) with modulation selection box (but no modulation selection in the ME)
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = RadioPresetsBlue["$RADIO_2_05"],
                    [6]  = RadioPresetsBlue["$RADIO_2_06"],
                    [7]  = RadioPresetsBlue["$RADIO_2_07"],
                    [8]  = RadioPresetsBlue["$RADIO_2_08"],
                    [9]  = RadioPresetsBlue["$RADIO_2_09"],
                    [10] = RadioPresetsBlue["$RADIO_2_10"],
                    [11] = RadioPresetsBlue["$RADIO_2_11"],
                    [12] = RadioPresetsBlue["$RADIO_2_12"],
                    [13] = RadioPresetsBlue["$RADIO_2_13"],
                    [14] = RadioPresetsBlue["$RADIO_2_14"],
                    [15] = RadioPresetsBlue["$RADIO_2_15"],
                    [16] = RadioPresetsBlue["$RADIO_2_16"],
                    [17] = RadioPresetsBlue["$RADIO_2_17"],
                    [18] = RadioPresetsBlue["$RADIO_2_18"],
                    [19] = RadioPresetsBlue["$RADIO_2_19"],
                    [20] = RadioPresetsBlue["$RADIO_2_20"],
                }, -- end of ["channels"]
            }, -- end of [2]
        },
    },

    ["red F-16C"] = {
        type = "F-16C_50",
        coalition = "red",
        country = nil,
        ["Radio"] =
        {
            --UHF with modulation selection box (but no modulation selection in the ME)
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --VHF (down to 30MHz) with modulation selection box (but no modulation selection in the ME)
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                    [5]  = RadioPresetsRed["$RADIO_2_05"],
                    [6]  = RadioPresetsRed["$RADIO_2_06"],
                    [7]  = RadioPresetsRed["$RADIO_2_07"],
                    [8]  = RadioPresetsRed["$RADIO_2_08"],
                    [9]  = RadioPresetsRed["$RADIO_2_09"],
                    [10] = RadioPresetsRed["$RADIO_2_10"],
                    [11] = RadioPresetsRed["$RADIO_2_11"],
                    [12] = RadioPresetsRed["$RADIO_2_12"],
                    [13] = RadioPresetsRed["$RADIO_2_13"],
                    [14] = RadioPresetsRed["$RADIO_2_14"],
                    [15] = RadioPresetsRed["$RADIO_2_15"],
                    [16] = RadioPresetsRed["$RADIO_2_16"],
                    [17] = RadioPresetsRed["$RADIO_2_17"],
                    [18] = RadioPresetsRed["$RADIO_2_18"],
                    [19] = RadioPresetsRed["$RADIO_2_19"],
                    [20] = RadioPresetsRed["$RADIO_2_20"],
                }, -- end of ["channels"]
            }, -- end of [2]
        },
    },

    ["blue Harrier"] = {
        type = "AV8BNA",
        coalition = "blue",
        country = nil,

        ["Radio"] =
        {
            --V/UHF (down to 30MHz) with modulation selection box (but no modulation selection in the ME)
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                    [26] = 1,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                }, -- end of ["channels"]
            }, -- end of [1]
            --V/UHF (down to 30MHz) with modulation selection box (but no modulation selection in the ME)
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                    [26] = 1,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = RadioPresetsBlue["$RADIO_2_05"],
                    [6]  = RadioPresetsBlue["$RADIO_2_06"],
                    [7]  = RadioPresetsBlue["$RADIO_2_07"],
                    [8]  = RadioPresetsBlue["$RADIO_2_08"],
                    [9]  = RadioPresetsBlue["$RADIO_2_09"],
                    [10] = RadioPresetsBlue["$RADIO_2_10"],
                    [11] = RadioPresetsBlue["$RADIO_2_11"],
                    [12] = RadioPresetsBlue["$RADIO_2_12"],
                    [13] = RadioPresetsBlue["$RADIO_2_13"],
                    [14] = RadioPresetsBlue["$RADIO_2_14"],
                    [15] = RadioPresetsBlue["$RADIO_2_15"],
                    [16] = RadioPresetsBlue["$RADIO_2_16"],
                    [17] = RadioPresetsBlue["$RADIO_2_17"],
                    [18] = RadioPresetsBlue["$RADIO_2_18"],
                    [19] = RadioPresetsBlue["$RADIO_2_19"],
                    [20] = RadioPresetsBlue["$RADIO_2_20"],
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                }, -- end of ["channels"]
            }, -- end of [2]
            --V/UHF (down to 30MHz) with modulation selection box (but no modulation selection in the ME)
            [3] =
            {
                ["modulations"] =
                {
                    [1] =  1,
                    [2] =  1,
                    [3] =  1,
                    [4] =  1,
                    [5] =  1,
                    [6] =  1,
                    [7] =  1,
                    [8] =  1,
                    [9] =  1,
                    [10] = 1,
                    [11] = 1,
                    [12] = 1,
                    [13] = 1,
                    [14] = 1,
                    [15] = 1,
                    [16] = 1,
                    [17] = 1,
                    [18] = 1,
                    [19] = 1,
                    [20] = 1,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                    [26] = 1,
                    [27] = 1,
                    [28] = 1,
                    [29] = 1,
                    [30] = 1,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_3_01"],
                    [2]  = RadioPresetsBlue["$RADIO_3_02"],
                    [3]  = RadioPresetsBlue["$RADIO_3_03"],
                    [4]  = RadioPresetsBlue["$RADIO_3_04"],
                    [5]  = RadioPresetsBlue["$RADIO_3_05"],
                    [6]  = RadioPresetsBlue["$RADIO_3_06"],
                    [7]  = RadioPresetsBlue["$RADIO_3_07"],
                    [8]  = RadioPresetsBlue["$RADIO_3_08"],
                    [9]  = RadioPresetsBlue["$RADIO_3_09"],
                    [10] = RadioPresetsBlue["$RADIO_3_10"],
                    [11] = RadioPresetsBlue["$RADIO_3_11"],
                    [12] = RadioPresetsBlue["$RADIO_3_12"],
                    [13] = RadioPresetsBlue["$RADIO_3_13"],
                    [14] = RadioPresetsBlue["$RADIO_3_14"],
                    [15] = RadioPresetsBlue["$RADIO_3_15"],
                    [16] = RadioPresetsBlue["$RADIO_3_16"],
                    [17] = RadioPresetsBlue["$RADIO_3_17"],
                    [18] = RadioPresetsBlue["$RADIO_3_18"],
                    [19] = RadioPresetsBlue["$RADIO_3_19"],
                    [20] = RadioPresetsBlue["$RADIO_3_20"],
                    [21] = RadioPresetsBlue["$RADIO_3_21"],
                    [22] = RadioPresetsBlue["$RADIO_3_22"],
                    [23] = RadioPresetsBlue["$RADIO_3_23"],
                    [24] = RadioPresetsBlue["$RADIO_3_24"],
                    [25] = RadioPresetsBlue["$RADIO_3_25"],
                    [26] = RadioPresetsBlue["$RADIO_3_26"],
                    [27] = RadioPresetsBlue["$RADIO_3_27"],
                    [28] = RadioPresetsBlue["$RADIO_3_28"],
                    [29] = RadioPresetsBlue["$RADIO_3_29"],
                    [30] = RadioPresetsBlue["$RADIO_3_30"],
                }, -- end of ["channels"]
            }, -- end of [3]
        },
    },

    ["red Harrier"] = {
        type = "AV8BNA",
        coalition = "red",
        country = nil,

        ["Radio"] =
        {
            --V/UHF (down to 30MHz) with modulation selection box (but no modulation selection in the ME)
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                    [26] = 1,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                }, -- end of ["channels"]
            }, -- end of [1]
            --V/UHF (down to 30MHz) with modulation selection box (but no modulation selection in the ME)
            [2] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                    [26] = 1,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                    [5]  = RadioPresetsRed["$RADIO_2_05"],
                    [6]  = RadioPresetsRed["$RADIO_2_06"],
                    [7]  = RadioPresetsRed["$RADIO_2_07"],
                    [8]  = RadioPresetsRed["$RADIO_2_08"],
                    [9]  = RadioPresetsRed["$RADIO_2_09"],
                    [10] = RadioPresetsRed["$RADIO_2_10"],
                    [11] = RadioPresetsRed["$RADIO_2_11"],
                    [12] = RadioPresetsRed["$RADIO_2_12"],
                    [13] = RadioPresetsRed["$RADIO_2_13"],
                    [14] = RadioPresetsRed["$RADIO_2_14"],
                    [15] = RadioPresetsRed["$RADIO_2_15"],
                    [16] = RadioPresetsRed["$RADIO_2_16"],
                    [17] = RadioPresetsRed["$RADIO_2_17"],
                    [18] = RadioPresetsRed["$RADIO_2_18"],
                    [19] = RadioPresetsRed["$RADIO_2_19"],
                    [20] = RadioPresetsRed["$RADIO_2_20"],
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                }, -- end of ["channels"]
            }, -- end of [2]
            --V/UHF (down to 30MHz) with modulation selection box (but no modulation selection in the ME)
            [3] =
            {
                ["modulations"] =
                {
                    [1] =  1,
                    [2] =  1,
                    [3] =  1,
                    [4] =  1,
                    [5] =  1,
                    [6] =  1,
                    [7] =  1,
                    [8] =  1,
                    [9] =  1,
                    [10] = 1,
                    [11] = 1,
                    [12] = 1,
                    [13] = 1,
                    [14] = 1,
                    [15] = 1,
                    [16] = 1,
                    [17] = 1,
                    [18] = 1,
                    [19] = 1,
                    [20] = 1,
                    [21] = 1,
                    [22] = 1,
                    [23] = 1,
                    [24] = 1,
                    [25] = 1,
                    [26] = 1,
                    [27] = 1,
                    [28] = 1,
                    [29] = 1,
                    [30] = 1,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_3_01"],
                    [2]  = RadioPresetsRed["$RADIO_3_02"],
                    [3]  = RadioPresetsRed["$RADIO_3_03"],
                    [4]  = RadioPresetsRed["$RADIO_3_04"],
                    [5]  = RadioPresetsRed["$RADIO_3_05"],
                    [6]  = RadioPresetsRed["$RADIO_3_06"],
                    [7]  = RadioPresetsRed["$RADIO_3_07"],
                    [8]  = RadioPresetsRed["$RADIO_3_08"],
                    [9]  = RadioPresetsRed["$RADIO_3_09"],
                    [10] = RadioPresetsRed["$RADIO_3_10"],
                    [11] = RadioPresetsRed["$RADIO_3_11"],
                    [12] = RadioPresetsRed["$RADIO_3_12"],
                    [13] = RadioPresetsRed["$RADIO_3_13"],
                    [14] = RadioPresetsRed["$RADIO_3_14"],
                    [15] = RadioPresetsRed["$RADIO_3_15"],
                    [16] = RadioPresetsRed["$RADIO_3_16"],
                    [17] = RadioPresetsRed["$RADIO_3_17"],
                    [18] = RadioPresetsRed["$RADIO_3_18"],
                    [19] = RadioPresetsRed["$RADIO_3_19"],
                    [20] = RadioPresetsRed["$RADIO_3_20"],
                    [21] = RadioPresetsRed["$RADIO_3_21"],
                    [22] = RadioPresetsRed["$RADIO_3_22"],
                    [23] = RadioPresetsRed["$RADIO_3_23"],
                    [24] = RadioPresetsRed["$RADIO_3_24"],
                    [25] = RadioPresetsRed["$RADIO_3_25"],
                    [26] = RadioPresetsRed["$RADIO_3_26"],
                    [27] = RadioPresetsRed["$RADIO_3_27"],
                    [28] = RadioPresetsRed["$RADIO_3_28"],
                    [29] = RadioPresetsRed["$RADIO_3_29"],
                    [30] = RadioPresetsRed["$RADIO_3_30"],
                }, -- end of ["channels"]
            }, -- end of [3]
        },
    },

    ["blue JF-17"] = {
        type = "JF-17",
        coalition = "blue",
        country = nil,

        ["Radio"] = 
        {
            --V/UHF (down to 30MHz) with modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red JF-17"] = {
        type = "JF-17",
        coalition = "red",
        country = nil,

        ["Radio"] = 
        {
            --V/UHF (down to 30MHz) with modulation selection box
            [1] = 
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] = 
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue Mirage"] = {
        type = "M-2000C",
        coalition = "blue",
        country = nil,

        ["Radio"] =
        {
            --UHF with modulation selection box (but no modulation selection in the ME)
            [1] =
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --V/UHF with modulation selection box (but no modulation selection in the ME)
            [2] =
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = RadioPresetsBlue["$RADIO_2_05"],
                    [6]  = RadioPresetsBlue["$RADIO_2_06"],
                    [7]  = RadioPresetsBlue["$RADIO_2_07"],
                    [8]  = RadioPresetsBlue["$RADIO_2_08"],
                    [9]  = RadioPresetsBlue["$RADIO_2_09"],
                    [10] = RadioPresetsBlue["$RADIO_2_10"],
                    [11] = RadioPresetsBlue["$RADIO_2_11"],
                    [12] = RadioPresetsBlue["$RADIO_2_12"],
                    [13] = RadioPresetsBlue["$RADIO_2_13"],
                    [14] = RadioPresetsBlue["$RADIO_2_14"],
                    [15] = RadioPresetsBlue["$RADIO_2_15"],
                    [16] = RadioPresetsBlue["$RADIO_2_16"],
                    [17] = RadioPresetsBlue["$RADIO_2_17"],
                    [18] = RadioPresetsBlue["$RADIO_2_18"],
                    [19] = RadioPresetsBlue["$RADIO_2_19"],
                    [20] = RadioPresetsBlue["$RADIO_2_20"],
                }, -- end of ["channels"]
            }, -- end of [2]
        },
    },

    ["red Mirage"] = {
        type = "M-2000C",
        coalition = "red",
        country = nil,

        ["Radio"] =
        {
            --UHF with modulation selection box (but no modulation selection in the ME)
            [1] =
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --V/UHF with modulation selection box (but no modulation selection in the ME)
            [2] =
            {
                ["modulations"] = 
                {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                    [5]  = RadioPresetsRed["$RADIO_2_05"],
                    [6]  = RadioPresetsRed["$RADIO_2_06"],
                    [7]  = RadioPresetsRed["$RADIO_2_07"],
                    [8]  = RadioPresetsRed["$RADIO_2_08"],
                    [9]  = RadioPresetsRed["$RADIO_2_09"],
                    [10] = RadioPresetsRed["$RADIO_2_10"],
                    [11] = RadioPresetsRed["$RADIO_2_11"],
                    [12] = RadioPresetsRed["$RADIO_2_12"],
                    [13] = RadioPresetsRed["$RADIO_2_13"],
                    [14] = RadioPresetsRed["$RADIO_2_14"],
                    [15] = RadioPresetsRed["$RADIO_2_15"],
                    [16] = RadioPresetsRed["$RADIO_2_16"],
                    [17] = RadioPresetsRed["$RADIO_2_17"],
                    [18] = RadioPresetsRed["$RADIO_2_18"],
                    [19] = RadioPresetsRed["$RADIO_2_19"],
                    [20] = RadioPresetsRed["$RADIO_2_20"],
                }, -- end of ["channels"]
            }, -- end of [2]
        },
    },


    -----------------------------------------------------------------------------------------------------------
    --trainers

    ["blue C-101CC"] = {
        type = "C-101CC",
        coalition = "blue",
        country = nil,

        ["Radio"] = {
            --V/UHF without modulation selection box
            [1] = {
                ["channels"] = {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red C-101CC"] = {
        type = "C-101CC",
        coalition = "red",
        country = nil,

        ["Radio"] = {
            --V/UHF without modulation selection box
            [1] = {
                ["channels"] = {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue C-101EB"] = {
        type = "C-101EB",
        coalition = "blue",
        country = nil,

        ["Radio"] = {
            --UHF, yes UHF, without modulation selection box
            [1] = {
                ["channels"] = {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red C-101EB"] = {
        type = "C-101EB",
        coalition = "red",
        country = nil,

        ["Radio"] = {
            --UHF, yes UHF, without modulation selection box
            [1] = {
                ["channels"] = {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue L-39C"] = {
        type = "L-39C",
        coalition = "blue",
        country = nil,

        ["Radio"] =
        {
            --V/UHF with modulation selection box (but no modulation selection in the ME)
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
        },
    },

    ["red L-39C"] = {
        type = "L-39C",
        coalition = "red",
        country = nil,

        ["Radio"] =
        {
            --V/UHF with modulation selection box (but no modulation selection in the ME)
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
        },
    },

    ["blue L-39ZA"] = {
        type = "L-39ZA",
        coalition = "blue",
        country = nil,

        ["Radio"] =
        {
            --V/UHF with modulation selection box (but no modulation selection in the ME)
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
        },
    },

    ["red L-39ZA"] = {
        type = "L-39ZA",
        coalition = "red",
        country = nil,

        ["Radio"] =
        {
            --V/UHF with modulation selection box (but no modulation selection in the ME)
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
            }, -- end of [1]
        },
    },

    ["blue T-45"] = {
        type = "T-45",
        coalition = "blue",
        country = nil,

        ["Radio"] =
        {
            --Unknown
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                    [27] = 0,
                    [28] = 0,
                    [29] = 0,
                    [30] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                    [27] = 0,
                    [28] = 0,
                    [29] = 0,
                    [30] = 0,
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red T-45"] = {
        type = "T-45",
        coalition = "red",
        country = nil,

        ["Radio"] =
        {
            --Unknown
            [1] =
            {
                ["modulations"] =
                {
                    [1] =  0,
                    [2] =  0,
                    [3] =  0,
                    [4] =  0,
                    [5] =  0,
                    [6] =  0,
                    [7] =  0,
                    [8] =  0,
                    [9] =  0,
                    [10] = 0,
                    [11] = 0,
                    [12] = 0,
                    [13] = 0,
                    [14] = 0,
                    [15] = 0,
                    [16] = 0,
                    [17] = 0,
                    [18] = 0,
                    [19] = 0,
                    [20] = 0,
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                    [27] = 0,
                    [28] = 0,
                    [29] = 0,
                    [30] = 0,
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                    [21] = 0,
                    [22] = 0,
                    [23] = 0,
                    [24] = 0,
                    [25] = 0,
                    [26] = 0,
                    [27] = 0,
                    [28] = 0,
                    [29] = 0,
                    [30] = 0,
                }, -- end of ["channels"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    -----------------------------------------------------------------------------------------------------------
    --helicopters
    -----------------------------------------------------------------------------------------------------------

    ["blue AH-64D"] = {
        type = "AH-64D",
        coalition = "blue",
        country = nil,

        ["Radio"] = {
            --VHF with modulation selection box (but no modulation selection in ME)
            [1] = {
                ["channels"] = {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                }, -- end of ["channels"]
                ["modulations"] = {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                }, -- end of ["modulations"]
            }, -- end of [1]
            --UHF with modulation selection box (but no modulation selection in ME)
            [2] = {
                ["channels"] = {
                    [1]  = RadioPresetsBlue["$RADIO_2_01"],
                    [2]  = RadioPresetsBlue["$RADIO_2_02"],
                    [3]  = RadioPresetsBlue["$RADIO_2_03"],
                    [4]  = RadioPresetsBlue["$RADIO_2_04"],
                    [5]  = RadioPresetsBlue["$RADIO_2_05"],
                    [6]  = RadioPresetsBlue["$RADIO_2_06"],
                    [7]  = RadioPresetsBlue["$RADIO_2_07"],
                    [8]  = RadioPresetsBlue["$RADIO_2_08"],
                    [9]  = RadioPresetsBlue["$RADIO_2_09"],
                    [10] = RadioPresetsBlue["$RADIO_2_10"],
                }, -- end of ["channels"]
                ["modulations"] = {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                }, -- end of ["modulations"]
            }, -- end of [2]
            --FM without modulation selection box
            [3] = {
                ["channels"] = {
                    [1]  = RadioPresetsBlue["$RADIO_3_01"],
                    [2]  = RadioPresetsBlue["$RADIO_3_02"],
                    [3]  = RadioPresetsBlue["$RADIO_3_03"],
                    [4]  = RadioPresetsBlue["$RADIO_3_04"],
                    [5]  = RadioPresetsBlue["$RADIO_3_05"],
                    [6]  = RadioPresetsBlue["$RADIO_3_06"],
                    [7]  = RadioPresetsBlue["$RADIO_3_07"],
                    [8]  = RadioPresetsBlue["$RADIO_3_08"],
                    [9]  = RadioPresetsBlue["$RADIO_3_09"],
                    [10] = RadioPresetsBlue["$RADIO_3_10"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [3]
            --FM without modulation selection box
            [4] = {
                ["channels"] = {
                    [1] = 30,
                    [2] = 30.01,
                    [3] = 30.015,
                    [4] = 30.02,
                    [5] = 30.025,
                    [6] = 30.03,
                    [7] = 30.035,
                    [8] = 30.04,
                    [9] = 30.045,
                    [10] = 30.05,
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [4]
        }, -- end of ["Radio"]
    },

    ["red AH-64D"] = {
        type = "AH-64D",
        coalition = "red",
        country = nil,

        ["Radio"] = {
            --VHF with modulation selection box (but no modulation selection in ME)
            [1] = {
                ["channels"] = {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                }, -- end of ["channels"]
                ["modulations"] = {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                }, -- end of ["modulations"]
            }, -- end of [1]
            --UHF with modulation selection box (but no modulation selection in ME)
            [2] = {
                ["channels"] = {
                    [1]  = RadioPresetsRed["$RADIO_2_01"],
                    [2]  = RadioPresetsRed["$RADIO_2_02"],
                    [3]  = RadioPresetsRed["$RADIO_2_03"],
                    [4]  = RadioPresetsRed["$RADIO_2_04"],
                    [5]  = RadioPresetsRed["$RADIO_2_05"],
                    [6]  = RadioPresetsRed["$RADIO_2_06"],
                    [7]  = RadioPresetsRed["$RADIO_2_07"],
                    [8]  = RadioPresetsRed["$RADIO_2_08"],
                    [9]  = RadioPresetsRed["$RADIO_2_09"],
                    [10] = RadioPresetsRed["$RADIO_2_10"],
                }, -- end of ["channels"]
                ["modulations"] = {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    [4] = 0,
                    [5] = 0,
                    [6] = 0,
                    [7] = 0,
                    [8] = 0,
                    [9] = 0,
                    [10] = 0,
                }, -- end of ["modulations"]
            }, -- end of [2]
            --FM without modulation selection box
            [3] = {
                ["channels"] = {
                    [1]  = RadioPresetsRed["$RADIO_3_01"],
                    [2]  = RadioPresetsRed["$RADIO_3_02"],
                    [3]  = RadioPresetsRed["$RADIO_3_03"],
                    [4]  = RadioPresetsRed["$RADIO_3_04"],
                    [5]  = RadioPresetsRed["$RADIO_3_05"],
                    [6]  = RadioPresetsRed["$RADIO_3_06"],
                    [7]  = RadioPresetsRed["$RADIO_3_07"],
                    [8]  = RadioPresetsRed["$RADIO_3_08"],
                    [9]  = RadioPresetsRed["$RADIO_3_09"],
                    [10] = RadioPresetsRed["$RADIO_3_10"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [3]
            --FM without modulation selection box
            [4] = {
                ["channels"] = {
                    [1] = 30,
                    [2] = 30.01,
                    [3] = 30.015,
                    [4] = 30.02,
                    [5] = 30.025,
                    [6] = 30.03,
                    [7] = 30.035,
                    [8] = 30.04,
                    [9] = 30.045,
                    [10] = 30.05,
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [4]
        }, -- end of ["Radio"]
    },

    ["blue Gazelles"] = {
        type = "SA342.+",
        coalition = "blue",
        country = nil,

        ["Radio"] = {
            --FM with modulation selection box (but no modulation selection in ME)
            [1] = {
                ["channels"] = {
                    [1]  = RadioPresetsBlue["$RADIO_3_01"],
                    [2]  = RadioPresetsBlue["$RADIO_3_02"],
                    [3]  = RadioPresetsBlue["$RADIO_3_03"],
                    [4]  = RadioPresetsBlue["$RADIO_3_04"],
                    [5]  = RadioPresetsBlue["$RADIO_3_05"],
                    [6]  = RadioPresetsBlue["$RADIO_3_06"],
                    [7]  = RadioPresetsBlue["$RADIO_3_07"],
                }, -- end of ["channels"]
                ["modulations"] = {
                    [1]  = 0,
                    [2]  = 0,
                    [3]  = 0,
                    [4]  = 0,
                    [5]  = 0,
                    [6]  = 0,
                    [7]  = 0,
                }, -- end of ["modulations"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red Gazelles"] = {
        type = "SA342.+",
        coalition = "red",
        country = nil,

        ["Radio"] = {
            --FM with modulation selection box (but no modulation selection in ME)
            [1] = {
                ["channels"] = {
                    [1]  = RadioPresetsRed["$RADIO_3_01"],
                    [2]  = RadioPresetsRed["$RADIO_3_02"],
                    [3]  = RadioPresetsRed["$RADIO_3_03"],
                    [4]  = RadioPresetsRed["$RADIO_3_04"],
                    [5]  = RadioPresetsRed["$RADIO_3_05"],
                    [6]  = RadioPresetsRed["$RADIO_3_06"],
                    [7]  = RadioPresetsRed["$RADIO_3_07"],
                }, -- end of ["channels"]
                ["modulations"] = {
                    [1]  = 0,
                    [2]  = 0,
                    [3]  = 0,
                    [4]  = 0,
                    [5]  = 0,
                    [6]  = 0,
                    [7]  = 0,
                }, -- end of ["modulations"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["blue Ka-50"] = {
        type = "Ka-50",
        coalition = "blue",
        country = nil,

        ["Radio"] =
        {
            --FM without modulation selection box
            [1] =
            {
                ["modulations"] =
                {
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsBlue["$RADIO_3_01"],
                    [2]  = RadioPresetsBlue["$RADIO_3_02"],
                    [3]  = RadioPresetsBlue["$RADIO_3_03"],
                    [4]  = RadioPresetsBlue["$RADIO_3_04"],
                    [5]  = RadioPresetsBlue["$RADIO_3_05"],
                    [6]  = RadioPresetsBlue["$RADIO_3_06"],
                    [7]  = RadioPresetsBlue["$RADIO_3_07"],
                    [8]  = RadioPresetsBlue["$RADIO_3_08"],
                    [9]  = RadioPresetsBlue["$RADIO_3_09"],
                    [10] = RadioPresetsBlue["$RADIO_3_10"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --ARK-22 ADF (Range 0.15 to 1.75MHz)
            [2] =
            {
                ["modulations"] =
                {
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = 0.441,
                    [2]  = 0.442,
                    [3]  = 0.443,
                    [4]  = 0.444,
                    [5]  = 0.445,
                    [6]  = 0.446,
                    [7]  = 0.447,
                    [8]  = 0.448,
                    [9]  = 0.449,
                    [10] = 0.450,
                    [11] = 0.451,
                    [12] = 0.452,
                    [13] = 0.453,
                    [14] = 0.454,
                    [15] = 0.455,
                    [16] = 0.456,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["red Ka-50"] = {
        type = "Ka-50",
        coalition = "red",
        country = nil,

        ["Radio"] =
        {
            --FM without modulation selection box
            [1] =
            {
                ["modulations"] =
                {
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = RadioPresetsRed["$RADIO_3_01"],
                    [2]  = RadioPresetsRed["$RADIO_3_02"],
                    [3]  = RadioPresetsRed["$RADIO_3_03"],
                    [4]  = RadioPresetsRed["$RADIO_3_04"],
                    [5]  = RadioPresetsRed["$RADIO_3_05"],
                    [6]  = RadioPresetsRed["$RADIO_3_06"],
                    [7]  = RadioPresetsRed["$RADIO_3_07"],
                    [8]  = RadioPresetsRed["$RADIO_3_08"],
                    [9]  = RadioPresetsRed["$RADIO_3_09"],
                    [10] = RadioPresetsRed["$RADIO_3_10"],
                }, -- end of ["channels"]
            }, -- end of [1]
            --ARK-22 ADF (Range 0.15 to 1.75MHz)
            [2] =
            {
                ["modulations"] =
                {
                }, -- end of ["modulations"]
                ["channels"] =
                {
                    [1]  = 0.441,
                    [2]  = 0.442,
                    [3]  = 0.443,
                    [4]  = 0.444,
                    [5]  = 0.445,
                    [6]  = 0.446,
                    [7]  = 0.447,
                    [8]  = 0.448,
                    [9]  = 0.449,
                    [10] = 0.450,
                    [11] = 0.451,
                    [12] = 0.452,
                    [13] = 0.453,
                    [14] = 0.454,
                    [15] = 0.455,
                    [16] = 0.456,
                }, -- end of ["channels"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["blue Mi-8MT"] = {
        type = "Mi-8MT",
        coalition = "blue",
        country = nil,

        ["Radio"] = {
            --V/UHF without modulation selection box
            [1] = {
                ["channels"] = {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
            --FM without modulation selection box
            [2] = {
                ["channels"] = {
                    [1]  = RadioPresetsBlue["$RADIO_3_01"],
                    [2]  = RadioPresetsBlue["$RADIO_3_02"],
                    [3]  = RadioPresetsBlue["$RADIO_3_03"],
                    [4]  = RadioPresetsBlue["$RADIO_3_04"],
                    [5]  = RadioPresetsBlue["$RADIO_3_05"],
                    [6]  = RadioPresetsBlue["$RADIO_3_06"],
                    [7]  = RadioPresetsBlue["$RADIO_3_07"],
                    [8]  = RadioPresetsBlue["$RADIO_3_08"],
                    [9]  = RadioPresetsBlue["$RADIO_3_09"],
                    [10] = RadioPresetsBlue["$RADIO_3_10"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["red Mi-8MT"] = {
        type = "Mi-8MT",
        coalition = "red",
        country = nil,

        ["Radio"] = {
            --V/UHF without modulation selection box
            [1] = {
                ["channels"] = {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
            --FM without modulation selection box
            [2] = {
                ["channels"] = {
                    [1]  = RadioPresetsRed["$RADIO_3_01"],
                    [2]  = RadioPresetsRed["$RADIO_3_02"],
                    [3]  = RadioPresetsRed["$RADIO_3_03"],
                    [4]  = RadioPresetsRed["$RADIO_3_04"],
                    [5]  = RadioPresetsRed["$RADIO_3_05"],
                    [6]  = RadioPresetsRed["$RADIO_3_06"],
                    [7]  = RadioPresetsRed["$RADIO_3_07"],
                    [8]  = RadioPresetsRed["$RADIO_3_08"],
                    [9]  = RadioPresetsRed["$RADIO_3_09"],
                    [10] = RadioPresetsRed["$RADIO_3_10"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },
    
    ["blue Mi-24P"] = {
        type = "Mi-24P",
        coalition = "blue",
        country = nil,

        ["Radio"] = {
            --V/UHF without modulation selection box
            [1] = {
                ["channels"] = {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
            --FM without modulation selection box
            [2] = {
                ["channels"] = {
                    [1]  = RadioPresetsBlue["$RADIO_3_01"],
                    [2]  = RadioPresetsBlue["$RADIO_3_02"],
                    [3]  = RadioPresetsBlue["$RADIO_3_03"],
                    [4]  = RadioPresetsBlue["$RADIO_3_04"],
                    [5]  = RadioPresetsBlue["$RADIO_3_05"],
                    [6]  = RadioPresetsBlue["$RADIO_3_06"],
                    [7]  = RadioPresetsBlue["$RADIO_3_07"],
                    [8]  = RadioPresetsBlue["$RADIO_3_08"],
                    [9]  = RadioPresetsBlue["$RADIO_3_09"],
                    [10] = RadioPresetsBlue["$RADIO_3_10"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["red Mi-24P"] = {
        type = "Mi-24P",
        coalition = "red",
        country = nil,

        ["Radio"] = {
            --V/UHF without modulation selection box
            [1] = {
                ["channels"] = {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
            --FM without modulation selection box
            [2] = {
                ["channels"] = {
                    [1]  = RadioPresetsRed["$RADIO_3_01"],
                    [2]  = RadioPresetsRed["$RADIO_3_02"],
                    [3]  = RadioPresetsRed["$RADIO_3_03"],
                    [4]  = RadioPresetsRed["$RADIO_3_04"],
                    [5]  = RadioPresetsRed["$RADIO_3_05"],
                    [6]  = RadioPresetsRed["$RADIO_3_06"],
                    [7]  = RadioPresetsRed["$RADIO_3_07"],
                    [8]  = RadioPresetsRed["$RADIO_3_08"],
                    [9]  = RadioPresetsRed["$RADIO_3_09"],
                    [10] = RadioPresetsRed["$RADIO_3_10"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [2]
        }, -- end of ["Radio"]
    },

    ["blue UH-1H"] = {
        type = "UH-1H",
        coalition = "blue",
        country = nil,

        ["Radio"] = {
            --UHF without modulation selection box
            [1] = {
                ["channels"] = {
                    [1]  = RadioPresetsBlue["$RADIO_1_01"],
                    [2]  = RadioPresetsBlue["$RADIO_1_02"],
                    [3]  = RadioPresetsBlue["$RADIO_1_03"],
                    [4]  = RadioPresetsBlue["$RADIO_1_04"],
                    [5]  = RadioPresetsBlue["$RADIO_1_05"],
                    [6]  = RadioPresetsBlue["$RADIO_1_06"],
                    [7]  = RadioPresetsBlue["$RADIO_1_07"],
                    [8]  = RadioPresetsBlue["$RADIO_1_08"],
                    [9]  = RadioPresetsBlue["$RADIO_1_09"],
                    [10] = RadioPresetsBlue["$RADIO_1_10"],
                    [11] = RadioPresetsBlue["$RADIO_1_11"],
                    [12] = RadioPresetsBlue["$RADIO_1_12"],
                    [13] = RadioPresetsBlue["$RADIO_1_13"],
                    [14] = RadioPresetsBlue["$RADIO_1_14"],
                    [15] = RadioPresetsBlue["$RADIO_1_15"],
                    [16] = RadioPresetsBlue["$RADIO_1_16"],
                    [17] = RadioPresetsBlue["$RADIO_1_17"],
                    [18] = RadioPresetsBlue["$RADIO_1_18"],
                    [19] = RadioPresetsBlue["$RADIO_1_19"],
                    [20] = RadioPresetsBlue["$RADIO_1_20"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },

    ["red UH-1H"] = {
        type = "UH-1H",
        coalition = "red",
        country = nil,

        ["Radio"] = {
            --UHF without modulation selection box
            [1] = {
                ["channels"] = {
                    [1]  = RadioPresetsRed["$RADIO_1_01"],
                    [2]  = RadioPresetsRed["$RADIO_1_02"],
                    [3]  = RadioPresetsRed["$RADIO_1_03"],
                    [4]  = RadioPresetsRed["$RADIO_1_04"],
                    [5]  = RadioPresetsRed["$RADIO_1_05"],
                    [6]  = RadioPresetsRed["$RADIO_1_06"],
                    [7]  = RadioPresetsRed["$RADIO_1_07"],
                    [8]  = RadioPresetsRed["$RADIO_1_08"],
                    [9]  = RadioPresetsRed["$RADIO_1_09"],
                    [10] = RadioPresetsRed["$RADIO_1_10"],
                    [11] = RadioPresetsRed["$RADIO_1_11"],
                    [12] = RadioPresetsRed["$RADIO_1_12"],
                    [13] = RadioPresetsRed["$RADIO_1_13"],
                    [14] = RadioPresetsRed["$RADIO_1_14"],
                    [15] = RadioPresetsRed["$RADIO_1_15"],
                    [16] = RadioPresetsRed["$RADIO_1_16"],
                    [17] = RadioPresetsRed["$RADIO_1_17"],
                    [18] = RadioPresetsRed["$RADIO_1_18"],
                    [19] = RadioPresetsRed["$RADIO_1_19"],
                    [20] = RadioPresetsRed["$RADIO_1_20"],
                }, -- end of ["channels"]
                ["modulations"] = {
                }, -- end of ["modulations"]
            }, -- end of [1]
        }, -- end of ["Radio"]
    },
}

