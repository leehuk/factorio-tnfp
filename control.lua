Position = require('__stdlib__/stdlib/area/position')
Table = require('__stdlib__/stdlib/utils/table')

tnpdefines = {}

require('tnp/action')
require('tnp/event')
require('tnp/direction')
require('tnp/state_player')
require('tnp/state_train')
require('tnp/train')

-- tnp_stop_istnp()
--   Validates if a stop is assigned for TNfP
function tnp_stop_istnp(stop)
    local signals = stop.get_merged_signals(defines.circuit_connector_id.combinator_input)
    if signals then
        for _, signal in pairs(signals) do
            if signal.signal.type == "virtual" and signal.signal.name == "tnp-station" then
                return true
            end
        end
    end
    
    return false
end

-- tnp_stop_getall()
--   Returns an array of all TNfP train stops
function tnp_stop_getall(player)
    local tnp_stops = {}
    
    local entities = player.surface.find_entities_filtered({
        name = "train-stop"
    })
    for _, ent in pairs(entities) do
        if tnp_stop_istnp(ent) then
            table.insert(tnp_stops, ent)
        end
    end
    
    return tnp_stops
end

-- tnp_train_istnp()
--   Determines if a given train is one allocated to TNfP
function tnp_train_istnp(player, train)
    -- Train schedules are not entity references but string based stop names, so go the long way round.
    local tnp_trains = tnp_train_getall(player)
    if tnp_trains then
        for _, v in pairs(tnp_trains) do
            if train.id == v.id then
                return true
            end
        end
    end
    
    return false
end

-- tnp_train_getall()
--    Returns an array of all trains allocated to TNfP
function tnp_train_getall(player)
    local tnp_trains = {}
    local tnp_train_ids = {}
    
    local tnp_stops = tnp_stop_getall(player)
    for _, ent in pairs(tnp_stops) do        
        local trains = ent.get_train_stop_trains()
        if trains then
            for _, train in pairs(trains) do
                if not tnp_train_ids[train.id] then
                    table.insert(tnp_trains, train)
                    tnp_train_ids[train.id] = true
                end
            end
        end
    end
    
    return tnp_trains
end

function tnp_flytext(player, position, text)
    player.surface.create_entity({
        name = "flying-text",
        type = "flying-text",
        text = text,
        flags = { "not-on-map" },
        position = position,
        time_to_live = 250,
        speed = 0.05
    })
end

-- tnp_find_usable_stop()
--   Finds a suitable TNfP location using an existing train stop
function tnp_find_usable_stop(player)
    local settings = settings.get_player_settings(player)

    -- Order of preference is:
    --   - Any train station with a TNfP train stopped
    --   - A TNfP station without a train
    --   - A normal station without a train
    
    local valid_stops_train = {}
    local valid_stops_tnp = {}
    local valid_stops_std = {}
    
    local entities = player.surface.find_entities_filtered({
        area = Position.expand_to_area(player.position, settings['tnp-train-search-radius'].value),
        name = "train-stop"
    })
    
    for _, ent in pairs(entities) do
        local train = ent.get_stopped_train()
        if train then
            -- Disallow train stations blocked by non-TNfP trains
            if tnp_train_istnp(player, train) then
                tnp_flytext(player, ent.position, "Valid TNfP train") 
                table.insert(valid_stops_train, ent)
            else
                tnp_flytext(player, ent.position, "Ignoring")
            end
        else
            if tnp_stop_istnp(ent) then
                tnp_flytext(player, ent.position, "TNfP Train Station: Valid")
                table.insert(valid_stops_tnp, ent)
            else
                tnp_flytext(player, ent.position, "Train Station: Valid")
                table.insert(valid_stops_std, ent)
            end
        end
    end
    
    if #valid_stops_train > 0 then
        return tnp_direction_closest(player, valid_stops_train)
    elseif #valid_stops_tnp > 0 then
        return tnp_direction_closest(player, valid_stops_tnp)
    elseif #valid_stops_std > 0 then
        return tnp_direction_closest(player, valid_stops_std)
    end
    
    return nil
end

function tnp_find_usable_train(player, target)
    -- Ok, we actually need to dispatch a train
    local tnp_trains = tnp_train_getall(player)
    
    if #tnp_trains == 0 then
        player.print({"tnp_error_train_none", player.name})
        return
    end
    
    local tnp_train
    local tnp_train_distance = 0
    
    repeat
        local tnp_cand = tnp_trains[#tnp_trains]
        table.remove(tnp_trains)
        
        if not tnp_cand.front_rail or not tnp_cand.back_rail then
            break
        end
        
        distance = Position.distance(target.position, tnp_cand.front_rail.position)
        if tnp_train and distance >= tnp_train_distance then
            break
        end
        
        tnp_train = tnp_cand
        tnp_train_distance = distance
    until #tnp_trains == 0
    
    return tnp_train
end

function tnp_dispatch(player, target, train)
    local result = tnp_state_train_set(train, 'player', player)
    if not result then
        -- error: failed to dispatch
        return
    end
    
    result = tnp_state_player_set(player, 'train', train)
    result = tnp_state_train_set(train, 'station', target)
    result = tnp_state_train_set(train, 'status', tnpdefines.train.status.dispatching)
    result = tnp_state_train_setstate(train)
    
    local schedule = Table.deep_copy(train.schedule)
    local schedule_found = false
    
    -- Trains must have a schedule, as otherwise TNfP wouldnt find them
    for i, ent in ipairs(schedule.records) do
        if ent.station == target.backer_name then
            schedule.current = i
            schedule_found = true
        end
    end
    
    if not schedule_found then
        table.insert(schedule.records, {
            station = target.backer_name,
            wait_conditions = {
                {
                    type="inactivity",
                    compare_type = "or",
                    ticks = 3600
                }
            }
        })
        
        schedule.current = #schedule.records
    end

    tnp_train_schedule_enact(train, schedule)
    if train.manual_mode then
        train.manual_mode = false
    end
    
    player.print({"tnp_train_called", player.name, target.backer_name})
end

function tnp_handle_arrival(player, train)
    tnp_state_train_set(train, 'status', tnpdefines.train.status.arrived)
    
    local settings = settings.get_player_settings(player)
    
    -- If we're switching the train to manual mode, we can safely restore its original schedule.
    if settings['tnp-train-arrival-behaviour'].value == "manual" then
        train.manual_mode = true
        tnp_train_schedule_restore(train)
    end
end

function tnp_handle_completion(player, train)
    local status = tnp_state_train_get(train, 'status')
    
    if not status then
        return
    end
    
    -- Player has boarded the train whilst we're dispatching -- treat that as an arrival.
    if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
        tnp_handle_arrival(player, train)
    end

    -- Delivery is complete
    tnp_action_cancel(player, train, false)
end

function tnp_handle_player_vehicle(event)
    -- Dont track entering non-train vehicles
    if not event.entity.train then
        return
    end
    
    -- Entering a vehicle
    if event.entity then
        local player = game.players[event.player_index]
        local train = tnp_state_player_get(player, 'train')
        
        -- Unrelated to TNfP
        if not train then
            return
        end
        
        -- Player has successfully boarded their TNfP Train
        if train.id == event.entity.train.id then
            player.print("handling completion")
            tnp_handle_completion(player, train)
        end
    end
end

function tnp_handle_train_state(event)
    local player = tnp_state_train_get(event.train, 'player')
    local status = tnp_state_train_get(event.train, 'status')
    
    -- A train we're not tracking
    if not player or not status then
        return
    end
    
    if event.train.state == defines.train_state.on_the_path then
        -- TNfP Train is on the move
        if status == tnpdefines.train.status.dispatching then
            -- This was a train awaiting dispatch
            tnp_state_train_set(event.train, 'status', tnpdefines.train.status.dispatched)
            tnp_flytext(player, player.position, "TNfP Train: Dispatched")
        elseif status == tnpdefines.train.status.dispatched then
            -- This train had stopped for some reason.
            tnp_flytext(player, player.position, "TNfP Train: Proceeding")
        end
        
        -- elseif event.train.state == defines.train_state.path_lost then
        -- Train has lost its path.  Await defines.train_state.no_path
        -- elseif event.train.state == defines.train_state.no_schedule then
        -- Train has no schedule.  We'll handle this via the on_schedule_changed event    
        
    elseif event.train.state == defines.train_state.no_path then
        -- Train has no path.
        -- If we're actively dispatching the train, we need to cancel it and restore its original schedule.
        if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
            tnp_action_cancel(player, event.train, true)
            tnp_flytext(player, player.position, "TNfP Train Cancelled: No path to destination")
        end
        -- elseif event.train.state == defines.train_state.arrive_signal
        -- Train has arrived at a signal.
        
    elseif event.train.state == defines.train_state.wait_signal then
        -- Train is now held at signals
        tnp_flytext(player, player.position, "TNfP Train: Held at signals")
        
        -- elseif event.train.state == defines.train_state.arrive_station then
        -- Train is arriving at a station, await its actual arrival
        
    elseif event.train.state == defines.train_state.wait_station then
        -- Train has arrived at a station
        -- If we're dispatching this train to this station, we now need to process its arrival.
        local station = tnp_state_train_get(event.train, 'station')
        local train = station.get_stopped_train()
        
        if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
            -- OK.  The trains arrived at a different station than the one we expected.  Lets just cancel the request.
            if not train then
                tnp_action_cancel(player, event.train, true)
                tnp_flytext(player, player.position, "TNfP Train Cancelled: Arrived at different station (?)")
                return
            end
            
            tnp_flytext(player, player.position, "TNfP Train: Arrived")
            tnp_handle_arrival(player, event.train)
        end
        
    elseif event.train.state == defines.train_state.manual_control_stop then
        -- Train has been switched to manual control
        -- If we're dispatching the train, we need to cancel the request and restore its original schedule
        if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
            tnp_action_cancel(player, event.train, true)
            tnp_flytext(player, player.position, "TNfP Train Cancelled: Train switched to manual mode")
        end
        
        -- elseif event.train.state == defines.train_state.manual_control then
        -- Train is now in manual control.
        
    end
end

-- Event Handling
-----------------
-- Player Events
script.on_event(defines.events.on_player_driving_changed_state, tnp_handle_player_vehicle)
--script.on_event(defines.events.on_player_died, tnp_handle_player_exit)
--script.on_event(defines.events.on_player_kicked, tnp_handle_player_exit)
--script.on_event(defines.events.on_player_left_game, tnp_handle_player_exit)

-- Shortcut Events
script.on_event(defines.events.on_lua_shortcut, tnp_handle_shortcut)

-- Train Events
script.on_event(defines.events.on_train_changed_state, tnp_handle_train_state)
script.on_event(defines.events.on_train_schedule_changed, tnp_handle_train_schedulechange)

-- Input Handling
script.on_event("tnp-handle-request", tnp_handle_request)