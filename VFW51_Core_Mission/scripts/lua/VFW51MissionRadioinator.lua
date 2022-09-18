-- ************************************************************************************************************
-- 
-- VFW51MissionRadioinator: Radio preset processing tool for 51st VFW workflow
--
-- NOTE: this script makes changes to the .miz mission file
--
-- Usage: VFW51MissionRadioinator <src_path> <dst_path> [--debug|--trace]
--
--   <src_path>     path to src/ directory in mission directory
--   <dst_path>     path to directory where mission is assembled (build/miz_image, typically)
--   --debug        enable debug log output
--   --trace        enable trace log output
--
-- injects the presets into the .miz mission file based on the specification in the settings file. this will
-- also generate legacy preset settings for the A-10C airframe (in UHF_RADIO, VHF_FM_RADIO, VHF_AM_RADIO)
--
-- the .miz must be unpacked at the usual place (src/miz_core) prior to using this tool.
--
-- this tool is run from the lua console, it uses the veafMissionEditor and VFW51WorkflowUtil libraries which
-- must be in the same directory as this script.
--
-- code adapted from and riffs on the veaf tools (specifically, veafMissionRadioPresetsEditor), by zip.
--
-- ************************************************************************************************************

require("veafMissionEditor")
require("VFW51WorkflowUtil")

VFW51MissionRadioinator = VFW51WorkflowUtil:new()

---------------------------------------------------------------------------------------------------------------
-- Core methods
---------------------------------------------------------------------------------------------------------------

local unitEditCount = 0
local presetEditCount = 0

function VFW51MissionRadioinator:buildRadioTable(radioSetting, aframe, name, callsign)
    local radio_t = self:deepCopy(radioSetting)
    for _, radio in ipairs(radio_t) do
        for presetNum, presetVal in ipairs(radio["channels"]) do
            self:logTrace(string.format("[%d] %s", presetNum, type(presetVal)))
            if (type(presetVal) == "table") then
                -- sort rules for preset
                local patterns = { }
                for pattern, value in pairs(presetVal) do
                    table.insert(patterns, pattern)
                end
                table.sort(patterns)

                -- find matches, searching from least- to more-specific, freq is most specific match.
                local freq = 0.0
                for _, pattern in ipairs(patterns) do
                    if self:matchRadioPattern(pattern, aframe, name, callsign) then
                        freq = presetVal[pattern]["f"]
                        self:logTrace(string.format("'%s' -- %s, %s, %s <<< **** MATCH **** %.2f", pattern, aframe, name, callsign, freq))
                    else
                        self:logTrace(string.format("'%s' -- %s, %s, %s", pattern, aframe, name, callsign))
                    end
                end
                radio["channels"][presetNum] = freq
                presetEditCount = presetEditCount + 1
            end
        end
    end
    return radio_t
end

function VFW51MissionRadioinator:buildRadioFiles(dstPath, fileSetting, aframe, name, callsign)
    for file, presets in pairs(fileSetting) do
        for presetNum, presetVal in ipairs(presets["presets"]) do
            self:logTrace(string.format("[%d] %s", presetNum, type(presetVal)))
            if (type(presetVal) == "table") then
                -- sort rules for preset
                local patterns = { }
                for pattern, value in pairs(presetVal) do
                    table.insert(patterns, pattern)
                end
                table.sort(patterns)

                -- find matches, searching from least- to more-specific, freq is most specific match.
                local freq = 0.0
                for _, pattern in ipairs(patterns) do
                    if self:matchRadioPattern(pattern, aframe, name, callsign) then
                        freq = presetVal[pattern]["f"]
                        self:logTrace(string.format("'%s' -- %s, %s, %s <<< **** MATCH **** %.2f", pattern, aframe, name, callsign, freq))
                    else
                        self:logTrace(string.format("'%s' -- %s, %s, %s", pattern, aframe, name, callsign))
                    end
                end

                presets["presets"][presetNum] = math.floor(freq * 1000000)
            else
                presets["presets"][presetNum] = math.floor(presets["presets"][presetNum] * 1000000)
            end
        end
        local tableAsLua = veafMissionEditor.serialize("settings", presets)

        local settingsPath = dstPath .. file .. "\\"
        os.execute("mkdir " .. settingsPath .. " >nul 2>&1")
        veafMissionEditor.writeMissionFile(settingsPath .. "SETTINGS.lua", tableAsLua)
    end
end

function VFW51MissionRadioinator:editUnit(coaName, countryName, unit_t)
    self:logTrace(string.format("editUnit(%s)",self:p(unit_t)))
    local hasBeenEdited = false
    local unitName = unit_t["name"]
    local unitId = unit_t["unitId"]
    local unitType = unit_t["type"]
    local unitCallsign = "<unknown>"
    if type(unit_t["callsign"]) == "table" then
        unitCallsign = unit_t["callsign"]["name"]
    end
    self:logDebug("\n\n")
    self:logDebug(string.format("Testing unit unitType=[%s], unitName=%s, unitId=%s in coaName=%s, countryName=%s) ", self:p(unitType), self:p(unitName), self:p(unitId),self:p(coaName), self:p(countryName)))

    if unit_t["skill"] and unit_t["skill"] == "Client" and unitType then -- only human players with unit type
        self:logTrace("Client found with type, checking radio settings")
        for setting, setting_t in pairs(RadioSettings) do
            self:logTrace("\n")
            self:logTrace(string.format("Testing setting %s", self:p(setting)))
            local coalition = setting_t["coalition"]
            self:logTrace(string.format("  coalition=%s / %s", self:p(coalition), self:p(coaName)))
            if not(coalition) or coalition == coaName then
                self:logTrace("  Coalition checked")
                local country = setting_t["country"]
                self:logTrace(string.format("  country=%s / %s", self:p(country), self:p(countryName)))
                if not(country) or country == countryName then
                    self:logTrace("  Country checked")
                    local type = setting_t["type"]
                    self:logTrace(string.format("  type=[%s] / [%s]", self:p(type), self:p(unitType)))
                    local regexType = self:sanitizePattern(type:lower())
                    if not(type) or unitType:lower() == type:lower() or string.match(unitType:lower(), regexType) then
                        self:logTrace("  Unit type checked " .. regexType)
                        -- edit the unit
                        self:logDebug(string.format("-> Edited unit unitType=%s, unitName=%s, unitId=%s in coaName=%s, countryName=%s) ", self:p(unitType), self:p(unitName), self:p(unitId),self:p(coaName), self:p(countryName)))
                        if setting_t["Radio"] then
                            --unit_t["Radio"] = nil
                            unit_t["Radio"] = self:buildRadioTable(setting_t["Radio"], unitType, unitName, unitCallsign)
                            hasBeenEdited = true
                        elseif not setting_t["emit"] then
                            setting_t["emit"] = unitType
                        end
                        break
                    end
                end
            end
        end
    end

    return hasBeenEdited
end

-- edit function for veafMissionEditor.editMission, since that is not OO, we define this with . and
-- pass self explicitly as the arg
function VFW51MissionRadioinator.processMission(mission_t, self)

    -- edit units in group based on settings
    local _editGroups = function(coaName, countryName, container)
        local groups_t = container["group"]
        for group, group_t in pairs(groups_t) do
            self:logTrace(string.format("Browsing group [%s]", group))
            local units_t = group_t["units"]
            for _, unit_t in pairs(units_t) do
                local hasBeenEdited = self:editUnit(coaName, countryName, unit_t)
                if hasBeenEdited then
                    if unit_t["Radio"] and unit_t["Radio"][1] then
                        group_t["communication"] = false
                        group_t["frequency"] = unit_t["Radio"][1]["channels"][1]
                        group_t["modulation"] = unit_t["Radio"][1]["modulations"][1]
                    end
                    -- set the "radioSet" value to false
                    self:logTrace("seting the radioSet value to false")
                    group_t["radioSet"] = true
                    unitEditCount = unitEditCount + 1
                end
            end
        end
    end

    -- browse coalitions
    local coalitions_t = mission_t["coalition"]
    for coa, coa_t in pairs(coalitions_t) do
        local coaName = coa_t["name"]
        self:logTrace(string.format("Browsing coalition [%s]", coaName))
        -- browse countries
        local countries_t = coa_t["country"]
        for country, country_t in pairs(countries_t) do
            local countryName = country_t["name"]
            self:logTrace(string.format("Browsing country [%s]", countryName))
            self:logTrace(string.format("country_t=%s", self:p(country_t)))
            -- process helicopters
            self:logTrace("Processing helicopters")
            local helicopters_t = country_t["helicopter"]
            if helicopters_t then
                self:logTrace(string.format("helicopters_t=%s", self:p(helicopters_t)))
                _editGroups(coaName, countryName, helicopters_t)
            end
            -- process airplanes
            self:logTrace("Processing airplanes")
            local planes_t = country_t["plane"]
            if planes_t then
                self:logTrace(string.format("planes_t=%s", self:p(planes_t)))
                _editGroups(coaName, countryName, planes_t)
            end
        end
    end

    return mission_t
end

function VFW51MissionRadioinator:process()
    local settingsPath = self:loadLuaFile(self.srcPath, "radio", "vfw51_radio_settings.lua")
    if settingsPath ~= nil then
        self:logInfo(string.format("Using radio settings [%s]", settingsPath))

        -- edit the "mission" file
        local mizMissionPath = self.dstPath .. "mission"
        local editFn = self.processMission
        self:logDebug(string.format("Processing [%s]", mizMissionPath))
        veafMissionEditor.editMission(mizMissionPath, mizMissionPath, "mission", editFn, self)
        self:logInfo(string.format("mission updated, inject %d presets in %d units", presetEditCount, unitEditCount))

        -- emit legacy presets if necessary
        for key, value in pairs(RadioSettings) do
            if value["emit"] then
                self:logInfo("Emitting legacy settings for " .. value["emit"])
                self:buildRadioFiles(self.dstPath, value["files"], value["emit"], "<?>", "<?>")
            end
        end
    else
        self:logInfo("Radio settings not found, skipping")
    end
end

function VFW51MissionRadioinator:new(o, arg)
    o = o or VFW51WorkflowUtil:new(o, arg)
    setmetatable(o, self)
    self.__index = self

    self.id = "Radioinator"
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
        print("Usage: VFW51MissionRadioinator <src_path> <dst_path> [--debug|--trace]")
        return nil
    end

    return o
 end

---------------------------------------------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------------------------------------------

local inator = VFW51MissionRadioinator:new(nil, arg)
if inator then
    inator:process()
end