-- 51st MapSOP
-- Initial version by Blackdog Jan 2022
--
-- Tested against MOOSE GITHUB Commit Hash ID:
-- 2022-08-04T20:13:18.0000000Z-fa0549f34ff9c2317de11ec2dfb95c786e1f947c
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
--
-- Known issues:
--   - Extra Non-SOP Shell/Magic units act like land-based Tankers/AWACS.
--   - While RTB, relieved Tankers/AWACS still show up in the radio menu, but at least now as the '9' callsign.
--   - ACLS does not work for CVN-70 (USS Carl Vincent, apparently not a 'real' DCS SuperCarrier).

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
    TEMPLATE        =   16  -- ENUMS.SupportUnitTemplate.BOOMTANKER -- Unit template type
}

local SUPPORTUNITS = {}

-- Set according to 51st SOPs: https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/missionsEditingSOPs.md
-- CALLSIGN, CALLSIGN_NUM, TYPE, RADIOFREQ, TACANCHAN, TACANBAND, TACANMORSE, ICLSCHAN, ICLSMORSE, LINK4FREQ, ALTITUDE, SPEED, MODEX, REFUELINGSYSTEM, GROUNDSTART, TEMPLATE

-- Tankers
SUPPORTUNITS[ "Texaco1" ] = { CALLSIGN.Tanker.Texaco,  1, ENUMS.UnitType.TANKER,  251.00, 51, ENUMS.TacanBand.Y, "TX1", nil, nil, nil, 25000, 300, 251, ENUMS.RefuelingSystem.BOOM, false, ENUMS.SupportUnitTemplate.BOOMTANKER }
SUPPORTUNITS[ "Texaco2" ] = { CALLSIGN.Tanker.Texaco,  2, ENUMS.UnitType.TANKER,  252.00, 52, ENUMS.TacanBand.Y, "TX2", nil, nil, nil, 15000, 220, 252, ENUMS.RefuelingSystem.BOOM, false, ENUMS.SupportUnitTemplate.BOOMTANKER }
SUPPORTUNITS[ "Arco1" ]   = { CALLSIGN.Tanker.Arco,    1, ENUMS.UnitType.TANKER,  253.00, 53, ENUMS.TacanBand.Y, "AR1", nil, nil, nil, 20000, 285, 254, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.PROBETANKER }
SUPPORTUNITS[ "Arco2" ]   = { CALLSIGN.Tanker.Arco,    2, ENUMS.UnitType.TANKER,  254.00, 54, ENUMS.TacanBand.Y, "AR2", nil, nil, nil, 21000, 285, 255, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.PROBETANKER }
-- Tankers for each CVN
SUPPORTUNITS[ "Shell9" ] =  { CALLSIGN.Tanker.Shell,   9, ENUMS.UnitType.TANKER,  270.80, 120, ENUMS.TacanBand.Y, "SH9", nil, nil, nil,  6000, 285, 220, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.NAVYTANKER }
SUPPORTUNITS[ "Shell1" ]  = { CALLSIGN.Tanker.Shell,   1, ENUMS.UnitType.TANKER,  271.80, 121, ENUMS.TacanBand.Y, "SH1", nil, nil, nil,  6000, 285, 221, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.NAVYTANKER }
SUPPORTUNITS[ "Shell2" ]  = { CALLSIGN.Tanker.Shell,   2, ENUMS.UnitType.TANKER,  272.80, 122, ENUMS.TacanBand.Y, "SH2", nil, nil, nil,  6000, 285, 222, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.NAVYTANKER }
SUPPORTUNITS[ "Shell3" ]  = { CALLSIGN.Tanker.Shell,   3, ENUMS.UnitType.TANKER,  273.80, 123, ENUMS.TacanBand.Y, "SH3", nil, nil, nil,  6000, 285, 223, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.NAVYTANKER }
SUPPORTUNITS[ "Shell4" ]  = { CALLSIGN.Tanker.Shell,   4, ENUMS.UnitType.TANKER,  274.80, 124, ENUMS.TacanBand.Y, "SH4", nil, nil, nil,  6000, 285, 224, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.NAVYTANKER }
SUPPORTUNITS[ "Shell5" ]  = { CALLSIGN.Tanker.Shell,   5, ENUMS.UnitType.TANKER,  275.80, 125, ENUMS.TacanBand.Y, "SH5", nil, nil, nil,  6000, 285, 225, ENUMS.RefuelingSystem.PROBE, false, ENUMS.SupportUnitTemplate.NAVYTANKER }

-- AWACS
SUPPORTUNITS[ "Overlord1" ] = { CALLSIGN.AWACS.Overlord,    1, ENUMS.UnitType.AWACS,  240.00, nil, nil, nil, nil, nil, nil, 30000, 310, 240, nil, false, ENUMS.SupportUnitTemplate.AWACS }
-- AWACS for each CVN
SUPPORTUNITS[ "Magic9" ]   =  { CALLSIGN.AWACS.Magic,       9, ENUMS.UnitType.AWACS,  270.60, nil, nil, nil, nil, nil, nil, 25000, 259, 240, nil, false, ENUMS.SupportUnitTemplate.NAVYAWACS }
SUPPORTUNITS[ "Magic1" ]    = { CALLSIGN.AWACS.Magic,       1, ENUMS.UnitType.AWACS,  271.60, nil, nil, nil, nil, nil, nil, 25000, 259, 241, nil, false, ENUMS.SupportUnitTemplate.NAVYAWACS }
SUPPORTUNITS[ "Magic2" ]    = { CALLSIGN.AWACS.Magic,       2, ENUMS.UnitType.AWACS,  272.60, nil, nil, nil, nil, nil, nil, 25000, 259, 242, nil, false, ENUMS.SupportUnitTemplate.NAVYAWACS }
SUPPORTUNITS[ "Magic3" ]    = { CALLSIGN.AWACS.Magic,       3, ENUMS.UnitType.AWACS,  273.60, nil, nil, nil, nil, nil, nil, 25000, 259, 243, nil, false, ENUMS.SupportUnitTemplate.NAVYAWACS }
SUPPORTUNITS[ "Magic4" ]    = { CALLSIGN.AWACS.Magic,       4, ENUMS.UnitType.AWACS,  274.60, nil, nil, nil, nil, nil, nil, 25000, 259, 244, nil, false, ENUMS.SupportUnitTemplate.NAVYAWACS }
SUPPORTUNITS[ "Magic5" ]    = { CALLSIGN.AWACS.Magic,       5, ENUMS.UnitType.AWACS,  275.60, nil, nil, nil, nil, nil, nil, 25000, 259, 245, nil, false, ENUMS.SupportUnitTemplate.NAVYAWACS }

-- Navy
SUPPORTUNITS[ "LHA-1"  ] = { nil, nil, ENUMS.UnitType.SHIP,  264.40, 64, ENUMS.TacanBand.X, "TAR", 1,   "TAR", nil,    nil, nil, 264, nil, false, nil }
SUPPORTUNITS[ "CVN-70" ] = { nil, nil, ENUMS.UnitType.SHIP,  270.40, 70, ENUMS.TacanBand.X, "CVN", 10,  "CVN", 270.20, nil, nil, 270, nil, false, nil }
SUPPORTUNITS[ "CVN-71" ] = { nil, nil, ENUMS.UnitType.SHIP,  271.40, 71, ENUMS.TacanBand.X, "TDY", 11,  "TDY", 271.20, nil, nil, 271, nil, false, nil }
SUPPORTUNITS[ "CVN-72" ] = { nil, nil, ENUMS.UnitType.SHIP,  272.40, 72, ENUMS.TacanBand.X, "ABE", 12,  "ABE", 272.20, nil, nil, 272, nil, false, nil }
SUPPORTUNITS[ "CVN-73" ] = { nil, nil, ENUMS.UnitType.SHIP,  273.40, 73, ENUMS.TacanBand.X, "WSH", 13,  "WSH", 273.20, nil, nil, 273, nil, false, nil }
SUPPORTUNITS[ "CVN-74" ] = { nil, nil, ENUMS.UnitType.SHIP,  274.40, 74, ENUMS.TacanBand.X, "STN", 14,  "STN", 274.20, nil, nil, 274, nil, false, nil }
SUPPORTUNITS[ "CVN-75" ] = { nil, nil, ENUMS.UnitType.SHIP,  275.40, 75, ENUMS.TacanBand.X, "TRU", 15,  "TRU", 275.20, nil, nil, 275, nil, false, nil }

-- Rescue Helo
SUPPORTUNITS[ "CSAR1" ] = { CALLSIGN.Aircraft.Pontiac , 8, ENUMS.UnitType.HELICOPTER, nil, nil, nil, nil, nil, nil, nil, nil, nil, 265, nil, false, ENUMS.SupportUnitTemplate.RESCUEHELO }

-- If no "Support Airbase" exists, then use a default airbase for each map
local DEFAULTSUPPORTAIRBASES = { 
    AIRBASE.Caucasus.Batumi,
    AIRBASE.Nevada.Nellis_AFB,
    AIRBASE.PersianGulf.Al_Dhafra_AB,
    AIRBASE.Syria.Incirlik,
    AIRBASE.MarianaIslands.Andersen_AFB
}

function TEMPLATE.SetPayload(Template, Fuel, Flare, Chaff, Gun, Pylons, UnitNum)
    Template["units"][UnitNum or 1]["payload"]["fuel"] = tostring(Fuel or 0)
    Template["units"][UnitNum or 1]["payload"]["flare"] = Flare or 0
    Template["units"][UnitNum or 1]["payload"]["chaff"] = Chaff or 0
    Template["units"][UnitNum or 1]["payload"]["gun"] = Gun or 0
    Template["units"][UnitNum or 1]["payload"]["pylons"] = Pylons or {}
    return Template
end

local SupportBeacons = {}
local SpawnSchedule = {}

-- Overriding MOOSE function to hack callsign behavior
-- Don't change template callsign if SpawnTemplateKeepCallsign is True
local SpawnTemplateKeepCallsign = nil
--- Prepares the new Group Template.
-- @param #SPAWN self
-- @param #string SpawnTemplatePrefix
-- @param #number SpawnIndex
-- @return #SPAWN self
function SPAWN:_Prepare( SpawnTemplatePrefix, SpawnIndex ) --R2.2
	self:F( { self.SpawnTemplatePrefix, self.SpawnAliasPrefix } )
	
--	if not self.SpawnTemplate then
--	  self.SpawnTemplate = self:_GetTemplate( SpawnTemplatePrefix )
--	end
	
  local SpawnTemplate
  if self.TweakedTemplate ~= nil and self.TweakedTemplate == true then
    BASE:I("WARNING: You are using a tweaked template.")
    SpawnTemplate = self.SpawnTemplate
  else
    SpawnTemplate = self:_GetTemplate( SpawnTemplatePrefix )
    SpawnTemplate.name = self:SpawnGroupName( SpawnIndex )
  end

	
	SpawnTemplate.groupId = nil
	--SpawnTemplate.lateActivation = false
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
      if type(Callsign) ~= "number" then -- blue callsign
        if not SpawnTemplateKeepCallsign then  -- MapSOP mod
          Callsign[2] = ( ( SpawnIndex - 1 ) % 10 ) + 1
        end -- MapSOP mod
        local CallsignName = SpawnTemplate.units[UnitID].callsign["name"] -- #string
        local CallsignLen = CallsignName:len()
        SpawnTemplate.units[UnitID].callsign["name"] = CallsignName:sub(1,CallsignLen) .. SpawnTemplate.units[UnitID].callsign[2] .. SpawnTemplate.units[UnitID].callsign[3]
      else
        SpawnTemplate.units[UnitID].callsign = Callsign + SpawnIndex
      end
    end
  end
	
	self:T3( { "Template:", SpawnTemplate } )
	return SpawnTemplate
		
end

--- Activate Link4 system of the CONTROLLABLE. The controllable should be an aircraft carrier!
-- @param #CONTROLLABLE Controllable
-- @param #number Frequency Radio frequency in MHz.
-- @return #CONTROLLABLE Controllable
function CommandActivateLink4(Controllable, Frequency)
  local UnitID=UnitID or Controllable:GetID()

  -- Command to activate Link4 system.
  local CommandActivateLink4Obj= {
    id = "ActivateLink4",
    params= {
      ["frequency"] = Frequency*1000000,
      ["unitId"] = UnitID,
    }
  }

  Controllable:SetCommand(CommandActivateLink4Obj)

  return Controllable
end

--- Dectivate Link4 system of the CONTROLLABLE. The controllable should be an aircraft carrier!
-- @param #CONTROLLABLE Controllable
-- @return #CONTROLLABLE Controllable
function CommandDeactivateLink4(Controllable)

  -- Command to deactivate Link4 system.
  local CommandDeactivateLink4Obj= {
    id = "DeactivateLink4",
    params= {}
  }

  Controllable:SetCommand(CommandDeactivateLink4Obj)

  return Controllable
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
      self:I(self.lid..string.format("Activating TACAN Channel %d%s (%s)", self.TACANchannel, self.TACANmode, self.TACANmorse))
      self.beacon:ActivateTACAN(self.TACANchannel, self.TACANmode, self.TACANmorse, true)
    end
  
    -- Activate ICLS.
    if self.ICLSon then
      self:I(self.lid..string.format("Activating ICLS Channel %d (%s)", self.ICLSchannel, self.ICLSmorse))
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

    local AirbaseName = nil
    local RedAirbaseName = nil
    local AirbaseZone = ZONE:FindByName("Support Airbase")
    local RedAirbaseZone = ZONE:FindByName("Red Support Airbase")
    local AircraftCarriers = {}
    local VTOLcarriers = {}

    if AirbaseZone then
        AirbaseName = AirbaseZone:GetCoordinate(0):GetClosestAirbase(Airbase.Category.AIRDROME, coalition.side.BLUE):GetName()
    end

    if RedAirbaseZone then
      RedAirbaseName = RedAirbaseZone:GetCoordinate(0):GetClosestAirbase(Airbase.Category.AIRDROME, coalition.side.RED):GetName()
    end

    if not AirbaseName then
        local Airbases = AIRBASE.GetAllAirbases(nil, Airbase.Category.AIRDROME)
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

    CLEANUP_AIRBASE:New(SupportBase:GetName()):SetCleanMissiles(false)

    local CarrierShips = AIRBASE.GetAllAirbases(coalition.side.BLUE, Airbase.Category.SHIP)
    for _,CarrierShip in pairs(CarrierShips) do
        local ShipName = CarrierShip:GetName()
        local ShipInfo = SUPPORTUNITS[ShipName]

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
    
    local callsigns = CALLSIGN.Tanker
    for k,v in pairs(CALLSIGN.AWACS) do callsigns[k] = v end
    callsigns['CSAR'] = 8
  
    for  _,P1zone in ipairs(P1zones) do

      local callsign, num, param

      local IsRed = false
      local P1zoneParse = P1zone
      if string.find(P1zone, "^RED%-") then
        IsRed = true
        P1zoneParse = string.gsub(P1zone, "RED%-", "")
      end

      local pattern = "^(%a+)" .. "(%d)" .. "-*" .. "(.*)" .. "-P1"
      callsign, num, param =  string.match(P1zoneParse,  pattern)

      if callsigns[callsign] ~= nil then

        if num then 
          
          local FullCallsign = callsign .. num
          local NoRedFullCallsign = FullCallsign
          if IsRed then
            FullCallsign = "RED-" .. FullCallsign
          end

          local template,alt,speed,freq,tacan,tacanband,invisible,airframes,groundstart

          template = template or 1
          
          if SUPPORTUNITS[ FullCallsign ] == nil then
            if SUPPORTUNITS[ callsign .. template ] ~= nil then
              SUPPORTUNITS[ FullCallsign ] = routines.utils.deepCopy(SUPPORTUNITS[ callsign .. "1" ])
            else
              SUPPORTUNITS[ FullCallsign ] = routines.utils.deepCopy(SUPPORTUNITS[ callsign .. template ])
            end
          end

          if param then
            for token in string.gmatch(param, "[^-]+") do
              template = template or string.match(token, "T(%d)")
    
              local op,newalt = string.match(token, "FL([mp]?)(%d+)")
              if newalt then
                if op == "p" then
                  alt = (SUPPORTUNITS[ FullCallsign ][ ENUMS.SupportUnitFields.ALTITUDE ] ) + (newalt * 100)
                elseif op == "m" then
                  alt = (SUPPORTUNITS[ FullCallsign ][ ENUMS.SupportUnitFields.ALTITUDE ] ) - (newalt * 100)
                else
                  alt = newalt * 100
                end
              end

              local op,newspeed = string.match(token, "SP([mp]?)(%d+)")
              if newspeed then
                if op == "p" then
                  speed = SUPPORTUNITS[ FullCallsign ][ ENUMS.SupportUnitFields.SPEED ] + newspeed
                elseif op == "m" then
                  speed = SUPPORTUNITS[ FullCallsign ][ ENUMS.SupportUnitFields.SPEED ] - newspeed
                else
                  speed = newspeed
                end
              end

              freq = freq or string.match(token, "FR(%d+%.*%d*)")
              tacan = tacan or string.match(token, "TC(%d+)%u")
              tacanband = tacanband or string.match(token, "TC%d+(%u)")
              
              invisible = invisible or string.match(token, "INV")
              if invisible == "INV" then
                invisible = true
              end

              groundstart = groundstart or string.match(token, "GND")
              if groundstart == "GND" then
                groundstart = true
              end

              airframes = airframes or string.match(token, "QTY(%d+)")

            end
          end

          if airframes then
            SUPPORTUNITS[ FullCallsign ].airframes = airframes
          end

          if num then
            SUPPORTUNITS[ FullCallsign ][ ENUMS.SupportUnitFields.CALLSIGN_NUM ] = num
          end

          if alt then
            SUPPORTUNITS[ FullCallsign ][ ENUMS.SupportUnitFields.ALTITUDE ] = alt
          end
          if speed then
            SUPPORTUNITS[ FullCallsign ][ ENUMS.SupportUnitFields.SPEED ] = speed
          end
          if freq then
            SUPPORTUNITS[ FullCallsign ][ ENUMS.SupportUnitFields.RADIOFREQ ] = freq
          end
          if tacan and tacanband then
            SUPPORTUNITS[ FullCallsign ][ ENUMS.SupportUnitFields.TACANCHAN ] = tacan
            SUPPORTUNITS[ FullCallsign ][ ENUMS.SupportUnitFields.TACANBAND ] = tacanband
          end

          if invisible then
            SUPPORTUNITS[ FullCallsign ].invisible = true
          end

          if groundstart then
            SUPPORTUNITS[ FullCallsign ][ ENUMS.SupportUnitFields.GROUNDSTART ] = true
          end

          if SUPPORTUNITS[ FullCallsign ][ ENUMS.SupportUnitFields.TACANCHAN ] then
            pattern = "^(%a+)%d"
            local morse = SUPPORTUNITS[ callsign .. template ][ ENUMS.SupportUnitFields.TACANMORSE ]
            local MorseAlphas

            if morse then
              MorseAlphas = string.match( morse, pattern )
            end

            if MorseAlphas then
              SUPPORTUNITS[ FullCallsign ][ ENUMS.SupportUnitFields.TACANMORSE ] = MorseAlphas .. num
            else
              SUPPORTUNITS[ FullCallsign ][ ENUMS.SupportUnitFields.TACANMORSE ] = "GAS"
            end
          end
          
          local P1 = ZONE:FindByName(P1zone)
          if P1 then
            SUPPORTUNITS[ FullCallsign ].CoordP1 = P1:GetCoordinate()
          end

        end
      end
    end

    for  _,P2zone in ipairs(P2zones) do
      local callsign, num, param
      local pattern = "^(%a+)" .. "(%d)" .. "-*" .. "(.*)" .. "-P2"

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
          local P2 = ZONE:FindByName(FullCallsign .. "-P2")
          if P2 then
            SUPPORTUNITS[ FullCallsign ].CoordP2 = P2:GetCoordinate()
            SUPPORTUNITS[ FullCallsign ].zoneP2exists = true
          end
        end
      end
    end

    -- Spawn late activated template units to use as basis for squadrons and such
    for SupportUnit,SupportUnitFields in pairs(SUPPORTUNITS) do
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
                --TEMPLATE.SetCallsign(SpawnTemplate, SupportUnit, SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN], SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN_NUM])
                if SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN] and SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN_NUM] then
                  SpawnTemplate.units[1].callsign = 
                    {
                        [1] = SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN],
                        [2] = SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN_NUM],
                        [3] = 1,
                        ["name"] = SupportUnit .. "1",
                    }
                end

                if SupportUnitFields[ENUMS.SupportUnitFields.SPEED] then
                  BASE:I("Setting speed for " .. SupportUnit .. ".")
                  SpawnTemplate.route.points[1].speed = 350
                  SpawnTemplate.units[1].speed = 350
                end

                --BASE:I(SpawnTemplate.units[1].callsign)
                TEMPLATE.SetPayload(SpawnTemplate, SupportUnitInfo[ENUMS.SupportUnitTemplateFields.FUEL], SupportUnitInfo[ENUMS.SupportUnitTemplateFields.FLARE], 
                    SupportUnitInfo[ENUMS.SupportUnitTemplateFields.CHAFF], SupportUnitInfo[ENUMS.SupportUnitTemplateFields.GUNS], {})

                SpawnTemplateKeepCallsign = true -- Use MapSOP SPAWN:_Prepare() callsign hack
                SPAWN:NewFromTemplate( SpawnTemplate, SupportUnit .. " Group", SupportUnit)
                  :InitLateActivated()
                  :InitModex(SupportUnitFields[ENUMS.SupportUnitFields.MODEX])
                  :InitAirbase(SupportBase, SPAWN.Takeoff.Hot)
                  :OnSpawnGroup(
                    function( SpawnGroup )
                      if SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN] and SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN_NUM] then
                        SpawnGroup:CommandSetCallsign(SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN], SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN_NUM])
                      end
                    end)
                  :Spawn()
                SpawnTemplateKeepCallsign = nil
            end
        end
    end
    return SupportBase, RedSupportBase, AircraftCarriers
end


function InitSupport( SupportBaseParam, RedSupportBase, InAir ) 

  for SupportUnit,SupportUnitFields in pairs(SUPPORTUNITS) do

    local SupportBase = SupportBaseParam
    local red = nil
    local UnitName = nil
    local NoRedSupportUnit = nil
    local pattern = "^(RED)-" .. "(.*)"
    local Scheduler = {}
    Scheduler[SupportUnit] = {}
    Scheduler[SupportUnit].Scheduler = nil 
    Scheduler[SupportUnit].TacanScheduleID = nil

    red, UnitName =  string.match(SupportUnit,  pattern)

    if red == "RED" then
      NoRedSupportUnit = UnitName
      SupportUnit = "RED-" .. UnitName
      SupportBase = RedSupportBase
    end

    local PreviousMission = {}
    PreviousMission[SupportUnit] = {}
    PreviousMission[SupportUnit].flightgroup = nil
    PreviousMission[SupportUnit].mission = nil
    
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

            local SetSupportBase = SET_AIRBASE:New():FilterCoalitions("red"):FilterCoalitions("airdrome"):FilterOnce()
            if not SupportBase then
              SupportBase = SetSupportBase:FindNearestAirbaseFromPointVec2(POINT_VEC2:NewFromVec3(OrbitPt1:GetVec3()))
            end

            local airframes = SupportUnitFields.airframes or '0'
            airframes = tonumber(airframes)

            local UnlimitedAirframes = false
            if airframes == 0 then
              BASE:I('Allowing unlimited airframes for ' .. SupportUnit .. '.')
              UnlimitedAirframes = true
            else
              BASE:I('Limiting ' .. SupportUnit .. ' to ' .. tostring(airframes) .. ' available airframes.')
            end
            
            local Flight = SPAWN:NewWithAlias(SupportUnit, SupportUnit .. " Flight")
                :InitLimit( 2, airframes )
                :InitHeading(OrbitDir)
            
            if red then
              Flight:InitCoalition(coalition.side.RED)
              Flight:InitCountry(country.id.CJTF_RED)
            end

            Flight:OnSpawnGroup(
                    function( SpawnGroup, SupportUnit, SupportUnitFields, SupportUnitInfo, Spawn, SupportBase, OrbitLeg, OrbitPt, OrbitDir )

                        local RouteToMission = nil
                        local Mission = nil

                        if SupportUnitFields.invisible then
                          BASE:I("Setting " .. SpawnGroup:GetName() .. " invisible to AI.")
                        end
                        SpawnGroup:SetCommandInvisible(SupportUnitFields.invisible)

                        -- Mission to get on-station
                        RouteToMission = AUFTRAG:NewORBIT(OrbitPt, SupportUnitFields[ENUMS.SupportUnitFields.ALTITUDE], 350, OrbitDir, OrbitLeg)

                        function RouteToMission:OnAfterStarted(From, Event, To)
                          self:I("Started mission " .. self:GetName() .. ".")
                          table.remove(self:GetOpsGroups()):GetGroup():CommandSetCallsign(SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN], SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN_NUM])
                        end
                        
                        function RouteToMission:OnAfterExecuting(From, Event, To)
                          self:I("Executing mission " .. RouteToMission:GetName() .. ".")
                          if PreviousMission[SupportUnit].mission then --and PreviousMission[SupportUnit].flightgroup then
                              PreviousMission[SupportUnit].mission:I("Relief flight on station " .. PreviousMission[SupportUnit].flightgroup:GetName() .. " is RTB.")
                              PreviousMission[SupportUnit].mission:Success()
                              PreviousMission[SupportUnit].flightgroup:GetGroup()
                                :CommandSetCallsign(SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN], 9)
                              PreviousMission[SupportUnit].flightgroup:SwitchRadio(tonumber(SupportUnitFields[ENUMS.SupportUnitFields.RADIOFREQ]) + .8)
                              PreviousMission[SupportUnit].flightgroup:TurnOffRadio()
                              PreviousMission[SupportUnit].flightgroup:RTB(SupportBase)
                          end
                          PreviousMission[SupportUnit].mission = self
                          PreviousMission[SupportUnit].flightgroup = table.remove(self:GetOpsGroups())
                        end

                        RouteToMission:SetDuration(2)

                        -- Actual mission to start when on-station
                        if SupportUnitInfo == ENUMS.SupportUnitTemplate.AWACS then
                            Mission=AUFTRAG:NewAWACS(OrbitPt, SupportUnitFields[ENUMS.SupportUnitFields.ALTITUDE], 
                              UTILS.KnotsToAltKIAS(SupportUnitFields[ENUMS.SupportUnitFields.SPEED], 
                              SupportUnitFields[ENUMS.SupportUnitFields.ALTITUDE]), OrbitDir, OrbitLeg)
                        else
                            Mission=AUFTRAG:NewTANKER(OrbitPt, SupportUnitFields[ENUMS.SupportUnitFields.ALTITUDE], 
                              UTILS.KnotsToAltKIAS(SupportUnitFields[ENUMS.SupportUnitFields.SPEED], 
                              SupportUnitFields[ENUMS.SupportUnitFields.ALTITUDE]), OrbitDir, OrbitLeg, 
                              SupportUnitFields[ENUMS.SupportUnitFields.REFUELINGSYSTEM])
                        end
                        Mission:SetRadio(SupportUnitFields[ENUMS.SupportUnitFields.RADIOFREQ])

                        function Mission:OnAfterExecuting(From, Event, To)
                            self:I("Executing mission " .. self:GetName() .. ".")

                            -- Exclude AWACS from TACAN scheduling
                            if SupportUnitInfo ~= ENUMS.SupportUnitTemplate.AWACS and
                               SupportUnitInfo ~= ENUMS.SupportUnitTemplate.NAVYAWACS then
                                
                                PreviousMission[SupportUnit].flightgroup:TurnOffTACAN()

                                -- Stop relieved flight's TACAN schedule
                                if Scheduler[SupportUnit].Scheduler and Scheduler[SupportUnit].TacanScheduleID then
                                  Scheduler[SupportUnit].Scheduler:Stop(Scheduler[SupportUnit].TacanScheduleID)
                                end

                                -- Start Tacan after 1 second and every 5 minutes
                                Scheduler[SupportUnit].Scheduler, Scheduler[SupportUnit].TacanScheduleID = SCHEDULER:New( nil, 
                                    function( TacanFlightGroup )
                                        BASE:I(TacanFlightGroup.lid..string.format(" %s: Activating TACAN Channel %d%s (%s)", TacanFlightGroup:GetName(), 
                                                TacanFlightGroup.tacanDefault.Channel, TacanFlightGroup.tacanDefault.Band, TacanFlightGroup.tacanDefault.Morse))
                                        TacanFlightGroup:SwitchTACAN()
                                    end, { PreviousMission[SupportUnit].flightgroup }, 1, 300
                                )
                            end
                        end

                        FlightGroup = FLIGHTGROUP:New( SpawnGroup )

                        RouteToMission:SetName(FlightGroup:GetName() .. "-RouteToMission")
                        Mission:SetName(FlightGroup:GetName() .. "-PrimaryMission")

                        FlightGroup:SetFuelLowRefuel(false)
                              :AddMission( RouteToMission )
                              :AddMission( Mission )
                              :SetFuelLowThreshold(math.random(25,30))
                              :SetFuelLowRTB(false)
                              :SetFuelCriticalThreshold(15)
                              :SetFuelCriticalRTB(true)
                              :SetDefaultSpeed(350)
                              :SetHomebase(SupportBase)
                              :SetDestinationbase(SupportBase)
                              :SetDefaultTACAN(SupportUnitFields[ENUMS.SupportUnitFields.TACANCHAN],
                                                SupportUnitFields[ENUMS.SupportUnitFields.TACANMORSE],
                                                FlightGroup:GetUnit(),
                                                SupportUnitFields[ENUMS.SupportUnitFields.TACANBAND],
                                                true)

                        function FlightGroup:OnAfterDestroyed(From, Event, To)
                            self:I(self:GetName() .. " destroyed, launching relief flight.")
                            Spawn:SpawnAtAirbase( SupportBase, SPAWN.Takeoff.Hot, nil, AIRBASE.TerminalType.OpenBig, true )
                        end

                        function FlightGroup:OnAfterFuelLow(From, Event, To)
                          self:I(self:GetName() .. " fuel low, launching relief flight.")
                          Spawn:SpawnAtAirbase( SupportBase, SPAWN.Takeoff.Hot, nil, AIRBASE.TerminalType.OpenBig, true )
                        end

                        function FlightGroup:OnAfterArrived(From, Event, To)
                          -- Make airframe available again in 60 minutes if airframes limited.
                          if not UnlimitedAirframes then
                            FlightGroup:I(FlightGroup:GetName() .. " landed, airframe will be refueling for 1 hour before operational. " .. airframes .. " airframes available for this mission.")
                            SCHEDULER:New( nil,
                              function()
                                if SupportUnitFields.airframes  then
                                  SupportUnitFields.airframes = tonumber(SupportUnitFields.airframes) + 1
                                  airframes = tonumber(SupportUnitFields.airframes)
                                  Flight:InitLimit( 2, airframes )
                                end
                                FlightGroup:I(FlightGroup:GetName() .. " refueled and airframe available for new tasking. " .. airframes .. " airframes available for this mission.")
                              end, {}, 3600)
                          end
                        end
                    end, SupportUnit, SupportUnitFields, SupportUnitInfo, Flight, SupportBase, OrbitLeg, OrbitPt, OrbitDir
                  )
            if SpawnSchedule[SupportUnit] == nil then
              SpawnSchedule[SupportUnit] = SCHEDULER:New( nil,
                function()
                  if (Flight:GetFirstAliveGroup() == nil) then
                    if InAir and not SupportUnitFields[ ENUMS.SupportUnitFields.GROUNDSTART ] and not ( timer.getAbsTime()-timer.getTime0() > 30 ) then
                      Flight:InitAirbase(SupportBase, SPAWN.Takeoff.Hot)
                      local SpawnPt = OrbitPt:Translate( 5000, OrbitDir + 180)
                        :SetAltitude(UTILS.FeetToMeters(SupportUnitFields[ENUMS.SupportUnitFields.ALTITUDE] + 5000), true)
                      Flight:SpawnFromCoordinate(SpawnPt)
                    else
                      Flight:SpawnAtAirbase( SupportBase, SPAWN.Takeoff.Hot, nil, AIRBASE.TerminalType.OpenBig, true )
                    end
                  end
                end, {}, 1, 60)
            end
        end
    end 
  end
end

function InitNavySupport( AircraftCarriers, CarrierMenu, InAir )

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

      for SupportUnit,SupportUnitFields in pairs(SUPPORTUNITS) do      
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
                  tanker:SetSpeed(
                    UTILS.KnotsToAltKIAS(SupportUnitFields[ENUMS.SupportUnitFields.SPEED], 
                      SupportUnitFields[ENUMS.SupportUnitFields.ALTITUDE])
                  )
                  tanker:SetRadio(SupportUnitFields[ENUMS.SupportUnitFields.RADIOFREQ])
                  tanker:SetModex(SupportUnitFields[ENUMS.SupportUnitFields.MODEX])
                  tanker:SetAltitude(SupportUnitFields[ENUMS.SupportUnitFields.ALTITUDE])
                  tanker:SetTACAN(SupportUnitFields[ENUMS.SupportUnitFields.TACANCHAN], SupportUnitFields[ENUMS.SupportUnitFields.TACANMORSE])
                  tanker:SetCallsign(SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN], SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN_NUM])
                  tanker:SetRacetrackDistances(30, 15)
                  tanker:__Start(2)

                  local ScheduleRecoveryTankerTacanStart = SCHEDULER:New( nil, 
                      function( tanker )
                          BASE:I(tanker.lid..string.format(" %s: Activating TACAN Channel %d%s (%s)", SupportUnit, 
                            tanker.TACANchannel, tanker.TACANmode, tanker.TACANmorse))
                          tanker:_ActivateTACAN()
                          BASE:I(tanker.lid..string.format(" %s: Set callsign", SupportUnit))
                          tanker:SetCallsign(SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN], SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN_NUM])
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
                awacs:SetCallsign(SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN], SupportUnitFields[ENUMS.SupportUnitFields.CALLSIGN_NUM]) 
                awacs:SetRacetrackDistances(40, 20)
                awacs:__Start(2)
              end
            elseif SupportUnitFields[ENUMS.SupportUnitFields.TYPE] == ENUMS.UnitType.SHIP then
              if SupportUnit == AircraftCarrier then 
                local carrier = CARRIER:New(AircraftCarrier)
                
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
                    CommandActivateLink4(self.carrier, SupportUnitFields[ENUMS.SupportUnitFields.LINK4FREQ])
                  end

                end

                -- Rescue Helo for LHAs and other non-carriers
                local rescuehelo=RESCUEHELO:New(SupportUnit, "CSAR1")

                if SUPPORTUNITS[ 'CSAR1' ][ ENUMS.SupportUnitFields.GROUNDSTART ] then
                  rescuehelo:SetTakeoffCold()
                else
                  if SupportUnit[ ENUMS.SupportUnitFields.GROUNDSTART ] then
                    rescuehelo:SetTakeoffCold()
                  else
                    rescuehelo:SetTakeoffAir()
                  end
                end

        rescuehelo:SetModex( SUPPORTUNITS[ 'CSAR1' ][ ENUMS.SupportUnitFields.MODEX ] + 8 )
        rescuehelo:__Start(2)

                Carriers[SupportUnit] = carrier

                Carriers[SupportUnit]:__Start(2)

                if CarrierMenu == nil then
                  CarrierMenu = MENU_COALITION:New(coalition.side.BLUE, "Carrier Control")
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

        -- Rescue Helo for LHAs and other non-carriers
        local rescuehelo=RESCUEHELO:New(SupportUnit, "CSAR1")

        if SUPPORTUNITS[ 'CSAR1' ][ ENUMS.SupportUnitFields.GROUNDSTART ] then
          rescuehelo:SetTakeoffCold()
        else
          if SupportUnit[ ENUMS.SupportUnitFields.GROUNDSTART ] then
            rescuehelo:SetTakeoffCold()
          else
            rescuehelo:SetTakeoffAir()
          end
        end

        rescuehelo:SetModex( SUPPORTUNITS[ 'CSAR1' ][ ENUMS.SupportUnitFields.MODEX ] + 8 )
        rescuehelo:__Start(2)
      end
    end
    return Carriers
end

function CarrierTurnIntoWind( Carrier )

    local Message = Carrier.alias .. " turning into the wind for 30 minutes."
    MESSAGE:New( Message ):ToBlue()
    BASE:I( Message )

    Carrier:CarrierTurnIntoWind(1800, 20, true)
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

        SupportUnitFields = SUPPORTUNITS[BeaconName]

        Beacon:ActivateTACAN(SupportUnitFields[ENUMS.SupportUnitFields.TACANCHAN], 
                             SupportUnitFields[ENUMS.SupportUnitFields.TACANBAND], 
                             SupportUnitFields[ENUMS.SupportUnitFields.TACANMORSE], 
                             true)
    end

end

function SetupMANTIS()
    local RedAwacs = SET_GROUP:New():FilterPrefixes('Red EWR AWACS'):FilterOnce():GetSetNames()
    SET_GROUP:New():FilterPrefixes('Red SAM'):FilterOnce():GetSetNames()
    local RedIADS = nil

    -- Create the IADS network with wor without AWACS
    if RedAwacs ~= {} then
        RedIADS = MANTIS:New("RedIADS","Red SAM","Red EWR",nil,"red",false,"Red EWR AWACS")
    else
        RedIADS = MANTIS:New("RedIADS","Red SAM","Red EWR",nil,"red",false)
    end

    -- Optional Zones for MANTIS IADS
    local AcceptZones = SET_ZONE:New():FilterPrefixes('Red IADS Accept'):FilterOnce():GetSetObjects()
    local RejectZones = SET_ZONE:New():FilterPrefixes('Red IADS Reject'):FilterOnce():GetSetObjects()
    local ConflictZones = SET_ZONE:New():FilterPrefixes('Red IADS Conflict'):FilterOnce():GetSetObjects()
    RedIADS:AddZones(AcceptZones,RejectZones,ConflictZones)

    RedIADS:Start()

    return RedIADS
end

function SetupSKYNET()
  local redIADS = nil

  --create an instance of the IADS
  redIADS = SkynetIADS:create('Red IADS')

  --add all groups begining with group name 'SAM' to the IADS:
  redIADS:addSAMSitesByPrefix('Red SAM')

  --add all units with unit name beginning with 'EW' to the IADS:
  redIADS:addEarlyWarningRadarsByPrefix('Red EWR')

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

local SupportBase = nil
local RedSupportBase = nil
local AircraftCarriers = nil
local AirStart = SupportFlightAirStart or true

local CarrierMenu = nil
local TacanMenu = MENU_MISSION:New("TACANs")

-- Initialize Airbase & Carriers
SupportBase, RedSupportBase, AircraftCarriers = InitSupportBases()

-- Init land-based support units
InitSupport(SupportBase, RedSupportBase, AirStart)

-- Periodically re-launch each Flight if none in the air
local SupportFlightScheduler = SCHEDULER:New( nil, InitSupportWings, {SupportBase}, 300, 300 )

-- Setup carrier and carrier group support units
local Carriers = InitNavySupport(AircraftCarriers, CarrierMenu, AirStart)

-- Enable TACAN reset menu
local TacanMenu1 = MENU_MISSION_COMMAND:New("Emergency TACAN reset", TacanMenu, EmergencyTacanReset, { SupportBeacons, Carriers } )

-- Setup either MANTIS or SKYNET IADS
RedIADS = nil
local RedSAMs = SET_GROUP:New():FilterPrefixes('Red SAM'):FilterOnce():GetSetNames()

if table.getn(RedSAMs) > 0 then
  BASE:I("Initializing IADS...")
  if samTypesDB == nil then
    BASE:I("Initializing MANTIS IADS.")
    RedIADS = SetupMANTIS()
  else 
    BASE:I("Initializing SKYNET IADS.")
    RedIADS = SetupSKYNET()
  end
else
  BASE:E("No group names with 'Red SAM' found, skipping IADS initialization.")
end
