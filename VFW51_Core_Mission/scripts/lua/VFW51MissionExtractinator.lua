-- ************************************************************************************************************
-- 
-- VFW51MissionExtractinator: Extraction tool for 51st VFW workflow
--
-- Usage: VFW51MissionExtractinator <miz_path> <--wx|--opt|--sp <group>> [--debug|--trace]
--
--   <miz_path>         path to unpacked .miz file to extract from
--   --wx               extract weather information
--   --opt              extract options infomration
--   --sp <group>       extract steerpoints for group <group>
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

function VFW51MissionExtractinator:process()
    if self.isWx and self:loadLuaFile(self.mizPath, "", "mission") then
---@diagnostic disable-next-line: undefined-global
        local luaData = mission["weather"]
        print(veafMissionEditor.serialize("WxData", luaData))
    elseif self.isOpt and self:loadLuaFile(self.mizPath, "", "options") then
---@diagnostic disable-next-line: undefined-global
        local luaData = options["difficulty"]
        print(veafMissionEditor.serialize("OptionsData", luaData))
    elseif self.spGroup and self:loadLuaFile(self.mizPath, "", "mission") then
        print("TODO")
    end
end

function VFW51MissionExtractinator:new(o, arg)
    o = o or VFW51WorkflowUtil:new(o, arg)
    setmetatable(o, self)
    self.__index = self

    self.id = "Extractinator"
    self.version = "1.0.0"

    self.isWx = false
    self.isOpts = false

    local isArgBad = false
    local isArgSp = false
    local argTag = 0
    for _, val in ipairs(arg) do
        if val:lower() == "--wx" then
            self.isWx = true
            if self.isOpt or self.spGroup then
                isArgBad = true
            end
        elseif val:lower() == "--opt" then
            self.isOpt = true
            if self.isWx or self.spGroup then
                isArgBad = true
            end
        elseif val:lower() == "--sp" then
            isArgSp = true
            if self.isOpt or self.isWx then
                isArgBad = true
            end
        elseif isArgSp then
            self.spGroup = val
            isArgSp = false
        elseif self.mizPath == nil then
            self.mizPath = self:canonicalizeDirPath(val)
        elseif (val:lower() ~= "--debug") and (val:lower() ~= "--trace") then
            isArgBad = true
        end
    end
    print(self.mizPath)
    if isArgBad or not self.mizPath or (self.isWx and self.isOpt) then
        print("Usage: VFW51MissionExtractinator <miz_path> <--wx|--opt|--sp <group>> [--debug|--trace]")
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