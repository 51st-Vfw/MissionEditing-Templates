-- ************************************************************************************************************
--
-- globals_frameworks.lua: Globals for frameworks
--
-- This file defines globals that are used to setup frameworks or that must be defined before any framework
-- Lua is loaded (for example, the MAPSOP_Settings table for MapSOP configuration). As such, this file must
-- be the first framework file in ScriptSettings if it is used.
--
-- ************************************************************************************************************

env.info("*** Loading Framework Script: globals_frameworks.lua")

-- MAPSOP_Settings = { ["DisableATC"] = true }