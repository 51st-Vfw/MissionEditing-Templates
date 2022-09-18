@echo off
rem *******************************************************************************************
rem
rem unpack.cmd: mission .miz unpack tool
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

set ARG_IMPORT=0
set ARG_DIRTY=0
set ARG_DRY_RUN=0
set ARG_LUADEBUG=0
set ARG_LUATRACE=0
set ARG_VERBOSE=0

for %%x in (%*) do (
    if "%%~x" == "--help" (
        goto Usage
    ) else if "%%~x" == "--import" (
        set ARG_IMPORT=1
    ) else if "%%~x" == "--dirty" (
        set ARG_DIRTY=1
    ) else if "%%~x" == "--dryrun" (
        set ARG_DRY_RUN=1
        set ARG_VERBOSE=1
    ) else if "%%~x" == "--dynamic" (
        set LUA_DYNAMIC=--dynamic
    ) else if "%%~x" == "--verbose" (
        set ARG_VERBOSE=1
    ) else if "%%~x" == "--luadebug" (
        set ARG_LUADEBUG=1
    ) else if "%%~x" == "--luatrace" (
        set ARG_LUATRACE=1
    ) else (
        echo Unknown command line argument
        goto Usage
    )
)

rem ======== set up variables

if [%VFW51_7ZIP_EXE%] == []  set VFW51_7ZIP_EXE=7z
if [%VFW51_LUA_EXE%] == [] set VFW51_LUA_EXE=lua54
if [%VFW51_LUA_LOG%] == [] (
    if %ARG_LUATRACE% == 1 set VFW51_LUA_LOG=--trace
    if %ARG_LUADEBUG% == 1 set VFW51_LUA_LOG=--debug
)

rem extracts the mission name from the path to the current directory.
for /f %%i in ('%VFW51_LUA_EXE% scripts\lua\VFW51WorkflowGetMission.lua %cd%') do set MISSION_NAME=%%i

set MISSION_SRC=%cd%\src
set MIZ_EXT_PATH=%MISSION_SRC%\miz_core
set MIZ_EXT_DFLT_PATH=%MIZ_EXT_PATH%\l10n\DEFAULT

rem ======== unpack and clean up

echo.
echo ========================================================
echo Extracting Mission Files from %MISSION_NAME%.miz
echo ========================================================
echo.
echo VFW51_7ZIP_EXE   %VFW51_7ZIP_EXE%
echo VFW51_LUA_EXE    %VFW51_LUA_EXE%
echo VFW51_LUA_LOG    %VFW51_LUA_LOG%
echo.
echo MISSION_SRC      %MISSION_SRC%
echo MIZ_EXT_PATH     %MIZ_EXT_PATH%
echo.

if %ARG_IMPORT% == 0 goto InitOK
echo **** WARNING: You are importing files from the .miz to the local mission directory. This
echo **** WARNING: may over-write audio, image, and script files in the mission directory with
echo **** WARNING: files taken from the .miz.
echo ****
set /p "ANSWER=**** Are you sure you want to do this? (Y/N) "
echo.
if /i "%ANSWER%" == "y" goto InitOK
exit /be
:InitOK

echo ---- Unpacking mission .miz to src/miz_core
if %ARG_VERBOSE% == 1 echo %VFW51_7ZIP_EXE% x -y %MISSION_NAME%.miz -o"%MIZ_EXT_PATH%\"
if %ARG_DRY_RUN% == 0 "%VFW51_7ZIP_EXE%" x -y %MISSION_NAME%.miz -o"%MIZ_EXT_PATH%\" >nul 2>&1
if %ERRORLEVEL% == 0 goto UnpackSuccess
echo Extraction fails with error %ERRORLEVEL%
exit /be %ERRORLEVEL%
:UnpackSuccess

if %ARG_IMPORT% == 1 (
    echo ---- Importing files from unpacked .miz
    if exist "%MIZ_EXT_DFLT_PATH%\*.jpg" xcopy /q /v /y "%MIZ_EXT_DFLT_PATH%\*.ogg" ".\src\briefing" >nul 2>&1
    if exist "%MIZ_EXT_DFLT_PATH%\*.png" xcopy /q /v /y "%MIZ_EXT_DFLT_PATH%\*.wav" ".\src\briefing" >nul 2>&1
    if exist "%MIZ_EXT_DFLT_PATH%\*.ogg" xcopy /q /v /y "%MIZ_EXT_DFLT_PATH%\*.ogg" ".\src\audio" >nul 2>&1
    if exist "%MIZ_EXT_DFLT_PATH%\*.wav" xcopy /q /v /y "%MIZ_EXT_DFLT_PATH%\*.wav" ".\src\audio" >nul 2>&1
    if exist "%MIZ_EXT_DFLT_PATH%\*.lua" xcopy /q /v /y "%MIZ_EXT_DFLT_PATH%\*.lua" ".\src\scripts" >nul 2>&1
)

if %ARG_DIRTY% == 1 goto SkipClean
if %ARG_VERBOSE% == 1 echo call "%cd%\scripts\cleanmission.cmd" --noheader
if %ARG_DRY_RUN% == 1 call "%cd%\scripts\cleanmission.cmd" --noheader
:SkipClean

pushd scripts\lua

echo ---- Updating scripting triggers
if %ARG_VERBOSE% == 1 echo %VFW51_LUA_EXE% VFW51MissionTriginator.lua %MISSION_SRC% %MIZ_EXT_PATH% %VFW51_LUA_LOG%
if %ARG_DRY_RUN% == 0 %VFW51_LUA_EXE% VFW51MissionTriginator.lua %MISSION_SRC% %MIZ_EXT_PATH% %VFW51_LUA_LOG%

echo ---- Updating waypoints
if %ARG_VERBOSE% == 1 echo %VFW51_LUA_EXE% VFW51MissionWaypointinator.lua %MISSION_SRC% %MIZ_EXT_PATH% %VFW51_LUA_LOG%
if %ARG_DRY_RUN% == 0 %VFW51_LUA_EXE% VFW51MissionWaypointinator.lua %MISSION_SRC% %MIZ_EXT_PATH% %VFW51_LUA_LOG%

echo ---- Updating radio presets
if %ARG_VERBOSE% == 1 echo %VFW51_LUA_EXE% VFW51MissionRadioinator.lua %MISSION_SRC% %MIZ_EXT_PATH% %VFW51_LUA_LOG%
if %ARG_DRY_RUN% == 0 %VFW51_LUA_EXE% VFW51MissionRadioinator.lua %MISSION_SRC% %MIZ_EXT_PATH% %VFW51_LUA_LOG%

echo ---- Updating briefing panels
if %ARG_VERBOSE% == 1 echo %VFW51_LUA_EXE% VFW51MissionBriefinator.lua %MISSION_SRC% %MIZ_EXT_PATH% %VFW51_LUA_LOG%
if %ARG_DRY_RUN% == 0 %VFW51_LUA_EXE% VFW51MissionBriefinator.lua %MISSION_SRC% %MIZ_EXT_PATH% %VFW51_LUA_LOG%

echo ---- Normalizing mission files
if %ARG_VERBOSE% == 1 echo %VFW51_LUA_EXE% veafMissionNormalizer.lua %MIZ_EXT_PATH% %VFW51_LUA_LOG%
if %ARG_DRY_RUN% == 0 %VFW51_LUA_EXE% veafMissionNormalizer.lua %MIZ_EXT_PATH% %VFW51_LUA_LOG%

popd

exit /be 0

:Usage
echo.
echo Usage: sync [--help] [--dirty] [--dryrun] [--dynamic] [--import] [--verbose]
echo             [--luatrace, --luadebug]
echo.
echo Unpack a DCS .miz file, normalizing and sanitizing it before using the unpacked mission
echo to update the mission directory.
echo.
echo This script must be run from the root of a mission directory.
echo.
echo Command line parameters:
echo.
echo   --help               Displays this usage information
echo   --dirty              After extracting, do not clean up the extracted mission contents
echo                        to remove redundant files
echo   --dryrun             Dry run, print but do not execute commands (implies --verbose)
echo   --dynamic            Set up mission for dynamic script loading
echo   --import             Imports briefing, audio, and scripts from .miz to local mission
echo                        directory. This will over-write existing files in the mission
echo                        directory src tree. Typically, this is only used to set up an
echo                        existing mission to use the workflow.
echo   --verbose            Verbose logging output
echo   --luatrace           Pass "--trace" to Lua scripts to set "trace" level logging
echo   --luadebug           Pass "--debug" to Lua scripts to set "debug" level logging
echo.
echo Environment variables:
echo.
echo   VFW51_7ZIP_EXE   7-zip executable (default "7z")
echo   VFW51_LUA_EXE    Lua console executable (default "lua54")
echo   VFW51_LUA_LOG    Lua support logging switches (default none), options
echo                      --trace   Enable trace log output
echo                      --debug   Enable debug log output
echo.

exit /be -1