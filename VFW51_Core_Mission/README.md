# 51st VFW Core Mission Template

This is the base 51st VFW mission template supporting the Caucusas, Marianas, NTTR, Persian
Gulf, Sinai, and Syria maps using the
[51st VFW workflow](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/me_workflow.md).
The template includes default setups for all 51st VFW airframes and flights, support
flights, and carrier groups per 
[51st VFW SOPs](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/missionsEditingSOPs.md).
These units will need to be positioned (or deleted) and other units added according to the
needs of the mission. The template sets up the scripting environment by loading the
[MOOSE](https://github.com/FlightControl-Master/MOOSE/),
[Skynet](https://github.com/walder/Skynet-IADS),
[mist](https://github.com/mrSkortch/MissionScriptingTools),
and
[51st VFW MapSOP](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/51stMapSOP/readme.md)
frameworks at mission start.

Workflow versions are identified with three numbers "`<frameworks>`-`<scripts>`-`<settings>`"
where each corresponds to the version of the corresponding component.

- **v20241215**, Workflow 11-17-9
    - Added Iraq template
    - Updated waypointinator to stop after first match
- **v20240927**, Workflow 11-16-9
    - Updates to VFW51 utilities
- **v20240811**, Workflow 10-15-8
    - Updated to MapSOP v20240818.1
- **v20240811**, Workflow 9-15-8
    - Added Afghanistan, Kola tempaltes
    - Removed F-14, A/V-8B from templates
    - Minor template tweaks
    - Updated to MapSOP v20240811.1
    - Updated to MOOSE e768ec3c
    - Updated for DCS 2.9.7.58923
- **v20240118**, Workflow 8-15-8
    - Added support for mision versions via --version argument to build, removed --tag argument
    - Added support for aircraft property extraction via --prop argument to Extractinator and
      extract scripts
    - Added suport for loadout properties in Loadoutinator
    - Added support for mission versions in Variantinator
    - Updated default loadouts and kneeboard templates
    - Updated to MapSOP v20231217.1
    - Updated to Skynet v3.3.0
    - Updated to MOOSE 5b7e0ce3
    - Updated for DCS 2.9.2.49940
- **v20230827**, Workflow 7-14-7
    - Updated Variantinator and build scripts to redact .lua from redacted missions
- **v20230716**, Workflow 7-13-7
    - Added in-game output to note --dyanmic build via triggerinator
- **v20230629**, Workflow 7-12-7
    - Updated vfw51_mission_util.lua
    - Updated vfw51_mission_splash_damage.lua
- **v20230622**, Workflow 6-12-7
    - Added support for F-15E radios
    - Updated for DCS 2.8.6.41363
- **v20230619**, Workflow 6-11-6
    - Added support tvredact.py script to redact TacView files
    - Incorporated A-10C II ARC-210 labels PR from Fizzle
    - Removed support for South Atlantic map
- **v20230613**, Workflow 6-10-5
    - Added support for Sinai map
    - Updated for DCS 2.8.6.41066
- **v20230323**, Workflow 6-10-5
    - Updates to 51st VFW mission utilities
    - Experimental support for Splash Damage scripting
- **v20230323**, Workflow 5-10-5
    - Triginator handles missing script files a little more gracefully (no longer asserting out)
    - Radioinator handles presets in new A-10C ARC-211 radio
    - Radioinator supports for non-preset-1 defaults
    - Radioinator deprecates support for legacy A-10C preset model
    - wfupdate script now has --version argument to print versions of workflow components
    - Significant update to 51st VFW mission utilities included in mission scripts by default
    - Updated default radio presets based on latest SOPs
- **v20230318**, Workflow 4-9-4
    - Loadoutinator script adds support for duplicating loadouts across multiple groups
    - extract script adds support for extracing loadouts from missions
    - Added src/loadouts directory to support loadout functionality
    - Added 51st SOP loadouts for wing aircraft for use in A2A arenas for BFM, WVR, BVR
    - wfupdate script now copies variant and waypoint settings when updating settings
- **v20230210**, Workflow 4-8-3
    - Adopt Skynet 3.1.0
- **v20230207**, Workflow 3-8-3
    - Variantinator script adds support for drawing redaction, limited "all" wildcards
- **v20230205**, Workflow 3-7-2
    - Adopt MapSOP Version 20230205.1 with matching MOOSE version
- **v20230125**, Workflow 2-7-2
    - Adopt MapSOP Version 20230125.1 with matching MOOSE version
    - Variantinator script adds support for mission redaction, updates to variant Lua settings to
      support redaction
    - Updated base templates
- **v20221211**, Workflow 1-6-1
    - Adopt MapSOP Version 20221211.1
    - Added template for South Atlantic (SAT) map
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

> Missions are encouraged to replace this README with a mission README with a structure similar
> to the following outline.

___
___

# Mission Name

> Capsule summary of the mission, for example
> |What|Notes|
> |---|---|
> |Pitch| PvP contested deep strike against fixed targets with PGMs |
> |Blue Slots|<ul><li>F-16C</li><li>Game master, Tactical Commander</li></ul>|
> |Red Slots|<ul><li>JF-17</li><li>AI</li><li>Game master, Tactical Commander</li></ul>|

## Overview

> More detailed overview of the mission

## Building from this Package

This mission uss the 51st VFW workflow. To rebuild the mission from the source, make sure you
have the support tools installed to enable 51st VFW workflow (see the
[51st VFW workflow](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/me_workflow.md) documentation),
then run `scripts\build.cmd` from a command shell.

> Additional build instructions or information

## Required Modules

> List of required modules

## Documentation

> List of documentation in the `docs\` directory

## Versions

> Details on the mission variants for missions that include variations of the base mission

## Revision History

> Mission revision history
