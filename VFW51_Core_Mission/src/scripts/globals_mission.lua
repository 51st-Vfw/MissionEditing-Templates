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

-- V51UTIL.debugLogging = true

-- ------------------------------------------------------------------------------------------------------------
-- Constants
-- ------------------------------------------------------------------------------------------------------------

K_FT2M                      = 0.3048                            -- m per ft
K_NM2KM                     = 1.8520                            -- km per nm
K_NM2M                      = K_NM2KM * 1000.0                  -- m per nm
K_M2S                       = 60.0                              -- sec per min
K_KTS2KMPH                  = 1.0                               -- km/h per nm/h
K_RAD2DEG                   = 57.2957795                        -- degrees per radian

K_DIST_400K_1M              = 6.7                               -- nm travelled in 1m at 400Kt
K_DIST_450K_1M              = 7.5                               -- nm travelled in 1m at 450Kt
K_DIST_500K_1M              = 8.3                               -- nm travelled in 1m at 500Kt

COA_BLUE                    = coalition.side.BLUE
COA_RED                     = coalition.side.RED
