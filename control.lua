tnpdefines = {}

require('util')
require('tnp/action')
require('tnp/devent')
require('tnp/draw')
require('tnp/dynamicstop')
require('tnp/event')
require('tnp/direction')
require('tnp/gui')
require('tnp/math')
require('tnp/message')
require('tnp/request')
require('tnp/state_dynamicstop')
require('tnp/state_gui')
require('tnp/state_ltnstop')
require('tnp/state_player')
require('tnp/state_stationpins')
require('tnp/state_train')
require('tnp/stop')
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
script.on_event(defines.events.on_gui_checked_state_changed, tnp_handle_gui_check)
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
script.on_event("tnp-handle-request", tnp_handle_input)
script.on_event("tnp-handle-train-manual", tnp_handle_input)

-- LTN Handling
script.on_init(function()
    if remote.interfaces["logistic-train-network"] then
        local ltn_stops_updated_event = remote.call("logistic-train-network", "on_stops_updated")
        script.on_event(ltn_stops_updated_event, tnp_handle_ltn_stops)
    end

    devent_populate()

    global.dynamicstop_data = global.dynamicstop_data or {}
    global.gui_data = global.gui_data or {}
    global.ltnstop_data = global.ltnstop_data or {}
    global.player_data = global.player_data or {}
    global.stationpins_data = global.stationpins_data or {}
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
    if not event["mod_changes"] or not event["mod_changes"]["TrainNetworkForPlayers"] then
        return
    end

    local old_version = event["mod_changes"]["TrainNetworkForPlayers"]["old_version"] or "0.0.0"
    local oldv = util.split(old_version, "%.")
    local newv = util.split(event["mod_changes"]["TrainNetworkForPlayers"]["new_version"], "%.")

    -- Old version is < 0.9.0
    if tonumber(oldv[1]) <= 0 and tonumber(oldv[2]) < 9 then
        devent_populate()

        global.dynamicstop_data = global.dynamicstop_data or {}
        global.gui_data = global.gui_data or {}
        global.ltnstop_data = global.ltnstop_data or {}
        global.player_data = global.player_data or {}
        global.train_data = global.train_data or {}
        global.stationpins_data = global.stationpins_data or {}
    end
end)
