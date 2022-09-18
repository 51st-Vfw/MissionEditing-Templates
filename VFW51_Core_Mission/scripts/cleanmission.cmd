@echo off
rem *******************************************************************************************
rem
rem cleanmission.cmd -- clean up redundant files from an extracted mission
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

set ARG_NO_HDR=0

:ParseArgs
if "%~1" == "" (
    goto ParseDone
) else if "%~1" == "--noheader" (
    set ARG_NO_HDR=1
) else (
    goto Usage
)
shift
goto ParseArgs
:ParseDone

rem ======== set up variables

rem extracts the mission name from the path to the current directory.
for /f %%i in ('%VFW51_LUA_EXE% scripts\lua\VFW51WorkflowGetMission.lua %cd%') do set MISSION_NAME=%%i

set MIZ_EXT_PATH=%cd%\src\miz_core
set MIZ_EXT_DFLT_PATH=%MIZ_EXT_PATH%\l10n\DEFAULT

rem ======== clean up

if %ARG_NO_HDR% == 1 goto SkipHeader
echo.
echo ========================================================
echo Cleaning %MISSION_NAME%
echo ========================================================
:SkipHeader

echo ---- Removing redundant files and directories from unpacked .miz
if exist %MIZ_EXT_PATH%\KNEEBOARD rmdir /s /q %MIZ_EXT_PATH%\KNEEBOARD >nul 2>&1
if exist %MIZ_EXT_PATH%\Config rmdir /s /q %MIZ_EXT_PATH%\Config >nul 2>&1
if exist %MIZ_EXT_PATH%\Scripts rmdir /s /q %MIZ_EXT_PATH%\Scripts >nul 2>&1
if exist %MIZ_EXT_PATH%\track rmdir /s /q %MIZ_EXT_PATH%\track >nul 2>&1
if exist %MIZ_EXT_PATH%\track_data rmdir /s /q %MIZ_EXT_PATH%\track_data >nul 2>&1
if exist %MIZ_EXT_DFLT_PATH%\*.jpg del /f /q %MIZ_EXT_DFLT_PATH%\*.jpg >nul 2>&1
if exist %MIZ_EXT_DFLT_PATH%\*.png del /f /q %MIZ_EXT_DFLT_PATH%\*.png >nul 2>&1
if exist %MIZ_EXT_DFLT_PATH%\*.ogg del /f /q %MIZ_EXT_DFLT_PATH%\*.ogg >nul 2>&1
if exist %MIZ_EXT_DFLT_PATH%\*.wav del /f /q %MIZ_EXT_DFLT_PATH%\*.wav >nul 2>&1
if exist %MIZ_EXT_DFLT_PATH%\*.lua del /f /q %MIZ_EXT_DFLT_PATH%\*.lua >nul 2>&1

exit /be 0

:Usage
echo.
echo Usage: cleanmission [--help] [--noheader]
echo.
echo Remove all of the files from the extracted .miz in src/miz_core that are either not tracked
echo (e.g., track, track_data directories) or redundant with other parts of the workflow mission
echo directory tree (e.g., kneeboards, audio files, Lua files).
echo.
echo This script must be run from the root of a mission directory.
echo.
echo Command line parameters:
echo.
echo   --help                 Displays this usage information
echo   --noheader             Do not output header information

exit /be -1