# 51st VFW Templates

This repository contains several different templates to help with mission design.

A `.zip` with the current release of this repository is available
[here](TODO).


## Core Mission Template

The `VFW51_Core_Mission` directory in this repository contains a template from the 51st VFW for
use by mission designers. The template directory is set up to support a mission managed under the
[51st VFW Workflow](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/me_workflow.md)
as such, the template is more than simply a `.miz` file. The template provides a starting point
for mission designers and is based on the 
[51st VFW SOPs](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/missionsEditingSOPs.md).
The template can be configured to support any of the maps listed in the following table.

|Abbreviation|Map Name|
|:----------:|---|
|AFG|Afghanistan|
|CAU|Caucasus|
|IRQ|Iraq|
|KOL|Kola Peninsula|
|MAR|Marianas|
|NTTR|Nevada Test and Training Range|
|PG|Persian Gulf|
|SNA|Sinai|
|SYR|Syria|

To use the template and configure it up for a particular map, see the Quick Start Guide in the
[51st VFW Workflow documentation](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/me_workflow.md).
This documentation also provides further details on the operation of the workflow in general.

Included in the `VFW51_Core_Mission` directory are a number of `Tmplt_<map>_Core.miz` base
packages that provide baseline mission templates.

> These templates are setup by the workflow via the `setup.cmd` script and are **not** intended
> to be used on their own.

There is a baseline mission template for each of the supported maps listed above.

## Kneeboard Templates

The `Kboard_Templates` directory in this repository contains a set of `.svg` 
[files](https://github.com/51st-Vfw/MissionEditing-Templates/tree/master/Kboard_Templates)
suitable for use as templates for kneeboards that are aligned with the
[51st VFW Mission SOPs](https://github.com/51st-Vfw/MissionEditing-Index).
These templates include common comms cards along with some per-airframe cards. Most vector
graphics programs provide the ability to edit `.svg` files and export the results as `.png`
or `.jpg` suitable for use as mission kneeboards.
