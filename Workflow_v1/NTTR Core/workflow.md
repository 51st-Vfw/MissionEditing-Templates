# Mission Editing and Packaging Workflow

This document describes a directory structure and workflows for mission editing along with
packaging missions and associated materials. As of DCS 2.7, the handling of assets such as
external Lua scripts or kneeboards in the DCS Mission Editor is clumsy, at best. This
workflow attempts to help make that less painful.

## Mission Directory Layout

Missions should be stored in a "mission directory" with a known structure that includes not
only the DCS `.miz` file, but also additional supporting material. This strucutre also allows
others to look at mission assets without having to extract them from the `.miz`. With this
structure, distributing a mission is a matter of creating and sharing a `.zip` archive.
Further, the structure allows revision control through source control systems like Github.

As an exmaple, consider the mission `51st_VFW_A_New_Hope`. The mission directory minimally
contains the mission and a README file,

- `51st_VFW_A_New_Hope.miz` the DCS mission file in standard `.miz` format.
- `readme.md` mission README file providing brief overview of the mission and any other
  summary information.

Based on the assets in the mission `.miz` (see below), the mission directory may also contain
one or more "mission master directories",

- `miz_master_audio/` directory containing the master audio files (in `.ogg` or `.wav` format)
  for the mission. This would include an audio file played in response to a trigger, for example.
- `miz_master_brief/` directory containing the master briefing image files (in `.jpg` or `.png`
  format with an aspect ratio of 3:4) to include in the mission. This would include images to
  include in the briefing panel at mission load.
- `miz_master_kboard/` directory containing the master kneeboard image files (in `.jpg` or
  `.png` format with an aspect ratio of 3:4, typically 1536 x 2048) to include in the mission.
  This would include a mission kneeboard available to all aircraft in the mission, for example.
- `miz_master_scripts/` directory containing the master Lua script files for mission scripting.

Other optional content in the mission directory include,

- `workflow.md` mission workflow description (this file).
- `docs/` directory containing mission briefing materials and any other documentation.
- `scripts/` directory contains the scripts that support the workflow. This directory does
  **not** contain mission-specific Lua scripts.
- `miz_tmp_unpacked/` directory contains an unpacked version of the mission extracted from the
  main mission file (`51st_VFW_A_New_Hope.miz` in this example). This data is transitory and
  does not need to be tracked by source control as it repeats information in the `.miz`.
- Alternate versions of the `.miz` file. For exmaple, the mission directory might contain two
  versions of the `51st_VFW_A_New_Hope` mission with different weather.

The mission can be distributed as a `.zip` archive of the mission directory if desired.

## Integrating with Source Control Systems

The manner in which DCS packages and encodes its missions makes it difficult to efficiently
use source control systems such as Github. Generally, the best way to integrate with source is
control is to adopt an approach of commiting only on major revisions of the entire mission, not
commiting on individual changes to, for example, a Lua script in the mission. The
`miz_tmp_unpacked` directory may be safely excluded from a source control repository.

## Setting up for the Full Workflow

Depending on mission complexity, the workflow may involve the use of several PowerShell scripts
that marshall data between packed (i.e., `.miz`) and unpacked forms. The scripts in question
are always included in the `scripts/` directory of the mission directory and help manage
external files (such as Lua scripts or kneeboards) that are either difficult or impossible to
manage from within the DCS Mission Editor.

> For simple missions that do not rely on external files, using the DCS Mission Editor alone
> without any additional PowerShell scripting is sufficient.

The pack/unpack scripts rely on [7-Zip](https://www.7-zip.org/) to manipulate `.miz` files.
They expect 7-zip executable to be available at the path `C:\Program Files\7-Zip\7z.exe`. To
change the install location, you can set the `7zip` user environment variable to the
appropriate path.

To run any of the PowerShell scripts, Windows will need to be set up to allow unsigned scripts
to run. You can change the Windows script execution policy to allow unsigned scripts to run in
a specific PowerShell process with the following command,

```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```

This command will only change the execution policy for the current PowerShell process. With
this invocation, the execution policy will not be persisted or reflected in any other
processes in the system (from `-Scope Process`). See the `Set-ExecutionPolicy` help for
other values for `-Scope` that can, for example, allow the setting to be persisted
system-wide across reboots.

## Managing Mission Assets in the Full Workflow

DCS Mission files (`.miz`) are basically `.zip` archives of a collection of files that
together define the mission. These files may include assets, such as external scripts, audio,
kneeboards, and briefing panels, that are difficult to edit from the DCS Mission Editor. This
workflow makes it easy to inject these assets back into an existing `.miz` file so that you
can edit outside of the DCS Mission Editor and incorporate changes back into the `.miz` without
needing to involve the DCS Mission Editor.

The first rule of the workflow is,

> The master versions of the assets are **_always_** found in a mission master directory such
> as `miz_master_scripts/`. Edits to the assets **_must always_** occur to the versions stored
> in these directories.

As the assets are incorporated into the `.miz`, this workflow results in the duplication of
assets. While this costs storage, it makes it much easier to, for example, inspect and edit
scripts within a mission.

In addition to including the assets, the `.miz` file also contains linkages to some of the
assets in several places within the mission file. The embedded linkages are best left to
the DCS Mission Editor to manage. The workflow relies on DCS Mission Editor to handle these
linkages.

### Packing and Unpacking Missions

The `mizunpack.ps1`, `mizpack.ps1`, and `mizrepack.ps1` scripts help move data to and from
a `.miz`. Typically, these scripts are always run from the root of the mission directory
described earlier. The `mizunpack.ps1` script takes a `.miz` file as an argument,

```
% .\scripts\mizunpack.ps1 51st_VFW_A_New_Hope.miz
```

This unpacks the mission `51st_VFW_A_New_Hope.miz` to the `miz_tmp_unpacked/` directory
in the current directory. If a `miz_tmp_unpacked/` directory exists, it is first deleted
prior to unpacking the mission file.

> NOTE: After unpacking, `7zip` may report a "Headers Error" warning. This is benign.

The `mizpack.ps1` script also takes a `.miz` file as an argument,

```
% .\scripts\mizpack.ps1 51st_VFW_A_New_Hope.miz
```

This packs the mission `51st_VFW_A_New_Hope.miz` using the mission master directories and the
`miz_tmp_unpacked/` directory in the current directory. If the mission file exists, it is
moved to the recycle bin before packing. Packing first copies all of the assets in the mission
master directories into their correct locations in the `miz_tmp_unpacked/` directory, then
creates a new `.miz` mission file from the updated unpacked mission directory.

The `mizrepack.ps1` script invokes `mizunpack.ps1` followed by `mizpack.ps1` on the same
argument, cleaning up the `miz_tmp_unpacked/` directory afterwards. This is primarily a
convience for situations where you unpack and then immediately repack.

### Adding, Removing, or Renaming Mission Assets

Due to the asset links within the `.miz` file, it is not possible to add, remove, or rename
audio, briefing, or script assets by making the corresponding change to the asset in the
mission master directories. For these assets, it is necessary to involve the DCS Mission
Editor.

All mission assets must be directly referenced from the mission file. Assets that are not
referenced may be discarded by the DCS Mission Editor. For example, DCS will not persist an
audio file that is only referenced in a Lua script file. To persist the audio file in this
example, it could be played in a DCS Mission Editor trigger that is set to never trigger.

When adding or removing an asset,

1. Add or remove master asset files in the appropriate mission master directories.
2. Open the mission in the DCS Mission Editor.
3. Update the assets in the DCS Mission Editor by adding or removing as necessary. When adding,
   the DCS Mission Editor should reference the appropriate files in the mission master
   directories.
3. Save the mission in the DCS Mission Editor.

The specifics of step (3) depend on the asset and operation. For example, adding a Lua script
might involve adding a trigger that does a "DO SCRIPT FILE" operation on a Lua script from the
`miz_master_scripts/` directory; removing this script might involve removing all triggers that
reference the script.

> If the mission editor is not involved, an asset in a mission master directory may not be
> available to the mission.

Renaming a mission asset requires first removing the asset in the DCS Mission Editor, then
adding it back under the new name.

For briefing assets, the updates can be made directly in the `miz_master_kboard/` directory.
Due to (apparent) caching in DCS, you may need to restart DCS to see updates to briefing
assets.

### Synchronizing the Mission and Master Assets

Periodically, you may want to synchronize changes to the master assets and changes to the
mission to incorporate changes in the master assets into the mission. Before starting, you
must ensure you have saved both the `.miz` through the DCS Mission Editor as well as any
master assets that have changed.

> It is generally good practice to make sure the mission is not open in the DCS Mission
> Editor prior to attempting any synchronization.

To synchronize following changes to master assets,

1. Use the `mizrepack.ps1` script to unpack the current version of the `.miz` to
   `miz_tmp_unpacked/`, inject the latest assets from the master asset directories, and repack
   the `.miz` file with the latest assets.
2. Open the `.miz` in the DCS Mission Editor to access the updated mission.

You can also perform step (1) by manually using the `mizunpack.ps1` followed by `mizpack.ps1`
scripts. This might be done when you need to make changes to other internal `.miz` files
which can be edited in `miz_tmp_unpacked/` after unpacking. Generally, you should avoid
directly editing any files in `miz_tmp_unpacked/`.
