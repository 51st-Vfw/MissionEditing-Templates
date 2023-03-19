-- ************************************************************************************************************
-- 
-- VFW51MissionExtractinator: Extraction tool for 51st VFW workflow
--
-- Usage: VFW51MissionExtractinator <miz_path> <--wx|--opt|--wp <group>|--loadout <group>> [--debug|--trace]
--
--   <miz_path>         path to unpacked .miz file to extract from
--   --wx               extract weather information
--   --opt              extract options infomration
--   --wp <group>       extract waypoints from group <group>, <group> must exact-match
--   --loadout <group>  extract loadout from first unit of group <group>, <group> must exact-match
--   --debug            enable debug log output
--   --trace            enable trace log output
--
-- extract weather, options difficulty, waypoints, or loadouts from the given unpacked mission and dump them
-- to stdout.
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
                            points = self:deepCopy(group["route"]["points"])
                        end
                        numFound = numFound + 1
                    end
                end
            end
            if country["helicopter"] then
                for _, group in ipairs(country["helicopter"]["group"]) do
                    -- TODO: for regex match, use string.match(group["name"], sanitize(groupPattern))
                    if group["name"] == groupPattern then
                        if numFound == 0 then
                            foundGroup = group["name"]
                            points = self:deepCopy(group["route"]["points"])
                        end
                        numFound = numFound + 1
                    end
                end
            end
        end
    end

    if numFound == 0 then
        print(string.format("-- no groups found matching '%s'", groupPattern))
    elseif numFound == 1 then
        print(string.format("-- extracted route waypoints from group '%s'", foundGroup))
    elseif numFound > 1 then
        print(string.format("-- %d groups match '%s', extracted route waypoints from group '%s'",
                            numFound, groupPattern, foundGroup))
    end

    return points
end

function VFW51MissionExtractinator:findLoadoutsFromGroupInCoalition(mission_t, groupPattern)
    local loadout = nil

    local coalitions = { "blue", "red", "neutrals" }
    local foundGroup = nil
    local numFound = 0
    for _, coa in ipairs(coalitions) do
        for _, country in pairs(mission_t["coalition"][coa]["country"]) do
            if country["plane"] then
                for _, group in ipairs(country["plane"]["group"]) do
                    -- TODO: for regex match, use string.match(group["name"], sanitize(groupPattern))
                    if group["name"] == groupPattern then
                        if numFound == 0 and group["units"] and group["units"][1] and group["units"][1]["payload"] then
                            foundGroup = group["name"]
                            loadout = self:deepCopy(group["units"][1]["payload"])
                        end
                        numFound = numFound + 1
                    end
                end
            end
            if country["helicopter"] then
                for _, group in ipairs(country["helicopter"]["group"]) do
                    -- TODO: for regex match, use string.match(group["name"], sanitize(groupPattern))
                    if group["name"] == groupPattern then
                        if numFound == 0 and group["units"] and group["units"][1] and group["units"][1]["payload"] then
                            foundGroup = group["name"]
                            loadout = self:deepCopy(group["units"][1]["payload"])
                        end
                        numFound = numFound + 1
                    end
                end
            end
        end
    end

    if numFound == 0 then
        print(string.format("-- no valid groups found matching '%s'", groupPattern))
    elseif numFound == 1 then
        print(string.format("-- extracted loadouts from first unit of group '%s'", foundGroup))
    elseif numFound > 1 then
        print(string.format("-- %d groups match '%s', extracted loadouts from first unit of group '%s'",
                            numFound, groupPattern, foundGroup))
    end

    return loadout
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
    elseif self.loutGroup and self:loadLuaFile(self.mizPath, "", "mission") then
---@diagnostic disable-next-line: undefined-global
        luaData = self:findLoadoutsFromGroupInCoalition(mission, self.loutGroup)
        tableName = "LoadoutData"
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
    local isArgLout = false
    for _, val in ipairs(arg) do
        if val:lower() == "--wx" then
            if self.isOpt or self.wpGroup or self.loutGroup then
                isArgBad = true
            else
                self.isWx = true
            end
        elseif val:lower() == "--opt" then
            if self.isWx or self.wpGroup or self.loutGroup then
                isArgBad = true
            else
                self.isOpt = true
            end
        elseif val:lower() == "--wp" then
            if self.isOpt or self.isWx or self.loutGroup then
                isArgBad = true
            else
                isArgWp = true
            end
        elseif val:lower() == "--loadout" then
            if self.isOpt or self.isWx or self.wpGroup then
                isArgBad = true
            else
                isArgLout = true
            end
        elseif isArgWp then
            self.wpGroup = val
            isArgWp = false
        elseif isArgLout then
            self.loutGroup = val
            isArgLout = false
        elseif self.mizPath == nil then
            self.mizPath = self:canonicalizeDirPath(val)
        elseif (val:lower() ~= "--debug") and (val:lower() ~= "--trace") then
            isArgBad = true
        end
    end

    if isArgBad or not self.mizPath or (self.isArgWp and not self.wpGroup) or
                                       (self.isArgLout and not self.loutGroup)
    then
        print("Usage: VFW51MissionExtractinator <miz_path> <--wx|--opt|--wp <group>|--loadout <group>> [--debug|--trace]")
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