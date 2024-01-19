-- ************************************************************************************************************
-- 
-- VFW51MissionLoadoutinator: Loadout processing tool for 51st VFW workflow
--
-- NOTE: this script makes changes to the .miz mission file
--
-- Usage: Usage: VFW51MissionLoadoutinator <src_path> <dst_path> [--debug|--trace]
--
--   <src_path>     path to src/ directory in mission directory
--   <dst_path>     path to directory where mission is assembled (build/miz_image, typically)
--   --debug        enable debug log output
--   --trace        enable trace log output
--
-- walk the map defined in src/loadouts/vfw51_loadout_settings.lua file to update group loadouts in the
-- mission file. the map is keyed by group name with a value of a file name in src/loadouts that provides
-- the loadout to inject.
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

VFW51MissionLoadoutinator = VFW51WorkflowUtil:new()

InjectGroupNum = 1
InjectUnitNum = 1

---------------------------------------------------------------------------------------------------------------
-- Core Methods
---------------------------------------------------------------------------------------------------------------

function VFW51MissionLoadoutinator:processSmokePods(coalition, loadout)
    if loadout["pylons"] then
        if coalition:lower() == "neutrals" then
            coalition = "white"
        end
        for _, pylonData in pairs(loadout["pylons"]) do
            if pylonData["CLSID"] == "{INV-SMOKE-COALITION}" then
                pylonData["CLSID"] = "{INV-SMOKE-" .. coalition:upper() .. "}"
            end
        end
    end
    return loadout
end

-- edit function for veafMissionEditor.editMission, since that is not OO, we define this with . and
-- pass self explicitly as the arg
function VFW51MissionLoadoutinator.processMission(mission_t, self)
    local coalitions = { "blue", "red", "neutrals" }

    for _, coa in pairs(coalitions) do
        for _, country in pairs(mission_t["coalition"][coa]["country"]) do
            if country["plane"] then
                for groupIdx, group in ipairs(country["plane"]["group"]) do
---@diagnostic disable-next-line: undefined-global
                    for groupPattern, groupInfo in pairs(LoadoutSettings) do
                        local gsubPattern = self:sanitizePattern(groupPattern)
                        if string.match(group["name"], gsubPattern) then
                            self:logInfo(string.format("Updating plane group '%s', matches key '%s'", group["name"], groupPattern))
                            for _, info in pairs(groupInfo) do
                                InjectGroupNum = info.group_num or 1
                                InjectUnitNum = 1
                                local perUnit = info.per_unit or false
                                local loadPath = "initial"

                                LoadoutData = nil
                                PropertyData = nil
                                if not perUnit then
                                    loadPath = self:loadLuaFile(self.srcPath, "loadouts", info.file)
                                end
                                for unitIdx, table in pairs(group["units"]) do
                                    if perUnit then
                                        InjectUnitNum = unitIdx
                                        loadPath = self:loadLuaFile(self.srcPath, "loadouts", info.file)
                                    end
                                    if loadPath == nil then
                                        self:logInfo("Loadout file '" .. info.file .. "' not found, skipping")
                                        break
                                    end
                                    if LoadoutData then
---@diagnostic disable-next-line: undefined-global
                                        local loadoutData = self:processSmokePods(coa, self:deepCopy(LoadoutData))
                                        country["plane"]["group"][groupIdx]["units"][unitIdx]["payload"] = loadoutData
                                    end
                                    if PropertyData then
                                        local propertyData = self:deepCopy(PropertyData)
                                        country["plane"]["group"][groupIdx]["units"][unitIdx]["AddPropAircraft"] = propertyData
                                    end
                                    if perUnit then
                                        LoadoutData = nil
                                        PropertyData = nil
                                    end
                                end
                            end
                            self.unitEditCount = self.unitEditCount + 1
                        end
                    end
                end
            end
            if country["helicopter"] then
                for groupIdx, group in ipairs(country["helicopter"]["group"]) do
---@diagnostic disable-next-line: undefined-global
                    for groupPattern, groupInfo in pairs(LoadoutSettings) do
                        local gsubPattern = self:sanitizePattern(groupPattern)
                        if string.match(group["name"], gsubPattern) then
                            self:logInfo(string.format("Updating helo group '%s', matches key '%s'", group["name"], groupPattern))
                            for _, info in pairs(groupInfo) do
                                InjectGroupNum = info.group_num or 1
                                InjectUnitNum = 1
                                local injectGroupNum = info.group_num or 1
                                local perUnit = info.per_unit or false
                                local isErr = false

                                LoadoutData = nil
                                PropertyData = nil
                                if not perUnit then
                                    isErr = self:loadLuaFile(self.srcPath, "loadouts", info.file)
                                end
                                for unitIdx, table in pairs(group["units"]) do
                                    if perUnit then
                                        InjectUnitNum = unitIdx
                                        local injectUnitNum = unitIdx
                                        isErr = self:loadLuaFile(self.srcPath, "loadouts", info.file)
                                    end
                                    if isErr then
                                        self:logInfo("Loadout file '" .. info.file .. "' not found, skipping")
                                        break
                                    end
                                    if LoadoutData then
---@diagnostic disable-next-line: undefined-global
                                        local loadoutData = self:processSmokePods(coa, self:deepCopy(LoadoutData))
                                        country["helicopter"]["group"][groupIdx]["units"][unitIdx]["payload"] = loadoutData
                                    end
                                    if PropertyData then
                                        local propertyData = self:deepCopy(PropertyData)
                                        country["helicopter"]["group"][groupIdx]["units"][unitIdx]["AddPropAircraft"] = propertyData
                                    end
                                    if perUnit then
                                        LoadoutData = nil
                                        PropertyData = nil
                                    end
                                end
                            end
                            self.unitEditCount = self.unitEditCount + 1
                        end
                    end
                end
            end
        end
    end
    return mission_t
end

function VFW51MissionLoadoutinator:process()
    local settingsPath = self:loadLuaFile(self.srcPath, "loadouts", "vfw51_loadout_settings.lua")
    if settingsPath ~= nil then
        self:logInfo(string.format("Using loadout settings [%s]", settingsPath))

        self.unitEditCount = 0

        -- edit the "mission" file
        local mizMissionPath = self.dstPath .. "mission"
        local editFn = self.processMission
        self:logDebug(string.format("Processing [%s]", mizMissionPath))
        veafMissionEditor.editMission(mizMissionPath, mizMissionPath, "mission", editFn, self)
        self:logInfo(string.format("mission updated, injected loadouts for %d group(s)", self.unitEditCount))
    else
        self:logInfo("Loadout settings not found, skipping")
    end
end

function VFW51MissionLoadoutinator:new(o, arg)
    o = o or VFW51WorkflowUtil:new(o, arg)
    setmetatable(o, self)
    self.__index = self

    self.id = "Loadoutinator"
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
        print("Usage: VFW51MissionLoadoutinator <src_path> <dst_path> [--debug|--trace]")
        return nil
    end

    return o
end

---------------------------------------------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------------------------------------------

local inator = VFW51MissionLoadoutinator:new(nil, arg)
if inator then
    inator:process()
end
