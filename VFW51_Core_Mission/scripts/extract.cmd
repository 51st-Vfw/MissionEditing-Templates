@echo off
rem *******************************************************************************************
rem
rem extract.cmd: .miz content extraction tool
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

set ARG_WX=0
set ARG_OPT=0
set ARG_WP=""
set ARG_WP_PARAM=0
set ARG_LOUT=""
set ARG_LOUT_PARAM=0
set ARG_TASKED=0
set ARG_MIZ=""
set ARG_LUADEBUG=1
set ARG_LUATRACE=1

for %%x in (%*) do (
    if "%%~x" == "--help" (
        goto Usage
    ) else if "%%~x" == "--wx" (
        if !ARG_WP_PARAM! == 1 goto Usage
        if !ARG_LOUT_PARAM! == 1 goto Usage
        if !ARG_TASKED! == 1 goto Usage
        set ARG_TASKED=1
        set LUA_DATA=--wx
    ) else if "%%~x" == "--opt" (
        if !ARG_WP_PARAM! == 1 goto Usage
        if !ARG_LOUT_PARAM! == 1 goto Usage
        if !ARG_TASKED! == 1 goto Usage
        set ARG_TASKED=1
        set LUA_DATA=--opt
    ) else if "%%~x" == "--wp" (
        if !ARG_WP_PARAM! == 1 goto Usage
        if !ARG_LOUT_PARAM! == 1 goto Usage
        if !ARG_TASKED! == 1 goto Usage
        set ARG_WP_PARAM=1
    ) else if "%%~x" == "--loadout" (
        if !ARG_WP_PARAM! == 1 goto Usage
        if !ARG_LOUT_PARAM! == 1 goto Usage
        if !ARG_TASKED! == 1 goto Usage
        set ARG_LOUT_PARAM=1
    ) else if "%%~x" == "--luadebug" (
        if !ARG_WP_PARAM! == 1 goto Usage
        if !ARG_LOUT_PARAM! == 1 goto Usage
        set ARG_LUADEBUG=1
    ) else if "%%~x" == "--luatrace" (
        if !ARG_WP_PARAM! == 1 goto Usage
        if !ARG_LOUT_PARAM! == 1 goto Usage
        set ARG_LUATRACE=1
    ) else if !ARG_WP_PARAM! == 1 (
        set ARG_WP_PARAM=0
        set ARG_TASKED=1
        set LUA_DATA=--wp "%%~x"
    ) else if !ARG_LOUT_PARAM! == 1 (
        set ARG_LOUT_PARAM=0
        set ARG_TASKED=1
        set LUA_DATA=--loadout "%%~x"
    ) else if !ARG_MIZ! == "" (
        set ARG_MIZ="%%~x"
    ) else (
        echo Unknown command line argument
        goto Usage
    )
)

if %ARG_TASKED% == 0 goto Usage
if %ARG_WP_PARAM% == 1 goto Usage
if %ARG_LOUT_PARAM% == 1 goto Usage
if exist %ARG_MIZ% goto GoodMiz
echo Unable to open .miz %ARG_MIZ% 1>&2
goto Usage
:GoodMiz

rem ======== set up variables

if [%VFW51_7ZIP_EXE%] == []  set VFW51_7ZIP_EXE=7z
if [%VFW51_LUA_EXE%] == [] set VFW51_LUA_EXE=lua54
if [%VFW51_LUA_LOG%] == [] (
    if %ARG_LUATRACE% == 1 set VFW51_LUA_LOG=--trace
    if %ARG_LUADEBUG% == 1 set VFW51_LUA_LOG=--debug
)

rem ======== extract stuff

set MIZ_EXT_PATH=%cd%\extract_miz_tmp

rmdir /s /q %MIZ_EXT_PATH% >nul 2>&1
mkdir %MIZ_EXT_PATH% >nul 2>&1

"%VFW51_7ZIP_EXE%" x -y %ARG_MIZ% -o"%MIZ_EXT_PATH%\" >nul 2>&1
if %ERRORLEVEL% == 0 goto UnpackSuccess
echo Extraction fails with error %ERRORLEVEL% 1>&2
rmdir /s /q %MIZ_EXT_PATH% >nul 2>&1
exit /be %ERRORLEVEL%
:UnpackSuccess

pushd %cd%\scripts\lua

%VFW51_LUA_EXE% VFW51MissionExtractinator.lua %LUA_DATA% %MIZ_EXT_PATH% %VFW51_LUA_LOG%

popd

rmdir /s /q %MIZ_EXT_PATH% >nul 2>&1

exit /be 0

:Usage
echo.
echo Usage: extract [--help] [--wx] [--opt] [--wp {group}]  [--load {group}]
echo                [--luadebug, --luatrace] {miz_path}
echo.
echo Extract Lua for a particular property from a .miz file.
echo.
echo This script must be run from the root of a mission directory.
echo.
echo Command line arguments:
echo.
echo   --help               Displays this usage information
echo   --wx                 Extract weather information
echo   --opt                Extract mission options
echo   --wp {group}         Extract waypoints from group {group}
echo   --loadout {group}    Extract loadout from first unit of group {group}
echo   {miz_path}           Path to .miz to extract the information from
echo   --luatrace           Pass "--trace" to Lua scripts to set "trace" level logging
echo   --luadebug           Pass "--debug" to Lua scripts to set "debug" level logging
echo.
echo Environment variables:
echo.
echo   VFW51_7ZIP_EXE       7-zip executable (default "7z")
echo   VFW51_LUA_EXE        Lua console executable (default "lua54")
echo   VFW51_LUA_LOG        Lua support logging switches (default none), options
echo                            --trace     Enable trace log output
echo                            --debug     Enable debug log output
echo.

exit /be -1