-- ************************************************************************************************************
-- 
-- VFW51MissionKboardinator: Kneeboard processing tool for 51st VFW workflow
--
-- Usage: VFW51MissionKboardinator <mission_name> <mission_path> [--debug|--trace]
--
--   <mission_name>             base name of mission files
--   <mission_path>             path to mission base directory
--   --debug                    enable debug log output
--   --trace                    enable trace log output
--
-- builds the mission kneeboard content based on the kneeboard settings file. processing can range from
-- copying fixed image assets to generating assets dynamically based on configuration such as a comms ladder.
--
-- the .miz must be unpacked at the usual place (src/miz_core) prior to using this tool.
--
-- this tool is run from the lua console, it uses the VFW51WorkflowUtil libraries which must be in the same
-- directory as this script.
--
-- code riffs on the veaf tools, by zip.
--
-- ************************************************************************************************************

require("VFW51WorkflowUtil")

VFW51MissionKboardinator = VFW51WorkflowUtil:new()

---------------------------------------------------------------------------------------------------------------
-- Core Methods
---------------------------------------------------------------------------------------------------------------

function VFW51MissionKboardinator:process()
    local settingsPath = self:loadLuaFile(self.srcPath, "kneeboards", "vfw51_kneeboard_settings.lua")
    if settingsPath then
        self:logInfo(string.format("Using kneeboard settings [%s]", settingsPath))

        for kbFile, kbInfo in pairs(KboardSettings) do
            -- create the kneeboard directory if it doesn't exist
            local dstDir
            if (kbInfo["airframe"] == nil) or (kbInfo["airframe"]:lower() == "all") then
                dstDir = self.dstPath .. "KNEEBOARD\\IMAGES\\"
            else
                dstDir = self.dstPath .. "KNEEBOARD\\" .. kbInfo["airframe"] .. "\\IMAGES\\"
            end
            os.execute("if not exist " .. dstDir .. " mkdir " .. dstDir)

            local srcFile = self.srcPath .. "kneeboards\\" .. kbFile
            local dstFile = dstDir .. kbFile
            local xform = kbInfo["transform"]
            if (xform == nil) or (xform:lower() == "none") then
                self:logTrace(string.format("Kneeboard [%s] --> [%s]", kbFile, dstFile))
                os.execute("copy /v /y " .. srcFile .. " " .. dstFile .. " >nul 2>&1")
            else
                local muXform = xform
                for var in string.gmatch(xform, "$[%a]+") do
                    local val = kbInfo[var]
                    if val ~= nil then
                        if string.find(val, "%s+") then
                            val = "\"" .. val .. "\""
                        end
                        muXform = string.gsub(muXform, var, val)
                    elseif not string.find(var, "^$_") then
                        muXform = string.gsub(muXform, var, "")
                    end
                end
                muXform = string.gsub(muXform, "$_air", kbInfo["airframe"])
                muXform = string.gsub(muXform, "$_mbd", self.srcPath .. "..")
                muXform = string.gsub(muXform, "$_src", self.srcPath .. "kneeboards\\" .. kbInfo["template"])
                muXform = string.gsub(muXform, "$_dst", dstFile)
                self:logTrace(string.format("Kneeboard [%s] --> [%s]", kbFile, dstFile))
                self:logTrace(string.format("  Transform [%s]", muXform))
                os.execute(muXform)
            end
        end
    else
        self:logInfo("Kneeboard settings not found, skipping")
    end
end

function VFW51MissionKboardinator:new(o, arg)
    o = o or VFW51WorkflowUtil:new(o, arg)
    setmetatable(o, self)
    self.__index = self

    self.id = "Kboardinator"
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
        print("Usage: VFW51MissionKboardinator <src_path> <dst_path> [--debug|--trace]")
        return nil
    end

    return o
 end

---------------------------------------------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------------------------------------------

local inator = VFW51MissionKboardinator:new(nil, arg)
if inator then
    inator:process()
end