-- ************************************************************************************************************
--
-- options description file for 51st vfw development mission options
--
-- these options are intended for use in a "development" version of the mission. changes from the sop options
-- include: all objects visible, unrestricted satnav allowed, and battle damage assesement allowed.
--
-- contains a single table OptionsData that has a table with the value of the ["options"] key for the .miz
-- mission file. the contents for this file can be extracted from an existing .miz with the extract.cmd
-- script.
--
-- ************************************************************************************************************

OptionsData = {
    ["accidental_failures"] = false,
    ["birds"] = 0,
    ["civTraffic"] = "low",
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
    ["optionsView"] = "optview_all",
    ["padlock"] = false,
    ["permitCrash"] = true,
    ["radio"] = false,
    ["RBDAI"] = true,
    ["unrestrictedSATNAV"] = true,
    ["userMarks"] = false,
    ["wakeTurbulence"] = true,
    ["weapons"] = false,
} -- end of OptionsData
