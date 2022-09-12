# Mission Editing and Packaging Workflow

_Version: 1.0 of 9-Sep-22_

This document describes a directory structure and workflows for mission editing along with
packaging missions and associated materials. As of DCS 2.7, the handling of assets such as
external Lua scripts or kneeboards in the DCS Mission Editor (DCS ME) is clumsy, at best;
and hostile, at worst. This workflow attempts to help make that less painful.

This is the second version of the 51st VFW workflow.

The workflow is based on and influenced by the [VEAF](https://github.com/VEAF) mission creation
and conversion tools. The 51st VFW workflow uses some of the VEAF scripts directly along with
techniques borrowed from VEAF and previous 51st VFW workflows.

Mission templates set up for the workflow are available through the 51st VFW `git` repository
at
[51st VFW Mission Templates](https://github.com/51st-Vfw/MissionEditing-Templates).
For those not familiar with `git`, a `.zip` files with templates are available at
[TODO](TODO).

# Workflow Capabilities

The workflow allows missions to be managed efficiently through a source control system such as
GitHub. This enables better collaboration between mission designers while preventing the need to
place the raw `.miz` files under source control. The workflow provides improved management of
user mission resources such as briefing panel images, kneeboards (potentially automatically
generated), and mission scripts. This management is better able to handle changes to these
resources without requiring "delete-save-add-save" loops in the DCS ME.

For scripting, the workflow allows a mission to be built in a "dynamic" configuration that
causes the mission to reload scripts from their source directory on each launch (rather than
packaging the scripts with the `.miz`). While this mode is only useful when running a mission
locally, it is helpful for debug allowing simultaneous editing of scripts through an external
IDE and the mission through the DCS ME.

The workflow can inject information directly into the DCS ME core files. This allows the
workflow to automatically configure radio presets, waypoints, or set up script loading.

The workflow assmebles a `.miz` file for the mission from the associated source files. The
workflow supports the automatic generation of multiple versions of a mission that differ in
mission options (such as dot labels or F10 map setup), weather, or time of day.

# Before Using the Workflow

Scripts in the 51st VFW workflow relies on several tools to support its operation. The tools,
their locations on the web, and their purpose are,

- [7-zip](https://www.7-zip.org/download.html)
  packs and unpacks a DCS `.miz` file. The workflow has been tested with 7-zip 21.07.
- [Lua](https://sourceforge.net/projects/luabinaries/files/5.4.2/Tools%20Executables/)
  executes some of the scripts the workflow uses to do process missions. The workflow has
  been tested with Lua 5.4.2.
- [ImageMagick](https://imagemagick.org/script/index.php)
  processes image files for use in kneeboard construction. The workflow has been tested
  with ImageMagick 7.1.0-46 Q16-HDRI x64.

While specific versions are called out above, installing more recent versions should be fine.
The tools must appear in the system or user `PATH` environment variable.

The 7-zip and Lua programs linked above are not packaged with Windows installers and must be
installed manually. Typically, extract the downloaded files to a directory such as
`C:\Program Files\<tool>` or equivalent. You will need to manually add the install paths to
the `PATH` environment variable (Google can get you instructions based on the version of
Windows you are running). ImageMagick is packaged with a Windows installer and will handle the
setup for you. Make sure to check the "Add to PATH" option during install to add the
appropriate directory to the `PATH`.

In addition to these tools that are directly used by the workflow, you may want to install

- [Visual Studio Code](https://code.visualstudio.com/) is an IDE that supports Lua
  development. You should also install the Lua plug-in from VSC.
- [GitHub](https://desktop.github.com/) is a desktop `git` client to allow access to
  the 51st VFW repositories and enable collaboration between multiple designers on a
  shared mission.

These tools may not be required, depending on what you want to do.

# Mission Directories

The workflow operates in _mission directories_ that contain all of the files related to the
mission, including source and scripts. A mission directory has the same name as the base
mission version. For example, the mission directory for a mission `Breaking_Bad` might be
`C:\Users\Raven\DCS_miz\Breaking_Bad`. Due to limitations in the Windows shell, the full
path to a mission directory should only contain alphanumeric, "-", and "_" characters. For
example, `C:\Users\Raven\DCS Missions\Reactor #5 Strike` is not a valid mission directory
name.

> Just keep paths to alphanumeric, "-", and "_" characters, and we'll all be happy. It kinda
> sucks, but that's Windows for you...

## Mission Directory Layout

The top level of the mission directory contains the following directories,

- `backup\` holds backups of the previous version of the `.miz` files generated by a mission
  build.
- `build\` holds temporary build products and files during mission construction.
- `scripts\` holds the Windows `.cmd` and Lua `.lua` scripts that support the workflow.
- `src\` holds the source files that make up the mission. This includes user-generated files
  (e.g., Lua scripts, kneeboards) along with `.miz` internal DCS ME files.

In addition to these directories, the top level of the mission directory typically contains a
number of packaged `.miz` files that provide different variants of a base mission, `README`
files, and the workflow documentation (this file).

Mission files are named `<mission_name>[-v<version>][-<variant>].miz` where the "base" mission
does not include `[-<variant>]`. In the mission name, `[-v<version>]` is an optional integer
version tag and `[-<variant>]` is the name of an optional automatically-generated "variant" of
the mission that differs from the base mission in weather, time of mission, or mission options.

## GitHub and the Mission Directory

The workflow is intended to support source control through GitHub. To do so, the workflow
"normalizes" all Lua files that the DCS ME generates so that they can be effectively compared
without generate false positives on changes.

> "Serialization" is the process of taking information and writing it to a file. When writing
> the data that makes up the `.miz` (primarily expressed through Lua tables) to a `.miz` file,
> the algorithm ED uses in the DCS ME can generate a different serialization each time the
> mission is saved, even if the mission was not changed. This implies that the source control
> system may believe something has changed when, in reality, it has not.
>
> To address this, the workflow will process files the DCS ME creates in a `.miz` with a tool
> that "normalizes" their contents. Normalized files will not change from save to save allowing
> source control to work as expected. For example, if DCS ME were serialize a list in a random
> order, normalizing that serialization would involve sorting the list.

To operate effectivey with GitHub, the mission directory should contain a `.gitignore` file, 

```
# 51st VFW Workflow .gitignore

/.vscode
/backup
/build
/src/miz_core/KNEEBOARD
/src/miz_core/Config
/src/miz_core/Scripts
/src/miz_core/track
/src/miz_core/track_data
*.miz
```

The files and directories this excludes are not needed for the workflow to rebuild the mission
and may duplicate information stored elsewhere in the mission directory.

# Setting up the Workflow

There are two ways to configure a mission for use with the 51st VFW workflow: create the
mission from a 51st VFW mission template or transition an existing mission to use the
workflow.

## Initial Setup

In either approach, you will start by making a copy of the `VFW51_Core_Mission` directory. You
can find this directory in the
[51st VFW Mission Templates](https://github.com/51st-Vfw/MissionEditing-Templates)
repository on GitHub or as a separate
[`.zip` package](TODO_LINK).

> If you are working from GitHub, you will want to make a copy of `VFW51_Core_Mission` outside
> of the repository, since you don't want to change the template in the repository... :) 

The copy of `VFW51_Core_Mission` should be renamed to the mission name. Further, the path to
this directory should include only alphanumeric, "-" and "_" characters as discussed earlier.
For example, assuming the new mission is to be called `Breaking_Bad` and the mission directory
is `C:\Users\Raven\DCS_Missions\`

```
C:\Users\Raven\DCS_Missions\> move VFW51_Core_Mission Breaking_Bad
```

The `setup.cmd` script from the mission directory will complete the setup for the workflow.

## Starting from a Mission Template

The `VFW51_Core_Mission` directory includes basic mission templates for all of the main maps
the wing supports. These can be found at the top level of the template mission directory in the
files named `Tmplt_<map>_core.miz` where `<map>` is the abbreviated map name. The support maps
include Caucuses (CAU), Marianas (MAR), NTTR (NTTR), Persian Gulf (PG), and Syria (SYR).

To complete setup from a template, use the `setup.cmd` script. For example, to set up the
`Breaking_Bad` mission from the NTTR map,

```
C:\Users\Raven\DCS_Missions\Breaking_Bad\> scripts\setup.cmd --map NTTR
```

This will create a `Breaking_Bad.miz` file from the template and synchronize it with the
contents of the mission directory. Setup will also remove any uneeded files such as the
templates for the other maps.

At this point, the mission directory is setup and ready for use.

## Starting From an Existing Mission

The `setup.cmd` script can also start from an existing `.miz` file, though the process is
slightly more complicated.

```
C:\Users\Raven\DCS_Missions\Breaking_Bad\> scripts\setup.cmd --miz C:\Stuff\NewMission.miz
```

In this case, the script will copy `NewMission.miz` to `Breaking_Bad.miz` in the mission
directory.

> The path to the existing `.miz` file must conform to the requirements on mission
> directory paths: it should only contain alphanumeric, "-", and "_" characters.

Once this script completes, the mission directory is only partially built. After the first
run is complete, the `src\miz_core\` subdirectory will contain the files extracted from the
`.miz`. Files such as scripts, kneeboards, or briefing panels will need to be manually moved
into their correct locations in the mission directory. Once this manual step is complete,
you run `setup.cmd` again with `--finalize` to complete the setup.

```
C:\Users\Raven\DCS_Missions\Breaking_Bad\> scripts\setup.cmd --finalize
```

At this point, the mission directory is ready for use. You may need to make further adjustments
to the scripting and triggers in the mission.

## Dynamic Versus Static Scripting Setups

The workflow can configure the mission to load mission Lua scripts either statically or
dynamically. In the static setup, the scripts are kept in the `.miz` package. Any change to a
mission script requires the `.miz` package to be rebuilt. In the dynamic setup, the scripts are
kept outside the `.miz` package in the mission directory `src\scripts\` subdirectory and can be
edited without updating the `.miz` package.

> Missions set up to use dynamic scripting will typically only work on the system they were
> created on. When building a mission to share with others or host on a server, it is important
> to use static script loading.

The `setup.cmd` script sets up the mission directory for static script handling. Specifying
`--dynamic` on the `setup.cmd` command line will initially set up the mission for dynamic
script handling. As described below, a mission directory can switch between dynamic and static
approaches on a build-by-build basis. There is no need for separate dynamic and static mission
directories for a mission.

# Using the Workflow

Once the mission directory is set up, you can use the workflow to build and manage the
mission and its resources.

## Basic Concepts and Operation

The `src\` subdirectory of the mission directory contains all the collateral necessary to build
a DCS `.miz` package for the mission. Within this directory,

- `miz_core\` contains files from the `.miz` mission package that are created, owned, and
  primarily edited by the DCS ME. The workflow may also modify these files.
- The remaining subdirectories contains files that the workflow owns and incorporates into the
  `.miz` mission package that the DCS ME does not modify.

The workflow relies on two main scripts to operate: `sync.cmd` (introduced above) and
`build.cmd`. All scripts must be run from the root level of a mission directory as discussed
earlier and also support a `--help` command line switch to provide usage information.
Generally speaking, `sync.cmd` moves data from the `.miz` to the mission directory while
`build.cmd` moves data from the mission directory to the `.miz`.

### _Synchronizing the Mission Directory with `sync.cmd`_

After saving the `.miz` in the DCS ME, you should evenutally use the `sync.cmd` script to
update the files in the mission directory,

```
C:\Users\Raven\DCS_Missions\Breaking_Bad> scripts\sync.cmd
```

This command updates the content of the mission directory (primarily in `miz_core\`) with the
contents of the base mission package.

The `sync.cmd` script has several command line arguments. The main arguments include,

- `--dirty` disables clean up of redundnat files in the `src\miz_core\` subdirectory allowing
  you to examine what was pulled from the `.miz` package. The `cleanmission.cmd` script will
  clean up this subdirectory.
- `--dynamic` configures the mission directory files for dynamic script handling.
- `--verbose` turns on logging information.

You need not run the `sync.cmd` script after every save in the DCS ME, but, if you make changes
to the mission in the DCS ME, you must run `sync.cmd` prior to packaging the mission using the
`build.cmd` script.

### _Building Mission Packages with `build.cmd`_

After making changes to the files outside of `miz_core\`, you should eventually use the
`build.cmd` script to rebuild the `.miz` packages from the mission directory,

```
C:\Users\Raven\DCS_Missions\Breaking_Bad> scripts\build.cmd
```

By default, the `build.cmd` script will first run `sync.cmd` prior to performing the steps to
build the mission..

The `build.cmd` script has several command line arguments. The main arguments include,

- `--dirty` disables deletion of the mission package build directory, `build\miz_image\`, after
  the build is complete allowing you to examine what was built in to the `.miz` packages.
- `--dynamic` builds `.miz` mission packages to use dynamic script handling. By default, the
  workflow will build packages for static script handling.
- `--nosync` prevents `build.cmd` from running `sync.cmd` prior to bulding the `.miz` packages.
- `--base` builds the base mission variant only and does not build any other variants the
  mission directory specifies, see
  [Mission Variants](#Mission-Variants) for further details.
- `--version {version}` adds the non-zero integer `{version}` to the filenames of the missions
  built by the script as a version tag
- `--verbose` turns on logging information.

The `build.cmd` script may build one or more `.miz` packages depending on mission directory
set up. There is a base variant, named `<mission_name>[-v<version>]` and additional optional
variants, each named `<mission_name>[-v<version>][-<variant>]`. See 
[Mission Variants](#Mission-Variants)
for further details.

Note that you need not build if you are only editing Lua scripts and the mission directory
is currently set up for dynamic mission scripting handling. Any time you build, you should
make sure to reload the `.miz` in the DCS ME. Generally, it is safest to exit out of the DCS
ME before doing the build. Prior to building, it is a good idea to ensure you have performed
a sync if you've made changes in the DCS ME.

## Workflow Tasks

The workflow allows you to inject different types of information into the mission. Each type
of information has its own subdirecotry in the `src\` subdirectory of the mission directory.
Generally, you will put relevant files into the appropriate subdirectory and edit a settings
file to make changes. The build scripts will use the settings and relevant files to assemble
the `.miz` at build time.

The following sections describe each type of information in further detail.

### _Audio Files_

The `src\audio\` subdirectory of a mission direcctory contains any audio files that are to be
included in the final mission. These files should be in `.ogg` or `.wav` format. To add audio
files, update the `vfw51_audio_settings.lua` file in the `src\audio\` subdirectory.

When building the mission, the workflow automatically updates a workflow-inserted trigger
that ensures the mission references all audio files (this is necessary to keep the DCS ME from
deleting files that do not appear in DCS ME triggers, see
[DCS ME Resource References](#DCS-ME-Resource-References)
below) as well as copy the audio files into the final `.miz` file.

The settings file contains a single Lua table, `AudioSettings` that specifies the audio files
to include in the mission. The file names the table specifies are relative to the `src\audio\`
subdirectory. The settings file should be self explanatory; see the file for further details.

### _Briefing Panels_

The `src\briefing\` subdirectory of a mission directory contains images to present on the
briefing panel that DCS shows at mission start. These files must be in `.jpg` or `.png` format.
To change the briefing panels in the mission, update the `vfw51_briefing_settings.lua` file in
the `src\briefing\` subdirectory.

When building the mission, the workflow will update internal DCS mission files to reference
the briefing panels as well as copy the image files into the final `.miz` file.

The settings file contains a single Lua table, `BriefingSettings` that specifies the briefing
panels to use for each coalition. The file names the table specifies are relative to the
`src\briefing\` subdirectory. The settings file should be self explanatory; see the file for
further details.

### _Kneeboards_

The `src\kneeboards\` subdirectory of a mission directory contains kneeboards and supporting
files for the kneeboards the mission carries. The workflow supports both global kneeboards
(visible to all pilots in any coalition) as well as airframe-specific kneeboards (visible to
all pilots of a specific airframe in any coalition). The workflow can use static images or
build kneeboards dynamically based on mission content such as radio presets. To add kneeboards,
update the `vfw51_kneeboard_settings.lua` file in the `src\kneeboards\` subdirectory.

When building the mission, the workflow will copy images to the proper location within the
`.miz` package, generating the image content on the fly as specified (see
[Dynamic Kneeboards](#Dynamic-Kneeboards)
for further details on dynamically generating kneeboard content).

The settings file contains a single Lua table, `KboardSettings` that describes how to generate
the `.miz` kneeboard content. There are two general approaches the workflow takes,

- Static images (`.jpg` or `.png`) are directly copied from the mission directory to the
  appropriate location in the `.miz` package. Images should be 1536 x 2048 (or maintain that
  aspect ratio).
- Dynamic images are built from information in the mission directory to create an image file
  that is copied to the appropriate location in the `.miz` package.

Currently, the workflow supports generating flight cards with radio preset and steerpoint
information dynamically.

### _Radio Preesets_

The `src\radio\` subdirectory of a mission directory contains settings for the radio presets
for the aircraft in the mission across the three radios DCS supports: Radio 1 (UHF), Radio 2
(VHF AM), and Radio 3 (VHF FM). The files in the standard template are initially configured
to support SOP comms with naval units using CVN-71 and CVN-75. To change the presets, update
the `vfw51_radio_settings.lua` settings file in the `src\radio\` subdirectory.

When building the mission, the workflow will inject the preset information into units in the
DCS ME files according to the settings. For A-10C units, the workflow creates the `UHF_RADIO`,
`VHF_AM_RADIO`, and `VHF_FM_RADIO` hierarchy within the `.miz`.

The settings file contains several Lua tables. The `RadioPresets[Warbird]<Blue|Red>` tables
establish the maping between a preset button and frequency and description by unit properties.
A series of rules define the mapping. For example, in `RadioPresetsBlue`

```
["$RADIO_1_10"] = {
    ["F-14B:*:*"]                   = { ["f"] = 271.40, ["d"] = "CVN-71 ATC" },
    ["FA-18C_hornet:*:*"]           = { ["f"] = 271.40, ["d"] = "CVN-71 ATC" }
},
```

sets Preset 10 on radio 1 (UHF) to 271.40MHz (CVN-71 ATC) on blue F-14B and FA-18C airframes
and unused on all other blue airframes. Keys in these tables (`"F-14B:*:*"` and
`"FA-18C_hornet:*:*"` in this example) are of the format `<airframe>:<name>:<callsign>`. To
match a given row in a `RadioPresets` table, a unit's airframe must match `<airframe>` exactly,
and the unit's group name and callsign must contain `<name>` and `<callsign>`. The value `"*"`
matches anything.

When determining the frequency and description to use for a unit, the rules for a preset on
a radio are applied in order of general to specific. For example,

```
["$RADIO_1_10"] = {
    ["*:*:*"]                   = { ["f"] = 270.00, ["d"] = "Tactical" },
    ["FA-16C_50:*:*"]           = { ["d"] = "Viper Tactical" }
    ["FA-16C_50:*:Uzi1"]        = { ["f"] = 275.00 }
},
```

results in the following frequency and descriptions for UHF (Radio 1) Preset 10,

|Airframe|Group Name|Callsign|Preset Frequency|Preset Description|
|:---:|:---:|:---:|:---:|:---:|
|FA-14B|CAP Flight|Dodge21|270.00|Tactical|
|F-16C_50|Strike Flight|Uzi11|275.00|Viper Tactical|
|F-16C_50|SEAD Flight|Venom21|270.00|Viper Tactical|

The `RadioSettings` table provides templates of the `"Radio"` key in the DCS ME internal
mission table to inject into a unit in order to configure its presets. Typically, the
contents of this table are not edited unless you want a given airframe to map preset N
from `RadioPresets` to preset M in the airframe.

### Scripts

The `src\scripts\` subdirectory of a mission directory contains the mission Lua scripts that
should be included in the mission package. This inculdes frameworks as well as mission-specific
scripting. To change the incorporated script files, update the `vfw51_script_settings.lua`
settings file in the `src\scripts\` subdirectory.

TODO

### Steerpoints

TODO: To be implemented...

### Mission Variants

The `src\variants\` subdirectory of a mission directory contains settings for the mission
variants that are generated when the mission is built. Mission variants differ from the base
mission in time of day, weather, or DCS mission options. To change variants, update the
`vfw51_variant_settings.lua` settings file in the `src\variants\` subdirectory.

When building the mission, the workflow will first build the base variant and then modify
it to create mission packages for each of the variants defined in settings.

> When given the `--base` argument, `build.cmd` will only build the base mission and will not
> build any of the variants the settings file describes.

The settings file contains the `VariantSettings` Lua table that defines the "moments" (i.e.,
time of day), weather, and options for each variant. Separate Lua files in the
`src\variants\` subdirectory define the specific weather and options configuration to apply
to the variant. These files are in the internal mission format from the DCS ME.

Given a mission with the desired weather or options settings, the `extract.cmd` script can
be used to extract the information of interest from an existing mission. The output of this
script can then be saved to a file in `src\variants\` for use in a variant.

# Updating the Workflow

Updates to the scripts and capabilities of the workflow will occur from time to time. Updating
existing missions to a new workflow is currently a manual, though straight-forward process.

TODO

# Technical Details, Odds, and Ends

TODO

## Workflow Trigger Setup

TODO

## Dynamic Kneeboards

TODO

## DCS ME Resource References

TODO

----------------------------




7-zip

https://sourceforge.net/projects/luabinaries/files/5.4.2/
https://sourceforge.net/projects/luabinaries/files/5.4.2/Tools%20Executables/

https://inkscape.org/

https://imagemagick.org/script/index.php
- "add to system path" selected

- must have 7-zip in path
- must have lua in path
- must have image magick in path


src/	scripts/	lua scripts
	radio/		radio presets


$BASE/src/miz_core has following directories by default:
	- KNEEBOARDS/[IMAGES|<airframe/IMAGES>]
	- UHF_RADIO
	- VHF_AM_RADIO
	- VHF_FM_RADIO

VEAF extract

1) unzip to $BASE/src/miz_core
2) set loading to static in .miz (l10n\Default\dictionary)
3) delete all scripts in $BASE/src/miz_core/l10n/Default that match scripts in $BASE/src/scripts (??)
	- What about scripts deleted from src/scripts? just delete all scripts instead?
4) delete $BASE/src/miz_core/options
5) delete $BASE/src/miz_core/[Config|Scripts|track|track_data] directories
6) setup radio presets
	- does not handle a-10's right now...
7) normalize all lua in $BASE/src/miz_core

VEAF build

1) make directory $BASE/build
2) copy 



What is missing?
- A-10C radio preset generation to build files in UHF_RADIO, VHF_AM_RADIO, VHF_FM_RADIO?
- Better handling of kneeboards? Like radios, with Lua definition that is built to pack KNEEBOARDS? auto-gen comms cards?
- Briefing panel image handling/injection
- audio file handling/injection




## Backups (`backup\`)

Prior to generating a new `.miz` file for a version of the mission, the scripts will copy the
previous `.miz` into the backup directory.

## Build Products (`build\`)

The workflow scripts use the build products directory to hold temporary files during the
creation of `.miz` files from the source. Generally, the scripts will delete this directory
after they complete their work, though options exist to keep the intermediate products
around for workflow debugging purposes.

The `miz_image\` directory in the build products holds the unpacked image of the `.miz` file.

## Shell and Lua Scripts (`scripts\`)

The `scripts\` directory contains shell and Lua scripts that support the workflow. This directory
does *not* contain any mission scripts (those are contained in the `src\` directory as discussed
below). Generally, the user will not need to make an changes to the content of this directory.

### Windows Shell (`.cmd`) workflow Scripts

There are four main Windows shell scripts that support the workflow. We will discuss the purpose
and use of these scripts in more detail later in this document.

- `build` assembles `.miz` files for the mission based on the specifications and information in
  the mission directory.
- `sync` synchronizes a `.miz` file with the base mission in the mission directory.
- `extract` generates Lua files for options, weather, and steerpoint information that is suitable
  for use by the inject scripts (see below) by extracting it from an existing mission.
- `cleanmission` removes any files from `src\miz_core` (see below) that duplicate information
  saved elsewhere in the mission directory (such as mission Lua scripts).

All Windows shell scripts are expected to be run from the top level of the mission directory.

### Lua (`.lua`) workflow Scripts

The Lua scripts reside in a subdirectory of `scripts/` (`scripts/lua`). These scripts are
primarily run by the workflow itself (i.e., invoked from a workflow shell `.cmd` script) and
not typically run by the user directly. The scripts support edits to the DCS ME mission files,
creation of resources such as kneeboards, etc.

All Lua scripts are expected to be run from the Lua subdirectory, `scripts/lua`.

## Source (`src\`)

The `src\` directory in a mission directory contains all the source assets associated with
the mission. These assets are either user-generated (e.g., Lua scripts, kneeboard images) or
DCS-ME-generated (e.g., internal DCS ME files that configure the mission). There are several
subdirectories in the `src\` directory,

- `audio\` contains any audio resources associated with the mission.
- `briefing\` contains any briefing panels for red, blue, or neutral coalitions.
- `kneeboards\` contains any kneeboards or other data necessary to generate kneeboards for
  the mission.
- `miz_core\` contains internal DCS ME files. These files are *not* user-generated and are
  maintained by the DCS ME. The workflow extracts these files from the `.miz`.
- `radio\` contains information on radio presets to preload into the client aircraft in the
  mission.
- `scripts\` contains mission Lua scripts including frameworks such as MOOSE.
- `versions\` contains information from which the workflow can determine how to build versions
  of the mission that differ in weather, time, and options.

Most of these directories contain Lua "settings" files that indicate to the workflow how to
handle the content for the missions.
