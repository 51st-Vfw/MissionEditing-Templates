@echo off
rem *******************************************************************************************
rem
rem setup.cmd: mission .miz setup tool
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

set ARG_DRY_RUN=0
set ARG_FINALIZE=0
set ARG_MAP=0
set ARG_MIZ=0
set ARG_VERBOSE=0

:ParseArgs
if "%~1" == "" (
    goto ParseDone
) else if "%~1" == "--help" (
    goto Usage
) else if "%~1" == "--dryrun" (
    set ARG_DRY_RUN=1
    set ARG_VERBOSE=1
) else if "%~1" == "--dynamic" (
    set ARG_DYNAMIC=--dynamic
) else if "%~1" == "--finalize" (
    set ARG_FINALIZE=1
) else if "%~1" == "--map" (
    if "%~2" == "" goto Usage
    set ARG_MAP=%~2
    shift
) else if "%~1" == "--miz" (
    if "%~2" == "" goto Usage
    set ARG_MIZ=%~2
    shift
) else if "%~1" == "--verbose" (
    set ARG_VERBOSE=1
) else (
    goto Usage
)
shift
goto ParseArgs
:ParseDone

rem ======== set up variables

if [%VFW51_LUA_EXE%] == [] set VFW51_LUA_EXE=lua54

rem extracts the mission name from the path to the current directory.
for /f %%i in ('%VFW51_LUA_EXE% scripts\lua\VFW51WorkflowGetMission.lua %cd%') do set MISSION_NAME=%%i

rem ======== set up mission

echo.
echo ========================================================
echo Setting Up %MISSION_NAME%
echo ========================================================
echo.
echo VFW51_7ZIP_EXE   %VFW51_7ZIP_EXE%
echo VFW51_LUA_EXE    %VFW51_LUA_EXE%

rem ======== map versus miz vector

if %ARG_FINALIZE% == 1 goto FinalizeMiz

if %ARG_MAP% == 0 goto CheckMiz
if exist Tmplt_%ARG_MAP%_core.miz goto HaveMap
echo Unable to find template for map '%ARG_MAP%'
exit /be -1

:CheckMiz
if %ARG_MIZ% == 0 goto NoInput
if exist %ARG_MIZ% goto HaveMiz
echo Unable to find mission file '%ARG_MAP%'
exit /be -1

:NoInput
echo Must specify either '--map' or '--miz' argument
exit /be -1

rem ======== starting from map template

:HaveMap
if %ARG_VERBOSE% == 1 echo copy /y Tmplt_%ARG_MAP%_core.miz %MISSION_NAME%.miz
if %ARG_DRY_RUN% == 0 copy /y Tmplt_%ARG_MAP%_core.miz %MISSION_NAME%.miz >nul 2>&1

goto Finalize

rem ======== starting from existing mission

:HaveMiz
if %ARG_VERBOSE% == 1 echo copy /y %ARG_MIZ% %MISSION_NAME%.miz
if %ARG_DRY_RUN% == 0 copy /y %ARG_MIZ% %MISSION_NAME%.miz >nul 2>&1

if %ARG_VERBOSE% == 1 echo call scripts\sync.cmd --dirty
if %ARG_DRY_RUN% == 0 call scripts\sync.cmd --dirty

echo NOTE: %MISSION_NAME%.miz has been extracted to the src\miz_core\ directory.
echo.
echo NOTE: Please move the files from src\miz_core\ to their proper locations in the
echo NOTE: mission directory and then run setup.cmd again with the "--finalize",
echo NOTE: and, if desired "--dynamic", arguments to complete workflow setup.
echo.
echo NOTE: This will clean up the src\miz_core\ directory, so make sure you have any
echo NOTE: information you need from src\miz_core\ before finalizing.

exit /be 0

rem ======== finalize setup

:FinalizeMiz

if %ARG_VERBOSE% == 1 echo call scripts\cleanmission.cmd --noheader
if %ARG_DRY_RUN% == 0 call scripts\cleanmission.cmd --noheader

:Finalize

if %ARG_VERBOSE% == 1 echo del /q Tmplt_*_core.miz
if %ARG_DRY_RUN% == 0 del /q Tmplt_*_core.miz >nul 2>&1

if %ARG_VERBOSE% == 1 echo call scripts\sync.cmd %ARG_DYNAMIC%
if %ARG_DRY_RUN% == 0 call scripts\sync.cmd %ARG_DYNAMIC%

if %ARG_VERBOSE% == 1 echo call scripts\build.cmd --nosync --dirty %ARG_DYNAMIC%
if %ARG_DRY_RUN% == 0 call scripts\build.cmd --nosync --dirty %ARG_DYNAMIC%

:Done

exit /be 0

:Usage
echo.
echo Usage: setup [--help] {--map {map}, --miz {path}} [--dynamic] [--dryrun] [--finalize] [--verbose]
echo.
echo Setup a mission directory for the 51st VFW workflow from either a map template (--map) or an
echo existing mission (--miz).
echo.
echo This script must be run from the root of a mission directory.
echo.
echo Command line arguments:
echo.
echo   --help               Displays this usage information
echo   --map {map}          Set up the mission from the map template for {map}, see Tmplt_*_core.miz
echo   --miz {path}         Set up the mission from the existing .miz at {path}
echo   --dynamic            Build mission for dynamic script loading
echo   --dryrun             Dry run, print but do not execute commands (implies --verbose)
echo   --finalize           Finalize --miz setup
echo   --verbose            Verbose logging output
echo.
echo Environment variables:
echo.
echo   VFW51_LUA_EXE        Lua console executable (default "lua54")

exit /be -1