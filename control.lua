tnpdefines = {}

require('util')
require('tnp/action')
require('tnp/action_trainstate')
require('tnp/devent')
require('tnp/draw')
require('tnp/event')
require('tnp/direction')
require('tnp/gui')
require('tnp/math')
require('tnp/message')
require('tnp/misc')
require('tnp/request')
require('tnp/state_gui')
require('tnp/state_ltnstop')
require('tnp/state_player')
require('tnp/state_playerprefs')
require('tnp/state_train')
require('tnp/stop')
require('tnp/supplytrain')
require('tnp/train')

-- Event Handling
-----------------

-- Timer Events
script.on_nth_tick(60, tnp_handle_tick_timeout)
script.on_nth_tick(300, tnp_handle_tick_prune)

-- Player Events
script.on_event(defines.events.on_player_driving_changed_state, tnp_handle_player_vehicle)
script.on_event(defines.events.on_player_dropped_item, tnp_handle_player_droppeditem)
--script.on_event(defines.events.on_player_died, tnp_handle_player_exit)
--script.on_event(defines.events.on_player_kicked, tnp_handle_player_exit)
--script.on_event(defines.events.on_player_left_game, tnp_handle_player_exit)

-- GUI Events
script.on_event(defines.events.on_gui_click, tnp_handle_gui_click)
script.on_event(defines.events.on_gui_text_changed, tnp_handle_gui_text)
script.on_event(defines.events.on_gui_confirmed, tnp_handle_gui_confirmed)

-- Shortcut Events
script.on_event(defines.events.on_lua_shortcut, tnp_handle_shortcut)

-- Train Events
script.on_event(defines.events.on_train_changed_state, tnp_handle_train_statechange)
script.on_event(defines.events.on_train_schedule_changed, tnp_handle_train_schedulechange)

-- Selection Tool Events
script.on_event(defines.events.on_player_alt_selected_area, tnp_handle_selectiontool_alt)
script.on_event(defines.events.on_player_selected_area, tnp_handle_selectiontool)

-- Input Handling
script.on_event("tnp-handle-railtool", tnp_handle_input)
script.on_event("tnp-handle-railtool-map", tnp_handle_input)
script.on_event("tnp-handle-railtool-supply", tnp_handle_input)
script.on_event("tnp-handle-railtool-supply-next", tnp_handle_input)
script.on_event("tnp-handle-request", tnp_handle_input)
script.on_event("tnp-handle-train-manual", tnp_handle_input)

-- LTN Handling
script.on_init(function()
    if remote.interfaces["logistic-train-network"] then
        local ltn_stops_updated_event = remote.call("logistic-train-network", "on_stops_updated")
        script.on_event(ltn_stops_updated_event, tnp_handle_ltn_stops)
    end

    devent_populate()

    global.gui_data = global.gui_data or {}
    global.ltnstop_data = global.ltnstop_data or {}
    global.player_data = global.player_data or {}
    global.playerprefs_data = global.playerprefs_data or {}
    global.train_data = global.train_data or {}
end)

script.on_load(function()
    devent_activate()

    if remote.interfaces["logistic-train-network"] then
        local ltn_stops_updated_event = remote.call("logistic-train-network", "on_stops_updated")
        script.on_event(ltn_stops_updated_event, tnp_handle_ltn_stops)
    end
end)

script.on_configuration_changed(function(event)
    -- The dynamic event framework shadows entries from defines.events and these need to be
    -- recalculated whenever factorio upgrades
    devent_populate()

    if not event["mod_changes"] or not event["mod_changes"]["TrainNetworkForPlayers"] then
        return
    end

    local old_version = event["mod_changes"]["TrainNetworkForPlayers"]["old_version"] or "0.0.0"
    local oldv = util.split(old_version, "%.")
    local newv = util.split(event["mod_changes"]["TrainNetworkForPlayers"]["new_version"], "%.")

    -- Old version is < 0.9.0
    if tonumber(oldv[1]) <= 0 and tonumber(oldv[2]) < 9 then
        devent_populate()

        global.gui_data = global.gui_data or {}
        global.ltnstop_data = global.ltnstop_data or {}
        global.player_data = global.player_data or {}
        global.train_data = global.train_data or {}
    end

    -- Old version is < 0.9.1
    if tonumber(oldv[1]) <= 0 and (tonumber(oldv[2]) < 9 or (tonumber(oldv[2]) == 9 and tonumber(oldv[3]) < 1)) then
        -- Dynamic stops moved from being per-player tracked to per-train tracked.  Handle the
        -- cleanup and cancel any in-flight requests.
        for id, data in pairs(global.player_data) do
            if data and data.dynamicstop then
                if data.train and data.train.valid then
                    tnp_train_enact(data.train, true, nil, nil, nil)
                end
                tnp_request_cancel(data.player, data.train, nil)
            end
        end
    end

    -- Old version is < 0.9.2
    if tonumber(oldv[1]) <= 0 and (tonumber(oldv[2]) < 9 or (tonumber(oldv[2]) == 9 and tonumber(oldv[3]) < 2)) then
        -- Populate dynamic event for on_gui_switch_state_changed
        devent_populate()

        -- Station pins moved from global.stationpins_data to global.playerprefs_data.  Migrate all data as-is
        global.playerprefs_data = {}

        if global.stationpins_data then
            for id, ent in pairs(global.stationpins_data) do
                global.playerprefs_data[id] = {}
                global.playerprefs_data[id]['player'] = ent.player
                global.playerprefs_data[id]['stationpins'] = {}

                if ent.stations then
                    for sid, station in pairs(ent.stations) do
                        global.playerprefs_data[id]['stationpins'][sid] = station
                    end
                end
            end

            -- Force a prune to clear out any invalid data
            _tnp_state_playerprefs_prune()

            global.stationpins_data = nil
        end
    end

    -- Old version is < 0.11.1
    if tonumber(oldv[1]) <= 0 and (tonumber(oldv[2]) < 11 or (tonumber(oldv[2]) == 11 and tonumber(oldv[3]) < 1)) then
        if global.dynamicstop_data then
            for id, data in pairs(global.dynamicstop_data) do
                if data.dynamicstop and data.dynamicstop.valid then
                    data.dynamicstop.destroy()
                end

                if data.altstop and data.altstop.valid then
                    data.altstop.destroy()
                end
            end

            global.dynamicstop_data = nil
        end
    end
end)
