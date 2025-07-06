@echo off
rem -------------------------------------------------------------------------------------------------
rem
rem build.cmd -- build wrapper for kbb kneeboard builder
rem
rem -------------------------------------------------------------------------------------------------

rem [REQUIRED] set KBB_PATH to the path to the Kboard_Builder directory on your system.
rem            do not enclose the path in quotations.
set KBB_PATH=c:\Users\twillis\Documents\GitHub\MissionEditing-Templates\Kboard_Builder

rem [OPTIONAL] set KBB_SEARCH to the path to an alternate template directory on your
rem            system outside of this project directory.
rem            do not enclose the path in quotations, "" uses default search paths.
set KBB_SEARCH=""

rem -------------------------------------------------------------------------------------------------

setlocal enableDelayedExpansion

set ARG_DEFN=""
set ARG_LOG=0
for %%x in (%*) do (
    if "%%~x" == "--log" (
        set ARG_LOG=1
    ) else if !ARG_DEFN! == "" (
        set ARG_DEFN="%%~x"
    ) else (
        echo Unknown command line argument
        goto Usage
    )
)
if %ARG_DEFN% == "" (
    echo No description file specified
    goto Usage
) else if not exist "%ARG_DEFN%" (
    echo Description file %ARG_DEFN% does not exist
    goto Usage
)

set KBB_ARGS= --search "%KBB_PATH%\templates"
if %ARG_LOG% == 1  set KBB_ARGS=%KBB_ARGS% --log
if exist "templates" set KBB_ARGS=%KBB_ARGS% --search templates
if exist "source" set KBB_ARGS=%KBB_ARGS% --search source
if exist "%KBB_SEARCH%" set KBB_ARGS=%KBB_ARGS% --search "%KBB_SEARCH%"
if exist "output" set KBB_ARGS=%KBB_ARGS% --output output

echo python "%KBB_PATH%\kbb.py"%KBB_ARGS% %ARG_DEFN%
python "%KBB_PATH%\kbb.py"%KBB_ARGS% %ARG_DEFN%

:BuildDone

exit /be 0

:Usage
echo.
echo Usage: build.cmd [--log] {definition.csv}
exit /be -1