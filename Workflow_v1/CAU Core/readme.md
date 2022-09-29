# 51st VFW Caucasus Core Mission Template

> Missions should include a readme with this structure. This content will change based on the
> specifics of the mission.

|What|Notes|
|---|---|
|Pitch|Brief description of mission would go here.|
|Blue Slots|<ul><li>Airplanes slots go here</li><li>Helo slots go here</li><li>JTAC/observer, etc. slots go here</li></ul>|
|Red Slots|<ul><li>Airplanes slots go here</li><li>Helo slots go here</li><li>JTAC/observer, etc. slots go here</li></ul>|

## Overview

This is the base 51st VFW mission template on the Persian Gulf map. This template include includes
default setup for the following elements,

- Units for all 51st VFW airframes and flights set up per
  [51st VFW SOPs](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/missionsEditingSOPs.md)
- Texaco, Arco, and Shell tankers set up using
  [MapSOP](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/51stMapSOP/readme.md)
- Overlord and Magic AWACS set up using
  [MapSOP](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/51stMapSOP/readme.md)
- CVN-71, CVN-75, and LHA-1 carrier groups setup using
  [MapSOP](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/51stMapSOP/readme.md)

These units will need to be positioned (or deleted) according to the needs of the mission. The
template sets up the scripting environment by loading the following frameworks around mission
start,

- [MOOSE](https://github.com/FlightControl-Master/MOOSE/) 2022-05-24T14:05:04.0000000Z-91686e252c967ffee744dd0ee91ff93d7f8291bd
- [Skynet](https://github.com/walder/Skynet-IADS) 2.4.0
- [mist](https://github.com/mrSkortch/MissionScriptingTools) 4.4.90
- [51st VFW MapSOP](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/51stMapSOP/readme.md) 20220604.1

The basic scripting infrastructure that comes pre-built in the template is as follows,

```
on MISSION_START                                # Load MOOSE Framework
    DO_SCRIPT_FILE(Moose_.lua)
on ONCE                                         # Load Skynet Scripts
    if TIME_MORE(4)
        DO_SCRIPT_FILE(mist_4_4_90.lua)
        DO_SCRIPT_FILE(skynet-iads-compiled.lua)
on ONCE                                         # Load Mission Scripts
    if TIME_MORE(8)
        DO_SCRIPT_FILE(51stMapSOP.lua)
        DO_SCRIPT_FILE(mission_globals.lua)
        DO_SCRIPT_FILE(mission_core.lua)
        DO_SCRIPT_FILE(mission_gci.lua)
        DO_SCRIPT_FILE(mission_iads.lua)
        DO_SCRIPT(env.info("*** Frameworks & Scripts Loaded"))
```

The mission-specific Lua scripts provide a basic scripting skeleton,

- `mission_globals.lua` for mission globals
- `mission_core.lua` for core mission functionalty
- `mission_gci.lua` for GCI functionality
- `mission_iads.lua` for IADS functionality

These files are placeholders and are initially empty in the template.

All scripting for frameworks and missions can be found in the mission master folder for
scripts. Other versions may be substituted by replacing the appropriate file.

The mission includes a single kneeboard with the default 51st VFW communications plan and
a briefing panel with the 51st VFW logo.

## Required Modules

- List of required modules would go here

## Versions

Details on the mission versions if there are multiple `.miz` files in the mission directory
with variations of the base mission.

## Revision History

- **v1.1** 11-Jun-2022
    - Updated MapSOP to 20220611.1
    - Updated Mission Options to match SOPs
    - Added default support elements
- **v1.0** 5-Jun-2022
    - Initial release
