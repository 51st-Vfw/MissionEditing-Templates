-- ************************************************************************************************************
--
-- options description file for base 51st vfw sop mission options
--
-- setup per: https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/images/51st_SOP_ME_Options.png
--
-- contains a single table OptionsData that has a table with the value of the ["forcedOptions"] key for the
-- .miz mission file. the contents for this file can be extracted from an existing .miz with the extract.cmd
-- script.
--
-- ************************************************************************************************************

OptionsData = {
    ["accidental_failures"] = false,
    ["birds"] = 0,
    ["cockpitStatusBarAllowed"] = false,
    ["cockpitVisualRM"] = false,
    ["easyCommunication"] = false,
    ["easyFlight"] = false,
    ["easyRadar"] = false,
    ["externalViews"] = true,
    ["fuel"] = false,
    ["geffect"] = "realistic",
    ["immortal"] = false,
    ["labels"] = 4,
    ["miniHUD"] = false,
    ["optionsView"] = "optview_myaircraft",
    ["padlock"] = false,
    ["permitCrash"] = true,
    ["radio"] = false,
    ["RBDAI"] = false,
    ["unrestrictedSATNAV"] = false,
    ["userMarks"] = false,
    ["wakeTurbulence"] = true,
    ["weapons"] = false,
} -- end of OptionsData
