# Kneeboard Builder

*Version 0.2 of 6 July 2025*

*Kneeboard Builder* (KBB) is a `python` program that can generate customized kneeboards
from a collection of `.svg` templates. The templates describe the structure of the kneeboard
image while a user-supplied definition file specifies the content. Typically, the definition
file is simply a spreadsheet saved in `.csv` format. You can think of the `.svg` file as a
"form" that is filled in according to the information in the `.csv` file. For example, the
`.svg` template tells KBB that "Name" goes in this area on the kneeboard while the `.csv`
tells KBB that the name to use for a specific kneeboard is "Raven".

This guide focuses on using existing templates. A guide for those who want to build custom
templates that go beyond what is available by default is available
[here](TODO).

## Preliminaries: Installation & Prerequisites

KBB is part of the
[51st VFW Mission Editing Templates](https://github.com/51st-Vfw/MissionEditing-Templates).
You can either clone the repository directly with `github` using something like the
[GitHub Desktop Client](https://github.com/apps/desktop)
or download a
[`.zip` archive](https://github.com/51st-Vfw/MissionEditing-Templates/archive/refs/heads/main.zip)
of the repository directly. KBB and its supporting files are found in the `Kboard_Builder`
directory within the Mission Editing Templates repository or archive.

> KBB does not require any files outside of the `Kboard_Builder` directory to function. You can
> safely remove the other files if you do not think you will use them.

In addition to
[KBB](https://github.com/51st-Vfw/MissionEditing-Index/blob/master/documentation/me_workflow.md)
itself, there are three other packages that must be installed on your system for KBB to
function.

- *Python* &ndash; KBB is written in
  [`python3`](https://www.python.org/downloads/windows/).
  It does not require anything beyond the standard Python packages, so a basic `python` install
  from the Python website should be sufficient.
- *Inkscape* &ndash; KBB uses
  [*Inkscape*](https://inkscape.org/)
  to convert `.svg` files into `.png` files suitable for use in DCS. Also, *Inkscape* is a
  vector graphics program that can also be used to build and edit your own templates.
- *Helvetica Neue Font Family* &ndash; Because *Arial* is ass, the standard KBB templates use
  *Helvetica Neue* (in Regular, Medium, Medium Italic, Bold, and Bold Italic weights), which,
  because Microsoft is cheap, is not part of a Windows release.

`python` and *Inkscape* are open source software and are free (as in beer), while there are
several "free for personal use" versions of *Helvetica Neue* available on the web. You can
find these packages on the Microsoft store or on the web (via your favorite search engine)
along with tutorials on installing new fonts on Windows.

An IDE such as
[*Visual Studio Code*](https://code.visualstudio.com/)
may also be helpful, but is not required.

Once installed, you can validate everything is set up correctly by opening up a command prompt
from Windows (search for `cmd` in the Windows search box and launch the Command Prompt
application) and then type,

```
python --version
```

You should see something like,

```
Python 3.12.0
```

The specific version number is not critical as long as it is later than 3.0.0. Next, type:

```
inkscape.com --version
```

You should see something like,

```
Inkscape 1.4 (86a8ad7, 2024-10-11)
```

Again, the specific version is not critical. If you do not see version numbers, you may not
have the Windows path set up correctly. Ask a Windows geek for help in this case.

## Running KBB

The easiest and fastest way to run KBB is through the `project` template included in the
repository or archive in the `Kboard_Builder\project` directory. The
[documentation](project/README.md)
in that directory describes how to use the project infrastructure. After reading through
that documentation, it is recommended that you also read through the material below on
[building kneeboards](#building-kneeboards).

For those wanting to know more about the underlying scripts, see the discussion
[below](#kbbpy-script)

## Building Kneeboards

In KBB, each kneeboard has a template. This template can then be edited to generate multiple
individual kneeboards customized for a particular audience. For example, you might have a
kneeboard that shows target information that has different versions for flights based on
their tasking. Here, there is a single template that is customized for each flight resulting
in several kneeboards that are similar in structure but differ in content.

To generate kneeboards, you provide KBB with a *definition file* that specifies the templates,
and changes to those templates, that KBB should perform. The distribution includes the
following base templates,

| Link to Template Documentation | Link to Sample Definition | Description |
|:-:|:-:|:-|
|[`KBT_Flight_Card.svg`](docs/KBT_Flight_Card.md)|[Link](https://github.com/51st-Vfw/MissionEditing-Templates/tree/master/Kboard_Builder/sdefs/Definition_Flight_Card.xlsx)| Summary of important general flight information
|[`KBT_Grid_Card.svg`](docs/KBT_Grid_Card.md)|[Link](https://github.com/51st-Vfw/MissionEditing-Templates/tree/master/Kboard_Builder/sdefs/Definition_Grid_Card.xlsx)| General grid-based layout for kneeboards, see the [element documentation](docs/Elements.md) for additional details

This table provides links to further documentation on the template as well as a sample
definition files that can serve as a starting point when building your own definition files.

### Definition Files

The sample definition files in `Kboard_Builder/sdefs` are in `.xlsx` format and can be opened
by most spreadsheet programs. We will use spreadsheet terminology like "cell", "row", and
"column" when discussing definition files. The samples provide a starting point for your own
definitions along with additional documentation that helps explains how to set up the
definition. After editing a defintion, it should be exported in `.csv` format or use by KBB.

> Generally, you will create a single definition file that may contain the definitions for
> mutliple kneeboards potentially based on different templates.

Columns in a definition file are divided into three groups,

- *Fields* &ndash; includes Columns A and B and defines the template content to be changed.
- *Variants* &ndash; includes Column C up to the first completely empty column and defines
  variations of the template. Each column in the *Variants* section corresponds to a different
  kneeboard. For example, a *Variants* section with two columns might describe kneeboards
  specialized for two flights in a package.
- *Notes* &ndash; includes all columns starting with the first completely empty column that
  marks the end of the *Variants* section and provides documentation.

KBB *ignores* all rows where Column B is empty. This allows comments to be added to
definition files by only putting text in Column A of the row.

Groups of rows in a definition file specify changes to apply to a template. These groups begin
with a header row with "Description" and "Field" in Columns A and B and are followed by rows
that describe the changes to make to a template for each of the variations in the *Variants*
section. Generally, specifying a definition requires editing cells in the group that are in the
non-header rows of the *Variants* columns.

> Different groups within a definition file may have different numbers of *Variants* columns.

KBB only uses the _content_ of the cells in the spreadsheet. All formatting of a cell's content
is *ignored*: using **bold** red text in the cell for a value will **not** result in **bold**
red text in the final kneeboard.

### Common Fields

All definition files will typically provide rows to set the four common fields listed below,

|Field|Description |
|:---:|------------|
|KBB&nbsp;Template | Template file name or path (relative to current directory) to apply the edits in the current group to. When searching for template, KBB will first search the current directory, followed by the `./templates` directory, followed by directories specified in any `--search` KBB [command line arguments](#kbbpy-script).
|KBB&nbsp;Output   | File name or path (relative to current directory) for output files (excluding extension). By convention, "VARIANT" (case-sensitive) in the value is replaced by the variant column header. When unspecified, this field defaults to "*T*_VARIANT" where "*T*" is the value of *KBB Template* with any extension removed. Files are saved relative to the current directory or the directory specified by an `--output` KBB [command line argument](#kbbpy-script).
|Card Title        | Optional title for the header of the kneeboard.
|Card Version      | Optional version number for the footer of the kneeboard.

These are typically the first few edits a group specifies. The field will appear in Column B of
the row.

### Specifying Edits

Each non-ignored row in a group from a definition file expresses a set of edits to apply to
a particular part of the template. Individual edits are found in one of the *Variants* columns
of the row. For templates that work more like "forms", you can likely use the sample
description file as a starting point. For more free-form templates, you may need to specify
edits yourself.

There are two types edits KBB can make to a template file,

- *Replace* &ndash; "Replace the element tagged `X` with the element tagged `Y` from the
  template `Z`.
- *Substitute* &ndash; "Substitue the text `Y` for all text tags `X` found in an element"

Here, an "element" refers to a component of an `.svg` file.

For example, a text span, rectangle, etc. For either type of edit, the tag `X` is given by the
content of the *Fields* column (Column B) of the row that describes the edit (we'll refer to
this as the _"Field Cell"_). The values of `Y` and, for replace edits, `Z` are taken from a
cell of the *Variants* section of the row (we'll refer to this as the _"Value Cell"_). Edits
are encoded as follows,

|Field Cell|Value Cell|Resulting Operation|
|:--:|:--:|---|
| `id`&nbsp;:&nbsp;Replace | Remove                   | Replace element with ID `id` in the template with an empty element (thus removing it). `id` is case-insensitive.
| `id`&nbsp;:&nbsp;Replace | `eid`&nbsp;:&nbsp;`file` | Replace element with ID `id` in the template with the element with ID `eid` from the template in file `file`. The template is searched for using the [same rules](#common-fields) as *KBB Template*. `id` and `eid` are case-insensitive.
| `tag`                    | `text`                   | Substitue the text `text` for any text content matching `tag` in any element in the template. `tag` is case-insensitive.
| `id`&nbsp;:&nbsp;`tag`   | `text`                   | Substitue the text `text` for any text content matching `tag` in any element of the element that replaced the element with ID `id` from the template. An "`id`&nbsp;:&nbsp;Replace" edit must preceed this in the defintion. `id` and `tag` are case-insensitive.
| :&nbsp;`tag`             | `text`                   | Substitue as in "`id`&nbsp;:&nbsp;`tag`" with the `id` given by `id` from the first preceeding "`id`&nbsp;:&nbsp;Replace" edit. `tag` is case-insensitive.

Replace and substitute edits are distinguished by the presence of a ":" in the field cell.
Note that the *KBB Template* and *KBB Output*
[fields](#specifying-edits)
are encoded as "substitution" edits, though they are not, strictly speaking, making changes
to a template.

### Definition Files: An Example

As an example, let's look at what the definition file might look like for kneeboards to
support a strike mission with the following setup,

- VENOM1 flight is striking a column of tanks at SP2
- JEDI2 flight is striking a command bunker at SP4

Both flights are operating out of Nellis AFB and will use Creech AFB as an alternate. Let's
also assume there are two kneeboard templates we will be using,

- `Ex_Base.svg` shows the primary and alternate bases for a mission.
- `Ex_Target.svg` shows the primary target for a strike.

For this mission, would like to build three kneeboards: one based on `Ex_Base.svg` for use by
both VENOM1 and JEDI2 flights, and two based on `Ex_Target.svg` specific to VENOM1 and JEDI2
flights.

The sample definition file for `Ex_Base.svg` might look like this,

|Row|A|B|C|D|E|
|:-:|:-|:-:|:-:|:-:|:--|
|1|Base Information     |
|2|                     |
|3|Description          |Field       |FLIGHT        ||Notes
|4|Template File Name   |KBB Template|Ex_Base.svg   ||Template file
|5|Output File Base Name|KBB Output  |              ||Output name
|6|Primary Airbase      |Pri         |              ||Name base
|7|Alternate Airbase    |Alt         |              ||Name base

The sample for `Ex_Target.svg` would look similar but only have a primary target field and use
a different template name. There are several things to point out here,

- Column C defines the *Variants* section of the definition and contains a single variant. To
  add more variants, you add columns following Column C.
- Rows 1 and 2 are ignored as they only have content in Column A or are empty.
- Row 3 is the header row that defines the start of the group.
- Row 4 defines the name of the template file that KBB customizes. Typically, the user does not
  need to change this value.
- Row 5 defines the base name of output files that KBB generates.

Removing ignored rows and building out for the mission outlined above gives us a definition
file,

|Row|A|B|C|D|E|F|
|:-:|:-|:-:|:-:|:-:|:--|:--|
| 1|_Description_        |_Field_     |***Package***  ||_Notes_
| 2|Template File        |KBB Template|Ex_Base.svg    ||File name
| 3|Output File Base     |KBB Output  |**Bases**      ||Output name
| 4|Primary Airbase      |Pri         |**Nellis AFB** ||Primary name
| 5|Alternate Airbase    |Alt         |**Creech AFB** ||Alternate name
| 6|_Description_        |_Field_     |***VENOM1***   |***JEDI2***     ||_Notes_
| 7|Template File        |Tmplt       |Ex_Target.svg  |Ex_Target.svg   ||Template file
| 8|Output File Base     |Out         |**Tgt_VARIANT**|**Tgt_VARIANT** ||Output name
| 9|Primary Target       |Pri         |**Tanks, SP2** |**Bunker, SP4** ||Primary name

To help with the explanation, in this example _italic_ text identifies header rows and
**bold** text identifies cells the edited by the user. Starting with the groups,

- The first group has its header in row 1 and runs through row 5. This group has one variation
  in its *Variants* section (Column C) for the package.
- The second group has its header in row 6 and runs through row 9. This group has two
  variations in its *Variants* section (Columns C and D), one each for VENOM1 and JEDI1
  flights.

The cells that contain content KBB uses to create the kneeboards (basically, the **bold**
text above) may be empty. If not specified, fields in the created kneeboards default to
empty; deleting row 5 (for example) would cause the generated kneeboards to have empty
alternate airbase fields.

> Generally, you should not need to edit any cells outside of the *Variants* section of the
> definition file. For compactness, you may want to delete rows for fields you are not going
> to set.

When processed by KBB, this definition generates three files,

- `Bases.png` contains the information on bases shared by both VENOM1 and JEDI2 flights.
- `Tgt_VENOM1.png` contains the infomration on the VENOM1 strike target.
- `Tgt_JEDI2.png` contains the information on the JEDI2 strike target.

As mentioned earlier, these files will be saved to the current directory or the location the
`--output` argument to KBB specifies.

## `kbb.py` Script

> This information is mosstly for the curious. The
> [project template](project/README.md)
> can take care of setting up and running KBB for you.

KBB is old school and run from the command line in a Windows Command Prompt or PowerShell
window (a "shell" for short). To use KBB, you need to start a shell in your `Kboard_Builder`
directory. The easiest way to do this is,

- Open a File Explorer window and navigate to your `Kboard_Builder` directory.
- Right click on the window in the file area (but not on a file) and select "Open in Terminal"
  from the context menu.

This will open a PowerShell window that is set up to work in the `Kboard_Builder` directory.
There are many other ways to start a shell as well. Regardless of how you launched the shell,
now type:

```
python kbb.py -h
```

This tells `python` to run KBB (`kbb.py`) with the argument `-h`. In response, KBB will display
help information that describes how to use the program and looks like this,

```
usage: kbb.py [-h] [--log] [--dry] [--svg] [--nopng] [--edits] [--search SEARCH] [--output OUTPUT] [--template TEMPLATE] definition

Build kneeboard from descriptions and templates

positional arguments:
  definition           Definition file: CSV by default, KBB edits file if --edits given

options:
  -h, --help           show this help message and exit
  --log                Generate logging information on template edits to kbb_log.txt
  --dry                Dry run, do not produce any output files
  --svg                Preserve .svg intermediate files when creating .png files
  --nopng              Do not create .png files (implies --svg)
  --edits              Definition argument is a KBB edits file file to process (requires --template)
  --search SEARCH      Additional search path for template files (optional, can be repeated)
  --output OUTPUT      Path save output files to (default: current directory)
  --template TEMPLATE  Path to template .svg file (--edits only)
  ```

There are a lot of options, but the most common command line for KBB typically looks like this,

```
python kbb.py C:\Users\raven\Documents\My_kneeboards.csv
```

which tells KBB to generate `.png` versions of the kneeboards specified by the `.csv`
definition file found at the path `C:\Users\raven\Documents\My_kneeboards.csv`.
