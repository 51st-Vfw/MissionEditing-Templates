-- ************************************************************************************************************
-- 
-- VFW51MissionBriefinator: Briefing processing tool for 51st VFW workflow
--
-- NOTE: this script makes changes to the .miz mission and mapResource files
--
-- Usage: VFW51MissionBriefinator <src_path> <dst_path> [--debug|--trace]
--
--   <src_path>     path to src/ directory in mission directory
--   <dst_path>     path to directory where mission is assembled (build/miz_image, typically)
--   --debug        enable debug log output
--   --trace        enable trace log output
--
-- installs the briefing images for red, blue, and neutral coalitions according to the standard briefing
-- setttings file at briefing/vfw51_briefing_settings.lua. this updates both the mission and mapResource
-- files within the .miz package.
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

VFW51MissionBriefinator = VFW51WorkflowUtil:new()

---------------------------------------------------------------------------------------------------------------
-- Core Methods
---------------------------------------------------------------------------------------------------------------

-- resource keys for the briefing panels expressed as c printf-esque format strings. the %d field is set
-- to an index of the image.
--
local resKeyBlue = "ResKey_ImageBriefing_160%02d"
local resKeyRed = "ResKey_ImageBriefing_161%02d"
local resKeyNeutral = "ResKey_ImageBriefing_162%02d"

local function buildResKeys(coa, rsrcFmt)
    local rsrcKeys = { }
    for i, _ in ipairs(BriefingSettings[coa]) do
        rsrcKeys[i] = string.format(rsrcFmt, i)
    end
    return rsrcKeys
end

-- edit function for veafMissionEditor.editMission, since that is not OO, we define this with . and
-- pass self explicitly as the arg
function VFW51MissionBriefinator.processMission(mission_t, self)
    mission_t["pictureFileNameB"] = self:deepCopy(buildResKeys("blue", resKeyBlue))
    mission_t["pictureFileNameR"] = self:deepCopy(buildResKeys("red", resKeyRed))
    mission_t["pictureFileNameN"] = self:deepCopy(buildResKeys("neutral", resKeyNeutral))
    return mission_t
end

-- edit function for veafMissionEditor.editMission, since that is not OO, we define this with . and
-- pass self explicitly as the arg
function VFW51MissionBriefinator.processMapResource(mapReource_t, self)
    for i, v in ipairs(BriefingSettings["blue"]) do
        mapReource_t[string.format(resKeyBlue, i)] = self:deepCopy(v)
    end
    for i, v in ipairs(BriefingSettings["red"]) do
        mapReource_t[string.format(resKeyRed, i)] = self:deepCopy(v)
    end
    for i, v in ipairs(BriefingSettings["neutral"]) do
        mapReource_t[string.format(resKeyNeutral, i)] = self:deepCopy(v)
    end
    return mapReource_t
end

function VFW51MissionBriefinator:process()
    local settingsPath = self:loadLuaFile(self.srcPath, "briefing", "vfw51_briefing_settings.lua")
    if settingsPath then
        self:logInfo(string.format("Using briefing settings [%s]", settingsPath))

        -- validate all briefing files from settings exist
        for coa, files in pairs(BriefingSettings) do
            for index, val in pairs(files) do
                local path = self.srcPath .. "briefing\\" .. val
                if not self:fileExists(path) then
                    self:logError(string.format("Missing briefing image file, %s", val))
                    return
                end
            end
        end

        -- edit the "mission" file
        local mizMissionPath = self.dstPath .. "mission"
        local editFn = VFW51MissionBriefinator.processMission
        self:logDebug(string.format("Processing [%s]", mizMissionPath))
        veafMissionEditor.editMission(mizMissionPath, mizMissionPath, "mission", editFn, self)
        self:logInfo("mission updated")

        -- edit the "mapResource" file
        local mizMapResPath = self.dstPath .. "l10n\\DEFAULT\\mapResource"
        self:logDebug(string.format("Processing [%s]", mizMapResPath))
        editFn = VFW51MissionBriefinator.processMapResource
        veafMissionEditor.editMission(mizMapResPath, mizMapResPath, "mapResource", editFn, self)
        self:logInfo("mapResource updated")
    else
        self:logInfo("Briefing settings not found, skipping")
    end
end

function VFW51MissionBriefinator:new(o, arg)
    o = o or VFW51WorkflowUtil:new(o, arg)
    setmetatable(o, self)
    self.__index = self

    self.id = "Briefinator"
    self.version = "1.0.0"

    local isArgBad = false
    for _, val in ipairs(arg) do
        if self.srcPath == nil then
            self.srcPath = self:canonicalizeDirPath(val)
        elseif self.dstPath == nil then
            self.dstPath = self:canonicalizeDirPath(val)
        elseif (val:lower() ~= "--debug") and (val:lower() ~= "--trace") then
            isArgBad = true
        end
    end
    if isArgBad or not self.srcPath or not self.dstPath then
        print("Usage: VFW51MissionBriefinator <src_path> <dst_path> [--debug|--trace]")
        return nil
    end

    return o
 end

---------------------------------------------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------------------------------------------

local inator = VFW51MissionBriefinator:new(nil, arg)
if inator then
    inator:process()
end