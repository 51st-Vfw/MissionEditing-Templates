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
--   <dst_path>/../<mission_name>[-v<version>][-<variant>]
--   <dst_path>/../options-<mission_name>[-v<version>][-<variant>]
--
-- in addition, for redaction, the tool can generate an exclude file list that lists files that should not
-- be included in the .miz (such as lua files in redacted variants). these are saved to
--
--   <dst_path>/../exclude-<mission_name>[-v<version>][-<variant>]
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

function VFW51MissionVariantinator:buildDstFileName(srcPath)
end

function VFW51MissionVariantinator:buildExcludedFileList(srcPath)
    local excludes = { }

    local audioSettingsPath = self:loadLuaFile(srcPath, "audio", "vfw51_audio_settings.lua")
    if audioSettingsPath ~= nil then
        for i = 1, #AudioSettings do
            table.insert(excludes, AudioSettings[i])
        end
    end

    local scriptSettingsPath = self:loadLuaFile(srcPath, "scripts", "vfw51_script_settings.lua")
    if scriptSettingsPath ~= nil and ScriptSettings["mission"] ~= nil then
        for i = 1, #ScriptSettings["mission"] do
            table.insert(excludes, ScriptSettings["mission"][i])
        end
    end

    return excludes
end

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

function VFW51MissionVariantinator:isRedacted(name, patterns)
    local is_redacted = false
    for i = 1,#patterns,1 do
        local pattern = patterns[i]:lower()
        local is_black = true
        if string.sub(pattern, 1, 1) == "+" then
            is_black = false
            pattern = string.sub(pattern, 2)
        elseif string.sub(pattern, 1, 1) == "-" then
            pattern = string.sub(pattern, 2)
        end
        if pattern == "*" and is_black then
            self:logTrace(string.format("'%s' -- %s <<< **** MATCH (-) ****", pattern, name))
            is_redacted = true
        elseif pattern == "*" then
            self:logTrace(string.format("'%s' -- %s <<< **** MATCH (+) ****", pattern, name))
            is_redacted = false
        else
            pattern = self:sanitizePattern(pattern)
            if is_black and string.find(name:lower(), pattern) then
                self:logTrace(string.format("'%s' -- %s <<< **** MATCH (-) ****", pattern, name))
                is_redacted = true
                break

            elseif not is_black and string.find(name:lower(), pattern) then
                self:logTrace(string.format("'%s' -- %s <<< **** MATCH (+) ****", pattern, name))
                is_redacted = false
                break
            else
                self:logTrace(string.format("'%s' (%s) -- %s", pattern, tostring(is_black), name))
            end
        end
    end
    return is_redacted
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
    local wx_delta = targInfo["wx_delta"] or { }
    if (wx ~= nil) and (wx:lower() ~= "base") then
        self:logTrace(string.format("Setting mission Wx for %s", wx))
        mission_t["weather"] = self:deepCopy(wxVersions[wx])
        for key, value in pairs(wx_delta) do
            mission_t["weather"][key] = self:deepCopy(value)
        end
    end

    -- set the mission options
    local opt = targInfo["options"]
    if (opt ~= nil) and (opt:lower() ~= "base") then
        self:logTrace(string.format("Setting mission options for %s", opt))
        mission_t["forcedOptions"] = self:deepCopy(optVersions[opt])
    end

    -- redact objects and scripting from the mission
    local redact = targInfo["redact"]
    if redact ~= nil then

        local rd_objs = redact["objects"] or { }
        local rd_zone = redact["zones"] or { }
        local rd_unct = redact["uncertain"] or { }
        local rd_dwgs = redact["drawings"] or nil

        local zn_tmplt = {
            ["color"] = { [1] = 1, [2] = 1, [3] = 1, [4] = 1 },    -- filled in
            ["heading"] = 0,
            ["hidden"] = false,
            ["name"] = "template",                                 -- filled in
            ["properties"] = { },
            ["radius"] = 1,                                        -- filled in
            ["type"] = 0,
            ["x"] = 0.0,                                           -- filled in
            ["y"] = 0.0,                                           -- filled in
            ["zoneId"] = 0                                         -- filled in
        }

        local zn_unct_idx = 1
        local zn_unct = { }

        self:logTrace(string.format("Redacting mission objects"))

        for _, cltn in pairs({ "blue", "red", "neutrals" }) do
            if mission_t["coalition"][cltn] ~= nil then
                for i = 1,#mission_t["coalition"][cltn]["country"],1 do
                    for _, type in pairs({ "helicopter", "plane", "ship", "static", "vehicle" }) do
                        if mission_t["coalition"][cltn]["country"][i][type] ~= nil then
                            local group = { }
                            local index = 1
                            for j = 1,#mission_t["coalition"][cltn]["country"][i][type]["group"],1 do
                                local name = mission_t["coalition"][cltn]["country"][i][type]["group"][j]["name"]
                                if rd_unct[name] then

                                    -- object is uncertain. we will replace it with a zone that is randomly offset
                                    -- by the uncertainity radius for the object. this removes the object and adds
                                    -- a zone.

                                    self:logTrace(string.format("Redact object " .. name .. ", now uncertain"))

                                    local x = mission_t["coalition"][cltn]["country"][i][type]["group"][j]["x"]
                                    local y = mission_t["coalition"][cltn]["country"][i][type]["group"][j]["y"]

                                    local r = math.random() * rd_unct[name] * (10000.0 / 5.4)   -- 10k x/y = 5.4nm
                                    local t = math.random() * 2.0 * 3.14159265

                                    local zone = self:deepCopy(zn_tmplt)
                                    if cltn == "blue" then
                                        zone["color"] = { [1] = 0, [2] = 0, [3] = 1, [4] = 0.125 }
                                    elseif cltn == "red" then
                                        zone["color"] = { [1] = 1, [2] = 0, [3] = 0, [4] = 0.125 }
                                    end
                                    zone["name"] = name .. " (Uncertain)"
                                    zone["radius"] = rd_unct[name] * 1852.0     -- convert nm to m
                                    zone["x"] = x + (r * math.cos(t))
                                    zone["y"] = y + (r * math.sin(t))

                                    zn_unct[zn_unct_idx] = zone
                                    zn_unct_idx = zn_unct_idx + 1

                                elseif not self:isRedacted(name, rd_objs) then

                                    -- object is not redacted. add the object to the new group array we are
                                    -- building to replace the array in the .miz file.

                                    group[index] = mission_t["coalition"][cltn]["country"][i][type]["group"][j]
                                    index = index + 1
                                else
                                    self:logTrace(string.format("Redact object " .. name))
                                end
                            end
                            mission_t["coalition"][cltn]["country"][i][type]["group"] = self:deepCopy(group)
                        end
                    end
                end
            end
        end

        self:logTrace(string.format("Redacting mission zones"))

        local triggers = {
            ["zones"] = { }
        }
        local triggers_zn_idx = 1
        local max_zn_id = 0

        if mission_t["triggers"]["zones"] ~= nil then
            for i = 1,#mission_t["triggers"]["zones"],1 do
                local name = mission_t["triggers"]["zones"][i]["name"]
                if not self:isRedacted(name, rd_zone) then
                    triggers["zones"][triggers_zn_idx] = mission_t["triggers"]["zones"][i]
                    triggers_zn_idx = triggers_zn_idx + 1

                    if max_zn_id < mission_t["triggers"]["zones"][i]["zoneId"] then
                        max_zn_id = mission_t["triggers"]["zones"][i]["zoneId"]
                    end
                else
                    self:logTrace(string.format("Redact zone " .. name))
                end
            end
        end

        for i = 1,#zn_unct,1 do
            zn_unct[i]["zoneId"] = max_zn_id + i

            triggers["zones"][triggers_zn_idx] = zn_unct[i]
            triggers_zn_idx = triggers_zn_idx + 1
        end

        self:logTrace(string.format("Redacting drawings"))

        if rd_dwgs and mission_t["drawings"]["layers"] ~= nil then
            for i = 1,#mission_t["drawings"]["layers"] do
                local layer = mission_t["drawings"]["layers"][i]["name"]
                if string.find(rd_dwgs:lower(), layer:lower()) then
                    self:logTrace(string.format("Redact drawing " .. layer))
                    mission_t["drawings"]["layers"][i]["objects"] = self:deepCopy({ })
                end
            end
        end

        -- remove all scripting content with the exception of non-redacted trigger zones.
        mission_t["trig"] = self:deepCopy({ })
        mission_t["trigrules"] = self:deepCopy({ })
        mission_t["triggers"] = self:deepCopy(triggers)
    end

    return mission_t
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

    -- build the list of excluded files just in case we need them.
    local excludedFiles = self:buildExcludedFileList(self.srcPath)

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

    -- copy initial mission file over without changes for the baseline (note baseline is not versioned)
    self:logInfo(string.format("Building content for base target"))
    local editFn = VFW51MissionVariantinator.processMission
    local inPath = self.dstPath .. "mission"
    local outPath = self.dstPath .. "..\\" .. self.missionName
    veafMissionEditor.editMission(inPath, outPath, "mission", nil)

    -- walk the target variants and build mission and exclude files for each
    for targName, targ in pairs(VariantSettings["variants"]) do
        self:logInfo(string.format("Building content for %s variant", targName))
        local editArgs = { ["self"] = self,
                           ["targInfo"] = VariantSettings["variants"][targName]
        }
        editFn = VFW51MissionVariantinator.processMission
        inPath = self.dstPath .. "mission"
        outPath = self.dstPath .. "..\\" .. self.missionNameVers .. "-" .. targName
        veafMissionEditor.editMission(inPath, outPath, "mission", editFn, editArgs)

        if VariantSettings["variants"][targName]["redact"] ~= nil then
            outPath = self.dstPath .. "..\\exclude-" .. self.missionNameVers.. "-" .. targName
            local file, e = io.open(outPath, "w+");
            if file == nil then
                veafMissionEditor.logError(string.format("Error while writing excludes to file [%s]", outPath))
            else
                for i = 1, #excludedFiles do
                    file:write(string.format("%s\n", excludedFiles[i]))
                end
                file:close();
            end
        end
    end
end

function VFW51MissionVariantinator:new(o, arg)
    o = o or VFW51WorkflowUtil:new(o, arg)
    setmetatable(o, self)
    self.__index = self

    self.id = "Variantinator"
    self.version = "1.1.0"

    local isArgBad = false
    local isArgVersion = false
    local argVersion = nil
    for _, val in ipairs(arg) do
        if val:lower() == "--version" then
            isArgVersion = true
        elseif isArgVersion then
            argVersion = val
            isArgVersion = false
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
    if isArgBad or isArgVersion or not self.missionName or not self.srcPath or not self.dstPath then
        print("Usage: VFW51MissionVariantinator <mission_name> <src_path> <dst_path> [--version <version>] [--debug|--trace]")
        return nil
    end
    if argVersion then
        self.missionNameVers = self.missionName .. "-v" .. argVersion
    else
        self.missionNameVers = self.missionName
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
