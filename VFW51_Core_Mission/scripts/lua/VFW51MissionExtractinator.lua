-- ************************************************************************************************************
-- 
-- VFW51MissionExtractinator: Extraction tool for 51st VFW workflow
--
-- Usage: VFW51MissionExtractinator <miz_path> <--wx|--opt|--wp <group>> [--debug|--trace]
--
--   <miz_path>         path to unpacked .miz file to extract from
--   --wx               extract weather information
--   --opt              extract options infomration
--   --wp <group>       extract waypoints for group <group>, <group> must exact-match
--   --debug            enable debug log output
--   --trace            enable trace log output
--
-- extract weather or options difficulty from the given unpacked message and dump them to stdout.
--
-- this tool is run from the lua console, it uses the veafMissionEditor and VFW51WorkflowUtil libraries which
-- must be in the same directory as this script.
--
-- code adapted from and riffs on the veaf tools, by zip.
--
-- ************************************************************************************************************

require("veafMissionEditor")
require("VFW51WorkflowUtil")

VFW51MissionExtractinator = VFW51WorkflowUtil:new()

---------------------------------------------------------------------------------------------------------------
-- Core Methods
---------------------------------------------------------------------------------------------------------------

function VFW51MissionExtractinator:findPointsFromGroupInCoalition(mission_t, groupPattern)
    local keeperKeys = { "alt", "alt_type", "speed", "speed_locked", "type", "x", "y"}
    local points = nil

    local coalitions = { "blue", "red", "neutrals" }
    local foundGroup = nil
    local numFound = 0
    for _, coa in ipairs(coalitions) do
        for _, country in pairs(mission_t["coalition"][coa]["country"]) do
            if country["plane"] then
                for _, group in ipairs(country["plane"]["group"]) do
                    -- TODO: for regex match, use string.match(group["name"], sanitize(groupPattern))
                    if group["name"] == groupPattern then
                        if numFound == 0 then
                            foundGroup = group["name"]
                            numFound = numFound + 1
                            points = self:deepCopy(group["route"]["points"])
                        end
                    end
                end
            end
            if country["helicopter"] then
                for _, group in ipairs(country["helicopter"]["group"]) do
                    -- TODO: for regex match, use string.match(group["name"], sanitize(groupPattern))
                    if group["name"] == groupPattern then
                        if numFound == 0 then
                            foundGroup = group["name"]
                            numFound = numFound + 1
                            points = self:deepCopy(group["route"]["points"])
                        end
                    end
                end
            end
        end
    end

    if numFound == 0 then
        print(string.format("-- no groups found matching '%s'", groupPattern))
    elseif numFound == 1 then
        print(string.format("-- extracted route waypoints for group '%s'", foundGroup))
    elseif numFound > 1 then
        print(string.format("-- %d groups match '%s', extracting '%s'", numFound, groupPattern, foundGroup))
    end

    return points
end

function VFW51MissionExtractinator:process()
    local luaData = nil
    local tableName
    if self.isWx and self:loadLuaFile(self.mizPath, "", "mission") then
---@diagnostic disable-next-line: undefined-global
        luaData = mission["weather"]
        tableName = "WxData"
    elseif self.isOpt and self:loadLuaFile(self.mizPath, "", "mission") then
---@diagnostic disable-next-line: undefined-global
        luaData = mission["forcedOptions"]
        tableName = "OptionsData"
    elseif self.wpGroup and self:loadLuaFile(self.mizPath, "", "mission") then
---@diagnostic disable-next-line: undefined-global
        luaData = self:findPointsFromGroupInCoalition(mission, self.wpGroup)
        tableName = "RouteData"
    end
    if luaData then
        print(veafMissionEditor.serialize(tableName, luaData))
    end
end

function VFW51MissionExtractinator:new(o, arg)
    o = o or VFW51WorkflowUtil:new(o, arg)
    setmetatable(o, self)
    self.__index = self

    self.id = "Extractinator"
    self.version = "1.1.0"

    self.isWx = false
    self.isOpts = false

    local isArgBad = false
    local isArgWp = false
    for _, val in ipairs(arg) do
        if val:lower() == "--wx" then
            self.isWx = true
            if self.isOpt or self.wpGroup then
                isArgBad = true
            end
        elseif val:lower() == "--opt" then
            self.isOpt = true
            if self.isWx or self.wpGroup then
                isArgBad = true
            end
        elseif val:lower() == "--wp" then
            isArgWp = true
            if self.isOpt or self.isWx then
                isArgBad = true
            end
        elseif isArgWp then
            self.wpGroup = val
            isArgWp = false
        elseif self.mizPath == nil then
            self.mizPath = self:canonicalizeDirPath(val)
        elseif (val:lower() ~= "--debug") and (val:lower() ~= "--trace") then
            isArgBad = true
        end
    end

    if isArgBad or not self.mizPath or (self.isWx and self.isOpt) then
        print("Usage: VFW51MissionExtractinator <miz_path> <--wx|--opt|--wp <group>> [--debug|--trace]")
        return nil
    end

    return o
 end

---------------------------------------------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------------------------------------------

local inator = VFW51MissionExtractinator:new(nil, arg)
if inator then
    inator:process()
end