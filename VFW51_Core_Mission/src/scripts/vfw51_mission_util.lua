-- ************************************************************************************************************
--
-- vfw51_mission_util.lua: Mission utilities
--
-- Useful utility functions for mission designers. This script requires MOOSE and mist.
--
-- v6-10-5, 16-Apr-23:
--   - tot target info supports fn_hit, fn_hit_once for callback on tot target hits
--
-- ************************************************************************************************************

env.info("*** Loading Mission Script: vfw51_mission_util.lua")

V51UTIL = {
    debugLogging = false
}

-- ============================================================================================================
--
-- CORE UTILITIES
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
        V51UTIL.log("tx " .. path .. " in zone " .. fromName)
        point = trigger.misc.getZone(fromName).point
    elseif GROUP:FindByName(fromName) ~= nil then
        V51UTIL.log("tx " .. path .. " from group " .. fromName)
        point = GROUP:FindByName(fromName):GetPositionVec3()
    else
        V51UTIL.log("tx " .. path .. " from group " .. fromName .. " NOT FOUND")
    end
    trigger.action.radioTransmission(path, point, modulation, false, frequency, 250)
end

-- remove a static randomly with probability p_remove on [0, 100]
--
function V51UTIL.removeStaticRandomly(static, p_remove, event)
    if event == nil then
        event = false
    end
    if math.random(1, 100) >= p_remove then
        V51UTIL.log("V51UTIL.removeStaticRandomly removed '" .. static .. "'")
        STATIC:FindByName(static):Destroy(event)
    end
end

-- TODO
--
function V51UTIL.smokeInZone(name, type, density)
    V51UTIL.log("V51UTIL.smokeInZone " .. name)
    local smokePt = trigger.misc.getZone(name).point
    smokePt.y = land.getHeight({ x = smokePt.x, y = smokePt.z })  -- compensate for ground level
    trigger.action.effectSmokeBig(smokePt, type, density)
end

-- trigger an explosion at a unit.
--
function V51UTIL.explodeUnit(name, size, dt)
    V51UTIL.log("V51UTIL.explodeUnit " .. name)
    UNIT:FindByName(name):Explode(size, dt)
end

-- ============================================================================================================
--
-- GROUP MODULE
--
-- ============================================================================================================

V51UTIL.groups = { }

-- activate a set of groups after a specified time.
--
-- @param groups        table containing names of groups to activate
-- @param dt            delay (s) to activation (default 0)
--
function V51UTIL.groups.activate(groups, dt)
    V51UTIL.log("activateGroups (dt " .. tostring(dt) .. ") " .. mist.utils.basicSerialize(groups))
    for _, group in pairs(groups) do
        local group_obj = GROUP:FindByName(group)
        if group_obj == nil then
            V51UTIL.log("ERROR: activateGroups got bogus group '" .. group .. "'")
        else
            group_obj:Activate(dt)
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
    if dt == nil then
        dt = 0
    end

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
            V51UTIL.activateGroups(slots[i], i * dt)
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
    if dt == nil then
        dt = 0
    end
    if n > m then
        n = m
    end

    local permute = mist.randomizeNumTable({ size = m })
    for i = 1,n,1 do
        local group_name = group_prefix .. permute[i]
        V51UTIL.log("V51UTIL.groups.activateRandom activated '" .. group_name .. "'")
        GROUP:FindByName(group_name):Activate(dt)
    end
end

-- destroy groups from a table of group names.
--
function V51UTIL.groups.destroy(groups, dt)
    if dt == nil then
        dt = 0
    end

    V51UTIL.log("V51UTIL.groups.destroy(dt=" .. tostring(dt) .. ") " .. mist.utils.basicSerialize(groups))
    for _, group in pairs(groups) do
        local groupObj = GROUP:FindByName(group)
        if groupObj == nil then
            V51UTIL.log("ERROR: V51UTIL.groups.destroy got bad group '" .. group .. "'")
        else
            groupObj:Destroy(false, dt)
        end
    end
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

        V51UTIL.log("TTS [" .. V51UTIL.tts.voiceMap[voice_key] .. "]: '" .. text .. "' on " .. tostring(freq))
        q:NewTransmission(text, STTS.getSpeechTime(text, 0.95), msrs, delay, interval)

    else
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
        for tgt_name, tgt_info in pairs(grp_info.tgt_info) do
            if tgt_info.t_hit == 0 then
                is_all_hit = false
                tgt_info.is_dead = false
            elseif tgt_info.max_life > 0 and tgt_info.max_life < GetRelativeLifeForUnit(tgt_name) then
                is_all_dead = false
                tgt_info.is_dead = false
            else
                tgt_info.is_dead = true
            end
            V51UTIL.log("  " .. tgt_name .. ": dead=" .. tostring(tgt_info.is_dead) ..
                        ", hit=" .. string.format("%.1f", tgt_info.t_hit) ..
                        ", life=" .. string.format("%.1f", GetRelativeLifeForUnit(tgt_name)))
        end
        if grp_info.fn_bda then
            mist.scheduleFunction(grp_info.fn_bda, { grp_info.tgt_info, is_all_hit, is_all_dead },
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
                V51UTIL.log("V51UTIL.tot onEvent() removes '" .. grp_name .. "', window has closed")
                V51UTIL.tot.groups[grp_name] = nil
            end
            if not is_1st_hit_prev and grp_info.is_1st_hit then
                V51UTIL.log("attack window closes at " .. t_hit + grp_info.dt_window)
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
-- @param fn_bda           bda function, signature fn(tgt_info, is_all_hit, is_all_dead)
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
    if not V51UTIL.tot.isEventHandlerAdded then
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
    -- the convoy should be stopped. nil indicates the convoy is no longer running.
    --
    convoyHalted = { },

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
        local action = "IDLE"

        if is_threat and ads_v == 0 and def_v ~= 0 and V51UTIL.convoy.convoyHalted[ads_group] == false then
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
        end
        if tout ~= 0 and cur_time + dt > tout then
            dt = tout - cur_time
        end

        V51UTIL.log("V51UTIL.convoy.CoordinateConvoys(tout=" .. mist.utils.round(tout) .. ", one_time=" ..
                    tostring(one_time) .. ") " .. action ..
                    " / halted=" .. tostring(V51UTIL.convoy.convoyHalted[ads_group]) ..
                    ", tout=" .. mist.utils.round(tout) .. ", is_threat=" .. tostring(is_threat) ..
                    ", ads_v=" .. tostring(ads_v) .. ", def_v=" .. tostring(def_v) ..
                    ", dt=" .. mist.utils.round(dt))

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
    if eng_zone == nil then
        eng_zone = SkynetIADSAbstractRadarElement.GO_LIVE_WHEN_IN_SEARCH_RANGE
    end
    if pd_groups == nil then
        pd_groups = { }
    end
    for _, sam_group in pairs(sam_groups) do
        local sam = iads:getSAMSiteByGroupName(sam_group)
        sam:setActAsEW(is_ewr)
        sam:setEngagementZone(eng_zone)
        for _, pd_group in pairs(pd_groups) do
            local pd = iads:getSAMSiteByGroupName(pd_group)
            sam:addPointDefence(pd)
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