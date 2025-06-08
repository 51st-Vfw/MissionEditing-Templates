-- ************************************************************************************************************
--
-- vfw51_mission_util.lua: Mission utilities
--
-- Useful utility functions for mission designers. This script requires MOOSE and mist.
--
-- v12-16-8, 8-Jun-25
--   - added ...
-- v11-16-8, 27-Sep-24
--   - added V51UTIL.skynet.alwaysDarkConstraint
-- v8-15-8, 8-Oct-23:
--   - added APIs to V51UTIL top-level: logc()
--   - added APIs to V51UTIL.groups module: destroyWithPrefix(), swizzle(), startRandomPauses(),
--     stopRandomPauses(), spawnPatrol(), spawnCluster(), activateWithProb()
--   - added APIs to V51UTIL.skynet module: setupEngageZones() and setupSwizzledSAMSite()
--   - added V51UTIL.traffic module
--   - time on target bda function now provides number of hits
-- v7-12-7, 29-Jun-23:
--   - added pauseMovement(), resumeMovement() to convoy
-- v6-10-5, 16-Apr-23:
--   - tot target info supports fn_hit, fn_hit_once for callback on tot target hits
--
-- ************************************************************************************************************

---@diagnostic disable: duplicate-set-field

env.info("*** Loading Mission Script: vfw51_mission_util.lua")
env.info("VFW51UTIL version: v12, 8-Jun-25")

V51UTIL = {
    debugLogging = false
}

-- ============================================================================================================
--
-- CORE MODULE
--
-- ============================================================================================================

-- log message to env.info and optionally UI via trigger.action.outText.
--
-- set V51UTIL.debugLogging to true to force logging to go to ui as well as logfile, regardless of log_ui.
--
-- @param msg           message to output to log/ui
-- @param log_ui        true to log to ui as well as logfile (optional, default false)
-- @param dt            duration (s) of message in ui (optional, default 15)
--
function V51UTIL.log(msg, log_ui, dt)
    env.info("MISSION: " .. msg)
    if log_ui or V51UTIL.debugLogging then
        if not dt then
            dt = 15
        end
        trigger.action.outText(msg, dt)
    end
end

-- log message to env.info using string.format to build the message.
--
-- @param fmt           format string for string.format
-- @param ...           varargs for values to fill in to the format string
--
function V51UTIL.logfmt(fmt, ...)
    V51UTIL.log("MISSION: " .. string.format(fmt, unpack(arg)))
end

-- log message to env.info and UI for a coalition via trigger.action.outTextForCoalition.
--
-- @param coa           coalition enum to log to
-- @param msg           message to output to log/ui
-- @param dt            duration (s) of message in ui (optional, default 15)
--
function V51UTIL.logc(coa, msg, dt)
    env.info("MISSION: " .. msg)
    if not dt then
        dt = 15
    end
    trigger.action.outTextForCoalition(coa, msg, dt)
end

-- transmit an audio file over the radio.
--
-- @param filename      name of audio file, relative to l10n/DEFAULT
-- @param fromName      name of zone or group from which transmission occurs
-- @param modulation    modulation of transmission, radio.modulation.AM or radio.modulation.FM
-- @param frequency     frequency of transmission (Hz)
--
function V51UTIL.radioTxAudioFile(filename, fromName, modulation, frequency)
    local path = "l10n/DEFAULT/" .. filename
    local point
    if trigger.misc.getZone(fromName) ~= nil then
        V51UTIL.log("V51UTIL.radioTxAudioFile tx " .. path .. " in zone " .. fromName)
        point = trigger.misc.getZone(fromName).point
    elseif GROUP:FindByName(fromName) ~= nil then
        V51UTIL.log("V51UTIL.radioTxAudioFile tx " .. path .. " from group " .. fromName)
        point = GROUP:FindByName(fromName):GetPositionVec3()
    else
        V51UTIL.log("V51UTIL.radioTxAudioFile tx " .. path .. " from group " .. fromName .. " NOT FOUND")
    end
    trigger.action.radioTransmission(path, point, modulation, false, frequency, 250)
end

-- remove a static randomly with probability p_remove on [0, 100]
--
function V51UTIL.removeStaticRandomly(static, p_remove, event)
    event = event or false
    if math.random(1, 100) >= p_remove then
        V51UTIL.log(string.format("V51UTIL.removeStaticRandomly removed '%s'", static))
        STATIC:FindByName(static):Destroy(event)
    end
end

-- TODO
--
function V51UTIL.smokeInZone(name, type, density)
    V51UTIL.log(string.format("V51UTIL.smokeInZone '%s'", name))
    local smokePt = trigger.misc.getZone(name).point
    smokePt.y = land.getHeight({ x = smokePt.x, y = smokePt.z })  -- compensate for ground level
    trigger.action.effectSmokeBig(smokePt, type, density)
end

-- trigger an explosion at a unit.
--
function V51UTIL.explodeUnit(name, size, dt)
    V51UTIL.log(string.format("V51UTIL.explodeUnit destroys '%s'", name))
    UNIT:FindByName(name):Explode(size, dt)
end

-- ============================================================================================================
--
-- GROUP MODULE
--
-- ============================================================================================================

V51UTIL.groups = {
    pause_info = { }
}

-- ------------------------------------------------------------------------------------------------------------
-- Groups Support Functions
-- ------------------------------------------------------------------------------------------------------------

-- handler function for the pause/resume functions to randomly pause/resume groups.
--
local function PauseResumeGroup(group_name)
    local group = GROUP:FindByName(group_name)
    local info = V51UTIL.groups.pause_info[group_name]
    local dt_next = 0
    if info.is_paused then
        info.is_paused = false
        group:PopCurrentTask()
        dt_next = math.random(info.dp_min, info.dp_max)
        V51UTIL.log(string.format("V51UTIL.groups.randomPauses '%s' resumes, pause in %ds", group_name, dt_next))
    elseif not info.is_stopping then
        info.is_paused = true
        group:PushTask(group:TaskHold(), 0)
        dt_next = math.random(info.tp_min, info.tp_max)
        V51UTIL.log(string.format("V51UTIL.groups.randomPauses '%s' pauses, resumes in %ds", group_name, dt_next))
    end
    if dt_next ~= 0 then
        mist.scheduleFunction(PauseResumeGroup, { group_name }, timer.getTime() + dt_next)
        if info.fn ~= nil then
            info.fn(group, info.is_paused)
        end
    else
        V51UTIL.groups.pause_info[group_name] = nil
    end
end

-- ------------------------------------------------------------------------------------------------------------
-- Groups External API Functions
-- ------------------------------------------------------------------------------------------------------------

-- activate a set of groups after a specified time.
--
-- @param groups        table containing names of groups to activate
-- @param dt            delay (s) to activation (optional, default 0)
--
function V51UTIL.groups.activate(groups, dt)
    dt = dt or 0
    for _, group in pairs(groups) do
        local group_obj = GROUP:FindByName(group)
        if group_obj == nil then
            V51UTIL.log(string.format("ERROR: V51UTIL.groups.activateGroups got bogus group '%s'", group))
        else
            V51UTIL.log(string.format("V51UTIL.groups.activateGroups activates '%s', +%ds", group, dt))
            group_obj:Activate(dt)
        end
    end
end

-- activate a set of groups after a specified time.
--
-- @param groups        table containing names of groups to activate
-- @param prob          probability of activating a group from groups, on (0, 1]
-- @param dt            delay (s) to activation (optional, default 0)
--
function V51UTIL.groups.activateWithProb(groups, prob, dt)
    dt = dt or 0
    for _, group in pairs(groups) do
        local group_obj = GROUP:FindByName(group)
        if group_obj == nil then
            V51UTIL.log(string.format("ERROR: V51UTIL.groups.activateWithProb got bogus group '%s'", group))
        elseif prob >= math.random() then
            V51UTIL.log(string.format("V51UTIL.groups.activateWithProb activates '%s', +%ds", group, dt))
            group_obj:Activate(dt)
        else
            V51UTIL.log(string.format("V51UTIL.groups.activateWithProb SKIPS '%s'", group))
        end
    end
end

-- cascaded activation of groups. this allows the activation of a set of units to be spread out over time
-- to avoid hitting dcs with a bunch of activations simultaneously. groups from the spec are assigned to
-- one of 8 slots. this should help reduce hiccups when activating large numbers of units.
--
-- a table specifies the groups to activate along with how to active them. elements of this table may be
--
--   (1) a string group name indicating a group to activate
--   (2) a table with "pick_min" Pm (integer minimum number of groups to pick), "pick_max" Px (integer
--       maximum number of groups to pick), "from" F (integer number of idexes on group name), and
--       "base" B (string base name). the table form picks between Pm and Px groups (inclusive) with
--       names of the format B-<n> where <n> is an integer on [1, F]. if there is no Px, Px = Pm.
--
-- @param group_specs   table containing specification of groups to activate
-- @param dt            time delta (s) between activations (optional, default 0)
-- @param ready_fn      function to invoke when all units are activated (optional, default nil)
--
function V51UTIL.groups.activateCascaded(group_specs, dt, ready_fn)
    dt = dt or 0
    local slots = { }
    local slot = 1
    for _, groupSpec in pairs(group_specs) do
        if slots[slot] == nil then
            slots[slot] = { }
        end
        if type(groupSpec) == "table" then
            local picks = groupSpec["pick_min"]
            if groupSpec["pick_max"] ~= nil then
                picks = math.random(picks, groupSpec["pick_max"])
            end
            -- V51UTIL.log("pick "..tostring(picks))
            assert(picks <= groupSpec["from"])
            local permute = mist.randomizeNumTable({ size = groupSpec["from"] })
            for i = 1,picks,1 do
                if slots[slot] == nil then
                    slots[slot] = { }
                end
                local group = groupSpec["base"] .. "-" .. permute[i]
                -- V51UTIL.log("group "..group..", slot "..tostring(slot).." b " .. MUtilTableDump(slots[slot]))
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
            V51UTIL.groups.activate(slots[i], i * dt)
            tActivate = tActivate + dt
        end
    end
    if ready_fn ~= nil then
        mist.scheduleFunction(ready_fn, { }, tActivate)
    end
end

-- activate n groups from a set of m groups that have names of the form "<prefix><number>".
--
function V51UTIL.groups.activateRandom(group_prefix, n, m, dt)
    dt = dt or 0
    if n > m then
        n = m
    end

    local permute = mist.randomizeNumTable({ size = m })
    for i = 1,n,1 do
        local group_name = group_prefix .. permute[i]
        V51UTIL.log(string.format("V51UTIL.groups.activateRandom activated '%s'", group_name))
        GROUP:FindByName(group_name):Activate(dt)
    end
end

-- build out a group cluster. a group cluster is a collection of related groups (like SAM radar/TEL and SAM
-- support groups) that are randomly selected from a set of templates, along with associated statics (like
-- revetments) that are programatically spawned into the game near units from the groups. a group cluster is
-- spawned within a spawn zone selected randomly from a list of trigger zones.
--
-- a spawn zone may include the following trigger zone properties (set via the mission editor),
--
--   rotation           amount to rotate units around the cluster centerpoint (degrees, default 0)
--   max_dr             maximum random delta to add to rotation (degrees, default 0)
--   max_bb_x           maximum cluster bounding box x size (feet, default infinite)
--   max_bb_y           maximum cluster bounding box y size (feet, default infinite)
--   allow_flip         true => can randomly flip the final rotation by 180 (default false)
--   spawn_at_center    true => spawn at center of zone, otherwise random within zone (default false)
--
-- cluster_info defines the cluster group using an array of per-member-group tables with the following keys,
--
--   group_name         string with group name
--   tmplt_names        array of string dcs group names for template groups that may be instantiated
--   distr_units        array of string index ranges for units to "widely" distribute in selected template
--   sticky_units       array of array of string unit pairs define units sticking together when distributed
--   statics            array of tables with information on statics to associate with the selected template
--
-- the arrays for all tmplt_names keys in the cluster_info must have the same number of elements, N. the
-- arrays for distr_units, sticky_units, or statics must have either N elements or 1 element. the sticky_units
-- key is ignored until a distr_units key has been seen.
--
-- a string index range in the distr_units array defines which unit(s) from the corresponding template are to
-- be widely distributed and has the format,
--
--   "<i>:<j>"          matches unit(s) at indices on [<i>, <j>]
--
-- a string unit pair in the distr_units array defines which unit(s) from the corresponding template are
-- tied to units from the first group in the cluster when widely distributed,
--
--   "<l>:<r>"          ties unit l in this group to unit r in the first group with distr_units
--
-- a statics table identifies potential static object to spawn around units from the corresponding template
-- (for example, a revetment). the statics table is keyed by a unit string index pattern,
--
--   "[<tag>|]<i>"      matches unit at index <i>
--   "[<tag>|]<i>:<j>"  matches unit(s) at indices on [<i>, <j>]
--   "*"                wild card, matches any unit if no other keys have matched
--
-- the <tag> allows multiple entries to refer to the same units without creating duplicate keys. the values
-- in the statics table are tables with the following key/value pairs (an empty table is legal and indicates
-- no statics are associated with the unit),
--
--   types              array of static type names
--   category           static category name
--   dhl                local heading delta from assoicated unit (degrees, optional)
--   dxl                local x delta from associated unit (feet, along unit's heading, optional)
--   dyl                local y delta from associated unit (feet, perpendicular to unit's heading, optional)
--
-- to build a group cluster, this function randomly selects a template from tmplt_names that fits within a
-- randomly-selected spawn zone for each group in cluster_info. the corresponding elements of distr_units,
-- sticky_units, and statics are also selected (if any of these arrays has a size of 1, that element is used
-- instead).
--
-- the template is instantiated in the selected spawn zone. units that match the distr_units range or match
-- the sticky_units mapping are randomized to other spawn zones and moved there.
--
-- statics are instantiated at the location of each unit at an index in their group that matches a key in the
-- statics table. one static is selected from the types array (all such statics must belong to the same dcs
-- category). values for types and category need to be pulled from the "Name" and "category" fields from the
-- Lua that defines the static (note that these are generally *not* what is specified in the mission editor).
--
-- @param spawn_names   spawn zone names (string or table of strings)
-- @param cluster_info  cluster information table, see above
-- @param group_suffix  string suffix to add to group names (optional)
--
-- @return              spawn_names with the name of the zone used to spawn removed
--
function V51UTIL.groups.spawnCluster(spawn_names, cluster_info, group_suffix)
    if type(spawn_names) == "string" then
        spawn_names = { spawn_names }
    end
    group_suffix = group_suffix or ""

    local function getParamElement(array, index, empty)
        if array == nil then
            return empty
        elseif index <= #array then
            return array[index]
        else
            return array[1]
        end
    end

    -- randomly select the spawn zone and pull out the properties that control how the group is spawned
    -- in the zone. compute the cluster rotation and spawn center point based on properties.
    --
    local function getZonePropAsInt(zone, prop, default)
        return tonumber(zone:GetProperty(prop) or default)
    end

    local function getZonePropAsBool(zone, prop, default)
        return string.lower(zone:GetProperty(prop) or default) == "true"
    end

    local index_spawn = math.random(1, #spawn_names)
    local spawn_name = spawn_names[index_spawn]
    local spawn_zone = ZONE:FindByName(spawn_name)
    assert(spawn_zone ~= nil)
    table.remove(spawn_names, index_spawn)

    local rot = getZonePropAsInt(spawn_zone, "rotation", "0")
    local max_dr = getZonePropAsInt(spawn_zone, "max_dr", "0")
    local is_flip = getZonePropAsBool(spawn_zone, "allow_flip", "false")
    local is_center = getZonePropAsBool(spawn_zone, "spawn_at_center", "false")
    local max_bb_x = getZonePropAsInt(spawn_zone, "max_bb_x", "500000000")
    local max_bb_y = getZonePropAsInt(spawn_zone, "max_bb_y", "500000000")
    if is_flip and math.random() < 0.50 then
        rot = rot + 180.0
    end
    rot = (rot + math.random(0, max_dr)) / K_RAD2DEG            -- deg 2 rad mahbrutha...

    local spawn_center = spawn_zone:GetRandomVec2()
    if is_center then
        spawn_center = spawn_zone:GetVec2()
    end

    max_bb_x = max_bb_x * K_FT2M
    max_bb_y = max_bb_y * K_FT2M

    -- randomly select a template for the cluster that can fit within any bounding box limits set by
    -- the spawn zone. we'll kick out if no such template can be found. compute the coordinate of the
    -- center of the cluster bounding box for the selected template.
    --
    local indices_tmplt = mist.randomizeNumTable({ size = #cluster_info[1].tmplt_names })
    local index_tmplt = 0
    local bb_min
    local bb_max
    for _, index in ipairs(indices_tmplt) do
        bb_min = { x = math.huge, y = math.huge }
        bb_max = { x = -math.huge, y = -math.huge }
        for _, dict in ipairs(cluster_info) do
            local group = mist.getCurrentGroupData(dict.tmplt_names[index])
            assert(group ~= nil)
            for _, unit in ipairs(group.units) do
                bb_min.x = math.min(bb_min.x, unit.x)
                bb_min.y = math.min(bb_min.y, unit.y)
                bb_max.x = math.max(bb_max.x, unit.x)
                bb_max.y = math.max(bb_max.y, unit.y)
            end
        end
        if ((bb_max.x - bb_min.x) <= max_bb_x) and ((bb_max.y - bb_min.y) <= max_bb_y) then
            index_tmplt = index
            break
        end
    end
    if index_tmplt == 0 then
        V51UTIL.log(string.format("V51UTIL.groups.spawnCluster cannot find template to fit '%s'", spawn_name))
        return { }
    end
    local bb_center = { x = bb_min.x + ((bb_max.x - bb_min.x) / 2.0),
                        y = bb_min.y + ((bb_max.y - bb_min.y) / 2.0) }

    -- pull the groups in the cluster for the template we just identified. while doing this, sanitize the
    -- name and identifier information that will be replaced upon spawn.
    --
    local groups = { }
    local distr_units = { }
    local sticky_units = { }
    for index, dict in ipairs(cluster_info) do
        local group = mist.getCurrentGroupData(dict.tmplt_names[index_tmplt])
        assert(group ~= nil)
        groups[index] = group
        if dict.distr_units then
            local min, max = string.match(getParamElement(dict.distr_units, index_tmplt, ""), "(%d+):(%d+)")
            distr_units[index] = { min = tonumber(min), max = tonumber(max) }
        else
            distr_units[index] = { min = -1, max = -1 }
        end
        sticky_units[index] = { }
        if dict.sticky_units then
            for _, mapping in pairs(getParamElement(dict.sticky_units, index_tmplt, "")) do
                local loc, rmt = string.match(mapping, "(%d+):(%d+)")
                sticky_units[index][tonumber(loc)] = tonumber(rmt)
            end
        end

        group.name = dict.group_name .. group_suffix
        group.groupId = nil
        group.groupName = dict.group_name .. group_suffix
        group.country = group.units[1].country

        for i, unit in ipairs(group.units) do
            unit.alt = nil
            unit.groupId = nil
            unit.groupName = dict.group_name .. group_suffix
            unit.unitId = nil
            unit.unitName = string.format("%s-%d", dict.group_name .. group_suffix, i)
        end
    end

    -- reposition a unit from its template position to its spawn position. returns the unit table for
    -- the repositioned unit.
    --
    -- the unit is rotated around the group cluster center point, pc, by theta (in radians) before being
    -- translated to its spawn point relative to the spawn center, ps.
    -- 
    local function repositionTemplateUnit(unit, pc, theta, ps)
        local sin = math.sin(theta)
        local cos = math.cos(theta)
        local p0 = { x = unit.x - pc.x, y = unit.y - pc.y }
        local p1 = { x = (p0.x * cos) - (p0.y * sin), y = (p0.x * sin) + (p0.y * cos) }
        unit.x = ps.x + p1.x
        unit.y = ps.y + p1.y
        unit.point.x = unit.x
        unit.point.y = unit.y
        unit.heading = unit.heading + theta
        return unit
    end

    -- spawn a static associated with a unit.
    --
    local function spawnUnitStatic(info, unit)
        local pos = { x = unit.x, y = unit.y }
        local heading = unit.heading
        local dxl = info.dxl or 0.0
        local dyl = info.dyl or 0.0
        local dhl = info.dhl or 0.0
        if info.dxl ~= 0.0 or info.dyl ~= 0.0 then
            local sin = math.sin(unit.heading)
            local cos = math.cos(unit.heading)
            pos = { x = unit.x + (((dxl * cos) - (dyl * sin)) * K_FT2M),
                    y = unit.y + (((dxl * sin) + (dyl * cos)) * K_FT2M) }
        end
        if info.dhl ~= 0.0 then
            heading = unit.heading + (dhl / K_RAD2DEG)
        end
        if info.type then
            local type = info.type[math.random(1, #info.type)]
            if type ~= "<none>" then
                mist.dynAddStatic({ type = type, category = info.category, country = unit.country,
                                    x = pos.x, y = pos.y, heading = heading })
            end
        end
    end

    -- walk the statics associated with a group to spawn statics associated with a particular unit.
    --
    local function spawnUnitStatics(unit, unit_index, statics)
        local index = tostring(unit_index)
        local is_matched = false
        if statics then
            for key, info in pairs(statics) do
                key = string.gsub(key, ".+|", "")
                local min, max = string.match(key, "(%d+):(%d+)")
                if (key == index) or (min ~= nil and max ~= nil and min <= index and index <= max) then
                    spawnUnitStatic(info, unit)
                    is_matched = true
                end
            end
            if not is_matched and statics["*"] then
                spawnUnitStatic(statics["*"], unit)
            end
        end
    end

    -- walk all units in all groups in the group cluster and update their position to their spawn position
    -- and instantiate any statics associated with the unit.
    --
    local distr_map = { }
    for index, group in ipairs(groups) do
        V51UTIL.log(string.format("V51UTIL.groups.spawnCluster built '%s' in '%s'", group.groupName, spawn_name))
        for i = 1, #group.units do
            if sticky_units[index][i] and distr_map[sticky_units[index][i]] then
                group.units[i] = repositionTemplateUnit(group.units[i], distr_map[sticky_units[index][i]].pc, rot,
                                                        distr_map[sticky_units[index][i]].sc)
                V51UTIL.log(string.format("V51UTIL.groups.spawnCluster sticks group:unit %d:%d to %d:%d",
                            index, i, distr_map[sticky_units[index][i]].grp, sticky_units[index][i]))
            elseif distr_units[index].min <= i and i <= distr_units[index].max and #spawn_names >= 1 then
                local index_distr = math.random(1, #spawn_names)
                local distr_name = spawn_names[index_distr]
                local distr_zone = ZONE:FindByName(distr_name)
                assert(distr_zone ~= nil)
                table.remove(spawn_names, index_distr)
                local sc = spawn_zone:GetRandomVec2()
                local pc = { x = group.units[i].x, y = group.units[i].y }
                if distr_map[i] == nil then
                    distr_map[i] = { pc = mist.utils.deepCopy(pc), sc = mist.utils.deepCopy(sc), grp = index }
                end
                group.units[i] = repositionTemplateUnit(group.units[i], pc, rot, sc)
                V51UTIL.log(string.format("V51UTIL.groups.spawnCluster relocates group:unit %d:%d to '%s'", index, i, distr_name))
            else
                group.units[i] = repositionTemplateUnit(group.units[i], bb_center, rot, spawn_center)
            end
            spawnUnitStatics(group.units[i], i, getParamElement(cluster_info[index].statics, index_tmplt, { }))
        end
        mist.dynAdd(group)
    end

    return spawn_names
end

-- spawn a group to patrol along a path according to a late-activated route template (note all points on
-- path must have non-zero speed). the unit spawned is randomly selected from the template list. the unit
-- starts from a random point along the path and loops continuously, going from dp to sp at end.
--
-- @param group_name    name of group to spawn
-- @param route_tmplt   name template for route (late activated)
-- @param tmplts        table of names of template units to use (optional, nil => use route_tmplt)
--
function V51UTIL.groups.spawnPatrol(group_name, route_tmplt, tmplts)
    tmplts = tmplts or { route_tmplt }
    local route_points = mist.getGroupRoute(route_tmplt, true)
    assert(route_points ~= nil)

    local route = { points = { } }
    local i_start = math.random(#route_points)
    for i = i_start, #route_points do
        route.points[#route.points+1] = mist.utils.deepCopy(route_points[i])
    end
    for i = 1, i_start - 1 do
        route.points[#route.points+1] = mist.utils.deepCopy(route_points[i])
    end
    route.points[1].task = mist.utils.deepCopy(route_points[1].task)
    local n_task = #route.points[#route.points].task.params.tasks + 1
    route.points[#route.points].task.params.tasks[n_task] = {
        auto = false,
        enabled = true,
        id = "GoToWaypoint",
        number = 1,
        params = {
            nWaypointIndx = 1,
            fromWaypointIndex = #route.points,
        }
    }

    local tmplt_name = tmplts[math.random(#tmplts)]
    local group = mist.utils.deepCopy(mist.getCurrentGroupData(tmplt_name))

    V51UTIL.log(string.format("V51UTIL.groups.spawnPatrol '%s' uses '%s' at [%d]", group_name, tmplt_name, i_start))

    group.country = group.units[1].country
    group.name = group_name
    group.groupId = nil
    group.groupName = group_name
    group.route = route
    group.x = route.points[1].x
    group.y = route.points[1].y
    local tmpl_loc = { x = group.units[1].x, y = group.units[1].y }
    for i, unit in ipairs(group.units) do
        unit.groupId = nil
        unit.groupName = group_name
        unit.unitId = nil
        unit.unitName = string.format("%s-%d", group_name, i)
        unit.x = group.x + (group.units[i].x - tmpl_loc.x)
        unit.y = group.y + (group.units[i].y - tmpl_loc.y)
        unit.point.x = unit.x
        unit.point.y = unit.y
        unit.alt = nil
    end

    mist.dynAdd(group)
end

-- start randomly pausing a group every dp seconds (random on min/max) for tp seconds (random on min/max)
--
-- @param group         name of group to start pausing
-- @param dp_min        minimum delta between pauses (s)
-- @param dp_max        maximum delta between pauses (s) (optional, default is dp_min)
-- @param tp_min        minimum time spent paused (s)
-- @param tp_max        maximum time spent paused (d) (optional, defauilt is tp_min)
-- @param fn            function to call when paused, fn(group, is_paused) (optional)
--
function V51UTIL.groups.startRandomPauses(group, dp_min, dp_max, tp_min, tp_max, fn)
    dp_max = dp_max or dp_min
    tp_max = tp_max or tp_min
    local is_update = false
    if V51UTIL.groups.pause_info[group] then
        is_update = true
    end
    V51UTIL.groups.pause_info[group] = {
        dp_max = dp_max,
        dp_min = dp_min,
        tp_max = tp_max,
        tp_min = tp_min,
        fn = fn
    }
    if not is_update then
        V51UTIL.groups.pause_info[group].is_paused = false
        V51UTIL.groups.pause_info[group].is_stopping = false
        mist.scheduleFunction(PauseResumeGroup, { group }, timer.getTime() + math.random(dp_min, dp_max))
    end
end

-- stop randomly pausing a group. this takes effect at the next pause interval.
--
-- @param group         name of group to stop pausing
--
function V51UTIL.groups.stopRandomPauses(group)
    if V51UTIL.groups.pause_info[group] then
        V51UTIL.groups.pause_info[group].is_stopping = true
    end
end

-- "swizzle" a group. the position of the units within the group is swapped randomly (unit order
-- will remain unchanged however). optionally, a random number of units can be removed from the
-- end of the group.
--
-- when used with skynet sam sites, swizzling should be done before the site is added to skynet.
--
-- @param group_name    name of sam group to swizzle
-- @param start_unit    first unit to swizzle
-- @param min_units     minimum number of units in swizzled group (default: number of group units)
-- @param max_units     maximum number of units in swizzled group (default: min_units)
--
function V51UTIL.groups.swizzle(group_name, start_unit, min_units, max_units)
    local group = mist.getCurrentGroupData(group_name)
    if group == nil then
        return
    end
    local group_swizzle = mist.utils.deepCopy(group)

    -- randomly exchange the position of units within the group.
    --
    local swizzler = mist.randomizeNumTable({ size = #group_swizzle.units })
    for i = 1, #group_swizzle.units do
        local j = swizzler[i]
        group_swizzle.units[i].x = group.units[j].x
        group_swizzle.units[i].y = group.units[j].y
        group_swizzle.units[i].point.x = group.units[j].point.x
        group_swizzle.units[i].point.y = group.units[j].point.y
        group_swizzle.units[i].heading = group.units[j].heading
    end
    group_swizzle.country = group_swizzle.units[1].country

    -- quoth the mist documentation around dynAdd(): "Due to the ids and names of the units being
    -- identical the original units will disappear and be replaced by the same units but simply
    -- [updated with the edits here]."
    --
    mist.dynAdd(group_swizzle)

    -- pull any extra units from the swizzled group. we'll do this by destroying the last N units
    -- in the group via moose to make sure dcs/moose understands that they're no longer a thing.
    --
    if min_units == nil then
        min_units = #group.units
    end
    if max_units == nil then
        max_units = min_units
    end
    local n_units = #group.units
    for i = math.random(min_units, max_units) + 1, #group.units do
        UNIT:FindByName(string.format("%s-%d", group_name, i)):Destroy()
        n_units = n_units - 1
    end

    V51UTIL.log(string.format("V51UTIL.groups.swizzle start %d, num %d -> %d", start_unit, #group.units, n_units))
end

-- destroy groups from a table of group names.
--
function V51UTIL.groups.destroy(groups, dt)
    dt = dt or 0

    for _, group in pairs(groups) do
        local groupObj = GROUP:FindByName(group)
        if groupObj == nil then
            V51UTIL.log(string.format("ERROR: V51UTIL.groups.destroy got bad group '%s'", group))
        else
            V51UTIL.log(string.format("V51UTIL.groups.destroy removes group '%s'", group))
            groupObj:Destroy(false, dt)
        end
    end
end

-- destroy groups with a name with a given prefix.
--
function V51UTIL.groups.destroyWithPrefix(prefix)
    local function destroyGroup(group)
        V51UTIL.log(string.format("V51UTIL.groups.destroyWithPrefix removes group '%s'", group:GetName()))
        group:Destroy(false, 1)
    end
    SET_GROUP:New():FilterPrefixes(prefix):FilterOnce():ForEachGroup(destroyGroup)
end

-- ============================================================================================================
--
-- TTS MODULE
--
-- ============================================================================================================

V51UTIL.tts = {
    engine = "microsoft", -- or "google"
    voiceMap = {
        ["<default>.microsoft"] = MSRS.Voices.Microsoft.David,
        ["<default>.google"] = MSRS.Voices.Google.Wavenet.en_US_Wavenet_A,
    }
}

-- set the tts engine for MSRS to the given engine ("google" or "microsoft"). default is "microsoft" if
-- the tts engine is unknown.
--
-- @param engine        tts engine (case-insensitive), "google" or "microsoft"
--
function V51UTIL.tts.setEngine(engine)
    if engine and string.lower(engine) == "google" then
        V51UTIL.tts.engine = string.lower(engine)
    else
        V51UTIL.tts.engine = "microsoft"
    end
end

-- set the voice(s) to use with the microsoft and google engines for a given actor. the actor name
-- "<default>" sets the default voice to use for an unknown actor.
--
-- @param actor             actor name, "<default>" for the default actor
-- @param vox_microsoft     microsoft tts voice name to associate with actor
-- @param vox_google        google tts voice name to associate with actor
--
function V51UTIL.tts.setVoice(actor, vox_microsoft, vox_google)
    if not vox_microsoft then
        vox_microsoft = MSRS.Voices.Microsoft.David
    end
    if not vox_google then
        vox_google = MSRS.Voices.Google.Wavenet.en_US_Wavenet_A
    end
    V51UTIL.tts.voiceMap[actor .. ".microsoft"] = vox_microsoft
    V51UTIL.tts.voiceMap[actor .. ".google"] = vox_google
end

-- broadcast a tts message on the given frequency/modulation using the specified MSRSQUEUE. a nil
-- MSRSQUEUE (q) indicates tts services are not available and the message is displayed for 30s
-- via the logging utility.
--
-- @param q             MSRSQUEUE to hold message
-- @param actor         name of actor performing broadcast
-- @param text          text of broadcast
-- @param frequency     frequency to broadcast on (MHz)
-- @param modu          modulation, radio.modulation enum (default .AM)
-- @param delay         delay (s) to broadcast (default 0)
-- @param interval      interval (s) between broadcast and last transmission (default 2)
--
function V51UTIL.tts.broadcast(q, actor, text, freq, modu, delay, interval)
    if q then
        if not modu then
            modu = radio.modulation.AM
        end
        if not delay then
            delay = 0
        end
        if not interval then
            interval = 2
        end
        local msrs = MSRS:New('', freq, modu)
        if V51UTIL.tts.engine == "microsoft" then
            msrs:SetWin()
        else
            msrs:SetGoogle()
        end
        local voice_key = actor .. "." .. V51UTIL.tts.engine
        if not V51UTIL.tts.voiceMap[voice_key] then
            voice_key = "<default>." .. V51UTIL.tts.engine
        end
        msrs:SetLabel(actor)
        msrs:SetVoice(V51UTIL.tts.voiceMap[voice_key])

        V51UTIL.log(string.format("V51UTIL.tts.broadcast [%s]: '%s' on %s",
                                  V51UTIL.tts.voiceMap[voice_key], text, tostring(freq)))
        q:NewTransmission(text, STTS.getSpeechTime(text, 0.95), msrs, delay, interval)

    elseif string.len(text) > 0 then
        V51UTIL.log(actor .. ": " .. text, true, 30)
    end
end

-- ============================================================================================================
--
-- TOT MODULE
--
-- ============================================================================================================

V51UTIL.tot = {
    isEventHandlerAdded = false,
    eventHandler = { },
    groups = { }
}

-- ------------------------------------------------------------------------------------------------------------
-- ToT Support Functions
-- ------------------------------------------------------------------------------------------------------------

-- perform bda on a tot group following window closure. invokes the tot group's fn_bda function with the
-- target info table, and status booleans as parameters.
--
local function TOTTargetBDA(grp_name, grp_info)

    local function GetRelativeLifeForUnit(unitName)
        local unit = UNIT:FindByName(unitName)
        if unit ~= nil then
            return unit:GetLifeRelative()
        end
        return 0
    end

    if not grp_info.is_window_closed then
        grp_info.is_window_closed = true

        V51UTIL.log("TOTTargetBDA '" .. grp_name .. "'")
        local is_all_hit = true
        local is_all_dead = true
        local n_hits = 0
        for tgt_name, tgt_info in pairs(grp_info.tgt_info) do
            if tgt_info.t_hit == 0 then
                is_all_hit = false
                tgt_info.is_dead = false
            elseif tgt_info.max_life > 0 and tgt_info.max_life < GetRelativeLifeForUnit(tgt_name) then
                is_all_dead = false
                tgt_info.is_dead = false
                n_hits = n_hits + 1
            else
                tgt_info.is_dead = true
                n_hits = n_hits + 1
            end
            V51UTIL.log("  " .. tgt_name .. ": dead=" .. tostring(tgt_info.is_dead) ..
                        ", hit=" .. string.format("%.1f", tgt_info.t_hit) ..
                        ", life=" .. string.format("%.1f", GetRelativeLifeForUnit(tgt_name)))
        end
        if grp_info.fn_bda then
            mist.scheduleFunction(grp_info.fn_bda, { grp_info.tgt_info, is_all_hit, is_all_dead, n_hits },
                                  timer.getTime() + 4)
        end
    end
end

-- event handler for "hit" events. look for hits on targets being managed for tot and process as
-- necessary.
--
-- NOTE: becuase we use HIT events, the ToT targets have to be things that generate such events.
-- NOTE: that is, not scenery...
--
function V51UTIL.tot.eventHandler:onEvent(event)
    if event.id == world.event.S_EVENT_HIT and event.target ~= nil then
        local t_hit = timer.getTime()
        for grp_name, grp_info in pairs(V51UTIL.tot.groups) do
            local is_1st_hit_prev = grp_info.is_1st_hit
            if not grp_info.is_window_closed then
                local evt_tgt_name = tostring(event.target:getName())

                for tgt_name, tgt_info in pairs(grp_info.tgt_info) do
                    if tgt_info.t_hit == 0 and
                       ((tgt_info.is_prefix and evt_tgt_name:find(tgt_name, 1, true) == 1 ) or
                        (not tgt_info.is_prefix and evt_tgt_name == tgt_name))
                    then
                        V51UTIL.log(grp_name .. " / " .. tgt_name .. " hit at " .. t_hit)
                        grp_info.is_1st_hit = true
                        tgt_info.t_hit = t_hit
                        if tgt_info.smoke_zone ~= nil then
                            local smoke_preset = BIGSMOKEPRESET.LargeSmoke
                            if tgt_info.smoke_preset ~= nil then
                                smoke_preset = tgt_info.smoke_preset
                            end
                            V51UTIL.smokeInZone(tgt_info.smoke_zone, smoke_preset, 0.75)
                        end
                        if tgt_info.fn_hit ~= nil then
                            tgt_info.fn_hit(tgt_info)
                            if tgt_info.fn_hit_once then
                                tgt_info.fn_hit = nil
                            end
                        end
                        break
                    end
                end
            else
                V51UTIL.log(string.format("V51UTIL.tot onEvent() removes '%s', window has closed", grp_name))
                V51UTIL.tot.groups[grp_name] = nil
            end
            if not is_1st_hit_prev and grp_info.is_1st_hit then
                V51UTIL.log(string.format("V51UTIL.tot attack window closes at %d", t_hit + grp_info.dt_window))
                mist.scheduleFunction(TOTTargetBDA, { grp_name, grp_info }, t_hit + grp_info.dt_window)
            end
        end
    end
end

-- ------------------------------------------------------------------------------------------------------------
-- ToT External API
-- ------------------------------------------------------------------------------------------------------------

-- add a group of targets to be managed for a "time on target" strike. each group of targets may contain one
-- or more dcs targets (i.e., units). a successful strike will sufficiently damage at least one target in each
-- group.
--
-- @param tot_group        unique name of group of targets to hit
-- @param dt_window        duration of window (opens on first target hit) in s
-- @param tgt_info         table of information on target(s), key is target unit name (from DCS ME), value is a
--                         table with information on target(s)
-- @param fn_bda           bda function, signature fn(tgt_info, is_all_hit, is_all_dead, n_hits)
--
-- each value in the tgt_info table contains the following fields,
--
-- max_life         maximum life on [0,1] allowed for the unit to be considered destroyed (nil implies 0)
-- is_prefix        indicates if the key is treated as a full unit name (false, default) or a prefix (true)
-- smoke_zone       name of the zone to trigger smoke in on hit (nil for no smoke)
-- smoke_preset     smoke preset to use, see BIGSMOKEPRESET enum (nil for large smoke)
-- fn_hit           hit function, signature fn(tgt_info), called on target hit (nil for none)
-- fn_hit_once      true => call fn_hit once (false, default)
--
-- NOTE: at present, this does not work on scenery objects unless there is a dcs unit nearby that can/will
-- NOTE: be damaged by splash damage.
--
function V51UTIL.tot.addTargetGroup(tot_group, dt_window, tgt_info, fn_bda)
    V51UTIL.log(string.format("V51UTIL.tot.addTargetGroup('%s', dt = %d s)", tot_group, dt_window))
    if not V51UTIL.tot.isEventHandlerAdded then
        V51UTIL.log("V51UTIL.tot.addTargetGroup installing event handler")
        world.addEventHandler(V51UTIL.tot.eventHandler)
        V51UTIL.tot.isEventHandlerAdded = true
    end

    V51UTIL.tot.groups[tot_group] = { dt_window = dt_window,
                                      fn_bda = fn_bda,
                                      is_window_closed = false,
                                      is_1st_hit = false,
                                      tgt_info = { }
    }
    for tgt_name, info in pairs(tgt_info) do
        local is_prefix = false
        if info.is_prefix ~= nil then
            is_prefix = info.is_prefix
        end
        local max_life = 0
        if info.max_life ~= nil then
            max_life = info.max_life
        end
        V51UTIL.log(string.format("V51UTIL.tot.addTargetGroup adds '%s', pfx %s", tgt_name, tostring(is_prefix)))
        V51UTIL.tot.groups[tot_group].tgt_info[tgt_name] = { t_hit = 0,
                                                             t_name = tgt_name,
                                                             max_life = max_life,
                                                             is_prefix = is_prefix,
                                                             smoke_zone = info.smoke_zone,
                                                             smoke_preset = info.smoke_preset,
                                                             fn_hit = info.fn_hit,
                                                             fn_hit_once = info.fn_hit_once
        }
    end
end

-- remove a group of targets from management for a "time on target" strike.
--
-- @param tot_group        name of group of targets to remove from tot management
--
function V51UTIL.tot.removeTargetGroup(tot_group)
    --
    -- TODO: pull V51UTIL.tot.eventHandler handler if there are no more active ToT groups?
    --
    if V51UTIL.tot.groups[tot_group] ~= nil then
        V51UTIL.tot.groups[tot_group] = nil
    end
end

-- ============================================================================================================
--
-- CONVOY MODULE
--
-- ============================================================================================================

-- the convoy support allows group(s) of units to move in coordination with a group of air defense units that
-- stop as they are tracking/engaging threats. when the air defense group stops to engage, the other group(s)
-- also stop. movement resumes when the air defense group determines it is safe to resume.
--
-- HACK: the air defense group can sometimes become wedged in dcs, causing them to stop moving even after all
-- HACK: threats have been addressed. this function will respawn the air defense group in this case. this has
-- HACK: the side-effect of re-arming the group, but it does allow forward progress to be maintained.
--
-- the pauseMovement() and resumeMovement() functions can be used to explicity stop and start movement of the
-- convoy and it's guardian air defense units.
--
-- to use this functionality,
--
-- 1) set up the air defense group to handle EVENTS.Shot,
--
--    local ADSGroup = GROUP:FindByName(ADS_GROUP_NAME)
--    ADSGroup:HandleEvent(EVENTS.Shot)
-- 
--    function ADSGroup:OnEventShot(data)
--        V51UTIL.convoy.onEventShot(ADS_GROUP_NAME, DEFEND_GROUP_NAME, ADS_WEZ_SIZE_NM)
--    end
--
-- 2) Call the V51UTIL.convoy.startCoordination function to start coordination
--
--    V51UTIL.convoy.startCoordination(ADS_GROUP_NAME, DEFEND_GROUP_NAME, ADS_WEZ_SIZE_NM, GetContactsNearGroup)
--
--    the contacts function should return a table of threats within a given distance of a group with the
--    given name: GetContactsNearGroup(group, distance)
--
-- 3) Coordination stops when either convoy is destroyed or when the stop function is called,
--
--    V51UTIL.convoy.endCoordination(ADS_GROUP_NAME)

V51UTIL.convoy = {

    -- dictionary describing current convoy state. key is air defense group name, value is a boolean indicating
    -- the convoy is halted by scripting or paused by mission. nil indicates the convoy is no longer running.
    --
    convoyHalted = { },
    convoyPaused = { },

    -- dictionary describing current convoy pause state. key is air defense group name, value is boolean
    -- indicating when the mission has requested a pause.
    --
    convoyPauseReq = { },

    -- dictionary describing contacts function to use for convoys. key is air defense group name, value is a
    -- "get contacts" function
    --
    convoyContactsFn = { }
}

-- ------------------------------------------------------------------------------------------------------------
-- Convoy Support Functions
-- ------------------------------------------------------------------------------------------------------------

-- coordinate the behavior of an ads group (ads_group) and a defended group (def_group) assuming the wez of
-- the ads group is wez_size.
--
-- this function uses the iads RedIADSContactsNearGroup() function to determine if the ads unit should be
-- worried.
--
local function CoordinateConvoys(tout, one_time, ads_group, def_group, wez_size)
    local cur_time = mist.utils.round(timer.getTime())
    local ads_convoy = GROUP:FindByName(ads_group)
    local def_convoy = GROUP:FindByName(def_group)
    if ads_convoy:IsAlive() and def_convoy:IsAlive() and V51UTIL.convoy.convoyHalted[ads_group] ~= nil then
        local is_threat = one_time
        local fn_contacts = V51UTIL.convoy.convoyContactsFn[ads_group]
        for _, _ in pairs(fn_contacts(ads_group, wez_size)) do
            is_threat = true
            tout = 0
            break
        end

        local ads_v = mist.utils.round(ads_convoy:GetVelocityMPS())
        local def_v = mist.utils.round(def_convoy:GetVelocityMPS())
        local dt = 30
        local action = "IDLE '" .. ads_group .. "'"

        if V51UTIL.convoy.convoyPaused[ads_group] == true then
            if V51UTIL.convoy.convoyPauseReq[ads_group] == true then
                action = "RESUME '" .. ads_group .. "', '" .. def_group .. "'"
                V51UTIL.convoy.convoyPaused[ads_group] = false
                V51UTIL.convoy.convoyPauseReq[ads_group] = false
                ads_convoy:PopCurrentTask()
                def_convoy:PopCurrentTask()
            end
            tout = 0
        elseif is_threat and ads_v == 0 and def_v ~= 0 and V51UTIL.convoy.convoyHalted[ads_group] == false then
            action = "STOP '" .. def_group .. "'"
            V51UTIL.convoy.convoyHalted[ads_group] = true
            def_convoy:PushTask(def_convoy:TaskHold(), 0)
            tout = 0
        elseif is_threat and tout ~= 0 then
            action = "REATTACK"
            tout = 0
        elseif not is_threat and ads_v ~= 0 and def_v == 0 and V51UTIL.convoy.convoyHalted[ads_group] == true then
            action = "START '" .. def_group .. "'"
            V51UTIL.convoy.convoyHalted[ads_group] = false
            def_convoy:PopCurrentTask()
            tout = 0
        elseif not is_threat and ads_v == 0 and tout == 0 then
            action = "CHECK '" .. ads_group .. "'"
            tout = cur_time + 120
        elseif not is_threat and ads_v == 0 and tout <= cur_time then
            action = "RESPAWN '" .. ads_group .. "'"
            local args = { }
            args.groupName = ads_group
            args.point = ads_convoy:GetPointVec3()
            args.action = "respawn"
            mist.teleportToPoint(args)
            tout = 0
            dt = 5
        elseif V51UTIL.convoy.convoyPauseReq[ads_group] == true then
            action = "PAUSE '" .. ads_group .. "', '" .. def_group .. "'"
            V51UTIL.convoy.convoyPaused[ads_group] = true
            V51UTIL.convoy.convoyPauseReq[ads_group] = false
            ads_convoy:PushTask(ads_convoy:TaskHold(), 0)
            def_convoy:PushTask(def_convoy:TaskHold(), 0)
            tout = 0
        end
        if tout ~= 0 and cur_time + dt > tout then
            dt = tout - cur_time
        end

--[[
        V51UTIL.log(string.format("V51UTIL.convoy.CoordinateConvoys(tout=%d, one_time=%s) %s" ..
                                  " / halted=%s, paused=%s, tout=%d, is_threat=%s, ads_v=%d, def_v=%d, dt=%d",
                                  mist.utils.round(tout), tostring(one_time), action,
                                  tostring(V51UTIL.convoy.convoyHalted[ads_group]),
                                  tostring(V51UTIL.convoy.convoyPaused[ads_group]),
                                  mist.utils.round(tout), tostring(is_threat),
                                  tostring(ads_v), tostring(def_v), mist.utils.round(dt)))
        V51UTIL.log("V51UTIL.convoy.CoordinateConvoys(tout=" .. mist.utils.round(tout) .. ", one_time=" ..
                    tostring(one_time) .. ") " .. action ..
                    " / halted=" .. tostring(V51UTIL.convoy.convoyHalted[ads_group]) ..
                    ", tout=" .. mist.utils.round(tout) .. ", is_threat=" .. tostring(is_threat) ..
                    ", ads_v=" .. tostring(ads_v) .. ", def_v=" .. tostring(def_v) ..
                    ", dt=" .. mist.utils.round(dt))
--]]

        if not one_time then
            mist.scheduleFunction(CoordinateConvoys,
                                  { tout, false, ads_group, def_group, wez_size }, timer.getTime() + dt)
        end
    end
end

-- ------------------------------------------------------------------------------------------------------------
-- Convoy External API
-- ------------------------------------------------------------------------------------------------------------

-- start convoy coordination.
--
-- @param ads_group     name of air defense group providing defense
-- @param def_group     name of group being defended
-- @param wez_size      size of the wez (nm) to halt convoy within
-- @param fn_contacts   function returning a table of groups that are within a distance of an defending group
--
function V51UTIL.convoy.startCoordination(ads_group, def_group, wez_size, fn_contacts)
    V51UTIL.log("V51UTIL.convoy.StartCoordination(ads='" .. ads_group .. "', def='" .. def_group ..
                "', wez=" .. tostring(wez_size) .. ")")
    V51UTIL.convoy.convoyHalted[ads_group] = false
    V51UTIL.convoy.convoyPaused[ads_group] = false
    V51UTIL.convoy.convoyPauseReq[ads_group] = false
    V51UTIL.convoy.convoyContactsFn[ads_group] = fn_contacts
    mist.scheduleFunction(CoordinateConvoys,
                          { 0, false, ads_group, def_group, wez_size }, timer.getTime() + 30)
end

-- stop convoy coorindation.
--
-- @param ads_group     name of air defense group providing defense
--
function V51UTIL.convoy.endCoordination(ads_group)
    V51UTIL.log("V51UTIL.convoy.EndCoordination(ads='" .. ads_group .. "')")
    V51UTIL.convoy.convoyHalted[ads_group] = nil
    V51UTIL.convoy.convoyPaused[ads_group] = nil
end

-- pause and resume convoy movement. stops the air defense group and it's associated convoy at the next
-- coordination update. there should be one resumeMovement() call for each pauseMovement() call.
--
-- @param ads_group     name of air defense group providing defense
--
function V51UTIL.convoy.pauseMovement(ads_group)
    if V51UTIL.convoy.convoyPaused[ads_group] ~= true then
        V51UTIL.convoy.convoyPauseReq[ads_group] = true
    end
end

function V51UTIL.convoy.resumeMovement(ads_group)
    if V51UTIL.convoy.convoyPaused[ads_group] == true then
        V51UTIL.convoy.convoyPauseReq[ads_group] = true
    end
end

-- OnEventShot handler for air defense groups in the convoy. called from the "shot" event handler for the air
-- defense groups in the convoy.
--
-- @param ads_group     name of air defense group providing defense
-- @param def_group     name of group being defended
-- @param wez_size      size of the wez (nm) to halt convoy within
--
function V51UTIL.convoy.onEventShot(ads_group, def_group, wez_size)
    V51UTIL.log("V51UTIL.convoy.OnEventShot(ads='" .. ads_group .. "', def='" .. def_group ..
                "', wez=" .. tostring(wez_size) .. ")")
    mist.scheduleFunction(CoordinateConvoys,
                          { 0, true, ads_group, def_group, wez_size }, timer.getTime() + 10)
end

-- ============================================================================================================
--
-- SKYNET MODULE
--
-- ============================================================================================================

V51UTIL.skynet = { }

-- set up sam sites for skynet by setting the use as ewr, engagement zone (default is withinsearch range),
-- and point defenses.
--
-- @param iads          skynet iads object
-- @param sam_groups    table with names of sam groups to update
-- @param is_ewr        true if sam_groups should act as ewr (optional, default false)
-- @param eng_zone      engagement zone for sam_groups optional, default GO_LIVE_WHEN_IN_SEARCH_RANGE)
-- @param pd_groups     table with names of groups to assign as pds to sam_groups (optional, default none)
--
function V51UTIL.skynet.setupSAMs(iads, sam_groups, is_ewr, eng_zone, pd_groups)
    if is_ewr == nil then
        is_ewr = false
    end
    eng_zone = eng_zone or SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE
    pd_groups = { } or pd_groups
    for _, sam_group in pairs(sam_groups) do
        local sam = iads:getSAMSiteByGroupName(sam_group)
        sam:setActAsEW(is_ewr)
        sam:setEngagementZone(eng_zone)
        if #pd_groups > 0 then
            for _, pd_group in pairs(pd_groups) do
                local pd = iads:getSAMSiteByGroupName(pd_group)
                sam:addPointDefence(pd)
            end
            sam:setCanEngageHARM(false)
        else
            sam:setCanEngageHARM(true)
        end
    end
end

-- set up ewr site(s) for skynet by setting up the point defenses.
--
-- @param iads          skynet iads object
-- @param ewr_units     table with names of ewr units to update
-- @param pd_groups     table with names of groups to assign as point defenses to ewr_units
--
function V51UTIL.skynet.setupEWRs(iads, ewr_units, pd_groups)
    for _, ewr_unit in pairs(ewr_units) do
        local ewr = iads:getEarlyWarningRadarByUnitName(ewr_unit)
        if pd_groups then
            for _, pd_group in pairs(pd_groups) do
                local pd = iads:getSAMSiteByGroupName(pd_group)
                ewr:addPointDefence(pd)
            end
        end
    end
end

-- set up engagement zone to match the extent of a dcs me zone. the name of the zone for a given sam site
-- is given by "ZN ENG <sam_group_name>". if no such zone exists, the function will try to filter the sam
-- site group name using the zone_regex.
--
-- @param iads          skynet iads object
-- @param sam_groups    table with names of sam groups to update
-- @param zone_regex    regex to filter the group name when building the dcs zone name (optional)
-- @param eng_zone      engagement zone for sam_groups (optional, default GO_LIVE_WHEN_IN_SEARCH_RANGE)
-- @param scale         scaling factor to apply to zone radius (optiona, default 1.0)
--
function V51UTIL.skynet.setupEngageZones(iads, sam_groups, zone_regex, eng_zone, scale)
    eng_zone = eng_zone or SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE
    scale = scale or 1.0
    for _, sam_group in pairs(sam_groups) do
        local sam = iads:getSAMSiteByGroupName(sam_group)
        local zone = ZONE:FindByName("ZN ENG " .. sam_group)
        if zone == nil and zone_regex ~= nil then
            zone = ZONE:FindByName("ZN ENG " .. string.match(sam_group, zone_regex))
        end
        if sam ~= nil and zone ~= nil then
            local radius = zone:GetRadius() * scale

            local maxRange = 0
            if eng_zone == SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE then
                for _, radar in pairs(sam.trackingRadars) do
                    maxRange = math.max(maxRange, radar.maximumRange)
                end
                for _, radar in pairs(sam.searchRadars) do
                    maxRange = math.max(maxRange, radar.maximumRange)
                end
            else
                for _, launcher in pairs(sam.launchers) do
                    maxRange = math.max(maxRange, launcher.maximumRange)
                end
            end

            local pctg = math.floor(((radius * 1.0) / (maxRange * 1.0 )) * 100.0)

            sam:setEngagementZone(eng_zone)
            sam:setGoLiveRangeInPercent(pctg)

            V51UTIL.log(string.format("V51UTIL.skynet.setupEngageZones '%s' (%d) mr %.1f, zr %.1f, pctg %d",
                                      sam_group, eng_zone, maxRange / K_NM2M, radius / K_NM2M, pctg))
        end
    end
end

-- "swizzle" a sam site. the sam group should be set up per skynet (single group with only radar
-- and tel units). the position of the units will be swapped randomly (unit order will remain
-- unchanged). optionally, a random number of units can be removed from the group. this allows
-- you to do things like build a site in ME with 20 tels and then randomly populate only four
-- of the me tel sites with actual tels.
--
-- to be safe, swizzling should be done before the same site is added to skynet.
--
-- @param group_name    name of sam group to scramble
-- @param min_units     minimum number of units in swizzled group (default: number of group units)
-- @param max_units     maximum number of units in swizzled group (default: min_units)
--
function V51UTIL.skynet.setupSwizzledSAMSite(group_name, min_units, max_units)
    local group = mist.getCurrentGroupData(group_name)
    if group == nil then
        return
    end
    local group_swizzle = mist.utils.deepCopy(group)

    -- randomly exchange the position of units within the group.
    --
    local swizzler = mist.randomizeNumTable({ size = #group_swizzle.units })
    for i = 1, #group_swizzle.units do
        local j = swizzler[i]
        group_swizzle.units[i].x = group.units[j].x
        group_swizzle.units[i].y = group.units[j].y
        group_swizzle.units[i].point.x = group.units[j].point.x
        group_swizzle.units[i].point.y = group.units[j].point.y
        group_swizzle.units[i].heading = group.units[j].heading
    end
    group_swizzle.country = group_swizzle.units[1].country

    -- quoth the mist documentation around dynAdd(): "Due to the ids and names of the units being
    -- identical the original units will disappear and be replaced by the same units but simply
    -- [updated with the edits here]."
    --
    mist.dynAdd(group_swizzle)

    -- pull any extra units from the swizzled group. we'll do this by destroying the last N units
    -- in the group via moose to make sure dcs/moose understands that they're no longer a thing.
    --
    if min_units == nil then
        min_units = #group.units
    end
    if max_units == nil then
        max_units = min_units
    end
    for i = math.random(min_units, max_units) + 1, #group_swizzle.units do
        UNIT:FindByName(string.format("%s-%d", group_name, i)):Destroy()
    end
end

-- return a table of skynet contacts for all contacts the iads is aware of that are within a given
-- distance of a group. the returned table is keyed by contact name.
--
-- @param iads          skynet iads object
-- @param group_name    name of group to check for
-- @param dist          maximum distance (nm) from group_name for a contact to be considered "near"
--
function V51UTIL.skynet.contactsNearGroup(iads, group_name, dist)

    -- build a table of unique contacts across the ewr and sam sites in the iads
    --
    local uniq_contacts = { }
    local ewrs = iads:getEarlyWarningRadars()
    for i = 1, #ewrs do
        local contacts = ewrs[i]:getDetectedTargets()
        for j = 1, #contacts do
            local contact = contacts[j]
            if uniq_contacts[contact:getName()] == nil then
                uniq_contacts[contact:getName()] = contact
            end
        end
    end
    local sams = iads:getSAMSites()
    for i = 1, #sams do
        local contacts = sams[i]:getDetectedTargets()
        for j = 1, #contacts do
            local contact = contacts[j]
            if uniq_contacts[contact:getName()] == nil then
                uniq_contacts[contact:getName()] = contact
            end
        end
    end

    -- walk the unique contacts looking for something within the given distance of the unit.
    --
    local hit_contacts = { }
    local pos = GROUP:FindByName(group_name):GetPositionVec3()
    for name, contact in pairs(uniq_contacts) do
        if dist > mist.utils.metersToNM(mist.utils.get2DDist(pos, contact:getPosition().p)) then
            hit_contacts[name] = contact
        end
    end
    return hit_contacts
end

-- skynet "go live" constraint to always remain dark.
--
function V51UTIL.skynet.alwaysDarkConstraint(contact)
    return false
end

-- ============================================================================================================
--
-- RANDOM TRAFFIC MODULE
--
-- ============================================================================================================

V51UTIL.traffic = {
    rnd_tfx_info = { },
}

-- ------------------------------------------------------------------------------------------------------------
-- Traffic Support Functions
-- ------------------------------------------------------------------------------------------------------------

-- internal function to spawn traffic for the random traffic module.
--
local function SpawnTraffic(info, start_sp, is_reverse)
    if info ~= nil and info.num_total > 0 then
        local group_name = string.format("Traffic %s-%d", info.route_tmplt, info.num_total)
        info.num_total = info.num_total - 1

        -- V51UTIL.log(string.format("V51UTIL.traffic SpawnTraffic '%s', nt# %d, sp %d, rev? %s",
        --                           group_name, info.num_total, start_sp, tostring(is_reverse)))

        local tmplt = info.tmplts[math.random(1,#info.tmplts)]
        local group = mist.utils.deepCopy(mist.getCurrentGroupData(tmplt))
        local route_points = info.route_points
        assert(route_points ~= nil)

        local route = { points = { } }
        local lua = string.format("V51UTIL.traffic.arrival(\"%s\", \"%s\", true)", group_name, info.route_tmplt)
        if is_reverse then
            for i = start_sp, 1, -1 do
                route.points[#route.points+1] = mist.utils.deepCopy(route_points[i])
            end
        else
            for i = start_sp, #info.route_points, 1 do
                route.points[#route.points+1] = mist.utils.deepCopy(route_points[i])
            end
            lua = string.format("V51UTIL.traffic.arrival(\"%s\", \"%s\", false)", group_name, info.route_tmplt)
        end

        -- add tasks to the route: point[1] sets "silent" to stop "passing waypoint notifications", point[N]
        -- invokes V51UTIL.traffic.arrival() to despawn and re-spawn traffic.

        route.points[1].task.params.tasks = {
            [1] = {
                auto = false,
                enabled = true,
                id = "WrappedAction",
                number= 1,
                params = {
                    action = {
                        id = "Option",
                        params = {
                            name = 7,
                            value = true,
                        },
                    },
                },
            },
        }
        route.points[#route.points].task.params.tasks = {
            [1] = {
                auto = false,
                enabled = true,
                id = "WrappedAction",
                number = 1,
                params = {
                    action = {
                        id = "Script",
                        params = {
                            command = lua,
                        }
                    }
                }
            }
        }

        group.country = group.units[1].country
        group.name = group_name
        group.groupId = nil
        group.groupName = group_name
        group.route = route
        group.x = route.points[1].x
        group.y = route.points[1].y
        local tmpl_loc = { x = group.units[1].x, y = group.units[1].y }
        for i, unit in ipairs(group.units) do
            unit.groupId = nil
            unit.groupName = group_name
            unit.unitId = nil
            unit.unitName = string.format("%s-%d", group_name, i)
            unit.x = group.x + (group.units[i].x - tmpl_loc.x)
            unit.y = group.y + (group.units[i].y - tmpl_loc.y)
            unit.point.x = unit.x
            unit.point.y = unit.y
            if unit.category == "plane" then
                unit.payload = { chaff = 0, flares = 0, guns = 0, fuel = 45000, pylons = { } }
                unit.alt = route.points[1].alt
                unit.heading = math.atan((route.points[1].x - route.points[2].x) /
                                         (route.points[1].y - route.points[2].y))
                unit.psi = -unit.heading
            else
                unit.alt = nil
            end
        end

        mist.dynAdd(group)
    end
end

-- ------------------------------------------------------------------------------------------------------------
-- Traffic External API Functions
-- ------------------------------------------------------------------------------------------------------------

-- generate random traffic along a route from a route template. selects a random group from a template
-- list to spawn along a route. the route may be traversed in order or in reverse order and starts and
-- ends at the first and last point of the route the template specifies. templates should be late
-- activated. all steerpoints on route templates should have non-zero speed.
--
-- @param route_tmplt   route template template name
-- @param num_enroute   number of groups to initially spawn enroute, must be less than route length
-- @param num_total     total number of groups to spawn over time
-- @param tmplts        group templates for spawned groups (optional, default is route_tmplt)
-- @param balance       probability of reverse traffic on [0, 1]
--
function V51UTIL.traffic.start(route_tmplt, num_enroute, num_total, tmplts, balance)
    if V51UTIL.traffic.rnd_tfx_info[route_tmplt] ~= nil then
        return
    end
    local route_points = mist.getGroupRoute(route_tmplt, true)
    assert(route_points ~= nil)

    num_enroute = math.min(num_enroute, #route_points)
    num_total = num_total or num_enroute
    tmplts = tmplts or { route_tmplt }
    balance = balance or 0.50

    V51UTIL.traffic.rnd_tfx_info[route_tmplt] = {
        num_total = num_total,
        route_tmplt = route_tmplt,
        route_points = mist.utils.deepCopy(route_points),
        tmplts = mist.utils.deepCopy(tmplts)
    }

    local randos = mist.randomizeNumTable({ size = #route_points })
    for i = 1, num_enroute do
        local start_sp = randos[i]
        local is_reverse = false
        if math.random() < balance then
            start_sp = math.max(start_sp, 2)
            is_reverse = true
        else
            start_sp = math.min(start_sp, #route_points-1)
        end
        if start_sp == 1 then
            SpawnTraffic(V51UTIL.traffic.rnd_tfx_info[route_tmplt], start_sp, false)
        elseif start_sp == #route_points then
            SpawnTraffic(V51UTIL.traffic.rnd_tfx_info[route_tmplt], start_sp, true)
        else
            SpawnTraffic(V51UTIL.traffic.rnd_tfx_info[route_tmplt], start_sp, is_reverse)
        end
    end
end

-- stop random traffic from being generated, optionally removing all enroute traffic.
--
-- @param route_tmplt   route template for traffic
-- @param is_stop_all   true => stop running traffic (optional, default false)
--
function V51UTIL.traffic.stop(route_tmplt, is_stop_all)
    is_stop_all = is_stop_all or false
    if is_stop_all then
        V51UTIL.groups.destroyWithPrefix("Traffic " .. route_tmplt .. "-")
    end
    V51UTIL.traffic.rnd_tfx_info[route_tmplt] = nil
end

-- arrival function for random traffic. this function is called from the waypoint action we associate
-- with the route for the randomly-generated traffic. spawns another group at the start of the route
-- in the same direction of travel.
--
-- NOTE: this function should not be called by V51UTIL clients.
--
function V51UTIL.traffic.arrival(group_name, route_tmplt, is_reverse)
    -- V51UTIL.log(string.format("V51UTIL.traffic.arrival '%s', '%s', rev? %s", group_name, route_tmplt,
    --                           tostring(is_reverse)))
    V51UTIL.groups.destroy({ group_name })
    local info = V51UTIL.traffic.rnd_tfx_info[route_tmplt]
    local start_sp = 1
    if is_reverse then
        start_sp = #info.route_points
    end
    SpawnTraffic(info, start_sp, is_reverse)
end