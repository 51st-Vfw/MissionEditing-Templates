-- ************************************************************************************************************
--
-- globals_mission.lua: Globals for missions
--
-- This file defines globals that are used in mission-specific scripting or other initialization that must be
-- defined or handled before any mission Lua is loaded. As such, this file must be first mission file in
-- ScriptSettings if it is used.
--
-- ************************************************************************************************************

env.info("*** Loading Mission Script: globals_mission.lua")

-- BASE:TraceOnOff(true)
-- BASE:TraceAll(true)

-- ------------------------------------------------------------------------------------------------------------
-- Constants
-- ------------------------------------------------------------------------------------------------------------

K_FT2M                      = 0.3048                            -- m per ft
K_NM2KM                     = 1.8520                            -- km per nm
K_NM2M                      = K_NM2KM * 1000.0                  -- m per nm
K_M2S                       = 60.0                              -- sec per min
