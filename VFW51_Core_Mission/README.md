# 51st VFW Core Mission Template

> This is the base 51st VFW mission template supporting the Caucusas, Marianas, NTTR, Persian
> Gulf, and Syria maps using the
> [51st VFW workflow](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/me_workflow.md). The template includes default setup for all 51st VFW airframes and
> flights, support flights, and carrier groups per 
> [51st VFW SOPs](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/missionsEditingSOPs.md).
> These units will need to be positioned (or deleted) according to the needs of the mission. The
> template sets up the scripting environment by loading the following frameworks at mission
> start,
> [MOOSE](https://github.com/FlightControl-Master/MOOSE/),
> [Skynet](https://github.com/walder/Skynet-IADS),
> [mist](https://github.com/mrSkortch/MissionScriptingTools),
> [51st VFW MapSOP](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/51stMapSOP/readme.md).

> Missions are encouraged to include a readme with similar structure to the outline below. This
> content will change based on the specifics of the mission.

# Mission Name

Capsule summary of mission here.

|What|Notes|
|---|---|
|Pitch|Brief description of mission would go here.|
|Blue Slots|<ul><li>Airplanes slots go here</li><li>Helo slots go here</li><li>JTAC/observer, etc. slots go here</li></ul>|
|Red Slots|<ul><li>Airplanes slots go here</li><li>Helo slots go here</li><li>JTAC/observer, etc. slots go here</li></ul>|

## Overview

Overview of the mission would go here

## Building from this Package

> This mission uss the 51st VFW workflow. To rebuild the mission from the source, make sure you have the
> support tools installed to enable 51st VFW workflow (see the
> [51st VFW workflow](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/me_workflow.md) documentation),
> then run `scripts\build.cmd` from a command shell.

## Required Modules

- List of required modules would go here

## Versions

Details on the mission variants if there are multiple `.miz` files in the mission directory
with variations of the base mission.

## Revision History

- **v20221205**, Workflow 1-6-1
    - Disabled legacy preset functionality in radioinator due to DCS behavior (or bug?) that causes
      legacy presets to over-ride non-legacy presets.
    - Use "A-10C_2" airframe tag for A-10C airframes in radio settings.
    - Updated scripting version to 6.
- **v20221201**, Workflow 1-5-1
    - Adopt MapSOP Version 20221130.1
    - Adopt Skynet Version 3.0.1
    - Fixed bug in parsing of `--miz` and `--map` command line arguments to setup script.
    - Updated scripting version to 5.
- **v20221104**, Workflow 1-4-1
    - Changes to preset setup logic.
    - Updated scripting version to 4.
- **v20221001**, Workflow 1-3-1
    - Now extract/inject options from/into "forcedOptions" key from the mission file.
    - Added options file for "development" where things like SATNAV and BDA are enabled.
    - Updated scripting version to 3.
- **v20220928**, Workflow 1-2-1
    - Removed --tag option from build scripts.
    - Updated scripting version to 2.
- **v20220921**, Workflow 1-1-1
    - Initial release
