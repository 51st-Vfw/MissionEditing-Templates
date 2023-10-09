-- ************************************************************************************************************
-- 
-- VFW51MissionWaypointinator: Waypoint processing tool for 51st VFW workflow
--
-- NOTE: this script makes changes to the .miz mission file
--
-- Usage: Usage: VFW51MissionWaypointinator <src_path> <dst_path> [--debug|--trace]
--
--   <src_path>     path to src/ directory in mission directory
--   <dst_path>     path to directory where mission is assembled (build/miz_image, typically)
--   --debug        enable debug log output
--   --trace        enable trace log output
--
-- walk the map defined in src/waypoints/vfw51_waypoint_settings.lua file to update group steerpoints in the
-- mission file. the map is keyed by group name with a value of a file name in src/waypoints that provides
-- the waypoints to inject.
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

VFW51MissionWaypointinator = VFW51WorkflowUtil:new()

---------------------------------------------------------------------------------------------------------------
-- Core Methods
---------------------------------------------------------------------------------------------------------------

-- edit function for veafMissionEditor.editMission, since that is not OO, we define this with . and
-- pass self explicitly as the arg
function VFW51MissionWaypointinator.processMission(mission_t, self)
    local coalitions = { "blue", "red", "neutrals" }

    for _, coa in pairs(coalitions) do
        for _, country in pairs(mission_t["coalition"][coa]["country"]) do
            if country["plane"] then
                for groupIdx, group in ipairs(country["plane"]["group"]) do
                    for groupPattern, groupFile in pairs(WaypointSettings) do
                        local gsubPattern = self:sanitizePattern(groupPattern)
                        if string.match(group["name"], gsubPattern) then
                            self:logInfo(string.format("Updating group '%s', matches key '%s'", group["name"], groupPattern))
                            if self:loadLuaFile(self.srcPath, "waypoints", groupFile) then
---@diagnostic disable-next-line: undefined-global
                                for routeIdx, table in ipairs(RouteData) do
                                    if routeIdx > 1 then
                                        if not country["plane"]["group"][groupIdx]["route"]["points"][routeIdx] then
                                            country["plane"]["group"][groupIdx]["route"]["points"][routeIdx] = { }
                                        end
                                        for key, value in pairs(table) do
                                            country["plane"]["group"][groupIdx]["route"]["points"][routeIdx][key] = self:deepCopy(value)
                                        end
                                    end
                                end
                            else
                                self:logInfo("Waypoint file '" .. groupFile .. "' not found, skipping")
                                WaypointSettings[groupPattern] = nil
                            end
                            self.unitEditCount = self.unitEditCount + 1
                        end
                    end
                end
            end
            if country["helicopter"] then
                for groupIdx, group in ipairs(country["helicopter"]["group"]) do
                    for groupPattern, groupFile in pairs(WaypointSettings) do
                        local gsubPattern = self:sanitizePattern(groupPattern)
                        if string.match(group["name"], gsubPattern) then
                            self:logInfo(string.format("Updating group '%s', matches key '%s'", group["name"], groupPattern))
                            if self:loadLuaFile(self.srcPath, "waypoints", groupFile) then
---@diagnostic disable-next-line: undefined-global
                                for routeIdx, table in ipairs(RouteData) do
                                    if routeIdx > 1 then
                                        if not country["helicopter"]["group"][groupIdx]["route"]["points"][routeIdx] then
                                            country["helicopter"]["group"][groupIdx]["route"]["points"][routeIdx] = { }
                                        end
                                        for key, value in pairs(table) do
                                            country["helicopter"]["group"][groupIdx]["route"]["points"][routeIdx][key] = self:deepCopy(value)
                                        end
                                    end
                                end
                            else
                                self:logInfo("Waypoint file '" .. groupFile .. "' not found, skipping")
                                WaypointSettings[groupPattern] = nil
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

function VFW51MissionWaypointinator:process()
    local settingsPath = self:loadLuaFile(self.srcPath, "waypoints", "vfw51_waypoint_settings.lua")
    if settingsPath ~= nil then
        self:logInfo(string.format("Using waypoint settings [%s]", settingsPath))

        self.unitEditCount = 0

        -- edit the "mission" file
        local mizMissionPath = self.dstPath .. "mission"
        local editFn = self.processMission
        self:logDebug(string.format("Processing [%s]", mizMissionPath))
        veafMissionEditor.editMission(mizMissionPath, mizMissionPath, "mission", editFn, self)
        self:logInfo(string.format("mission updated, injected waypoints for %d group(s)", self.unitEditCount))
    else
        self:logInfo("Waypoint settings not found, skipping")
    end
end

function VFW51MissionWaypointinator:new(o, arg)
    o = o or VFW51WorkflowUtil:new(o, arg)
    setmetatable(o, self)
    self.__index = self

    self.id = "Waypointinator"
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
        print("Usage: VFW51MissionWaypointinator <src_path> <dst_path> [--debug|--trace]")
        return nil
    end

    return o
end

---------------------------------------------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------------------------------------------

local inator = VFW51MissionWaypointinator:new(nil, arg)
if inator then
    inator:process()
end
