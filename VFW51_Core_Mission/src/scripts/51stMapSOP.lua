-- 51st MapSOP
MAPSOP_VERSION = "20230205.1"
-- Initial version by Blackdog Jan 2022
--
-- Tested against MOOSE GITHUB Commit Hash ID:
-- 2023-02-04T22:34:14.0000000Z-57079e5104a7f43085a90a0887de1546132ae350
--
-- Version 20220101.1 - Blackdog initial version
-- Version 20220115.1 - Fix: Tanker speeds adjusted to be close KIAS from SOP + better starting altitudes.
-- Version 20220123.1 - Fix: Unit orbit endpoints longer offset from orbit endpoint zone locations.
--                    - Fix: Carriers/LHA now set their assigned radio frequencies.
--                    - Fix: Tankers/AWACs relief launched at 25-35% fuel instead of testing value of 80-90%.
--                    - Allow 'extra' Tankers/AWACS flights not in SOP to be spawned via Trigger Zones.
--                    - Allow limiting the number of Tankers/AWACS spawns per flight via -P1 Zone name parameters.
--                    - Allow override of SOP parameters via -P1 Zone name parameters.
--                    - Allow relative adjustment of SOP FL/Airspeed via -P1 Zone name parameters.
--                    - Allow setting Tanker/AWACS invisible via -P1 Zone name parameter.
--                    - IADS completely disabled if no group names with 'Red SAM'.
-- Version 20220213.1 - No carrier F10 menu without a carrier.
-- Version 20220221.1 - Package MOOSE devel from 2022-02-21 for DCS NTTR Airport name changes.
-- Version 20220227.1 - Add Carrier STC/TACAN/ICLS info to comms/F10 carrier menu.
-- Version 20220327.1 - Updated MOOSE version (updates for DCS changes)
--                    - Fix: Bug that may have prevented Red AWACS for operating as part of MANTIS IADS network.
--                    - Fix: Ensure parameter override inheritance consistent, and document this behavior.
--                    - Add 'GND' Zone name parameter to make AWACS/Tanker initially ground start.
--                    - Prevent 'auto' creation of Carrier AWACS/Tanker if -P2 zone with same name.
-- Version 20220526.1 - Multi-carrier support / new 51st carrier support unit SOPs.
--                    - Same info as Hornet carrier kneeboard for each carrier via F10 carrier control menu.
--                    - Support new carrier Link4/ALCS.
--                    - Carrier control F10 menu now "Blue Only" and new formatting.
--                    - Rescue helo for LHA.
--                    - Ground start (no air respawn) honored for 'GND' Zone parameter for carrier support units.
--                    - Create RedFor versions of non-carrier Tankers/AWACS via "RED-" prefix P1/P2 zones.
--                    - Carrier wind speed at 15M not 50M (replicating AIRBOSS fix in MOOSE).
-- Version 20220604.1 - Fix Magic5 AWACS (CVN-75).
--                    - Fix rescue helo for CVNs.
-- Version 20220611.1 - Force callsign resets every 5 minutes (possibly address apparent callsign bug).
-- Version 20220727.1 - Undo unsucessful change from 20220611.1
--                    - Fix 'All tankers Acro 1-1' bug by working around DCS issue.
--                    - Fix non-AWACS in AWACS radio menu.
--                    - Fix aircraft spawning without velocity; now spawn in at 350kts @ +5k ft of dest altitude.
--                    - Aircraft spawn offset a bit from their initial destination to smooth initial flight.
--                    - Tanker/AWACS speed now actually ~KIAS (changes w/ assigned altitude), table speeds adjusted.
--                    - After being relieved, AWACS/Tanker flights change their callsign number to '9' and get off freq.
--                    - Limited airframes become available to launch again ~1 hour after landing (maint/refueling).
--                    - Tested/included MOOSE version bump.
-- Version 20220915.1 - Option to use Zone properties instead of zone naming to set Tanker/AWACS SOP overrides.
--                    - Airbase ATC silenced by default, enabled by putting Airbase inside an 'Enable ATC' zone(s).
--                    - Server pause control.
--                    - AWACS/Tanker get to their orbits much faster when air spawned.
--                    - Changed 'off duty' Tanker/AWACS callsign flight number to -8 (instead of 9).
--                    - 'Off duty' Tankers use 58Y (Viper TACAN freezes if you turn a Tanker TACAN off).
--                    - Use new native MOOSE function for Link4 activation.
--                    - Tested/included MOOSE version bump.
-- Version 20220917.1 - Eliminated mysterious aircraft disappearances (remove MOOSE cleanup at SupportBase)
--                    - Greatly reduced naval rotary aviation accidents (only one helo spawn on carriers) 
-- Version 20221130.1 - Fixed 'Invisible' Tanker/AWACs setting.
--                    - Fixed tanker speed issue caused by MOOSE changes.
--                    - Fixed server pausing if clients still connected (even if they are observers).
--                    - Pausing feature disabled in single player.
--                    - Added 'Immortal' Tanker/AWACs setting.
--                    - Added declaration of multiple orbit tracks for each tanker/AWACs.
--                    - Added scheduled flight launches and orbit track changes.
--                    - F10 menu mission starts and track pushes.
--                    - Fixed F10 map unit callsign labels.
--                    - Deprecated 'zone name' SOP setting overrides in favor of Zone Properties.
--                    - Tested/included MOOSE version bump.
--                    - Added Mount Pleasant as default Support Base for South Atlantic map.
-- Version 20221211.1 - New 'MapSOP Settings' zone with global MapSOP setting properties.
--                    - Moved 'PauseAfter' property from 'Unpause Client' zone(s) to 'MapSOP Settings' as 'PauseTime'.
--                    - Added RespawnAir option for Tankers/AWACS relief flights to air spawn.
--                    - Added scripting only functions RemoveFlight() and ReAddFlight().
-- Version 20230125.1 - Updated to latest MOOSE devel branch (Text-to-Speech via MSRS/DCS-gRPC plugin!).
--                    - Starts DCS-gRPC if present (required for TTS, must be configured on server)
--                    - Tankers/AWACS use SRS TTS to report new track push / arrived on station (on TacCommon).
--                    - Carrier SRS TTS report when turning into wind / return to initial course (Carrier ATC freq).
--                    - Option to set MapSOP Settings by global 'MAPSOP_Settings' table variable.
--                    - Added 'PrefixRedSAM', 'PrefixRedEWR', and 'PrefixRedAWACS' to 'MapSOP Settings' zone options.
--                    - Added 'UseSRS' and 'TacCommon' as a 'MapSOP Settings' zone option for TTS reports.
--                    - Added 'UseSubMenu' option to 'MapSOP Settings' that puts MapSOP F10 menus in own sub-menu.
--                    - Added 'DisableATC' option to 'MapSOP Settings' to disable all AI ATC (defaults to disabled)
--                    - Added 'Disable ATC' zones to enable AI ATC at airbases when DisableATC option is 'false'.
--                    - Arco-2 is now 'low and slow' KC-130 per SOP change.
--                    - Fixed a potential 'PauseTime' related Lua error.
--                    - Fixed a potential 'Support Base' / 'Red Support Base' related Lua error.
--                    - Improved documentation (readme.md)
-- Version 20230205.1 - Fixed PauseTime related 'nil' error.

--                    
-- Known issues/limitations:
--   - A paused server will not unpause unless a client enters a (valid) aircraft slot.
--   - Extra Non-SOP Shell/Magic units act like land-based Tankers/AWACS.
--   - Off-duty tankers/AWACS show up in radio menu under -8 callsigns.
--   - ACLS does not work for CVN-70 (USS Carl Vincent, apparently not a 'real' DCS SuperCarrier).

env.info("=== Loading 51stMapSOP v" .. MAPSOP_VERSION .. " ===")

ENUMS.CallsignString={}
ENUMS.CallsignString["Aircraft"]={}
ENUMS.CallsignString["AWACS"]={}
ENUMS.CallsignString["Tanker"]={}

ENUMS.CallsignString["Aircraft"][1]="Enfield"
ENUMS.CallsignString["Aircraft"][2]="Springfield"
ENUMS.CallsignString["Aircraft"][3]="Uzi"
ENUMS.CallsignString["Aircraft"][4]="Colt"
ENUMS.CallsignString["Aircraft"][5]="Dodge"
ENUMS.CallsignString["Aircraft"][6]="Ford"
ENUMS.CallsignString["Aircraft"][7]="Chevy"
ENUMS.CallsignString["Aircraft"][8]="Pontiac"
ENUMS.CallsignString["Aircraft"][9]="Hawg"
ENUMS.CallsignString["Aircraft"][10]="Boar"
ENUMS.CallsignString["Aircraft"][11]="Pig"
ENUMS.CallsignString["Aircraft"][12]="Tusk"
ENUMS.CallsignString["Helicopter"] = ENUMS.CallsignString["Aircraft"]

ENUMS.CallsignString["AWACS"][1]="Overlord"
ENUMS.CallsignString["AWACS"][2]="Magic"
ENUMS.CallsignString["AWACS"][3]="Wizard"
ENUMS.CallsignString["AWACS"][4]="Focus"
ENUMS.CallsignString["AWACS"][5]="Darkstar"

ENUMS.CallsignString["Tanker"][1]="Texaco"
ENUMS.CallsignString["Tanker"][2]="Arco"
ENUMS.CallsignString["Tanker"][3]="Shell"

ENUMS.UnitType = {
    AIRCRAFT     = "Aircraft",
    TANKER       = "Tanker",
    AWACS        = "AWACS",
    FARP         = "FARP",
    JTAC         = "JTAC",
    SHIP         = "Ship",
    HELICOPTER   = "Helicopter"
}

ENUMS.TacanBand = {
    X = "X",
    Y = "Y"
}

-- 0=Unit.RefuelingSystem.BOOM_AND_RECEPTACLE`, `1=Unit.RefuelingSystem.PROBE_AND_DROGUE
ENUMS.RefuelingSystem = {
    BOOM =  0,  --  Unit.RefuelingSystem.BOOM_AND_RECEPTACLE
    PROBE = 1   --  Unit.RefuelingSystem.PROBE_AND_DROGUE
}

ENUMS.SupportUnitTemplateFields = {
    UNITTYPE    = 1,
    FUEL        = 2,
    FLARE       = 3,
    CHAFF       = 4,
    GUNS        = 5
}

-- Loadouts for different support aircraft
ENUMS.SupportUnitTemplate = {
    --                UNITTYPE, FUEL, FLARE, CHAFF, GUNS
    BOOMTANKER  =   { "KC-135",         90700, 60, 120, 100 },
    PROBETANKER =   { "KC135MPRS",      90700, 60, 120, 100 },
    KC130TANKER  =  { "KC130",          30000, 60, 120, 100 },
    NAVYTANKER  =   { "S-3B Tanker",     7813, 30,  30, 100 },
    NAVYAWACS   =   { "E-2C",            5624, 30,  30, 100 },
    AWACS       =   { "E-3A",           65000, 60, 120, 100 },
    RESCUEHELO  =   { "SH-60B",          1100, 30,  30, 100 }
}

ENUMS.SupportUnitFields = {
    CALLSIGN        =   1,  -- CALLSIGN.AWACS.Texaco
    CALLSIGN_NUM    =   2,  -- 1 -- ie, Texaco-1
    TYPE            =   3,  -- ENUMS.UnitType.TANKER
    RADIOFREQ       =   4,  -- 251.00 -- Number radio frequency in MHz
    TACANCHAN       =   5,  -- 51 -- Number
    TACANBAND       =   6,  -- ENUMS.TacanBand.Y
    TACANMORSE      =   7,  -- "TX1" -- TACAN morse code callsign string
    ICLSCHAN        =   8,  -- 11 -- ICLS channel -- Number (Carrier)
    ICLSMORSE       =   9,  -- "HST" -- ICLS morse code callsign string
    LINK4FREQ       =   10, -- "270.2" -- Number LINK4 frequency in MHz
    ALTITUDE        =   11, -- 25000 -- Number in feet
    SPEED           =   12, -- 250 -- Number in knots
    MODEX           =   13, -- 511 -- Number -- Board number, etc.
    REFUELINGSYSTEM =   14, -- ENUMS.RefuelingSystem.BOOM -- Tanker refueling system
    GROUNDSTART     =   15, -- false -- whether to takeoff from the gound (and no airspawn for carrier units)
    TEMPLATE        =   16, -- ENUMS.SupportUnitTemplate.BOOMTANKER -- Unit template type
    PUSHTIME        =   17, -- 300 -- Seconds after start to autopush track. Default/'SOP' is always nil.
                            --        nil = Autostart default/initial track at mission start,
                            --              never autopush other tracks (menu push only).
                            --        0/  = Do not autostart default/initial track,
                            --              never autopush other tracks (menu push only).
    RESPAWNAIR      =   18  -- false -- whether to spawn relief flights in the air.
}

ENUMS.GoogleVoices = {
  "en-US-Wavenet-A",
  "en-US-Wavenet-B",
  "en-US-Wavenet-C",
  "en-US-Wavenet-D",
  "en-US-Wavenet-E",
  "en-US-Wavenet-F",
  "en-US-Wavenet-G",
  "en-US-Wavenet-H",
  "en-US-Wavenet-I",
  "en-US-Wavenet-J",
  "en-US-Neural2-A",
  "en-US-Neural2-C",
  "en-US-Neural2-D",
  "en-US-Neural2-E",
  "en-US-Neural2-F",
  "en-US-Neural2-G",
  "en-US-Neural2-H",
  "en-US-Neural2-I",
  "en-US-Neural2-J",
  "en-US-News-K",
  "en-US-News-L",
  "en-US-News-M",
  "en-US-News-N",
}

ENUMS.WinVoices = {
  "David",
  "Mark",
  "Zira"
}

local SUPPORTUNITS = {}
SUPPORTUNITS["_"] = {}

-- Set according to 51st SOPs: https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/missionsEditingSOPs.md
-- CALLSIGN, CALLSIGN_NUM, TYPE, RADIOFREQ, TACANCHAN, TACANBAND, TACANMORSE, ICLSCHAN, ICLSMORSE, LINK4FREQ, ALTITUDE, SPEED, MODEX, REFUELINGSYSTEM, GROUNDSTART, TEMPLATE

-- Tankers
SUPPORTUNITS["_"][ "Texaco1" ] = { CALLSIGN.Tanker.Texaco,  1, ENUMS.UnitType.TANKER,  251.00, 51, ENUMS.TacanBand.Y, "TX1", nil, nil, nil, 25000, 300, 251, ENUMS.RefuelingSystem.BOOM,  false, ENUMS.SupportUnitTemplate.BOOMTANKER }
SUPPORTUNITS["_"][ "Texaco2" ] = { CALLSIGN.Tanker.Texaco,  2, ENUMS.UnitType.TANKER,  252.00, 52, ENUMS.TacanBand.Y, "TX2", nil, nil, nil, 15000, 220, 252, ENUMS.RefuelingSystem.BOOM,  false, ENUMS.SupportUnitTemplate.BOOMTANKER }
SUPPORTUNITS["_"][ "Arco1" ]   = { CALLSIGN.Tanker.Arco,    1, ENUMS.UnitType.TANKER,  253.00, 53, ENUMS.TacanBand.Y, "AR1", nil, nil, nil, 20000, 285, 253, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.PROBETANKER }
SUPPORTUNITS["_"][ "Arco2" ]   = { CALLSIGN.Tanker.Arco,    2, ENUMS.UnitType.TANKER,  254.00, 54, ENUMS.TacanBand.Y, "AR2", nil, nil, nil, 17000, 240, 254, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.KC130TANKER }
-- Tankers for each CVN
SUPPORTUNITS["_"][ "Shell9" ] =  { CALLSIGN.Tanker.Shell,   9, ENUMS.UnitType.TANKER,  270.80, 120, ENUMS.TacanBand.Y, "SH9", nil, nil, nil, 6000, 285, 220, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.NAVYTANKER }
SUPPORTUNITS["_"][ "Shell1" ]  = { CALLSIGN.Tanker.Shell,   1, ENUMS.UnitType.TANKER,  271.80, 121, ENUMS.TacanBand.Y, "SH1", nil, nil, nil, 6000, 285, 221, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.NAVYTANKER }
SUPPORTUNITS["_"][ "Shell2" ]  = { CALLSIGN.Tanker.Shell,   2, ENUMS.UnitType.TANKER,  272.80, 122, ENUMS.TacanBand.Y, "SH2", nil, nil, nil, 6000, 285, 222, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.NAVYTANKER }
SUPPORTUNITS["_"][ "Shell3" ]  = { CALLSIGN.Tanker.Shell,   3, ENUMS.UnitType.TANKER,  273.80, 123, ENUMS.TacanBand.Y, "SH3", nil, nil, nil, 6000, 285, 223, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.NAVYTANKER }
SUPPORTUNITS["_"][ "Shell4" ]  = { CALLSIGN.Tanker.Shell,   4, ENUMS.UnitType.TANKER,  274.80, 124, ENUMS.TacanBand.Y, "SH4", nil, nil, nil, 6000, 285, 224, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.NAVYTANKER }
SUPPORTUNITS["_"][ "Shell5" ]  = { CALLSIGN.Tanker.Shell,   5, ENUMS.UnitType.TANKER,  275.80, 125, ENUMS.TacanBand.Y, "SH5", nil, nil, nil, 6000, 285, 225, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.NAVYTANKER }

-- AWACS
SUPPORTUNITS["_"][ "Overlord1" ] = { CALLSIGN.AWACS.Overlord,    1, ENUMS.UnitType.AWACS,  240.00, nil, nil, nil, nil, nil, nil, 30000, 310, 240, nil, false, ENUMS.SupportUnitTemplate.AWACS }
-- AWACS for each CVN
SUPPORTUNITS["_"][ "Magic9" ]   =  { CALLSIGN.AWACS.Magic,       9, ENUMS.UnitType.AWACS,  270.60, nil, nil, nil, nil, nil, nil, 25000, 259, 240, nil, false, ENUMS.SupportUnitTemplate.NAVYAWACS }
SUPPORTUNITS["_"][ "Magic1" ]    = { CALLSIGN.AWACS.Magic,       1, ENUMS.UnitType.AWACS,  271.60, nil, nil, nil, nil, nil, nil, 25000, 259, 241, nil, false, ENUMS.SupportUnitTemplate.NAVYAWACS }
SUPPORTUNITS["_"][ "Magic2" ]    = { CALLSIGN.AWACS.Magic,       2, ENUMS.UnitType.AWACS,  272.60, nil, nil, nil, nil, nil, nil, 25000, 259, 242, nil, false, ENUMS.SupportUnitTemplate.NAVYAWACS }
SUPPORTUNITS["_"][ "Magic3" ]    = { CALLSIGN.AWACS.Magic,       3, ENUMS.UnitType.AWACS,  273.60, nil, nil, nil, nil, nil, nil, 25000, 259, 243, nil, false, ENUMS.SupportUnitTemplate.NAVYAWACS }
SUPPORTUNITS["_"][ "Magic4" ]    = { CALLSIGN.AWACS.Magic,       4, ENUMS.UnitType.AWACS,  274.60, nil, nil, nil, nil, nil, nil, 25000, 259, 244, nil, false, ENUMS.SupportUnitTemplate.NAVYAWACS }
SUPPORTUNITS["_"][ "Magic5" ]    = { CALLSIGN.AWACS.Magic,       5, ENUMS.UnitType.AWACS,  275.60, nil, nil, nil, nil, nil, nil, 25000, 259, 245, nil, false, ENUMS.SupportUnitTemplate.NAVYAWACS }

-- Navy
SUPPORTUNITS["_"][ "LHA-1"  ] = { "Proud Eagle" , nil, ENUMS.UnitType.SHIP,  264.40, 64, ENUMS.TacanBand.X, "TAR", 1,   "TAR", nil,    nil, nil, 264, nil, false, nil }
SUPPORTUNITS["_"][ "CVN-70" ] = { "Gold Eagle"  , nil, ENUMS.UnitType.SHIP,  270.40, 70, ENUMS.TacanBand.X, "CVN", 10,  "CVN", 270.20, nil, nil, 270, nil, false, nil }
SUPPORTUNITS["_"][ "CVN-71" ] = { "Rough Rider" , nil, ENUMS.UnitType.SHIP,  271.40, 71, ENUMS.TacanBand.X, "TDY", 11,  "TDY", 271.20, nil, nil, 271, nil, false, nil }
SUPPORTUNITS["_"][ "CVN-72" ] = { "Union"       , nil, ENUMS.UnitType.SHIP,  272.40, 72, ENUMS.TacanBand.X, "ABE", 12,  "ABE", 272.20, nil, nil, 272, nil, false, nil }
SUPPORTUNITS["_"][ "CVN-73" ] = { "Warfighter"  , nil, ENUMS.UnitType.SHIP,  273.40, 73, ENUMS.TacanBand.X, "WSH", 13,  "WSH", 273.20, nil, nil, 273, nil, false, nil }
SUPPORTUNITS["_"][ "CVN-74" ] = { "Courage"     , nil, ENUMS.UnitType.SHIP,  274.40, 74, ENUMS.TacanBand.X, "STN", 14,  "STN", 274.20, nil, nil, 274, nil, false, nil }
SUPPORTUNITS["_"][ "CVN-75" ] = { "Lone Warrior", nil, ENUMS.UnitType.SHIP,  275.40, 75, ENUMS.TacanBand.X, "TRU", 15,  "TRU", 275.20, nil, nil, 275, nil, false, nil }

-- Rescue Helo
SUPPORTUNITS["_"][ "CSAR1" ] = { CALLSIGN.Aircraft.Pontiac , 8, ENUMS.UnitType.HELICOPTER, nil, nil, nil, nil, nil, nil, nil, nil, nil, 265, nil, false, ENUMS.SupportUnitTemplate.RESCUEHELO }

local BASESUPPORTUNITS = routines.utils.deepCopy(SUPPORTUNITS)

local MAPSOPSETTINGS = {}
MAPSOPSETTINGS.Defaults = {}
MAPSOPSETTINGS.Defaults.PauseTime      = 30
MAPSOPSETTINGS.Defaults.TacCommon      = 270.0
MAPSOPSETTINGS.Defaults.UseSRS         = "win"
MAPSOPSETTINGS.Defaults.PrefixRedSAM   = "Red SAM"
MAPSOPSETTINGS.Defaults.PrefixRedEWR   = "Red EWR"
MAPSOPSETTINGS.Defaults.PrefixRedAWACS = "Red AWACS"
MAPSOPSETTINGS.Defaults.UseSubMenu     = false
MAPSOPSETTINGS.Defaults.DisableATC     = true

CURRENTUNITTRACK = {}

local SupportBeacons = {}

-- If no "Support Airbase" exists, then use a default airbase for each map
local DEFAULTSUPPORTAIRBASES = { 
    AIRBASE.Caucasus.Batumi,
    AIRBASE.Nevada.Nellis_AFB,
    AIRBASE.PersianGulf.Al_Dhafra_AB,
    AIRBASE.Syria.Incirlik,
    AIRBASE.MarianaIslands.Andersen_AFB,
    AIRBASE.SouthAtlantic.Mount_Pleasant
}

function TEMPLATE.SetPayload(Template, Fuel, Flare, Chaff, Gun, Pylons, UnitNum)
    Template["units"][UnitNum or 1]["payload"]["fuel"] = tostring(Fuel or 0)
    Template["units"][UnitNum or 1]["payload"]["flare"] = Flare or 0
    Template["units"][UnitNum or 1]["payload"]["chaff"] = Chaff or 0
    Template["units"][UnitNum or 1]["payload"]["gun"] = Gun or 0
    Template["units"][UnitNum or 1]["payload"]["pylons"] = Pylons or {}
    return Template
end

-- Init MapSOP Settings
local MapSopSettingsZone = ZONE:FindByName("MapSOP Settings")

-- Allow 'MAPSOP_Settings' to be set via Lua before MapSOP
MAPSOP_Settings = MAPSOP_Settings or {}

for setting, value in pairs(MAPSOPSETTINGS.Defaults) do
  MAPSOPSETTINGS[setting] = value
end

for setting, value in pairs(MAPSOP_Settings) do
  MAPSOPSETTINGS[setting] = value
end

if MapSopSettingsZone then
  for setting, value in pairs(MapSopSettingsZone:GetAllProperties()) do
    MAPSOPSETTINGS[setting] = value
  end
end

for setting,value in pairs(MAPSOPSETTINGS) do
  if type(value) == 'string' and string.lower(value) == 'sop' then
    MAPSOPSETTINGS[setting] = MAPSOPSETTINGS.Defaults[setting]
  end
  if setting == "UseSRS" then
    MAPSOPSETTINGS.UseSRS = string.lower(value)
  end
  if type(value) == 'string' and string.lower(value) == 'false' then
    MAPSOPSETTINGS[setting] = false
  end
  if setting == 'TacCommon' or setting == 'PauseTime' then
    MAPSOPSETTINGS[setting] = tonumber(value)
  end
end

for setting,value in pairs(MAPSOPSETTINGS.Defaults) do
  if not MAPSOPSETTINGS[setting] then
    MAPSOPSETTINGS[setting] = value
  end
end

-- Initialize Menus
local BlueParentMenu
local RedParentMenu

-- Parent MapSOP menu if enabled
if MAPSOPSETTINGS.UseSubMenu then
  BlueParentMenu = MENU_COALITION:New(coalition.side.BLUE, "MapSOP Controls")
  RedParentMenu = MENU_COALITION:New(coalition.side.RED, "MapSOP Controls")
end

-- Tanker / AWACS menus
local TankerMenu = MENU_COALITION:New(coalition.side.BLUE, "Tanker Control", BlueParentMenu)
local AWACSMenu = MENU_COALITION:New(coalition.side.BLUE, "AWACS Control", BlueParentMenu)
local RedTankerMenu = MENU_COALITION:New(coalition.side.RED, "Tanker Control", RedParentMenu)
local RedAWACSMenu = MENU_COALITION:New(coalition.side.RED, "AWACS Control", RedParentMenu)
local CarrierMenu = nil

-- Initialize Text-to-Speech
local SpeechVoices, AllSpeechVoices
if GRPC and MAPSOPSETTINGS.UseSRS then
  BASE:I("MapSOP: Enabling DCS-gRPC for Text-to-Speech.")
  -- If DCS-gRPC is present, make sure it is loaded.
  if GRPC then
    GRPC.load()
  end

  MSRS.SetDefaultBackendGRPC()

  if not VFW51ST_TACCOMMON_msrs then
    VFW51ST_TACCOMMON_msrs = MSRS:New('', MAPSOPSETTINGS.TacCommon)
  end
  VFW51ST_TACCOMMON_msrs:SetLabel("MapSOP")
  if MAPSOPSETTINGS.UseSRS == 'gcloud' or MAPSOPSETTINGS.UseSRS == 'google' then
    VFW51ST_TACCOMMON_msrs:SetGoogle()
    AllSpeechVoices = ENUMS.GoogleVoices
  else
    VFW51ST_TACCOMMON_msrs:SetWin()
    AllSpeechVoices = ENUMS.WinVoices
  end
  SpeechVoices = UTILS.DeepCopy(AllSpeechVoices)

  if not VFW51ST_TACCOMMON_msrsQ then
    VFW51ST_TACCOMMON_msrsQ = MSRSQUEUE:New("Support Units")
  end
  VFW51ST_TACCOMMON_msrsQ:SetTransmitOnlyWithPlayers(true)
else
  BASE:I("MapSOP: Not using Text-to-Speech.")
end

-- time hh:mm:ss mm:ss :ss or ss -- returns seconds in integers
function time2sec( time )

  local timestring = time or 0
 
  local _, count = string.gsub(timestring, ":", "")
  local pattern, h, m, s, _
 
  if count == 2 then
    pattern="(%d+):(%d+):(%d+)"
    _, _, h, m, s = string.find(timestring, pattern)
  elseif count == 1 then
    pattern="(%d+):(%d+)"
    _, _, m, s = string.find(timestring, pattern)
  else
    pattern="(%d+)"
    _, _, s = string.find(timestring, pattern)
  end
  h = h or 0
  m = m or 0
  s = s or 0
  
  return (h * 60 * 60) + (m * 60) + s
 end

-- Seconds to mm:ss or hh:mm:ss
function sec2time(time)
  local hours = math.floor(math.fmod(time, 86400)/3600)
  local minutes = math.floor(math.fmod(time,3600)/60)
  local seconds = math.floor(math.fmod(time,60))
  if hours > 0 then
    return string.format("%02d:%02d:%02d",hours,minutes,seconds)
  else
    return string.format("%02d:%02d",minutes,seconds)
  end
end

function ServerPause()
  net.dostring_in("gui", "DCS.setPause( DCS.isMultiplayer() )")
end

function ServerPauseIfEmpty()
  net.dostring_in("gui", "DCS.setPause( ( #net.get_player_list() < 2) and DCS.isMultiplayer() )")
end

function ServerUnpause()
  net.dostring_in("gui", "return DCS.setPause(false)")
end

function UpdateFlightMenu(TrackFlight, track, oldtrack)
  -- oldtrack only passed when attempting a change, not for init
  if oldtrack == track then
    return false
  end

  local TrackFlightValues = SUPPORTUNITS[track][TrackFlight]
  local menu = nil
  local side = coalition.side.BLUE

  if string.find(TrackFlight, "^RED%-") then
    side = coalition.side.RED
  end

  if TrackFlightValues[ENUMS.SupportUnitFields.TYPE] == ENUMS.UnitType.TANKER then
    if side == coalition.side.RED then
      menu = RedTankerMenu
    else
      menu = TankerMenu
    end
  elseif TrackFlightValues[ENUMS.SupportUnitFields.TYPE] == ENUMS.UnitType.AWACS then
    if side == coalition.side.RED then
      menu = RedAWACSMenu
    else
      menu = AWACSMenu
    end
  end

  if menu then
    local TrackText = "Default"
    local OldTrackText = "Default"
    if track and track ~= "_" then
      TrackText = track
    end
    if oldtrack and oldtrack ~= "_" then
      OldTrackText = oldtrack
    end

    local MenuString = "Push track \"" .. TrackText .. "\""
    local OldMenuString = " Push track \"" .. OldTrackText .. "\""

    -- Note: If oldtrack is set and we're this far, this is a track change
    if oldtrack and SUPPORTUNITS[track][TrackFlight].PushSchedule then
      SUPPORTUNITS[track][TrackFlight].PushSchedule:Stop()
      SUPPORTUNITS[track][TrackFlight][ ENUMS.SupportUnitFields.PUSHTIME ] = nil
    end
    
    if oldtrack or (track == CURRENTUNITTRACK[TrackFlight]) then
      MenuString = "<" .. MenuString .. ">"
    else
      MenuString = " " .. MenuString
      if SUPPORTUNITS[track][ TrackFlight ][ ENUMS.SupportUnitFields.PUSHTIME ] and
          SUPPORTUNITS[track][ TrackFlight ][ ENUMS.SupportUnitFields.PUSHTIME ] > 0 then
        local timestring = SUPPORTUNITS[track][ TrackFlight ][ ENUMS.SupportUnitFields.PUSHTIME ]
        MenuString = MenuString .. " " .. "(" .. sec2time(timestring) .. ")"
      end
    end

    local spawngroup
    if SUPPORTUNITS["_"][TrackFlight].PreviousMission
        and SUPPORTUNITS["_"][TrackFlight].PreviousMission.flightgroup
        and SUPPORTUNITS["_"][TrackFlight].PreviousMission.flightgroup:GetGroup() then
          spawngroup = SUPPORTUNITS["_"][TrackFlight].PreviousMission.flightgroup:GetGroup()
    else
      spawngroup = nil
    end

    if SUPPORTUNITS["_"][TrackFlight].FlightMenu == nil then
      SUPPORTUNITS["_"][TrackFlight].FlightMenu = MENU_COALITION:New( side, TrackFlight, menu )
    end

    if oldtrack then
      if SUPPORTUNITS[oldtrack][TrackFlight].Menu then
        SUPPORTUNITS[oldtrack][TrackFlight].Menu:Remove()
      end
      SUPPORTUNITS[oldtrack][TrackFlight].Menu =
        MENU_COALITION_COMMAND:New(side, OldMenuString, SUPPORTUNITS["_"][TrackFlight].FlightMenu, ManageFlights, spawngroup, TrackFlight, oldtrack )
    end

    if SUPPORTUNITS[track][TrackFlight].Menu then
      SUPPORTUNITS[track][TrackFlight].Menu:Remove() 
    end

    SUPPORTUNITS[track][TrackFlight].Menu =
      MENU_COALITION_COMMAND:New(side, MenuString, SUPPORTUNITS["_"][TrackFlight].FlightMenu, ManageFlights, spawngroup, TrackFlight, track )

    -- Enables flight spawning if not already
    if SUPPORTUNITS["_"][TrackFlight].Scheduler and CURRENTUNITTRACK[TrackFlight] then
      SUPPORTUNITS["_"][TrackFlight].Scheduler:Start()
    end
  
    return true
  end

  BASE:E("Failed to update menu for " .. TrackFlight .. " track " .. track)
  return false
end

function ChangeTemplateCallsign(Template, CallsignName, CallsignGroup, CallsignNameString)

  if not Template or not Template.units or not Template.units[1].callsign then
      return nil
  end

  local callsign1 = CallsignName or nil
  local callsign2 = CallsignGroup or nil

  Template.KeepCallsigns = true

  for unit,_ in ipairs(Template.units) do
      local callsign3 = Template.units[unit].callsign[3]
      Template.units[1].callsign = 
                      {
                          [1] = callsign1,
                          [2] = callsign2,
                          [3] = callsign3,
                          ["name"] = CallsignNameString .. callsign2 .. callsign3,
                      }
  end

  return Template
end

-- Overriding MOOSE function to hack callsign behavior
-- If SPAWN.KeepCallsigns is set to true, then retain template callsigns
--- Prepares the new Group Template.
-- @param #SPAWN self
-- @param #string SpawnTemplatePrefix
-- @param #number SpawnIndex
-- @return #SPAWN self
--- Prepares the new Group Template.
-- @param #SPAWN self
-- @param #string SpawnTemplatePrefix
-- @param #number SpawnIndex
-- @return #SPAWN self
function SPAWN:_Prepare( SpawnTemplatePrefix, SpawnIndex ) -- R2.2
  self:F( { self.SpawnTemplatePrefix, self.SpawnAliasPrefix } )

  --  if not self.SpawnTemplate then
  --    self.SpawnTemplate = self:_GetTemplate( SpawnTemplatePrefix )
  --  end

  local SpawnTemplate
  if self.TweakedTemplate ~= nil and self.TweakedTemplate == true then
    --BASE:I( "WARNING: You are using a tweaked template." )
    SpawnTemplate = self.SpawnTemplate
  else
    SpawnTemplate = self:_GetTemplate( SpawnTemplatePrefix )
    SpawnTemplate.name = self:SpawnGroupName( SpawnIndex )
  end

  SpawnTemplate.groupId = nil
  -- SpawnTemplate.lateActivation = false
  SpawnTemplate.lateActivation = self.LateActivated or false

  if SpawnTemplate.CategoryID == Group.Category.GROUND then
    self:T3( "For ground units, visible needs to be false..." )
    SpawnTemplate.visible = false
  end

  if self.SpawnGrouping then
    local UnitAmount = #SpawnTemplate.units
    self:F( { UnitAmount = UnitAmount, SpawnGrouping = self.SpawnGrouping } )
    if UnitAmount > self.SpawnGrouping then
      for UnitID = self.SpawnGrouping + 1, UnitAmount do
        SpawnTemplate.units[UnitID] = nil
      end
    else
      if UnitAmount < self.SpawnGrouping then
        for UnitID = UnitAmount + 1, self.SpawnGrouping do
          SpawnTemplate.units[UnitID] = UTILS.DeepCopy( SpawnTemplate.units[1] )
          SpawnTemplate.units[UnitID].unitId = nil
        end
      end
    end
  end

  if self.SpawnInitKeepUnitNames == false then
    for UnitID = 1, #SpawnTemplate.units do
      SpawnTemplate.units[UnitID].name = string.format( SpawnTemplate.name .. '-%02d', UnitID )
      SpawnTemplate.units[UnitID].unitId = nil
    end
  else
    for UnitID = 1, #SpawnTemplate.units do
      local UnitPrefix, Rest = string.match( SpawnTemplate.units[UnitID].name, "^([^#]+)#?" ):gsub( "^%s*(.-)%s*$", "%1" )
      self:T( { UnitPrefix, Rest } )

      SpawnTemplate.units[UnitID].name = string.format( '%s#%03d-%02d', UnitPrefix, SpawnIndex, UnitID )
      SpawnTemplate.units[UnitID].unitId = nil
    end
  end

  -- Callsign
  for UnitID = 1, #SpawnTemplate.units do
    local Callsign = SpawnTemplate.units[UnitID].callsign
    if Callsign then
      if not SpawnTemplate.KeepCallsigns then --MapSOP
        if type( Callsign ) ~= "number" then -- blue callsign
          Callsign[2] = ((SpawnIndex - 1) % 10) + 1
          local CallsignName = SpawnTemplate.units[UnitID].callsign["name"] -- #string
          CallsignName = string.match(CallsignName,"^(%a+)") -- 2.8 - only the part w/o numbers
          local CallsignLen = CallsignName:len()
          SpawnTemplate.units[UnitID].callsign["name"] = CallsignName:sub( 1, CallsignLen ) .. SpawnTemplate.units[UnitID].callsign[2] .. SpawnTemplate.units[UnitID].callsign[3]
        else
          SpawnTemplate.units[UnitID].callsign = Callsign + SpawnIndex
        end
      end -- MapSOP
    end
  end

  self:T3( { "Template:", SpawnTemplate } )
  return SpawnTemplate

end

--- Overriding MOOSE function to make less log spammy.
--- Create a new BEACON Object. This doesn't activate the beacon, though, use @{#BEACON.ActivateTACAN} etc.
-- If you want to create a BEACON, you probably should use @{Wrapper.Positionable#POSITIONABLE.GetBeacon}() instead.
-- @param #BEACON self
-- @param Wrapper.Positionable#POSITIONABLE Positionable The @{Wrapper.Positionable} that will receive radio capabilities.
-- @return #BEACON Beacon object or #nil if the positionable is invalid.
function BEACON:New(Positionable)

  -- Inherit BASE.
  local self=BASE:Inherit(self, BASE:New()) --#BEACON

  -- Debug.
  self:F(Positionable)

  -- Set positionable.
  if Positionable:GetPointVec2() then -- It's stupid, but the only way I found to make sure positionable is valid
    self.Positionable = Positionable
    self.name=Positionable:GetName()
    self:F(string.format("New BEACON %s", tostring(self.name)))
    return self
  end

  self:E({"The passed positionable is invalid, no BEACON created", Positionable})
  return nil
end

--- Overriding MOOSE function to make less log spammy.
--- Activates a TACAN BEACON.
-- @param #BEACON self
-- @param #number Channel TACAN channel, i.e. the "10" part in "10Y".
-- @param #string Mode TACAN mode, i.e. the "Y" part in "10Y".
-- @param #string Message The Message that is going to be coded in Morse and broadcasted by the beacon.
-- @param #boolean Bearing If true, beacon provides bearing information. If false (or nil), only distance information is available.
-- @param #number Duration How long will the beacon last in seconds. Omit for forever.
-- @return #BEACON self
-- @usage
-- -- Let's create a TACAN Beacon for a tanker
-- local myUnit = UNIT:FindByName("MyUnit") 
-- local myBeacon = myUnit:GetBeacon() -- Creates the beacon
-- 
-- myBeacon:ActivateTACAN(20, "Y", "TEXACO", true) -- Activate the beacon
function BEACON:ActivateTACAN(Channel, Mode, Message, Bearing, Duration)
  self:T({channel=Channel, mode=Mode, callsign=Message, bearing=Bearing, duration=Duration})

  Mode=Mode or "Y"

  -- Get frequency.
  local Frequency=UTILS.TACANToFrequency(Channel, Mode)

  -- Check.
  if not Frequency then 
    self:E({"The passed TACAN channel is invalid, the BEACON is not emitting"})
    return self
  end

  -- Beacon type.
  local Type=BEACON.Type.TACAN

  -- Beacon system.  
  local System=BEACON.System.TACAN

  -- Check if unit is an aircraft and set system accordingly.
  local AA=self.Positionable:IsAir()


  if AA then
    System=5 --NOTE: 5 is how you cat the correct tanker behaviour! --BEACON.System.TACAN_TANKER
    -- Check if "Y" mode is selected for aircraft.
    if Mode=="X" then
      --self:E({"WARNING: The POSITIONABLE you want to attach the AA Tacan Beacon is an aircraft: Mode should Y!", self.Positionable})
      System=BEACON.System.TACAN_TANKER_X
    else
      System=BEACON.System.TACAN_TANKER_Y
    end
  end

  -- Attached unit.
  local UnitID=self.Positionable:GetID()

  -- Debug.
  self:T({string.format("BEACON Activating TACAN %s: Channel=%d%s, Morse=%s, Bearing=%s, Duration=%s!", tostring(self.name), Channel, Mode, Message, tostring(Bearing), tostring(Duration))})

  -- Start beacon.
  self.Positionable:CommandActivateBeacon(Type, System, Frequency, UnitID, Channel, Mode, AA, Message, Bearing)

  -- Stop scheduler.
  if Duration then
    self.Positionable:DeactivateBeacon(Duration)
  end

  return self
end

--- Activate ACLS system of the CONTROLLABLE. The controllable should be an aircraft carrier!
-- @param #CONTROLLABLE Controllable
-- @return #CONTROLLABLE Controllable
function CommandActivateACLS(Controllable)
  local UnitID=UnitID or Controllable:GetID()

  -- Command to activate ACLS system.
  local CommandActivateACLSObj= {
    id = "ActivateACLS",
    params= {
      ["unitId"] = UnitID,
    }
  }

  Controllable:SetCommand(CommandActivateACLSObj)

  return Controllable
end

--- Dectivate ACLS system of the CONTROLLABLE. The controllable should be an aircraft carrier!
-- @param #CONTROLLABLE Controllable
-- @return #CONTROLLABLE Controllable
function CommandDeactivateACLS(Controllable)

  -- Command to deactivate ACLS system.
  local CommandDeactivateACLSObj= {
    id = "DeactivateACLS",
    params= {}
  }

  Controllable:SetCommand(CommandDeactivateACLSObj)

  return Controllable
end

-- Borrow data structures from AIRBOSS for CARRIER (many fields not used)
local CARRIER = AIRBOSS
CARRIER.AircraftCarrier = AIRBOSS.AircraftCarrier
CARRIER.CarrierType = AIRBOSS.CarrierType

-- CARRIER class, gutted version of the Moose AIRBOSS class keeping only relevant features
-- Hacked together from AIRBOSS v1.2.1
CARRIER.version = "1.2.1" .. "-1"

function CARRIER:New(carriername, alias)
    -- Inherit everthing from FSM class.
    local self=BASE:Inherit(self, FSM:New()) -- #CARRIER

    -- Debug.
    self:F2({carriername=carriername, alias=alias})

    -- Set carrier unit.
    self.carrier=UNIT:FindByName(carriername)

    -- Check if carrier unit exists.
    if self.carrier==nil then
        -- Error message.
        local text=string.format("ERROR: Carrier unit %s could not be found! Make sure this UNIT is defined in the mission editor and check the spelling of the unit name carefully.", carriername)
        MESSAGE:New(text, 120):ToAllIf(carrier.Debug)
        self:E(text)
        return nil
    end

    -- Set some string id for output to DCS.log file.
    self.lid=string.format("CARRIER %s | ", carriername)

    -- Current map.
    self.theatre=env.mission.theatre
    self:T2(self.lid..string.format("Theatre = %s.", tostring(self.theatre)))

    -- Get carrier type.
    self.carriertype=self.carrier:GetTypeName()

    -- Set alias.
    self.alias=alias or carriername

    -- Set carrier airbase object.
    self.airbase=AIRBASE:FindByName(carriername)

    -- Create carrier beacon.
    self.beacon=BEACON:New(self.carrier)

    -- Initialize ME waypoints.
    self:_InitWaypoints()

    -- Current waypoint.
    self.currentwp=1

    -- Patrol route.
    self:_PatrolRoute()

  -------------
  --- Defaults:
  -------------

  -- Set magnetic declination.
  self:SetMagneticDeclination()

  -- Set ICSL to channel 1.
  self:SetICLS()

  -- Set TACAN to channel 74X.
  self:SetTACAN()

  -- Becons are reactivated very 5 min.
  self:SetBeaconRefresh()

  -- Carrier patrols its waypoints until the end of time.
  self:SetPatrolAdInfinitum(true)

  -- Collision check distance. Default 5 NM.
  self:SetCollisionDistance()

  -- Set update time intervals.
  self:SetQueueUpdateTime()
  self:SetStatusUpdateTime()

  -- Init runway angle
  if self.carriertype==CARRIER.CarrierType.STENNIS then
    self.carrierparam.rwyangle   =  -9.1359
  elseif self.carriertype==CARRIER.CarrierType.ROOSEVELT then
    self.carrierparam.rwyangle   =  -9.1359
  elseif self.carriertype==CARRIER.CarrierType.LINCOLN then
    self.carrierparam.rwyangle   =  -9.1359
  elseif self.carriertype==CARRIER.CarrierType.WASHINGTON then
    self.carrierparam.rwyangle   =  -9.1359
  elseif self.carriertype==CARRIER.CarrierType.TRUMAN then
    self.carrierparam.rwyangle   =  -9.1359
  elseif self.carriertype==CARRIER.CarrierType.FORRESTAL then
    self.carrierparam.rwyangle   =  -9.1359
  elseif self.carriertype==CARRIER.CarrierType.VINSON then
    self.carrierparam.rwyangle   =  -9.1359
  elseif self.carriertype==CARRIER.CarrierType.TARAWA then
    self.carrierparam.rwyangle   =  0
  elseif self.carriertype==CARRIER.CarrierType.AMERICA then
    self.carrierparam.rwyangle   =  0
  elseif self.carriertype==CARRIER.CarrierType.JCARLOS then
    self.carrierparam.rwyangle   =  0
  elseif self.carriertype==CARRIER.CarrierType.CANBERRA then
    self.carrierparam.rwyangle   =  0
  elseif self.carriertype==CARRIER.CarrierType.KUZNETSOV then
    self.carrierparam.rwyangle   =  -9.1359
  else
    self:E(self.lid..string.format("ERROR: Unknown carrier type %s!", tostring(self.carriertype)))
    return nil
  end    

  -----------------------
  --- FSM Transitions ---
  -----------------------

  -- Start State.
  self:SetStartState("Stopped")

  -- Add FSM transitions.
  --                 From State  -->   Event      -->     To State
  self:AddTransition("Stopped",       "Start",           "Idle")        -- Start CARRIER script.
  self:AddTransition("*",             "Idle",            "Idle")        -- Carrier is idling.
  self:AddTransition("*",             "Status",          "*")           -- Update status of queues.
  self:AddTransition("*",             "PassingWaypoint", "*")           -- Carrier is passing a waypoint.
  self:AddTransition("*",             "Stop",            "Stopped")     -- Stop CARRIER FMS.

  return self
end

--- Get wind direction and speed at carrier position.
-- @param #CARRIER self
-- @param #number alt Altitude ASL in meters. Default 50 m.
-- @param #boolean magnetic Direction including magnetic declination.
-- @param Core.Point#COORDINATE coord (Optional) Coordinate at which to get the wind. Default is current carrier position.
-- @return #number Direction the wind is blowing **from** in degrees.
-- @return #number Wind speed in m/s.
function CARRIER:GetWind(alt, magnetic, coord)

    -- Current position of the carrier or input.
    local cv=coord or self:GetCoordinate()
  
    -- Wind direction and speed. By default at 50 meters ASL.
    local Wdir, Wspeed=cv:GetWind(alt or 15)
  
    -- Include magnetic declination.
    if magnetic then
      Wdir=Wdir-self.magvar
      -- Adjust negative values.
      if Wdir<0 then
        Wdir=Wdir+360
      end
    end
  
    return Wdir, Wspeed
  end

--- Let the carrier turn into the wind.
-- @param #CARRIER self
-- @param #number time Time in seconds.
-- @param #number vdeck Speed on deck m/s. Carrier will
-- @param #boolean uturn Make U-turn and go back to initial after downwind leg.
-- @return #CARRIER self
function CARRIER:CarrierTurnIntoWind(time, vdeck, uturn)

    -- Wind speed.
    local _,vwind=self:GetWind()
  
    -- Speed of carrier in m/s but at least 2 knots.
    local vtot=math.max(vdeck-vwind, UTILS.KnotsToMps(2))
  
    -- Distance to travel
    local dist=vtot*time
  
    -- Speed in knots
    local speedknots=UTILS.MpsToKnots(vtot)
    local distNM=UTILS.MetersToNM(dist)
  
    -- Debug output
    self:T(self.lid..string.format("Carrier steaming into the wind (%.1f kts). Distance=%.1f NM, Speed=%.1f knots, Time=%d sec.", UTILS.MpsToKnots(vwind), distNM, speedknots, time))
  
    -- Get heading into the wind accounting for angled runway.
    local hiw=self:GetHeadingIntoWind()
  
    -- Current heading.
    local hdg=self:GetHeading()
  
    -- Heading difference.
    local deltaH=self:_GetDeltaHeading(hdg, hiw)
  
    local Cv=self:GetCoordinate()
  
    local Ctiw=nil --Core.Point#COORDINATE
    local Csoo=nil --Core.Point#COORDINATE
  
    -- Define path depending on turn angle.
    if deltaH<45 then
      -- Small turn.
  
      -- Point in the right direction to help turning.
      Csoo=Cv:Translate(750, hdg):Translate(750, hiw)
  
      -- Heading into wind from Csoo.
      local hsw=self:GetHeadingIntoWind(false, Csoo)
  
      -- Into the wind coord.
      Ctiw=Csoo:Translate(dist, hsw)
  
    elseif deltaH<90 then
      -- Medium turn.
  
       -- Point in the right direction to help turning.
      Csoo=Cv:Translate(900, hdg):Translate(900, hiw)
  
      -- Heading into wind from Csoo.
      local hsw=self:GetHeadingIntoWind(false, Csoo)
  
      -- Into the wind coord.
      Ctiw=Csoo:Translate(dist, hsw)
  
    elseif deltaH<135 then
      -- Large turn backwards.
  
      -- Point in the right direction to help turning.
      Csoo=Cv:Translate(1100, hdg-90):Translate(1000, hiw)
  
      -- Heading into wind from Csoo.
      local hsw=self:GetHeadingIntoWind(false, Csoo)
  
      -- Into the wind coord.
      Ctiw=Csoo:Translate(dist, hsw)
  
    else
      -- Huge turn backwards.
  
      -- Point in the right direction to help turning.
      Csoo=Cv:Translate(1200, hdg-90):Translate(1000, hiw)
  
      -- Heading into wind from Csoo.
      local hsw=self:GetHeadingIntoWind(false, Csoo)
  
      -- Into the wind coord.
      Ctiw=Csoo:Translate(dist, hsw)
  
    end
  
  
    -- Return to coordinate if collision is detected.
    self.Creturnto=self:GetCoordinate()
  
    -- Next waypoint.
    local nextwp=self:_GetNextWaypoint()
  
    -- For downwind, we take the velocity at the next WP.
    local vdownwind=UTILS.MpsToKnots(nextwp:GetVelocity())
  
    -- Make sure we move at all in case the speed at the waypoint is zero.
    if vdownwind<1 then
      vdownwind=10
    end
  
    -- Let the carrier make a detour from its route but return to its current position.
    self:CarrierDetour(Ctiw, speedknots, uturn, vdownwind, Csoo)
  
    -- Set switch that we are currently turning into the wind.
    self.turnintowind=true
  
    return self
  end

--- Set the magnetic declination (or variation). By default this is set to the standard declination of the map.
-- @param #CARRIER self
-- @param #number declination Declination in degrees or nil for default declination of the map.
-- @return #CARRIER self
function CARRIER:SetMagneticDeclination(declination)
    self.magvar=declination or UTILS.GetMagneticDeclination()
    return self
end

--- Set distance up to which water ahead is scanned for collisions.
-- @param #CARRIER self
-- @param #number dist Distance in NM. Default 5 NM.
-- @return #CARRIER self
function CARRIER:SetCollisionDistance(distance)
    self.collisiondist=UTILS.NMToMeters(distance or 5)
    return self
end

--- Set time interval for updating queues and other stuff.
-- @param #CARRIER self
-- @param #number interval Time interval in seconds. Default 30 sec.
-- @return #CARRIER self
function CARRIER:SetQueueUpdateTime(interval)
    self.dTqueue=interval or 30
    return self
end

--- Set time interval for updating player status and other things.
-- @param #CARRIER self
-- @param #number interval Time interval in seconds. Default 0.5 sec.
-- @return #CARRIER self
function CARRIER:SetStatusUpdateTime(interval)
    self.dTstatus=interval or 0.5
    return self
end

--- Carrier patrols ad inifintum. If the last waypoint is reached, it will go to waypoint one and repeat its route.
-- @param #CARRIER self
-- @param #boolean switch If true or nil, patrol until the end of time. If false, go along the waypoints once and stop.
-- @return #CARRIER self
function CARRIER:SetPatrolAdInfinitum(switch)
    if switch==false then
      self.adinfinitum=false
    else
      self.adinfinitum=true
    end
    return self
end

--- Check if carrier is idle, i.e. no operations are carried out.
-- @param #CARRIER self
-- @return #boolean If true, carrier is in idle state.
function CARRIER:IsIdle()
    return self:is("Idle")
end
  
--- Check if recovery of aircraft is paused.
-- @param #CARRIER self
-- @return #boolean If true, recovery is paused
function CARRIER:IsPaused()
    return self:is("Paused")
end

--- Disable automatic TACAN activation
-- @param #CARRIER self
-- @return #CARRIER self
function CARRIER:SetTACANoff()
    self.TACANon=false
    return self
  end
  
  --- Set TACAN channel of carrier.
  -- @param #CARRIER self
  -- @param #number channel TACAN channel. Default 74.
  -- @param #string mode TACAN mode, i.e. "X" or "Y". Default "X".
  -- @param #string morsecode Morse code identifier. Three letters, e.g. "STN".
  -- @return #CARRIER self
  function CARRIER:SetTACAN(channel, mode, morsecode)
  
    self.TACANchannel=channel or 74
    self.TACANmode=mode or "X"
    self.TACANmorse=morsecode or "STN"
    self.TACANon=true
  
    return self
  end
  
  --- Disable automatic ICLS activation.
  -- @param #CARRIER self
  -- @return #CARRIER self
  function CARRIER:SetICLSoff()
    self.ICLSon=false
    return self
  end
  
  --- Set ICLS channel of carrier.
  -- @param #CARRIER self
  -- @param #number channel ICLS channel. Default 1.
  -- @param #string morsecode Morse code identifier. Three letters, e.g. "STN". Default "STN".
  -- @return #CARRIER self
  function CARRIER:SetICLS(channel, morsecode)
  
    self.ICLSchannel=channel or 1
    self.ICLSmorse=morsecode or "STN"
    self.ICLSon=true
  
    return self
  end
  
  
--- Set beacon (TACAN/ICLS) time refresh interfal in case the beacons die.
-- @param #CARRIER self
-- @param #number interval Time interval in seconds. Default 1200 sec = 20 min.
-- @return #CARRIER self
function CARRIER:SetBeaconRefresh(interval)
    local dTbeacon = interval or (20*60)
    self.dTbeacon = dTbeacon

    return self
end

--- Activate TACAN and ICLS beacons.
-- @param #CARRIER self
function CARRIER:_ActivateBeacons()
    self:T(self.lid..string.format("Activating Beacons (TACAN=%s, ICLS=%s)", tostring(self.TACANon), tostring(self.ICLSon)))
  
    -- Activate TACAN.
    if self.TACANon then
      self:T(self.lid..string.format("Activating TACAN Channel %d%s (%s)", self.TACANchannel, self.TACANmode, self.TACANmorse))
      self.beacon:ActivateTACAN(self.TACANchannel, self.TACANmode, self.TACANmorse, true)
    end
  
    -- Activate ICLS.
    if self.ICLSon then
      self:T(self.lid..string.format("Activating ICLS Channel %d (%s)", self.ICLSchannel, self.ICLSmorse))
      self.beacon:ActivateICLS(self.ICLSchannel, self.ICLSmorse)
    end
  
    -- Set time stamp.
    self.Tbeacon=timer.getTime()
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FSM event functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- On after Start event. Starts the CARRIER. Adds event handlers and schedules status updates of requests and queue.
-- @param #CARRIER self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
function CARRIER:onafterStart(From, Event, To)

    -- Events are handled my MOOSE.
    self:I(self.lid..string.format("Starting CARRIER v%s for carrier unit %s of type %s on map %s", CARRIER.version, self.carrier:GetName(), self.carriertype, self.theatre))

    -- Activate TACAN and ICLS if desired
    self:_ActivateBeacons()

    -- Initial carrier position and orientation.
    self.Cposition=self:GetCoordinate()
    self.Corientation=self.carrier:GetOrientationX()
    self.Corientlast=self.Corientation
    self.Tpupdate=timer.getTime()
  
    -- Time stamp for checking queues. We substract 60 seconds so the routine is called right after status is called the first time.
    self.Tqueue=timer.getTime()-60
  
    -- Start status check in 1 second.
    self:__Status(1)
end

--- On after Status event. Checks for new flights, updates queue and checks player status.
-- @param #CARRIER self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
function CARRIER:onafterStatus(From, Event, To)

    -- Get current time.
    local time=timer.getTime()
  
    -- Update marshal and pattern queue every 30 seconds.
    if time-self.Tqueue>self.dTqueue then
  
      -- Get time.
      local clock=UTILS.SecondsToClock(timer.getAbsTime())
      local eta=UTILS.SecondsToClock(self:_GetETAatNextWP())
  
      -- Current heading and position of the carrier.
      local hdg=self:GetHeading()
      local pos=self:GetCoordinate()
      local speed=self.carrier:GetVelocityKNOTS()
  
      -- Check water is ahead.
      local collision=false --self:_CheckCollisionCoord(pos:Translate(self.collisiondist, hdg))
  
      local holdtime=0
      if self.holdtimestamp then
        holdtime=timer.getTime()-self.holdtimestamp
      end
  
      -- Check if carrier is stationary.
      local NextWP=self:_GetNextWaypoint()
      local ExpectedSpeed=UTILS.MpsToKnots(NextWP:GetVelocity())
      if speed<0.5 and ExpectedSpeed>0 and not (self.detour or self.turnintowind) then
        if not self.holdtimestamp then
          self:E(self.lid..string.format("Carrier came to an unexpected standstill. Trying to re-route in 3 min. Speed=%.1f knots, expected=%.1f knots", speed, ExpectedSpeed))
          self.holdtimestamp=timer.getTime()
        else
          if holdtime>3*60 then
            local coord=self:GetCoordinate():Translate(500, hdg+10)
            --coord:MarkToAll("Re-route after standstill.")
            self:CarrierResumeRoute(coord)
            self.holdtimestamp=nil
          end
        end
      end
  
      -- Debug info.
      local text=string.format("Time %s - Status %s - Speed=%.1f kts - Heading=%d - WP=%d - ETA=%s - Turning=%s - Collision Warning=%s - Detour=%s - Turn Into Wind=%s - Holdtime=%d sec",
      clock, self:GetState(), speed, hdg, self.currentwp, eta, tostring(self.turning), tostring(collision), tostring(self.detour), tostring(self.turnintowind), holdtime)
      self:T(self.lid..text)
  
      -- Check for collision.
      if collision then
  
        -- We are currently turning into the wind.
        if self.turnintowind then
  
          -- Carrier resumes its initial route. This disables turnintowind switch.
          self:CarrierResumeRoute(self.Creturnto)
  
          -- Since current window would stay open, we disable the WIND switch.
          if self:IsRecovering() and self.recoverywindow and self.recoverywindow.WIND then
            -- Disable turn into the wind for this window so that we do not do this all over again.
            self.recoverywindow.WIND=false
          end
  
        end
  
      end
  
      -- Check if carrier is currently turning.
      self:_CheckCarrierTurning()
  
      -- Time stamp.
      self.Tqueue=time
    end
  
    -- (Re-)activate TACAN and ICLS channels.
    if time-self.Tbeacon>self.dTbeacon then
        self:_ActivateBeacons()
    end

    -- Call status every ~0.5 seconds.
    self:__Status(-30)
  
end
  
--- Function called when a group is passing a waypoint.
--@param Wrapper.Group#GROUP group Group that passed the waypoint
--@param #CARRIER carrier Airboss object.
--@param #number i Waypoint number that has been reached.
--@param #number final Final waypoint number.
function CARRIER._PassingWaypoint(group, carrier, i, final)

    -- Debug message.
    local text=string.format("Group %s passing waypoint %d of %d.", group:GetName(), i, final)
  
    -- Debug message.
    MESSAGE:New(text,10):ToAllIf(carrier.Debug)
    carrier:T(carrier.lid..text)
  
    -- Set current waypoint.
    carrier.currentwp=i
  
    -- Passing Waypoint event.
    carrier:PassingWaypoint(i)
  
    -- Reactivate beacons.
    --carrier:_ActivateBeacons()
  
    -- If final waypoint reached, do route all over again.
    if i==final and final>1 and carrier.adinfinitum then
      carrier:_PatrolRoute()
    end
end
  
--- Carrier Strike Group resumes the route of the waypoints defined in the mission editor.
--@param Wrapper.Group#GROUP group Carrier Strike Group that passed the waypoint.
--@param #CARRIER carrier Airboss object.
--@param Core.Point#COORDINATE gotocoord Go to coordinate before route is resumed.
function CARRIER._ResumeRoute(group, carrier, gotocoord)

    -- Get next waypoint
    local nextwp,Nextwp=carrier:_GetNextWaypoint()

    -- Speed set at waypoint.
    local speedkmh=nextwp.Velocity*3.6

    -- If speed at waypoint is zero, we set it to 10 knots.
    if speedkmh<1 then
        speedkmh=UTILS.KnotsToKmph(10)
    end

    -- Waypoints array.
    local waypoints={}

    -- Current position.
    local c0=group:GetCoordinate()

    -- Current positon as first waypoint.
    local wp0=c0:WaypointGround(speedkmh)
    table.insert(waypoints, wp0)

    -- First goto this coordinate.
    if gotocoord then

        --gotocoord:MarkToAll(string.format("Goto waypoint speed=%.1f km/h", speedkmh))

        local headingto=c0:HeadingTo(gotocoord)

        local hdg1=carrier:GetHeading()
        local hdg2=c0:HeadingTo(gotocoord)
        local delta=carrier:_GetDeltaHeading(hdg1, hdg2)

        --env.info(string.format("FF hdg1=%d, hdg2=%d, delta=%d", hdg1, hdg2, delta))


        -- Add additional turn points
        if delta>90 then

            -- Turn radius 3 NM.
            local turnradius=UTILS.NMToMeters(3)

            local gotocoordh=c0:Translate(turnradius, hdg1+45)
            --gotocoordh:MarkToAll(string.format("Goto help waypoint 1 speed=%.1f km/h", speedkmh))

            local wp=gotocoordh:WaypointGround(speedkmh)
            table.insert(waypoints, wp)

            gotocoordh=c0:Translate(turnradius, hdg1+90)
            --gotocoordh:MarkToAll(string.format("Goto help waypoint 2 speed=%.1f km/h", speedkmh))

            wp=gotocoordh:WaypointGround(speedkmh)
            table.insert(waypoints, wp)

        end

        local wp1=gotocoord:WaypointGround(speedkmh)
        table.insert(waypoints, wp1)

    end

    -- Debug message.
    local text=string.format("Carrier is resuming route. Next waypoint %d, Speed=%.1f knots.", Nextwp, UTILS.KmphToKnots(speedkmh))

    -- Debug message.
    MESSAGE:New(text,10):ToAllIf(carrier.Debug)
    carrier:I(carrier.lid..text)

    -- Loop over all remaining waypoints.
    for i=Nextwp, #carrier.waypoints do

        -- Coordinate of the next WP.
        local coord=carrier.waypoints[i]  --Core.Point#COORDINATE

        -- Speed in km/h of that WP. Velocity is in m/s.
        local speed=coord.Velocity*3.6

        -- If speed is zero we set it to 10 knots.
        if speed<1 then
        speed=UTILS.KnotsToKmph(10)
        end

        --coord:MarkToAll(string.format("Resume route WP %d, speed=%.1f km/h", i, speed))

        -- Create waypoint.
        local wp=coord:WaypointGround(speed)

        -- Passing waypoint task function.
        local TaskPassingWP=group:TaskFunction("AIRBOSS._PassingWaypoint", carrier, i, #carrier.waypoints)

        -- Call task function when carrier arrives at waypoint.
        group:SetTaskWaypoint(wp, TaskPassingWP)

        -- Add waypoints to table.
        table.insert(waypoints, wp)
    end

    -- Set turn into wind switch false.
    carrier.turnintowind=false
    carrier.detour=false

    -- Route group.
    group:Route(waypoints)
end

--- Check if carrier is turning.
-- @param #CARRIER self
function CARRIER:_CheckCarrierTurning()

    -- Current orientation of carrier.
    local vNew=self.carrier:GetOrientationX()
  
    -- Last orientation from 30 seconds ago.
    local vLast=self.Corientlast
  
    -- We only need the X-Z plane.
    vNew.y=0 ; vLast.y=0
  
    -- Angle between current heading and last time we checked ~30 seconds ago.
    local deltaLast=math.deg(math.acos(UTILS.VecDot(vNew,vLast)/UTILS.VecNorm(vNew)/UTILS.VecNorm(vLast)))
  
    -- Last orientation becomes new orientation
    self.Corientlast=vNew
  
    -- Carrier is turning when its heading changed by at least one degree since last check.
    local turning=math.abs(deltaLast)>=1
  
    -- Check if turning stopped. (Carrier was turning but is not any more.)
    if self.turning and not turning then
  
      -- Get final bearing.
      local FB=self:GetFinalBearing(true)
  
    end
  
    -- Check if turning started. (Carrier was not turning and is now.)
    if turning and not self.turning then
  
      -- Get heading.
      local hdg
      if self.turnintowind then
        -- We are now steaming into the wind.
        hdg=self:GetHeadingIntoWind(false)
      else
        -- We turn towards the next waypoint.
        hdg=self:GetCoordinate():HeadingTo(self:_GetNextWaypoint())
      end
  
      -- Magnetic!
      hdg=hdg-self.magvar
      if hdg<0 then
        hdg=360+hdg
      end
    end
  
    -- Update turning.
    self.turning=turning
end

function InitSupportBases()

  ENUMS.MapsopZoneProperties = {
    TEMPLATE = "Template",
    ALTITUDE = "Altitude",
    SPEED = "Speed",
    FREQUENCY = "Frequency",
    TACAN = "TACAN",
    INVISIBLE = "Invisible",
    IMMORTAL = "Immortal",
    AIRFRAMES = "Airframes",
    GROUNDSTART = "GroundStart",
    RESPAWNAIR = "RespawnAir",
    PUSHTIME = "PushTime"
  }


    local AirbaseName = nil
    local RedAirbaseName = nil
    local AirbaseZone = ZONE:FindByName("Support Airbase")
    local RedAirbaseZone = ZONE:FindByName("Red Support Airbase")
    local ATCzones = SET_ZONE:New():FilterPrefixes('Enable ATC'):FilterOnce()
    local NoATCzones = SET_ZONE:New():FilterPrefixes('Disable ATC'):FilterOnce()
    local AircraftCarriers = {}
    local VTOLcarriers = {}
    local IngressZone, EgressZone

    if AirbaseZone then
        local Airbase = AirbaseZone:GetCoordinate(0):GetClosestAirbase(Airbase.Category.AIRDROME, coalition.side.BLUE)
        if Airbase then
          AirbaseName = Airbase:GetName()
        end
    end

    if RedAirbaseZone then
      local RedAirbase = RedAirbaseZone:GetCoordinate(0):GetClosestAirbase(Airbase.Category.AIRDROME, coalition.side.RED)
      if RedAirbase then
        RedAirbaseName = RedAirbase:GetName()
      end
    end

    local Airbases = AIRBASE.GetAllAirbases(nil, Airbase.Category.AIRDROME)

    -- Airbase ATC settings
    if MAPSOPSETTINGS.DisableATC then
      -- If DisableATC, disable by default then selectively enable
      BASE:I("All ATC AI set to 'disable' by default, enabling ATC in " .. ATCzones:Count() .. " 'Enable ATC'-prefixed Trigger Zones.")
      for _,CheckAirbase in ipairs(Airbases) do
        if ATCzones:IsCoordinateInZone(CheckAirbase:GetCoordinate()) then
          BASE:I("ATC enabled at " .. CheckAirbase:GetName() .. ".")
        else
          CheckAirbase:SetRadioSilentMode(true)
        end
      end
    else
      -- If not DisableATC, enable by default then selectively disable
      BASE:I("All ATC AI set to 'enable' by default, disabling ATC in " .. NoATCzones:Count() .. " 'Disable ATC'-prefixed Trigger Zones.")
      for _,CheckAirbase in ipairs(Airbases) do
        if NoATCzones:IsCoordinateInZone(CheckAirbase:GetCoordinate()) then
          BASE:I("ATC disabled at " .. CheckAirbase:GetName() .. ".")
          CheckAirbase:SetRadioSilentMode(true)
        end
      end
    end

    if not AirbaseName then
        for _,CheckAirbase in ipairs(Airbases) do
            local CheckAirbaseName = CheckAirbase:GetName()
            for _,DefaultAirbase in ipairs(DEFAULTSUPPORTAIRBASES) do
                if DefaultAirbase == CheckAirbaseName then
                    AirbaseName = DefaultAirbase
                    break
                end
            end
            if AirbaseName then break end
        end
    end

    local SupportBase = AIRBASE:Register(AirbaseName)
    local RedSupportBase = nil
    if RedAirbaseName then
      RedSupportBase = AIRBASE:Register(RedAirbaseName)
    end

    local CarrierShips = AIRBASE.GetAllAirbases(coalition.side.BLUE, Airbase.Category.SHIP)
    for _,CarrierShip in pairs(CarrierShips) do
        local ShipName = CarrierShip:GetName()
        local ShipInfo = SUPPORTUNITS["_"][ShipName]

        if ShipName:find("^CVN-") and ShipInfo then
                table.insert(AircraftCarriers, ShipName)
        end       
    end

    local P1ZoneSet = SET_ZONE:New():FilterPrefixes('-P1'):FilterOnce()
    local P2ZoneSet = SET_ZONE:New():FilterPrefixes('-P2'):FilterOnce()
    P1ZoneSet:SortByName()
    P2ZoneSet:SortByName()

    local P1zones = P1ZoneSet:GetSetNames()
    local P2zones = P2ZoneSet:GetSetNames()

    table.sort(P1zones)
    table.sort(P2zones)

    local callsigns = CALLSIGN.Tanker
    for k,v in pairs(CALLSIGN.AWACS) do callsigns[k] = v end
    callsigns['CSAR'] = 8
  
    for  _,P1zone in ipairs(P1zones) do

      local callsign, num, param, pushtime

      local IsRed = false
      local P1ZoneObj = ZONE:FindByName(P1zone)
      local trackpattern = '(.*-P1)%s*(.*)'

      local _,_,P1zoneParse,trackname = string.find(P1zone, trackpattern)
      if not trackname or trackname == "" then
        trackname = "_"
      end

      -- Note: Ingress/egress not functional yet
      local ingresszonename = string.gsub(P1zoneParse, "-P1", "-Ingress")
      local egresszonename = string.gsub(P1zoneParse, "-P1", "-Egress")

      if string.find(P1zone, "^RED%-") then
        IsRed = true
        P1zoneParse = string.gsub(P1zone, "RED%-", "")
      end

      local pattern = "^(%a+)" .. "(%d)" .. "-*" .. "(.*)" .. "-P1"
      callsign, num, param =  string.match(P1zoneParse,  pattern)
      param = param or ""
      param = param .. "-done"
      if num == '0' then
        num = nil
      end

      if callsigns[callsign] ~= nil then

        if num then 
          
          local FullCallsign = callsign .. num
          local NoRedFullCallsign = FullCallsign
          if IsRed then
            FullCallsign = "RED-" .. FullCallsign
          end

          local template,notemplate,tokentemplate,alt,speed,freq,tacan,tacanband,invisible,immortal,airframes,groundstart,respawnair,pushtime

          if param then
            for token in string.gmatch(param, "[^-]+") do
              tokentemplate = string.match(token, "T(%d)")

              local ZoneTemplate = P1ZoneObj:GetProperty(ENUMS.MapsopZoneProperties.TEMPLATE)
              if ZoneTemplate == 'SOP' then
                ZoneTemplate = nil
              end
              template = template or tokentemplate or ZoneTemplate
              if not template then notemplate = true end

              if template or (not SUPPORTUNITS[trackname] or not SUPPORTUNITS[trackname][ FullCallsign ]) then
                template = template or 1
                if not BASESUPPORTUNITS[trackname] or not BASESUPPORTUNITS[trackname][callsign .. template] then
                  template = 1
                end
                if trackname == "_" then
                  SUPPORTUNITS["_"][ FullCallsign ] = routines.utils.deepCopy(BASESUPPORTUNITS["_"][callsign .. template])
                else
                  -- Default "_" track will have already gone thanks to sort, so can copy it
                  SUPPORTUNITS[trackname] = SUPPORTUNITS[trackname] or {}
                  if notemplate then
                    SUPPORTUNITS[trackname][ FullCallsign ] = routines.utils.deepCopy(SUPPORTUNITS["_"][FullCallsign])
                  else
                    SUPPORTUNITS[trackname][ FullCallsign ] = routines.utils.deepCopy(BASESUPPORTUNITS["_"][callsign .. template])
                  end
                end
                SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.CALLSIGN_NUM ] = num
              end

              if IsRed then
                SUPPORTUNITS["_"][ FullCallsign ].IsRed = true
              else
                SUPPORTUNITS["_"][ FullCallsign ].IsBlue = true
              end
              
              local op,parsealt = string.match(token, "FL([mp]?)(%d+)")

              if not alt then
                local altstring = P1ZoneObj:GetProperty(ENUMS.MapsopZoneProperties.ALTITUDE)
                if altstring == 'SOP' then altstring = nil end
                local altvalue, altsign
                if altstring then
                  altsign,altvalue = string.match(altstring, "([%+%-pm]?)(%d+)")
                end

                if altsign and (altsign == "+" or string.lower(altsign) == "p") then
                  alt = (SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.ALTITUDE ] ) + tonumber(altvalue)
                elseif altsign and (altsign == "-" or string.lower(altsign) == "m") then
                  alt = (SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.ALTITUDE ] ) - tonumber(altvalue)
                elseif altvalue then 
                  alt = tonumber(altvalue)
                end

                if parsealt then
                  if op == "p" then
                    alt = (SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.ALTITUDE ] ) + (parsealt * 100)
                  elseif op == "m" then
                    alt = (SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.ALTITUDE ] ) - (parsealt * 100)
                  else
                    alt = parsealt * 100
                  end
                end
              end

              if not speed then
                local speedstring = P1ZoneObj:GetProperty(ENUMS.MapsopZoneProperties.SPEED)
                if speedstring == 'SOP' then speedstring = nil end
                local speedvalue, speedsign
                if speedstring then
                  speedvalue = string.match(speedstring, "%+?%-?p?m?(%d+)")
                  speedsign = string.match(speedstring, "([%+%-pm])%d+")
                end

                if speedsign and (speedsign == "+" or string.lower(speedsign) == "p") then
                  op = "p"
                  speed = (SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.SPEED ] ) + tonumber(speedvalue), alt or SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.ALTITUDE ]
                elseif speedsign and (speedsign == "-" or string.lower(speedsign) == "m") then
                  op = "m"
                  speed = (SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.SPEED ] ) - tonumber(speedvalue), alt or SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.ALTITUDE ]
                elseif speedvalue then 
                  speed = tonumber(speedvalue)
                end 
              end

              local op,parsespeed = string.match(token, "SP([mp]?)(%d+)")
              if parsespeed then
                if op == "p" then
                  speed = SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.SPEED ] + tonumber(parsespeed), alt or SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.ALTITUDE ]
                elseif op == "m" then
                  speed = SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.SPEED ] - tonumber(parsespeed), alt or SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.ALTITUDE ]
                else
                  speed = parsespeed
                end
              end

              local freqprop = P1ZoneObj:GetProperty(ENUMS.MapsopZoneProperties.FREQUENCY)
              if freqprop == 'SOP' then freqprop = nil end
              freq = freq or string.match(token, "FR(%d+%.*%d*)") or freqprop

              local tacanStringProp = P1ZoneObj:GetProperty(ENUMS.MapsopZoneProperties.TACAN)
              if tacanStringProp == 'SOP' then tacanprop = nil end

              tacan = tacan or string.match(token, "TC(%d+)%u") or tonumber(string.match(tacanStringProp or "", "(%d+)%u"))
              tacanband = tacanband or string.match(token, "TC%d+(%u)") or string.match(tacanStringProp or "", "%d+(%u)")
              if tacanband then
                tacanband = string.upper(tacanband)
              end
              if tacan == "" or tacanband == "" then 
                tacan = nil
              end
              
              local invprop = P1ZoneObj:GetProperty(ENUMS.MapsopZoneProperties.INVISIBLE)
              if invprop then invprop = string.lower(invprop) end
              if invprop == 'true' then
                invprop = true
              else
                invprop = nil
              end 
              invisible = invisible or string.match(token, "INV")
              if invisible == "INV" or invprop then
                invisible = invisible or true
              else
                invisible = invisible or nil
              end

              local immortalprop = P1ZoneObj:GetProperty(ENUMS.MapsopZoneProperties.IMMORTAL)
              if immortalprop then immortalprop = string.lower(immortalprop) end
              if immortalprop == 'true' then
                immortalprop = true
              else
                immortalprop = nil
              end 
              immortal = immortal or immortalprop

              local groundstartprop = P1ZoneObj:GetProperty(ENUMS.MapsopZoneProperties.GROUNDSTART)
              if groundstartprop then groundstartprop = string.lower(groundstartprop) end
              if groundstartprop == 'true' then
                groundstartprop = true
              else
                groundstartprop = nil
              end 
              groundstart = groundstart or string.match(token, "GND")
              if groundstart == "GND" or groundstartprop then
                groundstart = groundstart or true
              else
                groundstart = groundstart or nil
              end

              local respawnairprop = P1ZoneObj:GetProperty(ENUMS.MapsopZoneProperties.RESPAWNAIR)
              if respawnairprop then respawnairprop = string.lower(respawnairprop) end
              if respawnairprop == 'true' then
                respawnair = true
              else
                respawnair = nil
              end

              local pushtimeprop
              pushtimeprop = P1ZoneObj:GetProperty(ENUMS.MapsopZoneProperties.PUSHTIME)
              pushtime=nil
              if pushtimeprop and string.lower(pushtimeprop) ~= 'sop' then
                pushtime = pushtime or time2sec(pushtimeprop)
              end
              
              if trackname == '_' and not pushtime then
                CURRENTUNITTRACK[ FullCallsign ] = "_"
              end

              if trackname == '_' and pushtime then
                groundstart = true
              end

              airframes = airframes or string.match(token, "QTY(%d+)") or P1ZoneObj:GetProperty(ENUMS.MapsopZoneProperties.AIRFRAMES)
              if airframes and airframes == SOP then
                airframes = airframes or nil
              else
                airframes = airframes or tonumber(airframes)
              end

            end
          end

          if airframes and tonumber(airframes) and tonumber(airframes) > 0 and trackname == "_" then
            BASE:I(FullCallsign .. " SOP override to " .. airframes .. " airframes.")
            SUPPORTUNITS["_"][ FullCallsign ].airframes = airframes
          end

          SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.CALLSIGN_NUM ] = num

          if alt then
            BASE:I(FullCallsign .. " SOP override to " .. alt .. "ft MSL.")
            SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.ALTITUDE ] = alt
          end
          if speed then
            BASE:I(FullCallsign .. " SOP override to " .. speed .. " KIAS.")
            SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.SPEED ] = speed
          end
          if freq then
            BASE:I(FullCallsign .. " SOP override radio frequency to " .. freq .. "MHz AM.")
            SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.RADIOFREQ ] = freq
          end
          if tacan and tacanband then
            BASE:I(FullCallsign .. " SOP override radio TACAN to " .. tacan .. tacanband .. ".")
            SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.TACANCHAN ] = tacan
            SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.TACANBAND ] = tacanband
          end

          if invisible then
            BASE:I(FullCallsign .. " SOP override to be invisible to AI.")
            SUPPORTUNITS[trackname][ FullCallsign ].invisible = true
          end

          if immortal then
            BASE:I(FullCallsign .. " SOP override to be immortal.")
            SUPPORTUNITS[trackname][ FullCallsign ].immortal = true
          end

          if groundstart then
            BASE:I(FullCallsign .. " SOP override Default track to ground takeoff.")
            SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.GROUNDSTART ] = true
          end

          if respawnair then
            BASE:I(FullCallsign .. " SOP override relief flights to respawn in the air.")
            SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.RESPAWNAIR ] = true
          end

          if pushtime and pushtime > 0 then
            local trackstring = "track " .. trackname
            if trackname == '_' then
              trackstring = "initial track"
            end
            BASE:I(FullCallsign .. " SOP override " .. trackstring .. " push time to " .. sec2time(pushtime) .. ".")
            SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.PUSHTIME ] = pushtime
            SUPPORTUNITS[trackname][ FullCallsign ].PushSchedule =
              SCHEDULER:New( nil,
              ManageFlights, {nil, FullCallsign, trackname}, pushtime)
          else
            SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.PUSHTIME ] = nil
          end

          if SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.TACANCHAN ] then
            pattern = "^(%a+)%d"
            local morse = SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.TACANMORSE ]
            local MorseAlphas = nil

            if morse then
              MorseAlphas = string.match( morse, pattern )
            end

            if MorseAlphas then
              SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.TACANMORSE ] = MorseAlphas .. num
            else
              SUPPORTUNITS[trackname][ FullCallsign ][ ENUMS.SupportUnitFields.TACANMORSE ] = "GAS"
            end
          end
          
          local P1 = ZONE:FindByName(P1zone)
          if P1 then
            SUPPORTUNITS[trackname][ FullCallsign ].CoordP1 = P1:GetCoordinate()
          end

          -- Note: Ingress/Egress not yet functional
          IngressZone = ZONE:FindByName(ingresszonename)
          if IngressZone then
            SUPPORTUNITS[trackname][ FullCallsign ].CoordIngress = IngressZone:GetCoordinate()
          end

          EgressZone = ZONE:FindByName(egresszonename)
          if EgressZone then
            SUPPORTUNITS[trackname][ FullCallsign ].CoordEgress = EgressZone:GetCoordinate()
          end

        end
      end
    end

    for  _,P2zonename in ipairs(P2zones) do
      local callsign, num, param, P2zone, trackname
      local trackpattern = '(.*P2)%s*(.*)'
      local _,_,P2zone,trackname = string.find(P2zonename, trackpattern)
      local pattern = "^(%a+)" .. "(%d)" .. "-*" .. "(.*)" .. "-P2"

      if not trackname or trackname == "" then
        trackname = "_"
      end

      local IsRed = false
      if string.find(P2zone, "^RED%-") then
        IsRed = true
        P2zone = string.gsub(P2zone, "RED%-", "")
      end

      callsign, num, param =  string.match(P2zone,  pattern)

      if callsigns[callsign] ~= nil then

        if num then        
          local FullCallsign = callsign .. num
          local NoRedFullCallsign = FullCallsign
          if IsRed then
            FullCallsign = "RED-" .. FullCallsign
          end
          local P2
          if trackname == "_" then
            P2 = ZONE:FindByName(FullCallsign .. "-P2")
          else
            P2 = ZONE:FindByName(FullCallsign .. "-P2 " .. trackname)
          end
          if P2 and SUPPORTUNITS[trackname] and SUPPORTUNITS[trackname][ FullCallsign ] then
            SUPPORTUNITS[trackname][ FullCallsign ].CoordP2 = P2:GetCoordinate()
            SUPPORTUNITS[trackname][ FullCallsign ].zoneP2exists = true
          end
        end
      end
    end

    -- Spawn late activated template units to use as basis for spawns
    for SupportUnit,SupportUnitFields in pairs(SUPPORTUNITS["_"]) do
        local SpawnTemplate = nil
        local SupportUnitInfo = SupportUnitFields[ENUMS.SupportUnitFields.TEMPLATE]

        if SupportUnitInfo then
            local SupportUnitTypeName = SupportUnitInfo[ENUMS.SupportUnitTemplateFields.UNITTYPE]

            if SupportUnitFields[ENUMS.SupportUnitFields.TYPE] == ENUMS.UnitType.AIRCRAFT or
            SupportUnitFields[ENUMS.SupportUnitFields.TYPE] == ENUMS.UnitType.TANKER or
            SupportUnitFields[ENUMS.SupportUnitFields.TYPE] == ENUMS.UnitType.AWACS then
                SpawnTemplate = TEMPLATE.GetAirplane(SupportUnitTypeName, SupportUnit)
            elseif SupportUnitFields[ENUMS.SupportUnitFields.TYPE] == ENUMS.UnitType.HELICOPTER then
                SpawnTemplate = TEMPLATE.GetHelicopter(SupportUnitTypeName, SupportUnit)
            end

            if SpawnTemplate then
                if SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN] and SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN_NUM] then

                  ChangeTemplateCallsign(SpawnTemplate, 
                      SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN], 
                      SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN_NUM], 
                      ENUMS.CallsignString[SupportUnitFields[ENUMS.SupportUnitFields.TYPE]][SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN]])
                end

                if SupportUnitFields[ENUMS.SupportUnitFields.SPEED] then
                  SpawnTemplate.route.points[1].speed = UTILS.KnotsToMps(UTILS.KnotsToAltKIAS(SupportUnitFields[ENUMS.SupportUnitFields.SPEED],SupportUnitFields[ENUMS.SupportUnitFields.ALTITUDE]) or 350)
                  SpawnTemplate.units[1].speed = UTILS.KnotsToMps(UTILS.KnotsToAltKIAS(SupportUnitFields[ENUMS.SupportUnitFields.SPEED],SupportUnitFields[ENUMS.SupportUnitFields.ALTITUDE]) or 350)
                end

                TEMPLATE.SetPayload(SpawnTemplate, SupportUnitInfo[ENUMS.SupportUnitTemplateFields.FUEL], SupportUnitInfo[ENUMS.SupportUnitTemplateFields.FLARE], 
                    SupportUnitInfo[ENUMS.SupportUnitTemplateFields.CHAFF], SupportUnitInfo[ENUMS.SupportUnitTemplateFields.GUNS], {})

                --SUPPORTUNITS["_"][SupportUnit].SpawnTemplate = SpawnTemplate
                SPAWN:NewFromTemplate( SpawnTemplate, SupportUnit .. " Group", SupportUnit)
                  :InitLateActivated()
                  :InitModex(SupportUnitFields[ENUMS.SupportUnitFields.MODEX])
                  :InitAirbase(SupportBase, SPAWN.Takeoff.Hot)
                  :OnSpawnGroup(
                    function( SpawnGroup )
                      if SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN] and SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN_NUM] then
                        -- noop
                      end
                    end)
                  :Spawn()
            end
        end
    end
    return SupportBase, RedSupportBase, AircraftCarriers
end

function ManageFlights( SpawnGroupIn, SupportUnit, NewTrack )
  local SpawnGroup = SpawnGroupIn

  if NewTrack then
    local trackname = NewTrack
    if trackname == "_" then
      trackname = "Default"
    end

    if MAPSOPSETTINGS.UseSRS and VFW51ST_TACCOMMON_msrsQ and SUPPORTUNITS["_"][SupportUnit].IsBlue 
        and CURRENTUNITTRACK[SupportUnit] ~= NewTrack and SUPPORTUNITS[NewTrack][SupportUnit].zoneP2exists
        and (SUPPORTUNITS["_"][SupportUnit].UnlimitedAirframes or 
              ( SUPPORTUNITS["_"][SupportUnit].airframes and SUPPORTUNITS["_"][SupportUnit].airframes > 0)) then

      local SRStext = ''
      if trackname == "Default" then
        SRStext = "All players, " .. SupportUnit .. ": pushing Default track."
      else
        SRStext = "All players, " .. SupportUnit .. ": pushing track " .. trackname .. "."
      end

      if not SUPPORTUNITS["_"][SupportUnit].Voice then
        if SpeechVoices == {} then
          SpeechVoices = Utils.DeepCopy(AllSpeechVoices)
        end
        SUPPORTUNITS["_"][SupportUnit].Voice = table.remove(SpeechVoices,math.random(#SpeechVoices))
      end

      local duration = STTS.getSpeechTime(SRStext,0.95)
      VFW51ST_TACCOMMON_msrs:SetLabel(SupportUnit)
      VFW51ST_TACCOMMON_msrs:SetVoice(SUPPORTUNITS["_"][SupportUnit].Voice)

      BASE:I(SupportUnit .. " broadcasting \"" .. SRStext .. "\" on " .. tostring(MAPSOPSETTINGS.TacCommon) .. "." )
      VFW51ST_TACCOMMON_msrsQ:NewTransmission(SRStext,duration,VFW51ST_TACCOMMON_msrs,math.random(2,6),2)
      VFW51ST_TACCOMMON_msrs:SetLabel("MapSOP")
    end
  end

  if SpawnGroup == nil then
    if SUPPORTUNITS["_"][SupportUnit].PreviousMission
      and SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup 
      and SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup:IsAlive() then
        SpawnGroup = SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup:GetGroup()
    else
      if NewTrack then
        local old = CURRENTUNITTRACK[SupportUnit]
        CURRENTUNITTRACK[SupportUnit] = NewTrack
        UpdateFlightMenu(SupportUnit, NewTrack, old)
        if SUPPORTUNITS["_"][SupportUnit].Scheduler then
          SUPPORTUNITS["_"][SupportUnit].Scheduler:Start()
        end
        return
      end
      --return 
    end
  end

  local supportunitfields, track, newtrack

  if NewTrack and SUPPORTUNITS[NewTrack] and SUPPORTUNITS[NewTrack][SupportUnit] then
    supportunitfields = SUPPORTUNITS[NewTrack][SupportUnit]
    track = NewTrack
    local oldtrack = CURRENTUNITTRACK[SupportUnit]
    newtrack = UpdateFlightMenu(SupportUnit, track, oldtrack)
    if not newtrack then
      return
    end
    CURRENTUNITTRACK[SupportUnit] = track
  else
    track = CURRENTUNITTRACK[SupportUnit]
    if not track then 
      return
    end
    supportunitfields = SUPPORTUNITS[track][SupportUnit] or SUPPORTUNITS["_"][SupportUnit]
    newtrack = nil
  end

  local Spawn = SUPPORTUNITS["_"][SupportUnit].Spawn
  local UnlimitedAirframes = SUPPORTUNITS["_"][SupportUnit].UnlimitedAirframes
  local SupportBase = SUPPORTUNITS["_"][SupportUnit].SupportBase

  local OrbitPt1 = supportunitfields.CoordP1
  local OrbitPt2 = supportunitfields.CoordP2

  local OrbitLeg, OrbitPt, OrbitDir
  if OrbitPt1 and OrbitPt2 then
      OrbitLeg = UTILS.MetersToNM( OrbitPt1:Get2DDistance(OrbitPt2) )
      OrbitPt = OrbitPt1
      OrbitDir = OrbitPt1:GetAngleDegrees( OrbitPt1:GetDirectionVec3( OrbitPt2 ) )
  end

  local Mission = nil
  local unittype = supportunitfields[ENUMS.SupportUnitFields.TYPE]

  local FlightGroup
  if SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup and SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup:IsAlive() 
    and SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup:GetGroup():GetName() == SpawnGroup:GetName() then
    FlightGroup = SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup
  else
    FlightGroup = FLIGHTGROUP:New(SpawnGroup)
    if not SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup then
      SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup = FlightGroup
    end
  end

  if not SupportBase then
    SupportBase = FlightGroup:GetClosestAirbase()
  end

  -- Set Radios / TACANS / Callsigns for off-mission support units
  function FlightGroup:PrePostMissionSettings(IsPostMission)
    if supportunitfields.invisible then
      BASE:I("Setting " .. SpawnGroup:GetName() .. " invisible to AI.")
      SpawnGroup:SetCommandInvisible(supportunitfields.invisible)
    end

    if supportunitfields.immortal then
      BASE:I("Setting " .. SpawnGroup:GetName() .. " immortal.")
      SpawnGroup:SetCommandImmortal(supportunitfields.immortal)
    end

    if SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup and SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup:IsAlive() 
        and SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup:GetName() ~= self:GetName() or IsPostMission then

      self:SwitchRadio(258.0)
      self:SwitchCallsign(supportunitfields[ENUMS.SupportUnitFields.CALLSIGN], 8)

      if unittype ~= ENUMS.UnitType.AWACS then
        self:SwitchTACAN( 58, "OFF", FlightGroup:GetUnit(), "Y")
        self:TurnOffTACAN()
      end
    end
    return self
  end

  if not newtrack then
    FlightGroup:PrePostMissionSettings()
  end

  if supportunitfields then
    -- Tanker/AWACS Support Mission
    if unittype == ENUMS.UnitType.AWACS then
        Mission=AUFTRAG:NewAWACS(OrbitPt, supportunitfields[ENUMS.SupportUnitFields.ALTITUDE], 
          supportunitfields[ENUMS.SupportUnitFields.SPEED], OrbitDir, OrbitLeg)
    else
        Mission=AUFTRAG:NewTANKER(OrbitPt, supportunitfields[ENUMS.SupportUnitFields.ALTITUDE], 
          supportunitfields[ENUMS.SupportUnitFields.SPEED], OrbitDir, OrbitLeg, 
          supportunitfields[ENUMS.SupportUnitFields.REFUELINGSYSTEM])
    end
    --Mission.missionAltitude=Mission.orbitAltitude
    Mission:SetMissionAltitude(supportunitfields[ENUMS.SupportUnitFields.ALTITUDE])

    function Mission:OnAfterExecuting(From, Event, To)

      local aliveOpsGroups = false
      for _,og in pairs(self:GetOpsGroups()) do
        if og:IsAlive() then
          aliveOpsGroups = true
        end
      end

      if MAPSOPSETTINGS.UseSRS and VFW51ST_TACCOMMON_msrsQ and SUPPORTUNITS["_"][SupportUnit].IsBlue and aliveOpsGroups then

        local tracktext
        if CURRENTUNITTRACK[SupportUnit] == "_" then
          tracktext = ", Default track."
        else
          tracktext = ", track " ..  CURRENTUNITTRACK[SupportUnit] .. "."
        end

        if not SUPPORTUNITS["_"][SupportUnit].Voice then
          if SpeechVoices == {} then
            SpeechVoices = Utils.DeepCopy(AllSpeechVoices)
          end
          SUPPORTUNITS["_"][SupportUnit].Voice = table.remove(SpeechVoices,math.random(#SpeechVoices))
        end

        local SRStext = "All players, "  .. SupportUnit .. ": On station" .. tracktext
        local duration = STTS.getSpeechTime(SRStext,0.95)
        VFW51ST_TACCOMMON_msrs:SetLabel(SupportUnit)
        VFW51ST_TACCOMMON_msrs:SetVoice(SUPPORTUNITS["_"][SupportUnit].Voice)

        BASE:I(SupportUnit .. " broadcasting \"" .. SRStext .. "\" on " .. tostring(MAPSOPSETTINGS.TacCommon) .. "." )
        VFW51ST_TACCOMMON_msrsQ:NewTransmission(SRStext,duration,VFW51ST_TACCOMMON_msrs,math.random(2,6),2)
        VFW51ST_TACCOMMON_msrs:SetLabel("MapSOP")
      end

      if FlightGroup ~= SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup then 
        if SUPPORTUNITS["_"][SupportUnit].PreviousMission.mission then --and SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup then
          SUPPORTUNITS["_"][SupportUnit].PreviousMission.mission:I("Relief flight on station " .. SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup:GetName() .. " is RTB.")
          SUPPORTUNITS["_"][SupportUnit].PreviousMission.mission:Success()
          if SUPPORTUNITS["_"][SupportUnit][ENUMS.SupportUnitFields.RESPAWNAIR] then
            SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup:Destroy()
          else
            SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup:RTB(SupportBase)
          end

          if unittype ~= ENUMS.UnitType.AWACS then
            -- Stop relieved flight's TACAN schedule
            if SUPPORTUNITS["_"][SupportUnit].TacanScheduler and SUPPORTUNITS["_"][SupportUnit].TacanScheduleID then
              SUPPORTUNITS["_"][SupportUnit].TacanScheduler:Stop(SUPPORTUNITS["_"][SupportUnit].TacanScheduleID)
            end
            SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup:PrePostMissionSettings(true)
          end
        end
      end

      if newtrack and SUPPORTUNITS["_"][SupportUnit].PreviousMission.mission then
        SUPPORTUNITS["_"][SupportUnit].PreviousMission.mission:Success()
      end
      SUPPORTUNITS["_"][SupportUnit].PreviousMission.mission = self
      SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup = FlightGroup

      self:GetOpsGroups()[1]:GetGroup():CommandSetCallsign(supportunitfields[ENUMS.SupportUnitFields.CALLSIGN], supportunitfields[ENUMS.SupportUnitFields.CALLSIGN_NUM])
      FlightGroup:SwitchRadio(tonumber(supportunitfields[ENUMS.SupportUnitFields.RADIOFREQ]))

      if unittype ~= ENUMS.UnitType.AWACS then
        -- Start Tacan after 1 second and every 5 minutes
        if SUPPORTUNITS["_"][SupportUnit].TacanScheduler and SUPPORTUNITS["_"][SupportUnit].TacanScheduleID then
          SUPPORTUNITS["_"][SupportUnit].TacanScheduler:Stop(SUPPORTUNITS["_"][SupportUnit].TacanScheduleID)
        end
        SUPPORTUNITS["_"][SupportUnit].TacanScheduler, SUPPORTUNITS["_"][SupportUnit].TacanScheduleID = SCHEDULER:New( nil, 
            function( TacanFlightGroup )
                TacanFlightGroup:SwitchTACAN( supportunitfields[ENUMS.SupportUnitFields.TACANCHAN],
                                              supportunitfields[ENUMS.SupportUnitFields.TACANMORSE],
                                              FlightGroup:GetUnit(),
                                              supportunitfields[ENUMS.SupportUnitFields.TACANBAND])
            end, { SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup }, 1, 300
        )
      end

    end --Mission:OnAfterExecuting

    local tracktemp = track
    if track == '_' then
      tracktemp = 'Default'
    end

    Mission:SetName(FlightGroup:GetName() .. "-" .. tracktemp .. "-ID:#" .. Mission.auftragsnummer )

  else
    self:E("Support Unit Info Not Found -- track: " .. track .. " Support Unit: " .. SupportUnit)
    return nil
  end

  if newtrack and FlightGroup and FlightGroup:IsAlive() then
    FlightGroup:CancelAllMissions()
  end

  FlightGroup:SetFuelLowRefuel(false)
        :AddMission( Mission )
        :SetFuelLowThreshold(math.random(30,35))  
        :SetFuelLowRTB(false)
        :SetFuelCriticalThreshold(15)
        :SetFuelCriticalRTB(true)
        :SetDefaultSpeed(UTILS.KnotsToAltKIAS(350,30000))
        :SetDefaultAltitude(30000)
        :SetHomebase(SupportBase)
        :SetDestinationbase(SupportBase)
        :SetDefaultTACAN( supportunitfields[ENUMS.SupportUnitFields.TACANCHAN],
                          supportunitfields[ENUMS.SupportUnitFields.TACANMORSE],
                          FlightGroup:GetUnit(),
                          supportunitfields[ENUMS.SupportUnitFields.TACANBAND],
                          true)
        :PrePostMissionSettings()

  function FlightGroup:OnAfterMissionStart(From, Event, To, Mission)
    -- Set things to the pre-executing mission values
    self:PrePostMissionSettings()
    return self
  end

  function FlightGroup:OnAfterMissionDone(From, Event, To, Mission)
    -- Set things to the pre-executing mission values
    if FlightGroup:IsAlive() then
      self:PrePostMissionSettings(true)
    end
    return self
  end

  function FlightGroup:OnAfterElementDead(From, Event, To, Element)
    if SUPPORTUNITS["_"][SupportUnit].TacanScheduler and SUPPORTUNITS["_"][SupportUnit].TacanScheduleID then
      SUPPORTUNITS["_"][SupportUnit].TacanScheduler:Stop(SUPPORTUNITS["_"][SupportUnit].TacanScheduleID)
    end
    FlightGroup:Destroy()

    Spawn:FixAliveGroupCount()
  end

  function FlightGroup:OnAfterDead(From, Event, To)
    -- BASE:I(FlightGroup:GetName() .. " OnAfterDead()")
    -- if FlightGroup:GetGroup():IsAlive() then
    --   BASE:I(FlightGroup:GetGroup():GetName() .. " is Alive?")
    --   BASE:I("First alive Spawn group for " .. Spawn.SpawnTemplatePrefix ..  " is: " .. Spawn:GetFirstAliveGroup():GetName() )
    -- end
    -- self:I("SpawnIndex: " .. Spawn.SpawnIndex)
		-- self:I("SpawnCount: " ..  Spawn.SpawnCount)
    -- self:I("AliveUnits: " .. Spawn.AliveUnits)
    -- self:I("SpawnMaxUnitsAlive: " .. Spawn.SpawnMaxUnitsAlive)
    -- self:I("SpawnMaxGroups: " .. Spawn.SpawnMaxGroups)
  end

  function FlightGroup:OnAfterFuelLow(From, Event, To)
    self:I(self:GetName() .. " fuel low, launching relief flight.")
    local FirstGroup = Spawn:GetFirstAliveGroup()
    local LastGroup = Spawn:GetLastAliveGroup()

    Spawn:FixAliveGroupCount()
    
    local SpawnedGroup
    if CURRENTUNITTRACK[SupportUnit] then
      if SUPPORTUNITS["_"][SupportUnit][ ENUMS.SupportUnitFields.RESPAWNAIR ] and SUPPORTUNITS["_"][SupportUnit].SpawnPt then
        SpawnedGroup = Spawn:SpawnFromCoordinate( SUPPORTUNITS["_"][SupportUnit].SpawnPt )
      else
        SpawnedGroup = Spawn:SpawnAtAirbase( SupportBase, SPAWN.Takeoff.Hot )
      end
    end

  end

  function FlightGroup:OnAfterArrived(From, Event, To)
    -- Make airframe available again in 60 minutes if airframes limited.
    if not UnlimitedAirframes then
      local SupportUnitFields = SUPPORTUNITS["_"][SupportUnit]
      local airframes = SupportUnitFields.airframes or 0
      FlightGroup:I(FlightGroup:GetName() .. " landed, airframe will be refueling for 1 hour before operational. " .. airframes .. " airframes available for this mission.")
      SCHEDULER:New( nil,
        function()
          if SupportUnitFields.airframes then
            SUPPORTUNITS["_"][SupportUnit].airframes = tonumber(SupportUnitFields.airframes) + 1
            Flight:InitLimit( 2, SUPPORTUNITS["_"][SupportUnit].airframes )
          end
          FlightGroup:I(FlightGroup:GetName() .. " refueled and airframe available for new tasking. " .. airframes .. " airframes available for this mission.")
        end, {}, 3600)
    end
  end
end

function InitSupport( SupportBaseParam, RedSupportBase) 

  for SupportUnit,SupportUnitFields in pairs(SUPPORTUNITS["_"]) do
    local SupportBase = SupportBaseParam
    local red = nil
    local UnitName = nil
    local NoRedSupportUnit = nil
    local pattern = "^([Rr][Ee][Dd])-" .. "(.*)"

    red, UnitName =  string.match(SupportUnit,  pattern)
    if red then
      red = string.upper(red)
    end

    if red == "RED" then
      red = true
      NoRedSupportUnit = UnitName
      SupportUnit = "RED-" .. UnitName
      SupportBase = RedSupportBase
    else
      red = nil
    end

    if not SUPPORTUNITS["_"][SupportUnit].PreviousMission then
      SUPPORTUNITS["_"][SupportUnit].PreviousMission = {}
      SUPPORTUNITS["_"][SupportUnit].PreviousMission.flightgroup = nil
      SUPPORTUNITS["_"][SupportUnit].PreviousMission.mission = nil
      SUPPORTUNITS["_"][SupportUnit].PreviousMission.voice = nil
    end
    
    local SupportUnitInfo = SupportUnitFields[ENUMS.SupportUnitFields.TEMPLATE] 
    local SupportUnitType
    local CallsignNum = 0

    if SupportUnitInfo then
      SupportUnitType = SupportUnitInfo[ ENUMS.SupportUnitTemplateFields.UNITTYPE ]
      CallsignNum = SupportUnitFields[ ENUMS.SupportUnitFields.CALLSIGN_NUM ]
      if CallsignNum == nil then
        CallsignNum = 0
      else
        CallsignNum = tonumber(CallsignNum)
      end
    end

    if SupportUnitType == ENUMS.SupportUnitTemplate.BOOMTANKER[ ENUMS.SupportUnitTemplateFields.UNITTYPE ] or
       SupportUnitType == ENUMS.SupportUnitTemplate.PROBETANKER[ ENUMS.SupportUnitTemplateFields.UNITTYPE ] or
       SupportUnitType == ENUMS.SupportUnitTemplate.KC130TANKER[ ENUMS.SupportUnitTemplateFields.UNITTYPE ] or
       SupportUnitType == ENUMS.SupportUnitTemplate.AWACS[ ENUMS.SupportUnitTemplateFields.UNITTYPE ] or
       ( ( CallsignNum > 1 ) and
       ( SupportUnitType == ENUMS.SupportUnitTemplate.NAVYTANKER[ ENUMS.SupportUnitTemplateFields.UNITTYPE ] or
         SupportUnitType == ENUMS.SupportUnitTemplate.NAVYAWACS[ ENUMS.SupportUnitTemplateFields.UNITTYPE ] ) ) then

        local OrbitPt1 = SupportUnitFields.CoordP1
        local OrbitPt2 = SupportUnitFields.CoordP2

        if OrbitPt1 and OrbitPt2 then
            local OrbitLeg = UTILS.MetersToNM( OrbitPt1:Get2DDistance(OrbitPt2) )
            local OrbitPt = OrbitPt1
            local OrbitDir = OrbitPt1:GetAngleDegrees( OrbitPt1:GetDirectionVec3( OrbitPt2 ) )
            
            local SetSupportBase
            if red then
              SetSupportBase = SET_AIRBASE:New():FilterCoalitions("red"):FilterCoalitions("airdrome"):FilterOnce()
            else
              SetSupportBase = SET_AIRBASE:New():FilterCoalitions("blue"):FilterCoalitions("airdrome"):FilterOnce()
            end
            
            if not SupportBase then
              SupportBase = SetSupportBase:FindNearestAirbaseFromPointVec2(POINT_VEC2:NewFromVec3(OrbitPt1:GetVec3()))
            end
            SUPPORTUNITS["_"][SupportUnit].SupportBase = SupportBase

            local airframes = SupportUnitFields.airframes or '0'
            airframes = tonumber(airframes)

            local UnlimitedAirframes = false
            if airframes == 0 then
              UnlimitedAirframes = true
            end

            SUPPORTUNITS["_"][SupportUnit].UnlimitedAirframes = UnlimitedAirframes
          
            local Spawn = SPAWN:NewWithAlias(SupportUnit, SupportUnit .. " Flight")
                :InitLimit( 2, airframes )
                :InitHeading(OrbitDir-180)

            local MenuTable = {}
            for track,trackvalues in pairs(SUPPORTUNITS) do 
                if trackvalues[SupportUnit] then
                  local MenuValue = {}
                  MenuValue.unit = SupportUnit
                  MenuValue.track = track
                  if track ~= "_" then
                    table.insert(MenuTable, MenuValue)
                  end
                end
            end
            table.sort(MenuTable, function (k1, k2) return k1.track < k2.track end)
            if SUPPORTUNITS["_"][SupportUnit] then
              if CURRENTUNITTRACK[SupportUnit] then
                table.insert(MenuTable, {unit=SupportUnit, track="_" })
              else
                table.insert(MenuTable, 1, {unit=SupportUnit, track="_" })
              end
            end

            for _,values in pairs(MenuTable) do
              UpdateFlightMenu(values.unit, values.track)
            end

            -- Apparent bug workaround... only written to handle single-unit tanker/awacs groups
            function Spawn:FixAliveGroupCount()
              self:F( { self.SpawnTemplatePrefix, self.SpawnAliasPrefix } )
              
              local alivecount=0
              for SpawnIndex = self.SpawnCount, 1, -1 do -- Added
                local SpawnGroup = self:GetGroupFromIndex( SpawnIndex )
                if SpawnGroup and SpawnGroup:IsAlive() then
                  alivecount = alivecount + 1 
                end
              end

              if (self.AliveUnits ~= alivecount) then
                self.AliveUnits = alivecount
              end
              return self.AliveUnits
            end
            
            if red then
              Spawn:InitCoalition(coalition.side.RED)
              Spawn:InitCountry(country.id.CJTF_RED)
            end

            Spawn:OnSpawnGroup(
                    ManageFlights, SupportUnit, nil
                  )
            SUPPORTUNITS["_"][SupportUnit].Spawn = Spawn

            if SUPPORTUNITS["_"][SupportUnit].Scheduler == nil then
              SUPPORTUNITS["_"][SupportUnit].Scheduler, SUPPORTUNITS["_"][SupportUnit].ScheduleID = SCHEDULER:New( nil,
                function()
                  if (Spawn:GetFirstAliveGroup() == nil) then
                    Spawn:FixAliveGroupCount()
                    if SupportUnitFields[ ENUMS.SupportUnitFields.RESPAWNAIR ] or
                        (not SupportUnitFields[ ENUMS.SupportUnitFields.GROUNDSTART ] and not ( timer.getAbsTime()-timer.getTime0() > 30 )) then
                      Spawn:InitAirbase(SupportBase, SPAWN.Takeoff.Hot)
                      SUPPORTUNITS["_"][SupportUnit].SpawnPt = OrbitPt:Translate( UTILS.NMToMeters(3), OrbitDir-30, true, false)
                        :SetAltitude(UTILS.FeetToMeters(SupportUnitFields[ENUMS.SupportUnitFields.ALTITUDE]+100), false)
                      Spawn:SpawnFromCoordinate(SUPPORTUNITS["_"][SupportUnit].SpawnPt)
                    else
                      Spawn:SpawnAtAirbase( SupportBase, SPAWN.Takeoff.Hot)
                    end
                  end
                end, {}, 1, 60)
                if not CURRENTUNITTRACK[SupportUnit] then
                  SUPPORTUNITS["_"][SupportUnit].Scheduler:Stop()
                end
            end
            
        end
    end 
  end
end

function InitNavySupport( AircraftCarriers, CarrierMenu)

    local function ends_with(str, ending)
      return ending == "" or str:sub(-#ending) == ending
    end

    local Carriers = {}
    local OTHERUNITS = {}

    -- Deploy a recovery tanker, AWACS, and Rescue Helo for each full Aircraft Carrier
    for CarrierCount,AircraftCarrier in pairs(AircraftCarriers) do
      local pattern = "%d$"
      local CarrierNum = string.match(AircraftCarrier, pattern)
      if CarrierNum == '0' then
        CarrierNum = '9'
      end

      for SupportUnit,SupportUnitFields in pairs(SUPPORTUNITS["_"]) do      
            local SupportUnitInfo = SupportUnitFields[ENUMS.SupportUnitFields.TEMPLATE]
            if SupportUnitInfo == ENUMS.SupportUnitTemplate.NAVYTANKER and ends_with(SupportUnit,CarrierNum) then
                if not SupportUnitFields.zoneP2exists then
                  -- S-3B Recovery Tanker
                  local tanker=RECOVERYTANKER:New(AircraftCarrier, SupportUnit)
                  if not SupportUnitFields[ENUMS.SupportUnitFields.GROUNDSTART] then
                      tanker:SetTakeoffAir()
                  else
                      tanker:SetTakeoffCold()
                  end
                  tanker:SetSpeed(SupportUnitFields[ENUMS.SupportUnitFields.SPEED])
                  tanker:SetRadio(SupportUnitFields[ENUMS.SupportUnitFields.RADIOFREQ])
                  tanker:SetModex(SupportUnitFields[ENUMS.SupportUnitFields.MODEX])
                  tanker:SetAltitude(SupportUnitFields[ENUMS.SupportUnitFields.ALTITUDE])
                  tanker:SetTACAN(SupportUnitFields[ENUMS.SupportUnitFields.TACANCHAN], SupportUnitFields[ENUMS.SupportUnitFields.TACANMORSE])
                  tanker:SetRacetrackDistances(30, 15)
                  tanker:__Start(math.random(2,10))

                  local ScheduleRecoveryTankerTacanStart = SCHEDULER:New( nil, 
                      function( tanker )
                          BASE:T(tanker.lid..string.format(" %s: Activating TACAN Channel %d%s (%s)", SupportUnit, 
                            tanker.TACANchannel, tanker.TACANmode, tanker.TACANmorse))
                          tanker:_ActivateTACAN()
                          BASE:T(tanker.lid..string.format(" %s: Set callsign", SupportUnit))
                      end, { tanker }, 300, 300
                  )
                  SupportBeacons[SupportUnit] = tanker.beacon
                end
            elseif SupportUnitInfo == ENUMS.SupportUnitTemplate.NAVYAWACS and ends_with(SupportUnit,CarrierNum) then
              if not SupportUnitFields.zoneP2exists then

                -- E-2 AWACS
                local awacs=RECOVERYTANKER:New(AircraftCarrier, SupportUnit)
                if not SupportUnitFields[ENUMS.SupportUnitFields.GROUNDSTART] then
                    awacs:SetTakeoffAir()
                else
                    awacs:SetTakeoffCold()
                end
                awacs:SetAWACS()
                awacs:SetTACANoff()
                awacs:SetRadio(SupportUnitFields[ENUMS.SupportUnitFields.RADIOFREQ])
                awacs:SetModex(SupportUnitFields[ENUMS.SupportUnitFields.MODEX])
                awacs:SetAltitude(SupportUnitFields[ENUMS.SupportUnitFields.ALTITUDE])
                awacs:SetRacetrackDistances(40, 20)
                awacs:__Start(math.random(2,10))
              end
            elseif SupportUnitFields[ENUMS.SupportUnitFields.TYPE] == ENUMS.UnitType.SHIP then
              if SupportUnit == AircraftCarrier then 
                local carrier = CARRIER:New(AircraftCarrier)
                carrier.CallsignTTS = SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN]
                carrier.FreqTTS = SupportUnitFields[ENUMS.SupportUnitFields.RADIOFREQ]
                
                carrier:SetTACAN(SupportUnitFields[ENUMS.SupportUnitFields.TACANCHAN], 
                                SupportUnitFields[ENUMS.SupportUnitFields.TACANBAND], 
                                SupportUnitFields[ENUMS.SupportUnitFields.TACANMORSE])
                        :SetBeaconRefresh(5*60)
                
                if SupportUnitFields[ENUMS.SupportUnitFields.ICLSCHAN] and SupportUnitFields[ENUMS.SupportUnitFields.ICLSMORSE] then
                  carrier:SetICLS(SupportUnitFields[ENUMS.SupportUnitFields.ICLSCHAN], SupportUnitFields[ENUMS.SupportUnitFields.ICLSMORSE])
                end       
                
                function carrier:OnAfterStart( From, Event, To )
                  self:I(SupportUnit .. " ACLS activated." )

                  CommandActivateACLS(self.carrier)

                  if SupportUnitFields[ENUMS.SupportUnitFields.RADIOFREQ] then
                    self:I(SupportUnit .. " radio set to " .. SupportUnitFields[ENUMS.SupportUnitFields.RADIOFREQ] .. "MHz AM." )
                    self.carrier:CommandSetFrequency(SupportUnitFields[ENUMS.SupportUnitFields.RADIOFREQ])
                  end
                  if SupportUnitFields[ENUMS.SupportUnitFields.LINK4FREQ] then
                    self:I(SupportUnit .. " Link4 set to " .. SupportUnitFields[ENUMS.SupportUnitFields.LINK4FREQ] .. "MHz." )
                    self.beacon:ActivateLink4(SupportUnitFields[ENUMS.SupportUnitFields.LINK4FREQ], SupportUnitFields[ENUMS.SupportUnitFields.ICLSMORSE])
                  end
                end

                local rescuehelo=RESCUEHELO:New(SupportUnit, "CSAR1")

                if SUPPORTUNITS["_"][ 'CSAR1' ][ ENUMS.SupportUnitFields.GROUNDSTART ] then
                  rescuehelo:SetTakeoffCold()
                else
                  rescuehelo:SetTakeoffAir()
                  rescuehelo:SetRespawnInAir()
                end
                rescuehelo:SetModex( SUPPORTUNITS["_"][ 'CSAR1' ][ ENUMS.SupportUnitFields.MODEX ] + 8 )
                rescuehelo:__Start(2)

                Carriers[SupportUnit] = carrier

                Carriers[SupportUnit]:__Start(math.random(2,10))

                if CarrierMenu == nil then
                  CarrierMenu = MENU_COALITION:New(coalition.side.BLUE, "Carrier Control", BlueParentMenu)
                end
                local CarrierString = string.format("%s\n    -   ATC: %.2f MHz\n    - TACAN: %i%s %s \n    -  ICLS: %i \n    - LINK4: %.2f MHz", 
                                                    SupportUnit, SupportUnitFields[ENUMS.SupportUnitFields.RADIOFREQ], 
                                                    SupportUnitFields[ENUMS.SupportUnitFields.TACANCHAN], 
                                                    SupportUnitFields[ENUMS.SupportUnitFields.TACANBAND],
                                                    SupportUnitFields[ENUMS.SupportUnitFields.TACANMORSE],
                                                    SupportUnitFields[ENUMS.SupportUnitFields.ICLSCHAN],
                                                    SupportUnitFields[ENUMS.SupportUnitFields.LINK4FREQ])
                local CarrierMenu1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, CarrierString .. "\n    Turn into wind for 30 minutes", CarrierMenu, CarrierTurnIntoWind, Carriers[SupportUnit] )
              else
                OTHERUNITS[SupportUnit] = SupportUnitFields
              end
            end
      end
    end
    
    for SupportUnit,SupportUnitFields in pairs(OTHERUNITS) do
      local Ship = UNIT:FindByName(SupportUnit)
      if Ship then
        local ShipBeacon = Ship:GetBeacon()
        if SupportUnitFields[ENUMS.SupportUnitFields.RADIOFREQ] then
          BASE:I(SupportUnit .. " radio set to " .. SupportUnitFields[ENUMS.SupportUnitFields.RADIOFREQ] .. "MHz AM." )
          Ship:CommandSetFrequency(SupportUnitFields[ENUMS.SupportUnitFields.RADIOFREQ])
        end
        -- Schedule TACAN reset every 5 minutes
        if SupportUnitFields[ENUMS.SupportUnitFields.TACANCHAN] and SupportUnitFields[ENUMS.SupportUnitFields.TACANBAND] then 
          local ScheduleShipTacanStart = SCHEDULER:New( nil, 
                  function( Ship )
                      ShipBeacon:ActivateTACAN(SupportUnitFields[ENUMS.SupportUnitFields.TACANCHAN], 
                                              SupportUnitFields[ENUMS.SupportUnitFields.TACANBAND], 
                                              SupportUnitFields[ENUMS.SupportUnitFields.TACANMORSE], 
                                              true)
                  end, { ShipBeacon }, 1, 300
              )
        end
        SupportBeacons[SupportUnit] = ShipBeacon

        if not SupportUnit:find("CVN") then
        -- Rescue Helo for LHAs and other non-carriers
          local rescuehelo=RESCUEHELO:New(SupportUnit, "CSAR1")

          if SUPPORTUNITS["_"][ 'CSAR1' ][ ENUMS.SupportUnitFields.GROUNDSTART ] then
            rescuehelo:SetTakeoffCold()
          else
            if SupportUnit[ ENUMS.SupportUnitFields.GROUNDSTART ] then
              rescuehelo:SetTakeoffCold()
            else
              rescuehelo:SetTakeoffAir()
            end
          end
          rescuehelo:SetModex( SUPPORTUNITS["_"][ 'CSAR1' ][ ENUMS.SupportUnitFields.MODEX ] + 8 )
          rescuehelo:__Start(2)
        end
      end
    end
    return Carriers
end

function CarrierTurnIntoWind( Carrier )

    local Message = Carrier.alias .. " turning into the wind for 30 minutes."
    MESSAGE:New( Message ):ToBlue()
    BASE:I( Message )

    if MAPSOPSETTINGS.UseSRS and VFW51ST_TACCOMMON_msrsQ and Carrier.CallsignTTS then
        if not Carrier.msrs then
          Carrier.msrs = MSRS:New('', Carrier.FreqTTS)
          Carrier.msrs:SetLabel(Carrier.CallsignTTS)
          if MAPSOPSETTINGS.UseSRS == 'gcloud' or MAPSOPSETTINGS.UseSRS == 'google' then
            Carrier.msrs:SetGoogle()
            Carrier.Voice = ENUMS.GoogleVoices[math.random(1,#ENUMS.GoogleVoices)]
          else
            Carrier.msrs:SetWin()
            Carrier.Voice = ENUMS.WinVoices[math.random(1,#ENUMS.WinVoices)]
          end
          Carrier.msrs:SetVoice(Carrier.Voice)
      end

      local SRStext = "All aircraft, "  .. Carrier.CallsignTTS .. ": Turning into wind for 30 minutes." 
      local duration = STTS.getSpeechTime(SRStext,0.95)

      VFW51ST_TACCOMMON_msrsQ:NewTransmission(SRStext,duration,Carrier.msrs,1,2)

      if Carrier.ResumeRadioCall then
        Carrier.ResumeRadioCall:Stop()
      end
      Carrier.ResumeRadioCall = SCHEDULER:New( nil, 
        function()
          local SRStext = "All aircraft, "  .. Carrier.CallsignTTS .. ": Warning, preparing to resume course." 
          local duration = STTS.getSpeechTime(SRStext,0.95)
    
          VFW51ST_TACCOMMON_msrsQ:NewTransmission(SRStext,duration,Carrier.msrs,1,2)
        end, { }, 1730
      )
    end
    
    SCHEDULER:New( nil, 
      function()
        Carrier:CarrierTurnIntoWind(1800, 20, true)
      end, { }, math.random(3,6)
    )

end

function EmergencyTacanReset( BeaconTable )

    MESSAGE:New( "Emergency TACAN reset initiated." ):ToBlue()
    BASE:I("Emergency TACAN reset initiated.")

    -- Reset all carrier beacons
    for CarrierName,Carrier in pairs(BeaconTable[2]) do
        Carrier:_ActivateBeacons()
    end

    -- Reset tanker/ship beacons
    for BeaconName,Beacon in pairs(BeaconTable[1]) do

        SupportUnitFields = SUPPORTUNITS["_"][BeaconName]

        Beacon:ActivateTACAN(SupportUnitFields[ENUMS.SupportUnitFields.TACANCHAN], 
                             SupportUnitFields[ENUMS.SupportUnitFields.TACANBAND], 
                             SupportUnitFields[ENUMS.SupportUnitFields.TACANMORSE], 
                             true)
    end

end

function SetupMANTIS(PrefixRedSAM,PrefixRedEWR,PrefixRedAWACS)
    local NumRedAwacs = SET_GROUP:New():FilterPrefixes(PrefixRedAWACS):FilterOnce():Count()
    local RedIADS = nil

    -- Create the IADS network with wor without AWACS
    if NumRedAwacs > 0 then
        RedIADS = MANTIS:New("RedIADS",PrefixRedSAM,PrefixRedEWR,nil,"red",false,PrefixRedAWACS)
    else
        RedIADS = MANTIS:New("RedIADS",PrefixRedSAM,PrefixRedEWR,nil,"red",false)
    end

    -- Optional Zones for MANTIS IADS
    local AcceptZones = SET_ZONE:New():FilterPrefixes('Red IADS Accept'):FilterOnce():GetSetObjects()
    local RejectZones = SET_ZONE:New():FilterPrefixes('Red IADS Reject'):FilterOnce():GetSetObjects()
    local ConflictZones = SET_ZONE:New():FilterPrefixes('Red IADS Conflict'):FilterOnce():GetSetObjects()
    RedIADS:AddZones(AcceptZones,RejectZones,ConflictZones)

    RedIADS:Start()

    return RedIADS
end

function SetupSKYNET(PrefixRedSAM,PrefixRedEWR,PrefixRedAWACS)
  local redIADS = nil

  --create an instance of the IADS
  redIADS = SkynetIADS:create('Red IADS')

  --add all groups begining with SAM prefix to the IADS:
  redIADS:addSAMSitesByPrefix(PrefixRedSAM)

  --add all units with unit name beginning with EWR prefix to the IADS:
  redIADS:addEarlyWarningRadarsByPrefix(PrefixRedEWR)

  --add all units with unit name beginning with AWACS prefix to the IADS:
  redIADS:addEarlyWarningRadarsByPrefix(PrefixRedAWACS)

  -- Debug messages to log only
  local iadsDebug = redIADS:getDebugSettings()
  iadsDebug.addedEWRadar = true
  iadsDebug.addedSAMSite = true
  iadsDebug.warnings = true
  iadsDebug.radarWentLive = true
  iadsDebug.radarWentDark = true
  iadsDebug.harmDefence = true

  redIADS:activate()

  return redIADS
end

-- =============================================================
-- Init MapSOP
-- =============================================================

SpawnTemplateKeepCallsign = true -- Use MapSOP SPAWN:_Prepare() callsign hack

local SupportBase = nil
local RedSupportBase = nil
local AircraftCarriers = nil

local UseSubMenuText = 'false'
local DisableATCtext = 'false'
local UseSRStext

if MAPSOPSETTINGS.UseSubMenu then
  UseSubMenuText = 'true'
end

if MAPSOPSETTINGS.DisableATC then
  DisableATCtext = 'true'
end

if MAPSOPSETTINGS.UseSRS == nil then
  UseSRStext = 'win'
elseif MAPSOPSETTINGS.UseSRS == false then
  UseSRStext = 'false'
else
  UseSRStext = MAPSOPSETTINGS.UseSRS
end

env.info("")
env.info("== MapSOP Settings ==")
env.info("  PauseTime      : " .. (MAPSOPSETTINGS.PauseTime or MAPSOPSETTINGS.Defaults.PauseTime or ""))
env.info("  UseSubMenu     : " .. UseSubMenuText)
env.info("  DisableATC     : " .. DisableATCtext)
env.info("  UseSRS         : " .. UseSRStext)
env.info("  TacCommon      : " .. (MAPSOPSETTINGS.TacCommon or MAPSOPSETTINGS.Defaults.TacCommon or ""))
env.info("  PrefixRedSAM   : " .. (MAPSOPSETTINGS.PrefixRedSAM or MAPSOPSETTINGS.Defaults.PrefixRedSAM or ""))
env.info("  PrefixRedEWR   : " .. (MAPSOPSETTINGS.PrefixRedEWR or MAPSOPSETTINGS.Defaults.PrefixRedEWR or ""))
env.info("  PrefixRedAWACS : " .. (MAPSOPSETTINGS.PrefixRedAWACS or MAPSOPSETTINGS.Defaults.PrefixRedAWACS or ""))

env.info("")

-- Initialize Airbase & Carriers
SupportBase, RedSupportBase, AircraftCarriers = InitSupportBases()

-- Init land-based support units
InitSupport(SupportBase, RedSupportBase)

-- Setup carrier and carrier group support units
local Carriers = InitNavySupport(AircraftCarriers, CarrierMenu)

-- Base Tacan reset menu
local BlueTacanMenu = MENU_COALITION:New(coalition.side.BLUE, "TACAN Control", BlueParentMenu)
local TacanMenu1 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Emergency TACAN reset", BlueTacanMenu, EmergencyTacanReset, { SupportBeacons, Carriers } )

-- Setup either MANTIS or SKYNET IADS
RedIADS = nil
local NumRedSAMs = SET_GROUP:New():FilterPrefixes(MAPSOPSETTINGS.PrefixRedSAM):FilterOnce():Count()

if NumRedSAMs > 0 then
  BASE:I("Initializing IADS...")
  if samTypesDB == nil then
    BASE:I("Initializing MANTIS IADS.")
    RedIADS = SetupMANTIS(MAPSOPSETTINGS.PrefixRedSAM, MAPSOPSETTINGS.PrefixRedEWR, MAPSOPSETTINGS.PrefixRedAWACS)
  else 
    BASE:I("Initializing SKYNET IADS.")
    RedIADS = SetupSKYNET(MAPSOPSETTINGS.PrefixRedSAM, MAPSOPSETTINGS.PrefixRedEWR, MAPSOPSETTINGS.PrefixRedAWACS)
  end
else
  BASE:E("No group names with 'Red SAM' found, skipping IADS initialization.")
end

-- Server Pause/Resume behavior
local UnpauseZoneSet = SET_ZONE:New():FilterPrefixes("Unpause Client"):FilterOnce()
local UnpauseUnitNames = {}

local ClientSet = SET_CLIENT:New():FilterActive()

BASE:I("Unpause Zone Count: " .. UnpauseZoneSet:Count())
ClientSet:FilterStart()

UnpauseZoneSet:ForEachZone( 
  function(Zone)
    local unitprop = Zone:GetProperty("Unit")
    if unitprop and string.lower(unitprop) ~= "SOP" and string.lower(unitprop) ~= "none" then 
      UnpauseUnitNames[unitprop] = Zone:GetName()
    end
  end, {}
 )
BASE:I("Mission auto-pause time: " .. MAPSOPSETTINGS.PauseTime)

local PauseScheduler = nil 
local ConsecutiveNoAlive = nil
local UnpauseClientsSlotted = nil

if MAPSOPSETTINGS.PauseTime and MAPSOPSETTINGS.PauseTime > 0 then
  SCHEDULER:New( nil, 
  function()
    if not UnpauseClientsSlotted then
      ServerPause()
    end
  end, { }, MAPSOPSETTINGS.PauseTime
  )
  PauseScheduler = SCHEDULER:New( nil, 
  function()
        ServerPauseIfEmpty()
  end, { }, 300, 300
  )
end

function SetEventHandler()
    ClientBirth = ClientSet:HandleEvent(EVENTS.PlayerEnterAircraft)
end

function ClientSet:OnEventPlayerEnterAircraft(event_data)
    local unit_name = event_data.IniUnitName
    local unit = UNIT:FindByName(unit_name)
    local group = event_data.IniGroup
    local player_name = event_data.IniPlayerName

    env.info("Client connected!")
    env.info(unit_name)
    env.info(player_name)

    if UnpauseZoneSet:Count() > 0 then 
      if UnpauseZoneSet:IsCoordinateInZone( unit:GetCoordinate() ) then
        BASE:I(unit_name .. " found inside an Unpause Zone, unpausing server..." )
        UnpauseClientsSlotted = true
        ServerUnpause()
      end
      if UnpauseUnitNames[unit_name] then
          BASE:I(unit_name .. " Unit property found in " .. UnpauseUnitNames[unit_name] .. ", unpausing server..." )
          UnpauseClientsSlotted = true
          ServerUnpause()
      end
    else
      UnpauseClientsSlotted = true
      ServerUnpause()
    end
end

-- Scripting-only function to instantly remove a flight and stop re-launch/re-spawns
function RemoveFlight(FlightName)
  if SUPPORTUNITS["_"][FlightName] then
    BASE:I("RemoveFlight called for " .. FlightName .. ", removing.")
    if SUPPORTUNITS["_"][FlightName].PreviousMission and SUPPORTUNITS["_"][FlightName].PreviousMission.flightgroup then
      if SUPPORTUNITS["_"][FlightName].PreviousMission.flightgroup:IsAlive() then
        SUPPORTUNITS["_"][FlightName].PreviousMission.flightgroup:Destroy()
      end
    end
    if SUPPORTUNITS["_"][FlightName].Scheduler then
      SUPPORTUNITS["_"][FlightName].Scheduler:Stop()
    end
  end
end

-- Scripting-only function to instantly re-add a flight removed by RemoveFlight
function ReAddFlight(FlightName)
  if SUPPORTUNITS["_"][FlightName] then
    BASE:I("ReAddFlight called for " .. FlightName .. ", re-adding.")
    if SUPPORTUNITS["_"][FlightName].Scheduler then
      SUPPORTUNITS["_"][FlightName].Scheduler:Start()
    end
  end
end

SetEventHandler()

env.info("=== 51stMapSOP v" .. MAPSOP_VERSION .. " is executing ===")