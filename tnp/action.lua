-- tnp_action_request_cancel()
--   Cancels a tnp request, optionally restoring the trains original schedule
function tnp_action_request_cancel(player, train, restore_schedule)
    tnp_state_player_delete(player, false)
    
    if restore_schedule then
        tnp_train_schedule_restore(train)
    end
    
    tnp_state_train_delete(train, false)
end

-- tnp_action_request_complete()
--  Fully completes a tnp request
function tnp_action_request_complete(player, train)
    local status = tnp_state_train_get(train, 'status')
    
    if not status then
        return
    end
    
    -- Player has boarded the train whilst we're dispatching -- treat that as an arrival.
    if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
        tnp_action_train_arrival(player, train)
    end

    -- Delivery is complete
    tnp_action_request_cancel(player, train, false)
end


-- tnp_action_request_create()
--   Attempts to action a request for a tnp train
function tnp_action_request_create(player)
    local target = tnp_stop_find(player)
    if target then
        local train = target.get_stopped_train()
        if train then
            player.print({"tnp_train_waiting", player.name, target.backer_name})
            return
        end
        
        local train = tnp_train_find(player, target)
        if not train then
            player.print({"tnp_error_train_find", player.name})
            return
        end
        
        tnp_action_train_dispatch(player, target, train)
    end
end

-- tnp_action_train_arrival()
--   Fulfils a tnp request, restoring schedules and setting modes
function tnp_action_train_arrival(player, train)
    tnp_state_train_set(train, 'status', tnpdefines.train.status.arrived)
    
    local settings = settings.get_player_settings(player)
    
    -- If we're switching the train to manual mode, we can safely restore its original schedule.
    if settings['tnp-train-arrival-behaviour'].value == "manual" then
        train.manual_mode = true
        tnp_train_schedule_restore(train)
    end
end

-- tnp_action_train_dispatch()
--   Dispatches a train
function tnp_action_train_dispatch(player, target, train)
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


-- tnp_action_train_schedulechange()
--   Performs any checks and actions required when a trains schedule is changed.
function tnp_action_train_schedulechange(train, event_player)
    local player = tnp_state_train_get(train, 'player')
    local status = tnp_state_train_get(train, 'status')
    
    if event_player then
        -- The schedule was changed by a player, on a train we're dispatching.
        
        -- If we're dispatching this train, cancel the request -- but leave the schedule alone, as its changed.
        if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
            -- We were dispatching this train and its not arrived.  Leave the schedule alone as its changed, but cancel the request.
            tnp_action_request_cancel(player, train, false)
            tnp_message_flytext(player, player.position, "TNfP Train Cancelled: Schedule was changed by " .. event_player.name)
        elseif status == tnpdefines.train.status.arrived then
            -- This train already arrived at its station -- so we don't need to do anything other than cancel the pending boarding.
            tnp_action_request_cancel(player, train, false)
        end
    else
        -- This is likely a schedule change we've made.  Check if we're expecting one.
        local expect = tnp_state_train_get(train, 'expect_schedulechange')
        if expect then
            tnp_state_train_set(train, 'expect_schedulechange', false)
            return
        end
        
        -- This is either another mod changing schedules of a train we're using, or our tracking is off.
        -- For now, do nothing -- though we should be able to verify its still going where we expect it to.
    end
end
-- tnp_action_train_statechange()
--   Performs any checks and actions required when a trains state is changed.
function tnp_action_train_statechange(train, event_player)
    local player = tnp_state_train_get(train, 'player')
    local status = tnp_state_train_get(train, 'status')

    if train.state == defines.train_state.on_the_path then
        -- TNfP Train is on the moveevent
        if status == tnpdefines.train.status.dispatching then
            -- This was a train awaiting dispatch
            tnp_state_train_set(train, 'status', tnpdefines.train.status.dispatched)
            tnp_message_flytext(player, player.position, "TNfP Train: Dispatched")
        elseif status == tnpdefines.train.status.dispatched then
            -- This train had stopped for some reason.
            tnp_message_flytext(player, player.position, "TNfP Train: Proceeding")
        end
        
        -- elseif train.state == defines.train_state.path_lost then
        -- Train has lost its path.  Await defines.train_state.no_path
        -- elseif train.state == defines.train_state.no_schedule then
        -- Train has no schedule.  We'll handle this via the on_schedule_changed event    
        
    elseif train.state == defines.train_state.no_path then
        -- Train has no path.
        -- If we're actively dispatching the train, we need to cancel it and restore its original schedule.
        if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
            tnp_action_request_cancel(player, train, true)
            tnp_message_flytext(player, player.position, "TNfP Train Cancelled: No path to destination")
        end
        -- elseif train.state == defines.train_state.arrive_signal
        -- Train has arrived at a signal.
        
    elseif train.state == defines.train_state.wait_signal then
        -- Train is now held at signals
        tnp_message_flytext(player, player.position, "TNfP Train: Held at signals")
        
        -- elseif train.state == defines.train_state.arrive_station then
        -- Train is arriving at a station, await its actual arrival
        
    elseif train.state == defines.train_state.wait_station then
        -- Train has arrived at a station
        -- If we're dispatching this train to this station, we now need to process its arrival.
        local station = tnp_state_train_get(train, 'station')
        local train = station.get_stopped_train()
        
        if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
            -- OK.  The trains arrived at a different station than the one we expected.  Lets just cancel the request.
            if not train then
                tnp_action_request_cancel(player, train, true)
                tnp_message_flytext(player, player.position, "TNfP Train Cancelled: Arrived at different station (?)")
                return
            end
            
            tnp_message_flytext(player, player.position, "TNfP Train: Arrived")
            tnp_action_train_arrival(player, train)
        end
        
    elseif train.state == defines.train_state.manual_control_stop then
        -- Train has been switched to manual control
        -- If we're dispatching the train, we need to cancel the request and restore its original schedule
        if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
            tnp_action_request_cancel(player, train, true)
            tnp_message_flytext(player, player.position, "TNfP Train Cancelled: Train switched to manual mode")
        end
        
        -- elseif train.state == defines.train_state.manual_control then
        -- Train is now in manual control.
    end
end