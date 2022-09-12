# 51st VFW Mission Templates

This repository contains template missions from the 51st VFW for use by other wing members as
starting points. These missions are not complete and provide starting points based on the
[51st VFW SOPs](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/missionsEditingSOPs.md).
Template missions are each saved in their own mission directory with a name of the form
"`<map>` `<mission_name>`" where `<map>` is an abbreviation for the map that the mission takes
place on.

|`<map>`|Map Name|
|:----------:|---|
|CAU|Caucasus|
|MAR|Marianas|
|NTTR|Nevada Test and Training Range|
|PG|Persian Gulf|
|SAT|South Atlantic|
|SYR|Syria|

The structure and contents of a mission directory is somewhat flexible, but each mission
directory will contain at least two files at its root,

- A DCS `.miz` file with the mission.
- A `readme.md` file with a description of the mission.

Mission directories may also adopt the structure necessary to support the workflow that the
core template missions use to help smooth interactions with the DCS Mission Editor for
complex missions with scripting and other assets.
[This document](https://github.com/51st-Vfw/MissionEditing-Templates/blob/master/NTTR%20Core/workflow.md)
describes the workflow in greater detail. See any of the core templates for an example of
the mission directory layout the workflow assumes.

## Kneeboard Templates

The repository contains a set of `.svg` 
[templates](https://github.com/51st-Vfw/MissionEditing-Templates/tree/master/Templates)
for kneeboards that are aligned with the
[51st VFW Mission SOPs](https://github.com/51st-Vfw/MissionEditing-Index). These
templates include common comms cards along with some per-airframe cards.

## Caucasus Map

The repository contains the following mission templates for the Caucasus map,

- [Caucasus Core Template](https://github.com/51st-Vfw/MissionEditing-Templates/tree/master/CAU%20Core):
  Base template to set up core elements (tankers, AWACS, carriers, aircraft) along with MOOSE,
  MapSOP, and Skynet scripting.

## Marianas Map

The repository contains the following mission templates for the Marianas map,

- [Marianas Core Template](https://github.com/51st-Vfw/MissionEditing-Templates/tree/master/MAR%20Core):
  Base template to set up core elements (tankers, AWACS, carriers, aircraft) along with MOOSE,
  MapSOP, and Skynet scripting.

## NTTR Map

The repository contains the following mission templates for the NTTR map,

- [NTTR Core Template](https://github.com/51st-Vfw/MissionEditing-Templates/tree/master/NTTR%20Core):
  Base template to set up core elements (tankers, AWACS, carriers, aircraft) along with MOOSE,
  MapSOP, and Skynet scripting.

## Persian Gulf Map

The repository contains the following mission templates for the Persian Gulf map,

- [Persian Gulf Core Template](https://github.com/51st-Vfw/MissionEditing-Templates/tree/master/PG%20Core):
  Base template to set up core elements (tankers, AWACS, carriers, aircraft) along with MOOSE,
  MapSOP, and Skynet scripting.

## South Atlantic Map

Someday, when the map matures...

## Syria Map

The repository contains the following mission templates for the Syria map,

- [Syria Core Template](https://github.com/51st-Vfw/MissionEditing-Templates/tree/master/SYR%20Core):
  Base template to set up core elements (tankers, AWACS, carriers, aircraft) along with MOOSE,
  MapSOP, and Skynet scripting.
