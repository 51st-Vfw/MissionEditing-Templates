@echo off
rem *******************************************************************************************
rem
rem wfupdate.cmd: workflow update
rem
rem see usage below for further details
rem
rem *******************************************************************************************

setlocal enableDelayedExpansion

if exist %cd%/src goto InMissionDir
echo This script must be run from the base mission directory. Unable to locate src directory.
exit /be 1
:InMissionDir

rem ======== parse command line

set ARG_FORCE=0
set ARG_NO_FRAME=1
set ARG_NO_SCRIPTS=1
set ARG_NO_WFLOW=1
set ARG_DRY_RUN=0
set ARG_VERBOSE=0
set ARG_VERSION=0
set ARG_TARG_MDIR=""

for %%x in (%*) do (
    if "%%~x" == "--help" (
        goto Usage
    ) else if "%%~x" == "--dryrun" (
        set ARG_DRY_RUN=1
        set ARG_VERBOSE=1
    ) else if "%%~x" == "--force" (
        set ARG_FORCE=1
    ) else if "%%~x" == "--frame" (
        set ARG_NO_FRAME=0
    ) else if "%%~x" == "--script" (
        set ARG_NO_SCRIPTS=0
    ) else if "%%~x" == "--settings" (
        set ARG_NO_WFLOW=0
    ) else if "%%~x" == "--verbose" (
        set ARG_VERBOSE=1
    ) else if "%%~x" == "--version" (
        set ARG_VERSION=1
    ) else if !ARG_TARG_MDIR! == "" (
        set ARG_TARG_MDIR=%%~x
    ) else (
        goto Usage
    )
)

if %ARG_VERSION% == 1 goto GetThisVersions

if exist %ARG_TARG_MDIR% goto ValidTarget
echo Target mission directory %ARG_TARG_MDIR% not found
goto Usage
:ValidTarget
if exist %ARG_TARG_MDIR%\src goto ValidSrc
echo Target directory '%ARG_TARG_MDIR%' does not appear to be a mission directory
goto Usage
:ValidSrc

if %ARG_NO_FRAME% == 1 if %ARG_NO_SCRIPTS% == 1 if %ARG_NO_WFLOW% == 1 goto UpdateAll
goto SetupUpdate
:UpdateAll
set ARG_NO_FRAME=0
set ARG_NO_SCRIPTS=0
set ARG_NO_WFLOW=0
:SetupUpdate

rem ======== set up variables

rem extracts versions from the versions files
set TARG_VERS=%ARG_TARG_MDIR%\scripts\versions
for /f %%i in (%TARG_VERS%\frameworks.txt) do set TARG_VERS_FWORKS=%%i
for /f %%i in (%TARG_VERS%\scripts.txt) do set TARG_VERS_SCRIPTS=%%i
for /f %%i in (%TARG_VERS%\settings.txt) do set TARG_VERS_WKFLOW=%%i

:GetThisVersions
set THIS_VERS=%cd%\scripts\versions
for /f %%i in (%THIS_VERS%\frameworks.txt) do set THIS_VERS_FWORKS=%%i
for /f %%i in (%THIS_VERS%\scripts.txt) do set THIS_VERS_SCRIPTS=%%i
for /f %%i in (%THIS_VERS%\settings.txt) do set THIS_VERS_WKFLOW=%%i

set THIS_MDIR=%cd%
set THIS_MDIR_SRC=%THIS_MDIR%\src
set THIS_MDIR_SCRIPT=%THIS_MDIR%\scripts

set TARG_MDIR=%ARG_TARG_MDIR%
set TARG_MDIR_SRC=%TARG_MDIR%\src
set TARG_MDIR_SCRIPT=%TARG_MDIR%\scripts

rem ======== version

if %ARG_VERSION% == 0 goto StartUpdate

echo Workflow Element Versions for Mission Directory %cd%:
echo   Scripts    : v%THIS_VERS_SCRIPTS%
echo   Frameworks : v%THIS_VERS_FWORKS%
echo   Workflow   : v%THIS_VERS_WKFLOW%
goto SettingsDone

rem ======== update

:StartUpdate

echo.
echo ========================================================
echo Updating Mission Directory %ARG_TARG_MDIR%
echo ========================================================
echo.

if %ARG_NO_SCRIPTS% == 0 echo Scripts    : this v%THIS_VERS_SCRIPTS%, target v%TARG_VERS_SCRIPTS%
if %ARG_NO_FRAME% == 0   echo Frameworks : this v%THIS_VERS_FWORKS%, target v%TARG_VERS_FWORKS%
if %ARG_NO_WFLOW% == 0   echo Workflow   : this v%THIS_VERS_WKFLOW%, target v%TARG_VERS_WKFLOW%
echo.

if %ARG_NO_SCRIPTS% == 1 goto ScriptsDone
if %ARG_FORCE% == 1 goto ScriptsUpdate
if %THIS_VERS_SCRIPTS% leq %TARG_VERS_SCRIPTS% goto ScriptsDone

:ScriptsUpdate
echo ---- Updating workflow scripts

if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SCRIPT%\versions\scripts.txt %TARG_MDIR_SCRIPT%\versions\ 
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SCRIPT%\versions\scripts.txt %TARG_MDIR_SCRIPT%\versions\ >nul 2>&1

if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SCRIPT%\*.cmd %TARG_MDIR_SCRIPT%\
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SCRIPT%\*.cmd %TARG_MDIR_SCRIPT%\ >nul 2>&1

if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SCRIPT%\lua\* %TARG_MDIR_SCRIPT%\lua\
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SCRIPT%\lua\* %TARG_MDIR_SCRIPT%\lua\ >nul 2>&1

:ScriptsDone

if %ARG_NO_FRAME% == 1 goto FrameDone
if %ARG_FORCE% == 1 goto FrameUpdate
if %THIS_VERS_FWORKS% leq %TARG_VERS_FWORKS% goto FrameDone

:FrameUpdate
echo ---- Updating mission frameworks (MapSOP, MOOSE, Skynet)

if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SCRIPT%\versions\frameworks.txt %TARG_MDIR_SCRIPT%\versions\ 
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SCRIPT%\versions\frameworks.txt %TARG_MDIR_SCRIPT%\versions\ >nul 2>&1

if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SRC%\scripts\51stMapSOP.lua %TARG_MDIR_SRC%\scripts\
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SRC%\scripts\51stMapSOP.lua %TARG_MDIR_SRC%\scripts\ >nul 2>&1

if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SRC%\scripts\Moose_.lua %TARG_MDIR_SRC%\scripts\
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SRC%\scripts\Moose_.lua %TARG_MDIR_SRC%\scripts\ >nul 2>&1

if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SRC%\scripts\skynet-iads-compiled.lua %TARG_MDIR_SRC%\scripts\
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SRC%\scripts\skynet-iads-compiled.lua %TARG_MDIR_SRC%\scripts\ >nul 2>&1

if %ARG_VERBOSE% == 1 echo del %TARG_MDIR_SRC%\scripts\mist_*_*_*.lua
if %ARG_DRY_RUN% == 0 del %TARG_MDIR_SRC%\scripts\mist_*_*_*.lua >nul 2>&1

if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SRC%\scripts\mist_*_*_*.lua %TARG_MDIR_SRC%\scripts\
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SRC%\scripts\mist_*_*_*.lua %TARG_MDIR_SRC%\scripts\ >nul 2>&1

if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SRC%\scripts\vfw51_mission_util.lua %TARG_MDIR_SRC%\scripts\
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SRC%\scripts\vfw51_mission_util.lua %TARG_MDIR_SRC%\scripts\ >nul 2>&1

:FrameDone

if %ARG_NO_WFLOW% == 1 goto SettingsDone
if %ARG_FORCE% == 1 goto SettingsUpdate
if %THIS_VERS_WKFLOW% leq %TARG_VERS_WKFLOW% goto SettingsDone

:SettingsUpdate
echo ---- Updating workflow settings

echo.
echo NOTE: Workflow settings files may have changed format. The new files will be copied to the
echo NOTE: proper directory wth a "v%THIS_VERS_WKFLOW%" suffix. You will need to manually merge these with the
echo NOTE: existing settings in the mission being updated.
echo.

if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SCRIPT%\versions\settings.txt %TARG_MDIR_SCRIPT%\versions\ 
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SCRIPT%\versions\settings.txt %TARG_MDIR_SCRIPT%\versions\ >nul 2>&1

set SET_PATH=audio\vfw51_audio_settings.lua
if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW%
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW% >nul 2>&1

set SET_PATH=briefing\vfw51_briefing_settings.lua
if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW%
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW% >nul 2>&1

set SET_PATH=kneeboards\vfw51_kneeboard_settings.lua
if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW%
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW% >nul 2>&1

set SET_PATH=loadouts\vfw51_loadout_settings.lua
if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW%
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW% >nul 2>&1

set SET_PATH=radio\vfw51_radio_settings.lua
if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW%
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW% >nul 2>&1

set SET_PATH=scripts\vfw51_script_settings.lua
if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW%
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW% >nul 2>&1

set SET_PATH=variants\vfw51_variant_settings.lua
if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW%
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW% >nul 2>&1

set SET_PATH=waypoints\vfw51_waypoint_settings.lua
if %ARG_VERBOSE% == 1 echo copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW%
if %ARG_DRY_RUN% == 0 copy /Y %THIS_MDIR_SRC%\%SET_PATH% %TARG_MDIR_SRC%\%SET_PATH%_v%THIS_VERS_WKFLOW% >nul 2>&1

:SettingsDone

exit /be 0

:Usage
echo.
echo Usage: wfupdate [--help] [--dryrun] [--force] [--frame] [--script] [--settings] [--version]
echo                 [-verbose] {targ_mdir}
echo.
echo Update the scripting, settings, or framework components in a target mission directory to match
echo the versions in the current mission directory.
echo.
echo This script must be run from the root of a mission directory.
echo.
echo Command line parameters:
echo.
echo   --help               Displays this usage information
echo   --dryrun             Dry run, print but do not execute commands (implies --verbose)
echo   --force              Force updates regardless of version
echo   --frame              Update mission framework scripts component
echo   --script             Update workflow scripting component
echo   --settings           Update workflow settings component
echo   --version            Display current workflow versions without making changes
echo   --verbose            Verbose logging output
echo   {targ_mdir}          Target mission directory to update
echo.
echo If none of --frame, --script, or --settings are given, all components are updated as
echo necessary.
echo.

exit /be -1