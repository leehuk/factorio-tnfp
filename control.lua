Position = require('__stdlib__/stdlib/area/position')
Table = require('__stdlib__/stdlib/utils/table')

ptndefines = {}

require('ptnlib/action')
require('ptnlib/event')
require('ptnlib/direction')
require('ptnlib/state_player')
require('ptnlib/state_train')
require('ptnlib/train')

-- ptnlib_stop_isptn()
--   Validates if a stop is assigned for PTN
function ptnlib_stop_isptn(stop)
    local signals = stop.get_merged_signals(defines.circuit_connector_id.combinator_input)
    if signals then
        for _, signal in pairs(signals) do
            if signal.signal.type == "virtual" and signal.signal.name == "ptn-station" then
                return true
            end
        end
    end
    
    return false
end

-- ptnlib_stop_getall()
--   Returns an array of all PTN train stops
function ptnlib_stop_getall(player)
    local ptn_stops = {}
    
    local entities = player.surface.find_entities_filtered({
        name = "train-stop"
    })
    for _, ent in pairs(entities) do
        if ptnlib_stop_isptn(ent) then
            table.insert(ptn_stops, ent)
        end
    end
    
    return ptn_stops
end

-- ptnlib_train_isptn()
--   Determines if a given train is one allocated to PTN
function ptnlib_train_isptn(player, train)
    -- Train schedules are not entity references but string based stop names, so go the long way round.
    local ptn_trains = ptnlib_train_getall(player)
    if ptn_trains then
        for _, v in pairs(ptn_trains) do
            if train.id == v.id then
                return true
            end
        end
    end
    
    return false
end

-- ptnlib_train_getall()
--    Returns an array of all trains allocated to PTN
function ptnlib_train_getall(player)
    local ptn_trains = {}
    local ptn_train_ids = {}
    
    local ptn_stops = ptnlib_stop_getall(player)
    for _, ent in pairs(ptn_stops) do        
        local trains = ent.get_train_stop_trains()
        if trains then
            for _, train in pairs(trains) do
                if not ptn_train_ids[train.id] then
                    table.insert(ptn_trains, train)
                    ptn_train_ids[train.id] = true
                end
            end
        end
    end
    
    return ptn_trains
end

function ptnlib_flytext(player, position, text)
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

-- ptn_find_usable_stop()
--   Finds a suitable PTN location using an existing train stop
function ptn_find_usable_stop(player)
    local settings = settings.get_player_settings(player)

    -- Order of preference is:
    --   - Any train station with a PTN train stopped
    --   - A PTN station without a train
    --   - A normal station without a train
    
    local valid_stops_train = {}
    local valid_stops_ptn = {}
    local valid_stops_std = {}
    
    local entities = player.surface.find_entities_filtered({
        area = Position.expand_to_area(player.position, settings['ptn-train-search-radius'].value),
        name = "train-stop"
    })
    
    for _, ent in pairs(entities) do
        local train = ent.get_stopped_train()
        if train then
            -- Disallow train stations blocked by non-PTN trains
            if ptnlib_train_isptn(player, train) then
                ptnlib_flytext(player, ent.position, "Valid PTN train") 
                table.insert(valid_stops_train, ent)
            else
                ptnlib_flytext(player, ent.position, "Ignoring")
            end
        else
            if ptnlib_stop_isptn(ent) then
                ptnlib_flytext(player, ent.position, "PTN Train Station: Valid")
                table.insert(valid_stops_ptn, ent)
            else
                ptnlib_flytext(player, ent.position, "Train Station: Valid")
                table.insert(valid_stops_std, ent)
            end
        end
    end
    
    if #valid_stops_train > 0 then
        return ptnlib_direction_closest(player, valid_stops_train)
    elseif #valid_stops_ptn > 0 then
        return ptnlib_direction_closest(player, valid_stops_ptn)
    elseif #valid_stops_std > 0 then
        return ptnlib_direction_closest(player, valid_stops_std)
    end
    
    return nil
end

function ptn_find_usable_train(player, target)
    -- Ok, we actually need to dispatch a train
    local ptn_trains = ptnlib_train_getall(player)
    
    if #ptn_trains == 0 then
        player.print({"ptn_error_train_none", player.name})
        return
    end
    
    local ptn_train
    local ptn_train_distance = 0
    
    repeat
        local ptn_cand = ptn_trains[#ptn_trains]
        table.remove(ptn_trains)
        
        if not ptn_cand.front_rail or not ptn_cand.back_rail then
            break
        end
        
        distance = Position.distance(target.position, ptn_cand.front_rail.position)
        if ptn_train and distance >= ptn_train_distance then
            break
        end
        
        ptn_train = ptn_cand
        ptn_train_distance = distance
    until #ptn_trains == 0
    
    return ptn_train
end

function ptn_dispatch(player, target, train)
    local result = ptnlib_state_train_set(train, 'player', player)
    if not result then
        -- error: failed to dispatch
        return
    end
    
    result = ptnlib_state_player_set(player, 'train', train)
    result = ptnlib_state_train_set(train, 'station', target)
    result = ptnlib_state_train_set(train, 'status', ptndefines.train.status.dispatching)
    result = ptnlib_state_train_setstate(train)
    
    local schedule = Table.deep_copy(train.schedule)
    local schedule_found = false
    
    -- Trains must have a schedule, as otherwise PTN wouldnt find them
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

    ptn_train_schedule_enact(train, schedule)
    if train.manual_mode then
        train.manual_mode = false
    end
    
    player.print({"ptn_train_called", player.name, target.backer_name})
end

function ptn_handle_arrival(player, train)
    ptnlib_state_train_set(train, 'status', ptndefines.train.status.arrived)
    
    local settings = settings.get_player_settings(player)
    
    -- If we're switching the train to manual mode, we can safely restore its original schedule.
    if settings['ptn-train-arrival-behaviour'].value == "manual" then
        train.manual_mode = true
        ptn_train_schedule_restore(train)
    end
end

function ptn_handle_completion(player, train)
    local status = ptnlib_state_train_get(train, 'status')
    
    if not status then
        return
    end
    
    -- Player has boarded the train whilst we're dispatching -- treat that as an arrival.
    if status == ptndefines.train.status.dispatching or status == ptndefines.train.status.dispatched then
        ptn_handle_arrival(player, train)
    end

    -- Delivery is complete
    ptnlib_action_cancel(player, train, false)
end

function ptn_handle_player_vehicle(event)
    -- Dont track entering non-train vehicles
    if not event.entity.train then
        return
    end
    
    -- Entering a vehicle
    if event.entity then
        local player = game.players[event.player_index]
        local train = ptnlib_state_player_get(player, 'train')
        
        -- Unrelated to PTN
        if not train then
            return
        end
        
        -- Player has successfully boarded their PTN Train
        if train.id == event.entity.train.id then
            player.print("handling completion")
            ptn_handle_completion(player, train)
        end
    end
end

function ptn_handle_train_state(event)
    local player = ptnlib_state_train_get(event.train, 'player')
    local status = ptnlib_state_train_get(event.train, 'status')
    
    -- A train we're not tracking
    if not player or not status then
        return
    end
    
    if event.train.state == defines.train_state.on_the_path then
        -- PTN Train is on the move
        if status == ptndefines.train.status.dispatching then
            -- This was a train awaiting dispatch
            ptnlib_state_train_set(event.train, 'status', ptndefines.train.status.dispatched)
            ptnlib_flytext(player, player.position, "PTN Train: Dispatched")
        elseif status == ptndefines.train.status.dispatched then
            -- This train had stopped for some reason.
            ptnlib_flytext(player, player.position, "PTN Train: Proceeding")
        end
        
        -- elseif event.train.state == defines.train_state.path_lost then
        -- Train has lost its path.  Await defines.train_state.no_path
        -- elseif event.train.state == defines.train_state.no_schedule then
        -- Train has no schedule.  We'll handle this via the on_schedule_changed event    
        
    elseif event.train.state == defines.train_state.no_path then
        -- Train has no path.
        -- If we're actively dispatching the train, we need to cancel it and restore its original schedule.
        if status == ptndefines.train.status.dispatching or status == ptndefines.train.status.dispatched then
            ptnlib_action_cancel(player, event.train, true)
            ptnlib_flytext(player, player.position, "PTN Train Cancelled: No path to destination")
        end
        -- elseif event.train.state == defines.train_state.arrive_signal
        -- Train has arrived at a signal.
        
    elseif event.train.state == defines.train_state.wait_signal then
        -- Train is now held at signals
        ptnlib_flytext(player, player.position, "PTN Train: Held at signals")
        
        -- elseif event.train.state == defines.train_state.arrive_station then
        -- Train is arriving at a station, await its actual arrival
        
    elseif event.train.state == defines.train_state.wait_station then
        -- Train has arrived at a station
        -- If we're dispatching this train to this station, we now need to process its arrival.
        local station = ptnlib_state_train_get(event.train, 'station')
        local train = station.get_stopped_train()
        
        if status == ptndefines.train.status.dispatching or status == ptndefines.train.status.dispatched then
            -- OK.  The trains arrived at a different station than the one we expected.  Lets just cancel the request.
            if not train then
                ptnlib_action_cancel(player, event.train, true)
                ptnlib_flytext(player, player.position, "PTN Train Cancelled: Arrived at different station (?)")
                return
            end
            
            ptnlib_flytext(player, player.position, "PTN Train: Arrived")
            ptn_handle_arrival(player, event.train)
        end
        
    elseif event.train.state == defines.train_state.manual_control_stop then
        -- Train has been switched to manual control
        -- If we're dispatching the train, we need to cancel the request and restore its original schedule
        if status == ptndefines.train.status.dispatching or status == ptndefines.train.status.dispatched then
            ptnlib_action_cancel(player, event.train, true)
            ptnlib_flytext(player, player.position, "PTN Train Cancelled: Train switched to manual mode")
        end
        
        -- elseif event.train.state == defines.train_state.manual_control then
        -- Train is now in manual control.
        
    end
end

-- Event Handling
-----------------
-- Player Events
script.on_event(defines.events.on_player_driving_changed_state, ptn_handle_player_vehicle)
--script.on_event(defines.events.on_player_died, ptn_handle_player_exit)
--script.on_event(defines.events.on_player_kicked, ptn_handle_player_exit)
--script.on_event(defines.events.on_player_left_game, ptn_handle_player_exit)

-- Shortcut Events
script.on_event(defines.events.on_lua_shortcut, ptn_handle_shortcut)

-- Train Events
script.on_event(defines.events.on_train_changed_state, ptn_handle_train_state)
-- script.on_event(defines.events.on_player_driving_changed_state, ptn_handle_player_vehicle)
-- script.on_event(defines.events.on_train_schedule_changed, ptn_handle_train_schedule)

-- Input Handling
script.on_event("ptn-handle-request", ptn_handle_request)