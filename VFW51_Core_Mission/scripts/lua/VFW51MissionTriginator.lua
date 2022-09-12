-- ************************************************************************************************************
-- 
-- VFW51MissionTriginator: Trigger processing tool for 51st VFW workflow
--
-- NOTE: this script makes changes to the .miz mission, mapResource, and dictionary files
--
-- Usage: VFW51MissionTriginator <src_path> <src_path> [--debug|--trace]
--
--   <src_path>     path to src/ directory in mission directory
--   <dst_path>     path to directory where mission is assembled (build/miz_image, typically)
--   --debug        enable debug log output
--   --trace        enable trace log output
--
-- builds out the default triggers for a vfw51 workflow mission. in these missions, the default trigger
-- setup is as follows,
--
--     [1] setup static/dynamic script loading via VFW51_DYN_PATH variable
--     [2] load frameworks (dynamic)
--     [3] load frameworks (static)
--     [4] load mission scripts (dynamic)
--     [5] load mission scripts (static)
--     [6] reference audio files
--
-- this tool builds out the contents of these triggers based on scripting and audio configuration.
--
-- the .miz must be unpacked at the usual place (src/miz_core) prior to using this tool.
--
-- this tool is run from the lua console, it uses the veafMissionEditor and VFW51WorkflowUtil libraries which
-- must be in the same directory as this script.
--
-- code adapted from and riffs on the veaf tools (specifically, veafMissionTriggerInjector), by zip.
--
-- ************************************************************************************************************

require("veafMissionEditor")
require("VFW51WorkflowUtil")

VFW51MissionTriginator = VFW51WorkflowUtil:new()

---------------------------------------------------------------------------------------------------------------
-- Trigger Templates
---------------------------------------------------------------------------------------------------------------

-- l10n\DEFAULT\dictionary file key/value pairs to support standard triggers, no further edits are necessary
--
local mizDictionary = {
    ["DictKey_ActionText_20011"] = "return VFW51_DYN_PATH ~= nil",
    ["DictKey_ActionText_20013"] = "return VFW51_DYN_PATH == nil",
    ["DictKey_ActionText_20008"] = "return VFW51_DYN_PATH ~= nil",
    ["DictKey_ActionText_20009"] = "return VFW51_DYN_PATH == nil",
    ["DictKey_ActionText_20026"] = "return false"
}

-- mission file value for ["trig"]["conditions"], no further edits are necessary
--
local mizTrigConditions = {
    [1] = "return(true)",
    [2] = "return(c_predicate(getValueDictByKey(\"DictKey_ActionText_20008\")) )",
    [3] = "return(c_predicate(getValueDictByKey(\"DictKey_ActionText_20009\")) )",
    [4] = "return(c_predicate(getValueDictByKey(\"DictKey_ActionText_20011\")) )",
    [5] = "return(c_predicate(getValueDictByKey(\"DictKey_ActionText_20013\")) )",
    [6] = "return(c_predicate(getValueDictByKey(\"DictKey_ActionText_20026\")) )"
}

-- mission file value for ["trig"]["flag"], no further edits are necessary
--
local mizTrigFlag = {
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
}

-- mission file value for ["trig"]["funcStartup"], no further edits are necessary
--
local mizTrigFuncStartup = {
    [1] = "if mission.trig.conditions[1]() then mission.trig.actions[1]() end",
    [2] = "if mission.trig.conditions[2]() then mission.trig.actions[2]() end",
    [3] = "if mission.trig.conditions[3]() then mission.trig.actions[3]() end",
    [4] = "if mission.trig.conditions[4]() then mission.trig.actions[4]() end",
    [5] = "if mission.trig.conditions[5]() then mission.trig.actions[5]() end",
    [6] = "if mission.trig.conditions[6]() then mission.trig.actions[6]() end",
}

-- mission file value for ["trig"]["actions"], this must be updated per setup
--
-- each action ends with N "tmpl" elements based on the number of scripts/files/etc.
--
local mizTrigActions = {
    [1] = "a_do_script(\"env.info(\\\"*** VFW51: Setting Static/Dynamic\\\")\");",
    [2] = "a_do_script(\"env.info(\\\"*** VFW51: Loading Frameworks -- VFW51_DYN_PATH = \\\" .. VFW51_DYN_PATH)\");",
    [3] = "a_do_script(\"env.info(\\\"*** VFW51: Loading Frameworks -- Static\\\")\");",
    [4] = "a_do_script(\"env.info(\\\"*** VFW51: Loading Mission Scripts -- VFW51_DYN_PATH = \\\" .. VFW51_DYN_PATH)\");",
    [5] = "a_do_script(\"env.info(\\\"*** VFW51: Loading Mission Scripts -- Static\\\")\");",
    [6] = "a_do_script(\"env.info(\\\"*** VFW51: Reference audio\\\")\");",
}

-- note $DYNAMIC_PATH has 4x "\", "C:\\Users\\Raven\\" --> "C:\\\\\\\\Users\\\\\\\\Raven\\\\\\\\"

local mizTrigActionsTmplPath = "a_do_script(\\\"VFW51_DYN_PATH=$DYNAMIC_PATH\\\");"
local mizTrigActionsTmplDynamic = "a_do_script(\"assert(loadfile(VFW51_DYN_PATH .. \\\"$SCRIPT_FILE\\\"))()\");"
local mizTrigActionsTmplStatic = "a_do_script_file(getValueResourceByKey(\"$SCRIPT_RESKEY\"));"
local mizTrigActionsTmplAudio = "a_out_sound(getValueResourceByKey(\"$AUDIO_RESKEY\"), 0);"

-- mission file value for ["trig"]["trigRules"], this must be updated per setup
--
local mizTrigTrigRules = {

    -- static/dynamic setup trigger: ["actions"][2]["text{] defines the static/dynamic setup for
    -- the mission and should be edited to replace path with dynamic path or nil for static
    --
    -- $DYNAMIC_PATH <-- path to scr/scripts in mission directory
    --
    -- note $DYNAMIC_PATH has 2x "\", "C:\\Users\\Raven\\" --> "C:\\\\Users\\\\Raven\\\\\"

    [1] = {
        ["actions"] = {
            [1] = {
                ["predicate"] = "a_do_script",
                ["text"] = "env.info(\"*** VFW51: Setting Static/Dynamic\")",
            }, -- end of [1]
            [2] = {
                ["predicate"] = "a_do_script",
                ["text"] = "VFW51_DYN_PATH=\"$DYNAMIC_PATH\"",                      -- EDITED
            }, -- end of [2]
        }, -- end of ["actions"]
        ["colorItem"] = "0x8080ffff",
        ["comment"] = "VFW51 AUTOGEN: Select Static/Dynamic",
        ["eventlist"] = "",
        ["predicate"] = "triggerStart",
        ["rules"] = {
        }, -- end of ["rules"]
    }, -- end of [1]

    -- dynamic framework load: ["actions"][2] is a template that should be repeated for each
    -- framework script defined in the setup.
    --
    -- $SCRIPT_FILE <-- name of script .lua file

    [2] = {
        ["actions"] = {
            [1] = {
                ["predicate"] = "a_do_script",
                ["text"] = "env.info(\"*** VFW51: Loading Frameworks -- VFW51_DYN_PATH = \" .. VFW51_DYN_PATH)",
            }, -- end of [1]
            [2] = {                                                                 -- TEMPLATE
                ["predicate"] = "a_do_script",                                      -- TEMPLATE
                ["text"] = "assert(loadfile(VFW51_DYN_PATH .. \"$SCRIPT_FILE\")",   -- TEMPLATE
            }, -- end of [2]                                                        -- TEMPLATE
        }, -- end of ["actions"]
        ["colorItem"] = "0x8080ffff",
        ["comment"] = "VFW51 AUTOGEN: Load Frameworks -- Dynamic",
        ["eventlist"] = "",
        ["predicate"] = "triggerStart",
        ["rules"] = {
            [1] = {
                ["coalitionlist"] = "red",
                ["KeyDict_text"] = "DictKey_ActionText_20008",
                ["predicate"] = "c_predicate",
                ["text"] = "DictKey_ActionText_20008",
                ["unitType"] = "ALL",
                ["zone"] = "",
            }, -- end of [1]
        }, -- end of ["rules"]
    }, -- end of [2]

    -- static framework load: ["actions"][2] is a template that should be repeated for each
    -- framework script defined in the setup.
    --
    -- $SCRIPT_RESKEY <-- resource key (form mapResource) for script .lua file

    [3] = {
        ["actions"] = {
            [1] = {
                ["predicate"] = "a_do_script",
                ["text"] = "env.info(\"*** VFW51: Loading Frameworks -- Static\")",
            }, -- end of [1]
            [2] = {                                                                 -- TEMPLATE
                ["file"] = "$SCRIPT_RESKEY",                                        -- TEMPLATE
                ["predicate"] = "a_do_script_file",                                 -- TEMPLATE
            }, -- end of [2]                                                        -- TEMPLATE
        }, -- end of ["actions"]
        ["colorItem"] = "0x8080ffff",
        ["comment"] = "VFW51 AUTOGEN: Load Frameworks -- Static",
        ["eventlist"] = "",
        ["predicate"] = "triggerStart",
        ["rules"] = {
            [1] = {
                ["coalitionlist"] = "red",
                ["KeyDict_text"] = "DictKey_ActionText_20009",
                ["predicate"] = "c_predicate",
                ["text"] = "DictKey_ActionText_20009",
                ["unitType"] = "ALL",
                ["zone"] = "",
            }, -- end of [1]
        }, -- end of ["rules"]
    }, -- end of [3]

    -- dynamic mission script load: ["actions"][2] is a template that should be repeated for each
    -- mission script defined in the setup.
    --
    -- $SCRIPT_FILE <-- name of script .lua file

    [4] = {
        ["actions"] = {
            [1] = {
                ["predicate"] = "a_do_script",
                ["text"] = "env.info(\"*** VFW51: Loading Mission Scripts -- VFW51_DYN_PATH = \" .. VFW51_DYN_PATH)",
            }, -- end of [1]
            [2] = {                                                                 -- TEMPLATE
                ["predicate"] = "a_do_script",                                      -- TEMPLATE
                ["text"] = "assert(loadfile(VFW51_DYN_PATH .. \"$SCRIPT_FILE\")",   -- TEMPLATE
            }, -- end of [2]                                                        -- TEMPLATE
        }, -- end of ["actions"]
        ["colorItem"] = "0x8080ffff",
        ["comment"] = "VFW51 AUTOGEN: Load Mission Scripts -- Dynamic",
        ["eventlist"] = "",
        ["predicate"] = "triggerStart",
        ["rules"] = {
            [1] = {
                ["coalitionlist"] = "red",
                ["KeyDict_text"] = "DictKey_ActionText_20011",
                ["predicate"] = "c_predicate",
                ["text"] = "DictKey_ActionText_20011",
                ["unitType"] = "ALL",
                ["zone"] = "",
            }, -- end of [1]
        }, -- end of ["rules"]
    }, -- end of [4]

    -- static mission script load: ["actions"][2] is a template that should be repeated for each
    -- framework script defined in the setup.
    --
    -- $SCRIPT_RESKEY <-- resource key (form mapResource) for script .lua file

    [5] = {
        ["actions"] = {
            [1] = {
                ["predicate"] = "a_do_script",
                ["text"] = "env.info(\"*** VFW51: Loading Mission Scripts -- Static\")",
            }, -- end of [1]
            [2] = {
                ["file"] = "$SCRIPT_RESKEY",
                ["predicate"] = "a_do_script_file",
            }, -- end of [2]
        }, -- end of ["actions"]
        ["colorItem"] = "0x8080ffff",
        ["comment"] = "VFW51 AUTOGEN: Load Mission Scripts -- Static",
        ["eventlist"] = "",
        ["predicate"] = "triggerStart",
        ["rules"] = {
            [1] = {
                ["coalitionlist"] = "red",
                ["KeyDict_text"] = "DictKey_ActionText_20013",
                ["predicate"] = "c_predicate",
                ["text"] = "DictKey_ActionText_20013",
                ["unitType"] = "ALL",
                ["zone"] = "",
            }, -- end of [1]
        }, -- end of ["rules"]
    }, -- end of [5]

    -- audio file references: ["actions"][2] is a template that should be repeated for each audio
    -- file defined in the setup.
    --
    -- $AUDIO_RESKEY <-- resource key (form mapResource) for audio file

    [6] = {
        ["actions"] = {
            [1] = {
                ["predicate"] = "a_do_script",
                ["text"] = "env.info(\"*** VFW51: Reference audio\")",
            }, -- end of [1]
            [2] = {                                                                 -- TEMPLATE
                ["file"] = "$AUDIO_RESKEY",                                         -- TEMPLATE
                ["predicate"] = "a_out_sound",                                      -- TEMPLATE
                ["start_delay"] = 0,                                                -- TEMPLATE
            }, -- end of [2]                                                        -- TEMPLATE
        }, -- end of ["actions"]
        ["colorItem"] = "0x8080ffff",
        ["comment"] = "VFW51 AUTOGEN: Reference Audio",
        ["eventlist"] = "",
        ["predicate"] = "triggerStart",
        ["rules"] = {
            [1] = {
                ["coalitionlist"] = "red",
                ["KeyDict_text"] = "DictKey_ActionText_20026",
                ["predicate"] = "c_predicate",
                ["text"] = "DictKey_ActionText_20026",
                ["unitType"] = "ALL",
                ["zone"] = "",
            }, -- end of [1]
        }, -- end of ["rules"]
    } -- end of [6]
}

---------------------------------------------------------------------------------------------------------------
-- Core Methods
---------------------------------------------------------------------------------------------------------------

function VFW51MissionTriginator:buildResourceMaps()
    self.mapKeyToRsrc = { }
    self.mapRsrcToKey = { }

    local function addFiles(filePath, list, ident, type)
        for key, val in pairs(list) do
            local path = filePath .. val
            if not self:fileExists(path) then
                self:logError(string.format("Skip missing %s file, %s", type, val))
            else
                local mrKey = string.format("ResKey_Action_20%1d%02d", ident, key)
                self.mapKeyToRsrc[mrKey] = val
                self.mapRsrcToKey[val] = mrKey
            end
        end
    end

    addFiles(self.srcPath .. "scripts\\", ScriptSettings["framework"], 1, "framework Lua")
    addFiles(self.srcPath .. "scripts\\", ScriptSettings["mission"], 2, "mission Lua")
    addFiles(self.srcPath .. "audio\\", AudioSettings, 3, "audio")
end

-- edit function for veafMissionEditor.editMission, since that is not OO, we define this with . and
-- pass self explicitly as the arg
function VFW51MissionTriginator.processMission(mission_t, self)
    -- helper function to build actions/trigrules for dynamic script loading
    local function buildLoadDynamic(mission, files, action, num, trigRules, tmplt)
        local rules = { [1] = trigRules[1] }
        for key, val in ipairs(files) do
            action = action .. tmplt:gsub("$SCRIPT_FILE", val)
            rules[key+1] = {
                ["predicate"] = "a_do_script",
                ["text"] = "assert(loadfile(VFW51_DYN_PATH .. \"" .. val .. "\"))()",
            }
        end
        mission["trig"]["actions"][num] = self:deepCopy(action)
        mission["trigrules"][num]["actions"] = self:deepCopy(rules)
        return mission
    end

    -- helper function to build actions/trigrules for static script loading
    local function buildLoadStatic(mission, files, action, num, trigRules, tmplt)
        local rules = { [1] = trigRules[1] }
        for key, val in ipairs(files) do
            local resKey = self.mapRsrcToKey[val]
            action = action .. tmplt:gsub("$SCRIPT_RESKEY", resKey)
            rules[key+1] = {
                ["file"] = resKey,
                ["predicate"] = "a_do_script_file",
            }
        end
        mission["trig"]["actions"][num] = self:deepCopy(action)
        mission["trigrules"][num]["actions"] = self:deepCopy(rules)
        return mission
    end

    -- helper function to build actions/trigrules for audio file reference
    local function buildAudioRef(mission, files, action, num, trigRules, tmplt)
        local rules = { [1] = trigRules[1] }
        for key, val in ipairs(files) do
            local resKey = self.mapRsrcToKey[val]
            action = action .. tmplt:gsub("$AUDIO_RESKEY", resKey)
            rules[key+1] = {
                ["file"] = resKey,
                ["predicate"] = "a_out_sound",
                ["start_delay"] = 0,
            }
        end
        mission["trig"]["actions"][num] = self:deepCopy(action)
        mission["trigrules"][num]["actions"] = self:deepCopy(rules)
        return mission
    end

    -- check if the mission already has the workflow triggers in place.
    self.isUpdate = true
    for i = 1,6,1 do
        local action = mission_t["trig"]["actions"][i]
        if not action or not string.find(action, "*** VFW51: ") then
            self.isUpdate = false
        end
    end

    if not self.isUpdate then
        self:logInfo("Adding VFW51 triggers")

        -- we are updating a .miz that's not yet "in the workflow". insert the standard set of 6
        -- triggers (see above) along with any supporting state in the mission table. we preserve
        -- the order of the templates.
        --
        -- NOTE: this assumes we can insert new actions, etc. without breaking links or otherwise
        -- NOTE: fucking things up.
        for i = #mizTrigActions, 1, -1 do
            self.logDebug("add action <-- ", mizTrigActions[i])
            table.insert(mission_t["trig"]["actions"], 1, self:deepCopy(mizTrigActions[i]))
        end
        for i = #mizTrigConditions, 1, -1 do
            self.logDebug("add conditions <-- ", mizTrigConditions[i])
            table.insert(mission_t["trig"]["conditions"], 1, self:deepCopy(mizTrigConditions[i]))
        end
        for i = #mizTrigFlag, 1, -1 do
            self.logDebug("add flag <-- ", mizTrigFlag[i])
            table.insert(mission_t["trig"]["flag"], 1, self:deepCopy(mizTrigFlag[i]))
        end
        for i = #mizTrigFuncStartup, 1, -1 do
            self.logDebug("add funcStartup <-- ", mizTrigFuncStartup[i])
            table.insert(mission_t["trig"]["funcStartup"], 1, self:deepCopy(mizTrigFuncStartup[i]))
        end
        for i = #mizTrigTrigRules, 1, -1 do
            table.insert(mission_t["trigrules"], 1, self:deepCopy(mizTrigTrigRules[i]))
        end
    end

    -- trigger action 1: set up dynamic path
    local dynamicPath = "nil"
    if self.isDynamic then
        -- TODO: need to get the right escapes in here when path is dynamic
        dynamicPath = "[[" .. string.gsub(self.srcPath, "\\", "\\\\") .. "scripts\\\\" .. "]]"
    end
    local actDynPath = mizTrigActionsTmplPath:gsub("$DYNAMIC_PATH", dynamicPath)
    mission_t["trig"]["actions"][1] = self:deepCopy(mizTrigActions[1] .. actDynPath)
    mission_t["trigrules"][1]["actions"][2]["text"] = self:deepCopy("VFW51_DYN_PATH=" .. dynamicPath)


    -- trigger actions 2-5: set up dynamic/static framework/mission script loads
    mission_t = buildLoadDynamic(mission_t, ScriptSettings["framework"], mizTrigActions[2], 2,
                                 mizTrigTrigRules[2]["actions"], mizTrigActionsTmplDynamic)
    mission_t = buildLoadDynamic(mission_t, ScriptSettings["mission"], mizTrigActions[4], 4,
                                 mizTrigTrigRules[4]["actions"], mizTrigActionsTmplDynamic)

    mission_t = buildLoadStatic(mission_t, ScriptSettings["framework"], mizTrigActions[3], 3,
                                mizTrigTrigRules[3]["actions"], mizTrigActionsTmplStatic)
    mission_t = buildLoadStatic(mission_t, ScriptSettings["mission"], mizTrigActions[5], 5,
                                mizTrigTrigRules[5]["actions"], mizTrigActionsTmplStatic)

    -- trigger action 6: reference audio resources
    mission_t = buildAudioRef(mission_t, AudioSettings, mizTrigActions[6], 6,
                              mizTrigTrigRules[6]["actions"], mizTrigActionsTmplAudio)

    return mission_t
end

-- edit function for veafMissionEditor.editMission, since that is not OO, we define this with . and
-- pass self explicitly as the arg
function VFW51MissionTriginator.processMapResource(mapResource_t, self)
    for key, value in pairs(self.mapKeyToRsrc) do
        mapResource_t[key] = value
    end
    return mapResource_t
end

-- edit function for veafMissionEditor.editMission, since that is not OO, we define this with . and
-- pass self explicitly as the arg
function VFW51MissionTriginator.processDictionary(dictionary_t, self)
    for key, value in pairs(mizDictionary) do
        dictionary_t[key] = value
    end
    return dictionary_t
end

function VFW51MissionTriginator:process()
    -- pull audio settings, setting to empty if not found
    local audioSettingsPath = self:loadLuaFile(self.srcPath, "audio", "vfw51_audio_settings.lua")
    if audioSettingsPath == nil then
        self:logInfo("Audio settings not found, skipping audio injection")
        AudioSettings = { }
    else
        self:logInfo(string.format("Loaded settings [%s]", audioSettingsPath))
    end

    -- pull scripts settings, setting to empty if not found
    local scriptSettingsPath = self:loadLuaFile(self.srcPath, "scripts", "vfw51_script_settings.lua")
    if scriptSettingsPath == nil then
        self:logInfo("Script settings not found, skipping script injection")
        ScriptSettings = { ["framework"] = { }, ["mission"] = { } }
    else
        self:logInfo(string.format("Loaded settings [%s]", scriptSettingsPath))
    end

    -- build out the resource maps
    self:buildResourceMaps()

    -- process the mission, mapResource, and dictionary tables from the .miz.
    local function processTable(path, table, editFn, arg)
        arg:logDebug(string.format("Processing [%s]", path))
        veafMissionEditor.editMission(path, path, table, editFn, self)
        arg:logInfo(table .. " updated")
    end

    processTable(self.dstPath .. "mission", "mission", self.processMission, self)
    processTable(self.dstPath .. "l10n\\DEFAULT\\mapResource", "mapResource", self.processMapResource, self)
    processTable(self.dstPath .. "l10n\\DEFAULT\\dictionary", "dictionary", self.processDictionary, self)
end

function VFW51MissionTriginator:new(o, arg)
    o = o or VFW51WorkflowUtil:new(o, arg)
    setmetatable(o, self)
    self.__index = self

    self.id = "Triginator"
    self.version = "1.0.0"
    self.isDynamic = false

    local isArgBad = false
    for _, val in ipairs(arg) do
        if val:lower() == "--dynamic" then
            self.isDynamic = true
        elseif self.srcPath == nil then
            self.srcPath = self:canonicalizeDirPath(val)
        elseif self.dstPath == nil then
            self.dstPath = self:canonicalizeDirPath(val)
        elseif (val:lower() ~= "--debug") and (val:lower() ~= "--trace") then
            isArgBad = true
        end
    end
    if isArgBad or not self.srcPath or not self.dstPath then
        print("Usage: VFW51MissionTriginator <src_path> <dst_path> [--dynamic] [--debug|--trace]")
        return nil
    end

    return o
 end

---------------------------------------------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------------------------------------------

local inator = VFW51MissionTriginator:new(nil, arg)
if inator then
    inator:process()
end