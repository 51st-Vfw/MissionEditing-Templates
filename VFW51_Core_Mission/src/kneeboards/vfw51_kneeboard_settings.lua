-- ************************************************************************************************************
--
-- vfw51_kneeboard_settings.lua: kneeboard set up for mission
--
-- TODO: don't think there's a way to use different kneeboards for different coalitions...
--
-- the KboardSettings table is keyed by a kneeboard filename (from src/kneeboards) that will be placed in
-- the KNEEBOARD hierarchy in the final .miz file. the filename should be a .jpg or .png file.
--
-- a table with the following key/value pairs supplies the value for these keys,
--
--   "airframe" : <string>      specifies the airframe the kneeboard applies to. the value "all" or nil
--                              indicates the kneeboard is available to all airframes. values appropriate for
--                              51st vfw main airframes are: "AH-64D", "A-10C", "AV8BN", "F-14B", "F-16C_50",
--                              "FA-18C_hornet"
--   "transform" : <string>     specifies the shell command to invoke to transform the template into the
--                              final kneeboard file. within the transform string, the following substitutions
--                              will be made,
--                                  $_air   airframe from "airframe" key/value
--                                  $_mbd   mission base directory
--                                  $_src   source directory for kneeboard files src/kneeboards
--                                  $_dst   destination file path for final kneeboard
--                                  $<var>  value of the "$<var>" key in the table, quoted if it has spaces.
--                                          <var> may not start with "_"
--                              the value "none" or nil indicates that not transform is applied and the
--                              kneeboard file is simply copied from src/kneeboards into the KNEEBOARDS
--                              hierarchy.
--
-- ************************************************************************************************************

KboardSettings = {
    ["01_51st_SOP_Comms.png"] = { },
    ["02_51st_SOP_Comms_Presets.png"] = { },
--[[
    ["03_51st_F16C_Flight_Card.png"] = {
        ["airframe"] = "F-16C_50",
        ["transform"] = "lua54 VFW51KbFlightCardinator.lua $_air $_mbd\\src $_src\\Tmplt_51st_SOP_Card.svg $_dst $mission $flight $loadout $stpts",
        ["$mission"] = "Operation New Workflow",
        ["$flight"] = "VENOM, LOBO; SEAD/DEAD on Hama SA-10",
        ["$loadout"] = "Pilot's discretion",
        ["$stpts"] = "vfw51_stpts.lua"
    }
]]
}