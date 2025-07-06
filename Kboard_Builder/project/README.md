# KBB Projects

The *KBB Project* is an environment and scripts that help simplify kneeboard building with
KBB. Projects allow you to split kneeboard-specific files (like descriptions and custom
templates) from the files in the `KBoard_Builder` installation.

> Before using the project environment, you must have installed the KBB package along with the
> necessary pre-requsites as described in the
> [KBB Documentation](../README.md).

A sample *KBB Project* environment is found in the `KBoard_Builder\project` directory. This
environment includes three directories

- `output` &ndash; All `.png` output files are saved in this directory by default. If the
  directory does not exist, output files are saved to the `project` directory itself.
- `source` &ndash; This directory holds project-specific source collateral like images that
  appear on a kneeboards.
- `templates` &ndash; This directory holds project-specific templates.

Any of these directories may be safely deleted if they are not used for a specific project.

The `project` directory in `KBoard_Builder` includes sample files that build a set of
kneeboards. The sample files (any `.png`, `.xlsx`, or `.csv` files in `project` or its
subdiretories) may be safely deleted.

There are four steps to using the project environment.

## Step 1: Copy the Project Template

The project template, found in `Kboard_Builder\project`, provides a starting point for
building kneeboards. To create a new set of kneeboards for a mission, you start by making a
copy of this directory and its contents.

Use Windows File Explorer to copy the entire `project` directory from `Kboard_Builder`
to where ever you want to save your KBB projects and rename it as necessary. For example,
let's assume our KBB installation is at

```
C:\Users\Raven\Documents\Kboard_Builder
```

and that we are building kneeboards for *Operation Caw* and we would like to use the following
directory to hold the KBB project,

```
C:\Users\Raven\Documents\DCS Stuff\kboards\Operation Caw
```

Using the File Explorer copy/paste or a shell `xcopy` command, we can copy the `project`
directory and its contents from the KBB installation to the new location and reanme it. in
this example, we copy the directory `C:\Users\Raven\Documents\Kboard_Builder\project` to
`C:\Users\Raven\Documents\DCS Stuff\kboards` and rename it from `project` to `Operation Caw`.

> After copying the directory, feel free to delete the sample files (any `.png`, `.xlsx`, or
> `.csv` files) that build the sample kneeboards.

When we want to build a different set of kneeboards for another mission, we just repeat this
process and make a new copy of `project` (or, we could also start from the `Operation Caw`
project we just built).

## Step 2: Update `build.cmd`

Within the project directory (`Operation Caw` in this example), there is a Windows `.cmd`
script called `build.cmd` that takes care of launching KBB and building the kneeboards. To
use this script, you will first need to make some changes to let it know where the project
directory is on your system.

Open up `Operation Caw\build.cmd` in Notepad or any other text editor. Near the top of the
file, you should see these lines:

```cmd
rem [REQUIRED] set KBB_PATH to the path to the Kboard_Builder directory on your system.
rem            do not enclose the path in quotations.
set KBB_PATH=c:\Users\Raven\Documents\GitHub\MissionEditing-Templates\Kboard_Builder

rem [OPTIONAL] set KBB_SEARCH to the path to an alternate template directory on your
rem            system outside of this project directory.
rem            do not enclose the path in quotations, "" uses default search paths.
set KBB_SEARCH=""
```

We are going to edit `KBB_PATH`, and, for now, will leave `KBB_SEARCH` as is (we will
discuss the purpose of this variable
[later](#odds--ends)).
We need `KBB_PATH` to provide the path to the KBB directory on our system. In our example,
our base KBB installation is at,

```
C:\Users\Raven\Documents\Kboard_Builder
```

So, we will change `KBB_PATH` to match this path. Once we do, the lines near the top of
`build.cmd` we will look like this,

```cmd
rem [REQUIRED] set KBB_PATH to the path to the Kboard_Builder directory on your system.
rem            do not enclose the path in quotations.
set KBB_PATH=c:\Users\Raven\Documents\Kboard_Builder

rem [OPTIONAL] set KBB_SEARCH to the path to an alternate template directory on your
rem            system outside of this project directory.
rem            do not enclose the path in quotations, "" uses default search paths.
set KBB_SEARCH=""
```

Save the `build.cmd` file with the changes.

> Remember that the path should never be enclosed in quotation marks.

If you make a mistake, you can always copy a fresh version of `build.cmd` from the `project`
directory in your KBB install and try again.

## Step 3: Get Ready...

At this point, we need to construct the kneeboard definition files (and, optionally, any other
colleteral we need like custom templates or images) for the kneeboards for *Operation Caw*.
Typically, this involves using a spreadsheet like *Google Sheets*, *Open Office Calc*, or
*Microsoft Excel* to build a single spreadsheet that incorporates the relevant defintion
templates along with the edits to apply to the kneeboard templates.

> An example definition is in the `project\source\TW7_Kneeboards.xlsx` file. You can also
> get templates for definitions using the base templates from the `sdefs` directory in
> `KBoard_Builder` installation.

Depending on the complexity of the kneeboards, this step may also involve developing custom
templates or graphical elements that appear on the kneeboard. This collateral is typically
saved in the `templates` or `source` directories in the project.

Once the spreadsheet is constructed, it must be exported as a `.csv` file for use by the KBB
scripts.

> An example `.csv` export is in the `project\source\TW7_Kneeboards.csv` file.

See the
[main KBB documentation](TODO)
for further details on definition files, templates, and so forth.

## Step 4: Profit!

To build the kneeboards the definition you built in Step 3 describes, you need to run the
`build.cmd` script. To do so, you first need to open a command shell in the project directory.
One way to do this for our example would be,

1. Open a Windows File Explorer and navigate to the proejct directory
   (`C:\Users\Raven\Documents\DCS Stuff\kboards\Operation Caw` in this example).
2. Right click on an area outside any files and select "Open in Terminal..."

Next, simply run the `build.cmd` script providing the path to the `.csv` file you exported in
Step 3. Let's say that file is located in the project's `source` directory and named
`oc_kb.csv` In this case, you would type,

```
build.cmd source\oc_kb.csv
```

To run the script. This will process the definition file and generate any output kneeboards that
are defined in the description. If you have not deleted the `output` directory, the `.png` files
will be located there.

> The sample kneeboards in the project can be built by running
> "`build.cmd source\TW7_Kneeboards.csv`".

## Odds & Ends

By default, `build.cmd` searches the following directories for content,

1. `templates` in the KBB installation, located by the `KBB_PATH` variable in `build.cmd`
2. `templates` in the project directory, if the directory exists
3. `source` in the project directory, if the directory exists

The `KBB_SEARCH` variable in `build.cmd` allows you to add an additional directory to search
for templates and other content. This might be helpful if, for example, you have a set of
custom templates that you use for your kneeboards. For example, say you have a set of custom
templates here,

```
C:\Users\Raven\Documents\DCS Stuff\kboards\Custom Templates
```

to use your custom templates or content in the project, you would change the `KBB_SEARCH`
variable in `build.cmd` as follows,

```cmd
rem [OPTIONAL] set KBB_SEARCH to the path to an alternate template directory on your
rem            system outside of this project directory.
rem            do not enclose the path in quotations, "" uses default search paths.
set KBB_SEARCH=C:\Users\Raven\Documents\DCS Stuff\kboards\Custom Templates
```

With this variable defined, KBB will search the specified directory for template and other
content files when building a kneeboard. For more on building your own custom templates, see
the
[KBB Documentation](../README.md).

> Like the `KBB_PATH` variable, `KBB_SEARCH` should not contain quotations if it specifies
> a path.

The `build.cmd` command takes an optional `--log` argument that saves log information to a
`kbb.log` file at the root of the project directory. This file can be helpful in debugging
build issues with a description. For example, to generate the log in our earlier example
in Step 4,

```
build.cmd --log source\oc_kb.csv
```

This will overwrite any previous `kbb.log` file.