-- ************************************************************************************************************
-- 
-- VFW51MissionVariantinator: Version processing tool for 51st VFW workflow
--
-- Usage: Usage: VFW51MissionVariantinator <mission_name> <src_path> <dst_path> [--version <version>]
--                                         [--debug|--trace]
--
--   <mission_name>         base name of mission files
--   <src_path>             path to src/ directory in mission directory
--   <dst_path>             path to directory where mission is assembled (build/miz_image, typically)
--   --version <version>    add integer <version> to file names
--   --debug                enable debug log output
--   --trace                enable trace log output
--
-- walk the target variants defined in src/variants/vfw51_variant_settings.lua file and generate internal
-- .miz "mission" and "options" files for each variant. variants change the time, weather, and options of
-- the base mission. the base mission files are found on the build path. mission and options versions are
-- saved to
--
--   <dst_path>/../<mission_name>[-<version>][-<variant>]
--   <dst_path>/../options-<mission_name>[-<version>][-<variant>]
--
-- the .miz must be unpacked at the usual place (src/miz_core) prior to using this tool.
--
-- this tool is run from the lua console, it uses the veafMissionEditor and VFW51WorkflowUtil libraries which
-- must be in the same directory as this script.
--
-- code adapted from and riffs on the veaf tools, by zip.
--
-- ************************************************************************************************************

require("veafMissionEditor")
require("VFW51WorkflowUtil")

VFW51MissionVariantinator = VFW51WorkflowUtil:new()

---------------------------------------------------------------------------------------------------------------
-- Core Methods
---------------------------------------------------------------------------------------------------------------

local wxVersions = { }
local optVersions = { }

function VFW51MissionVariantinator:parseMoment(moment)
    -- time in .miz is seconds after midnight while moment is 4-digit 24-hour time (with colon), covert
    --
    -- TODO: would be cool to allow sunrise/sunset-based relative times with date/lat/lon (a'la the veaf
    -- TODO: nodejs tool). this requires lua modules to support REST and JSON to use something like
    -- TODO: https://sunrise-sunset.org/api
    --
    local h, m = string.match(VariantSettings["moments"][moment], "([^:]+):([^:]+)")
    if not h and not m then
        self:logError(string.format("Invalid time format in moment \"%s\"", moment))
        h = 13
        m = 0
    end
    return (h * 60 * 60) + (m * 60)
end

-- edit function for veafMissionEditor.editMission, since that is not OO, we define this with . and
-- pass self explicitly as the arg
function VFW51MissionVariantinator.processMission(mission_t, args)
    local self = args["self"]
    local targInfo = args["targInfo"]

    -- set the mission time
    local moment = targInfo["moment"]
    if (moment ~= nil) and (moment:lower() ~= "base") then
        local time = self:parseMoment(moment)
        self:logTrace(string.format("Setting mission time for %s to %s", moment, tostring(time)))
        mission_t["start_time"] = self:deepCopy(time)
    end

    -- set the mission weather
    local wx = targInfo["wx"]
    if (wx ~= nil) and (wx:lower() ~= "base") then
        self:logTrace(string.format("Setting mission Wx for %s", wx))
        mission_t["weather"] = self:deepCopy(wxVersions[wx])
    end

    return mission_t
end

-- edit function for veafMissionEditor.editMission, since that is not OO, we define this with . and
-- pass self explicitly as the arg
function VFW51MissionVariantinator.processOptions(options_t, args)
    local self = args["self"]
    local targInfo = args["targInfo"]

    local opt = targInfo["options"]
    if (opt ~= nil) and (opt:lower() ~= "base") then
        self:logTrace(string.format("Setting mission options for %s", opt))
        options_t["difficulty"] = self:deepCopy(optVersions[opt])
    end
    return options_t
end

function VFW51MissionVariantinator:process()
    -- load the version setting file
    local settingsPath = self:loadLuaFile(self.srcPath, "variants", "vfw51_variant_settings.lua")
    if settingsPath == nil then
        self:logInfo("Variant settings not found, building base version only")
        VariantSettings = { ["moments"] = { }, ["variants"] = { } }
    else
        self:logInfo(string.format("Loaded settings [%s]", settingsPath))
    end

    -- build out wxVersions table, this has the weather information for each weather setup defined in
    -- the versions settings
    self:logDebug(string.format("Loading weather"))
    for targName, targ in pairs(VariantSettings["variants"]) do
        local wxName = targ["wx"]
        if wxName and (wxName ~= "base") and (wxVersions[wxName] == nil) then
            self:logTrace(string.format("Loading wx file for %s", wxName))
            if self:loadLuaFile(self.srcPath, "variants", wxName) then
---@diagnostic disable-next-line: undefined-global
                wxVersions[wxName] = WxData
            else
                self:logInfo("Unable to load weather file " .. wxName)
            end
        end
    end

    -- build out optVersions table, this has the options information for each option setup defined in
    -- the versions settings
    self:logDebug(string.format("Loading options"))
    for targName, targ in pairs(VariantSettings["variants"]) do
        local optName = targ["options"]
        if optName and (optName ~= "base") and (optVersions[optName] == nil) then
            self:logTrace(string.format("Loading options file for %s", optName))
            if self:loadLuaFile(self.srcPath, "variants", optName) then
---@diagnostic disable-next-line: undefined-global
                optVersions[optName] = OptionsData
            else
                self:logInfo("Unable to load options file " .. optName)
            end
        end
    end

    -- copy initial mission file over without changes for the baseline
    self:logInfo(string.format("Building mission files for base target"))
    local editFn = VFW51MissionVariantinator.processMission
    local inPath = self.dstPath .. "mission"
    local outPath = self.dstPath .. "..\\" .. self.missionName
    veafMissionEditor.editMission(inPath, outPath, "mission", nil)

    -- walk the versions and build mission files for each
    for targName, targ in pairs(VariantSettings["variants"]) do
        self:logInfo(string.format("Building mission files for %s target", targName))
        local editArgs = { ["self"] = self,
                           ["targInfo"] = VariantSettings["variants"][targName]
        }
        editFn = VFW51MissionVariantinator.processMission
        inPath = self.dstPath .. "mission"
        outPath = self.dstPath .. "..\\" .. self.missionName .. "-" .. targName
        veafMissionEditor.editMission(inPath, outPath, "mission", editFn, editArgs)

        editFn = VFW51MissionVariantinator.processOptions
        inPath = self.dstPath .. "options"
        outPath = self.dstPath .. "..\\options-" .. self.missionName .. "-" .. targName
        veafMissionEditor.editMission(inPath, outPath, "options", editFn, editArgs)
    end
end

function VFW51MissionVariantinator:new(o, arg)
    o = o or VFW51WorkflowUtil:new(o, arg)
    setmetatable(o, self)
    self.__index = self

    self.id = "Variantinator"
    self.version = "1.0.1"

    local isArgBad = false
    local isArgVers = false
    local argVers = 0
    for _, val in ipairs(arg) do
        if val:lower() == "--version" then
            isArgVers = true
        elseif isArgVers then
            argVers = val
            if string.find(val, "[^%d]+") then
                isArgBad = true
            end
            isArgVers = false
        elseif self.missionName == nil then
            self.missionName = val
        elseif self.srcPath == nil then
            self.srcPath = self:canonicalizeDirPath(val)
        elseif self.dstPath == nil then
            self.dstPath = self:canonicalizeDirPath(val)
        elseif (val:lower() ~= "--debug") and (val:lower() ~= "--trace") then
            isArgBad = true
        end
    end
    if isArgBad or isArgVers or not self.missionName or not self.srcPath or not self.dstPath then
        print("Usage: VFW51MissionVariantinator <mission_name> <src_path> <dst_path> [--version <version>] [--debug|--trace]")
        return nil
    end
    if argVers ~= 0 then
        self.missionName = self.missionName .. "-v" .. argVers
    end

    return o
 end

---------------------------------------------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------------------------------------------

local inator = VFW51MissionVariantinator:new(nil, arg)
if inator then
    inator:process()
end
