-- ************************************************************************************************************
--
-- mission_globals.lua: Globals and core functions
--
-- This file should be loaded first.
--
-- ************************************************************************************************************

env.info("*** Loading Mission Script: mission_globals.lua")

-- BASE:TraceOnOff(true)
-- BASE:TraceAll(true)

-- ------------------------------------------------------------------------------------------------------------
-- Constants
-- ------------------------------------------------------------------------------------------------------------

K_FT2M                      = 0.3048                            -- m per ft
K_NM2KM                     = 1.8520                            -- km per nm
K_NM2M                      = 1852.0                            -- m per nm
K_M2S                       = 60.0                              -- sec per min

-- ------------------------------------------------------------------------------------------------------------
-- User Flags
-- ------------------------------------------------------------------------------------------------------------

FLG_SAY_LUA_SA15_1          = 151
FLG_SAY_LUA_SA15_2          = 152
FLG_SAY_LUA_SA15_3          = 153
FLG_SAY_LUA_SA15_4          = 154

FLG_SAY_LUA_SA19_1          = 191
FLG_SAY_LUA_SA19_2          = 192

-- ------------------------------------------------------------------------------------------------------------
-- Utility Functions
-- ------------------------------------------------------------------------------------------------------------

-- log message to env.info and optionally UI via trigger.action.outText (does not log to UI if no 2nd param)
--
function MUtilLog(msg, logToUI)
    env.info("MISSION: " .. msg)
    if logToUI then
        trigger.action.outText(msg, 15)
    end
end

-- generate random permutation of integers on [min, max]
--
function MUtilPermute(min, max)
    local rands = { }
    for i = min,max,1 do
        rands[i] = { ["elem"] = tostring(i), ["rnd"] = math.random(1, 100) }
    end
    table.sort(rands, function(a,b)
        return a["rnd"] > b["rnd"]
    end)
    local permute = { }
    for i = 1,(max - min + 1),1 do
        permute[i] = rands[i]["elem"]
    end
    return permute
end

function MUtilActivateGroups(groups, dt)
    MUtilLog("MUtilActivateGroups (dt " .. tostring(dt) .. ") " .. MUtilTableDump(groups))
    for _, group in pairs(groups) do
        local groupObj = GROUP:FindByName(group)
        if groupObj == nil then
            MUtilLog("ERROR: MUtilActivateGroups got bad group " .. group)
        else
            groupObj:Activate(dt)
        end
    end
end

-- cascaded activation of units.
-- 
-- elements of group specs are either a string group name (to activate a single group), or a
-- table with "pick_min" Pm (integer minimum number of groups to pick), "pick_max" Px (integer
-- maximum number of groups to pick), "from" F (integer number of idexes on group name), and
-- "base" B (string base name). the table form picks between Pm and Px groups (inclusive) with
-- names of the format B-<n> where <n> is an integer on [1, F]. if there is no Px, Px = Pm.
--
function MUtilCascadedActivate(groupSpecs, dt, readyFn)
    local slots = { }
    local slot = 1
    for _, groupSpec in pairs(groupSpecs) do
        if slots[slot] == nil then
            slots[slot] = { }
        end
        if type(groupSpec) == "table" then
            local picks = groupSpec["pick_min"]
            if groupSpec["pick_max"] ~= nil then
                picks = math.random(picks, groupSpec["pick_max"])
            end
            -- MUtilLog("pick "..tostring(picks))
            assert(picks <= groupSpec["from"])
            local permute = MUtilPermute(1, groupSpec["from"])
            for i = 1,picks,1 do
                if slots[slot] == nil then
                    slots[slot] = { }
                end
                local group = groupSpec["base"] .. "-" .. permute[i]
                -- MUtilLog("group "..group..", slot "..tostring(slot).." b " .. MUtilTableDump(slots[slot]))
                table.insert(slots[slot], group)
                slot = slot + 1
                if slot > 8 then
                    slot = 1
                end
            end
        else
            table.insert(slots[slot], groupSpec)
            slot = slot + 1
            if slot > 8 then
                slot = 1
            end
        end
    end
    local tActivate = timer.getTime() + dt
    for i = 1,8,1 do
        if slots[i] ~= nil then
            MUtilActivateGroups(slots[i], i * dt)
            tActivate = tActivate + dt
        end
    end
    if readyFn ~= nil then
        mist.scheduleFunction(readyFn, { }, tActivate)
    end
end

function MUtilRadioTx(filename, fromName, modulation, frequency)
    local path = "l10n/DEFAULT/" .. filename
    local point
    if trigger.misc.getZone(fromName) ~= nil then
        MUtilLog("tx " .. path .. " in zone " .. fromName)
        point = trigger.misc.getZone(fromName).point
    elseif GROUP:FindByName(fromName) ~= nil then
        MUtilLog("tx " .. path .. " from group " .. fromName)
        point = GROUP:FindByName(fromName):GetPositionVec3()
    else
        MUtilLog("tx " .. path .. " from group " .. fromName .. " NOT FOUND")
    end
    trigger.action.radioTransmission(path, point, modulation, false, frequency, 250)
end

function MUtilTableDump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. MUtilTableDump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end
