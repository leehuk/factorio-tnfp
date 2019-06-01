-- tnp_action_request_cancel()
--   Completes a tnp request and removes all state tracking
function tnp_action_request_cancel(player, train, message)
    if player then
        if player.valid then
            player.set_shortcut_toggled('tnp-handle-request', false)

            if message then
                tnp_message(tnpdefines.loglevel.standard, player, message)
            end
        end

        tnp_state_player_delete(player, 'train')
    end

    if train then
        tnp_state_train_delete(train, false)
    end
end

-- tnp_action_request_board()
--  Handles actions from a player boarding a requested tnp train.
function tnp_action_request_board(player, train)
    local config = settings.get_player_settings(player)
    local status = tnp_state_train_get(train, 'status')

    -- Player has boarded the train whilst we're dispatching -- treat that as an arrival.
    if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
        tnp_action_train_arrival(player, train)
    end

    if config['tnp-train-boarding-behaviour'].value == 'manual' then
        -- Force the train into manual mode, request is then fully complete.
        tnp_train_enact(train, true, nil, true, nil)
        tnp_action_request_cancel(player, train, nil)
    elseif config['tnp-train-boarding-behaviour'].value == 'stationselect' then
        -- Force the train into manual mode then display station select
        tnp_train_enact(train, true, nil, true, nil)
        tnp_gui_stationlist(player, train)
    end
end


-- tnp_action_request_create()
--   Attempts to action a request for a tnp train
function tnp_action_request_create(player)
    local target = tnp_stop_find(player)
    if target then
        local train = target.get_stopped_train()
        if train and train.valid then
            tnp_action_train_assign(player, target, train)
            return
        end

        local train = tnp_train_find(player, target)
        if not train then
            tnp_message(tnpdefines.loglevel.core, player, {"tnp_train_invalid"})
            return
        end

        tnp_action_train_dispatch(player, target, train)
    end
end

-- tnp_action_request_status()
--   Shows the status of a tnp request
function tnp_action_request_status(player, train)
end

-- tnp_action_stationselect_cancel()
--   Actions the stationselect dialog being cancelled
function tnp_action_stationselect_cancel(player)
    local train = tnp_state_player_get(player, 'train')

    tnp_gui_stationlist_close(player)

    -- We're still tracking a request at this point we need to cancel, though theres no
    -- schedule to amend.
    tnp_action_request_cancel(player, train, nil)
end

-- tnp_action_stationselect_redispatch()
--   Actions a stationselect request to redispatch
function tnp_action_stationselect_redispatch(player, gui)
    local station = tnp_state_gui_get(gui, player, 'station')
    local train = tnp_state_player_get(player, 'train')

    tnp_gui_stationlist_close(player)

    if not station or not station.valid then
        tnp_action_request_cancel(player, train, {"tnp_train_cancelled_invalidstation"})
        return
    end

    -- Lets just revalidate the player is on a valid train
    if not player.vehicle or not player.vehicle.train or not player.vehicle.train.valid then
        tnp_action_request_cancel(player, train, {"tnp_train_cancelled_invalidstate"})
    end

    tnp_action_train_redispatch(player, station, player.vehicle.train)
end

-- tnp_action_train_arrival()
--   Partially fulfils a tnp request, marking a train as successfully arrived.
function tnp_action_train_arrival(player, train)
    tnp_state_train_delete(train, 'timeout')
    tnp_state_train_set(train, 'status', tnpdefines.train.status.arrived)
end

-- tnp_action_train_rearrival()
--   Partially fulfils a tnp request, marking a train as successfully arrived after redispatch.
function tnp_action_train_rearrival(player, train)
    tnp_state_train_set(train, 'status', tnpdefines.train.status.rearrived)
end

-- tnp_action_train_assign()
--   Assigns a parked train to a player
function tnp_action_train_assign(player, target, train)
    local config = settings.get_player_settings(player)

    tnp_state_train_set(train, 'player', player)
    tnp_state_player_set(player, 'train', train)

    tnp_state_train_set(train, 'station', target)
    tnp_action_train_arrival(player, train)

    tnp_message(tnpdefines.loglevel.standard, player, {"tnp_train_waiting", target.backer_name})
end

-- tnp_action_train_dispatch()
--   Dispatches a train
function tnp_action_train_dispatch(player, target, train)
    local config = settings.get_player_settings(player)

    tnp_state_train_set(train, 'player', player)
    tnp_state_player_set(player, 'train', train)

    tnp_state_train_set(train, 'station', target)
    tnp_state_train_set(train, 'status', tnpdefines.train.status.dispatching)
    tnp_state_train_set(train, 'timeout', config['tnp-train-arrival-timeout'].value)
    tnp_train_info_save(train)

    local schedule = tnp_train_schedule_copy(train)
    local schedule_found = tnp_train_schedule_check(schedule, target.backer_name)

    if schedule_found == false then
        table.insert(schedule.records, {
            station = target.backer_name,
            wait_conditions = {
                {
                    type="time",
                    compare_type = "or",
                    ticks = config['tnp-train-boarding-timeout'].value*60
                }
            }
        })

        schedule.current = #schedule.records
    else
        schedule.current = schedule_found
    end

    tnp_train_enact(train, false, schedule, nil, false)

    tnp_message(tnpdefines.loglevel.core, player, {"tnp_train_requested", target.backer_name})
end

-- tnp_action_train_redispatch()
--   Actions an redispatch for an onward journey
function tnp_action_train_redispatch(player, target, train)
    local config = settings.get_player_settings(player)

    tnp_state_train_set(train, 'player', player)
    tnp_state_player_set(player, 'train', train)

    tnp_state_train_set(train, 'station', target)
    tnp_state_train_set(train, 'status', tnpdefines.train.status.redispatched)
    tnp_train_info_save(train)

    local schedule = tnp_train_schedule_copy(train)
    local schedule_found = tnp_train_schedule_check(schedule, target.backer_name)

    if schedule_found == false then
        table.insert(schedule.records, {
            station = target.backer_name,
            wait_conditions = {
                {
                    type="passenger_not_present",
                    compare_type = "or"
                }
            }
        })

        schedule.current = #schedule.records
    else
        schedule.current = schedule_found
    end

    tnp_train_enact(train, false, schedule, nil, false)
end

-- tnp_action_train_schedulechange()
--   Performs any checks and actions required when a trains schedule is changed.
function tnp_action_train_schedulechange(train, event_player)
    if event_player then
        -- The schedule was changed by a player, on a train we're dispatching.  We need to cancel this request
        local player = tnp_state_train_get(train, 'player')
        tnp_action_request_cancel(player, train, {"tnp_train_cancelled_schedulechange", event_player.name})
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
function tnp_action_train_statechange(train)
    local player = tnp_state_train_get(train, 'player')
    local status = tnp_state_train_get(train, 'status')

    if train.state == defines.train_state.on_the_path then
        -- TNfP Train is on the move event
        if status == tnpdefines.train.status.dispatching then
            -- This was a train awaiting dispatch
            tnp_state_train_set(train, 'status', tnpdefines.train.status.dispatched)
            tnp_message(tnpdefines.loglevel.standard, player, {"tnp_train_dispatched"})

        elseif status == tnpdefines.train.status.dispatched then
            -- This train had stopped for some reason.
            tnp_message(tnpdefines.loglevel.detailed, player, {"tnp_train_status_onway"})

        elseif status == tnpdefines.train.status.arrived then
            -- Train has now departed after arrival.  This could be a timeout, or someone has manually
            -- moved it to another station without changing the schedule.
            tnp_train_enact(train, true, nil, nil, nil)
            tnp_action_request_cancel(player, train, {"tnp_train_cancelled_left"})

        elseif status == tnpdefines.train.status.rearrived then
            -- Train has now departed after rearrival.  The passenger has either disembarked, or someone
            -- moved it to another station without changing the schedule.  Either way we just reset
            -- the schedule.
            tnp_train_enact(train, true, nil, nil, nil)
            tnp_action_request_cancel(player, train, nil)
        end

        -- elseif train.state == defines.train_state.path_lost then
        -- Train has lost its path.  Await defines.train_state.no_path
        -- elseif train.state == defines.train_state.no_schedule then
        -- Train has no schedule.  We'll handle this via the on_schedule_changed event

    elseif train.state == defines.train_state.no_path then
        -- Train has no path.
        -- If we're actively dispatching the train, we need to cancel it and restore its original schedule.
        if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
            tnp_train_enact(train, true, nil, nil, false)
            tnp_action_request_cancel(player, train, {"tnp_train_cancelled_nopath"})

        -- Train has no path, but we need to restore the schedule anyway.
        elseif status == tnpdefines.train.status.arrived then
            tnp_train_enact(train, true, nil, nil, nil)
            tnp_action_request_cancel(player, train, {"tnp_train_cancelled_timeout_boarding"})

        elseif status == tnpdefines.train.status.redispatched then
            tnp_train_enact(train, true, nil, nil, nil)
            tnp_action_request_cancel(player, train, {"tnp_train_cancelled_nopath"})
        end
        -- elseif train.state == defines.train_state.arrive_signal
        -- Train has arrived at a signal.

    elseif train.state == defines.train_state.wait_signal then
        -- Train is now held at signals
        tnp_message(tnpdefines.loglevel.detailed, player, {"tnp_train_status_heldsignal"})

        -- elseif train.state == defines.train_state.arrive_station then
        -- Train is arriving at a station, await its actual arrival

    elseif train.state == defines.train_state.wait_station then
        -- Train has arrived at a station

        if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
            -- This is an arrival to a station, after we've dispatched it.
            local station = tnp_state_train_get(train, 'station')

            -- The station we were dispatching to is no longer valid
            if not station or not station.valid then
                tnp_train_enact(train, true, nil, nil, nil)
                tnp_action_request_cancel(player, train, {"tnp_train_cancelled_invalidstation"})
                return
            end

            -- Our train has arrived at a different station.
            local station_train = station.get_stopped_train()
            if not station_train or not station_train.id == train.id then
                tnp_train_enact(train, true, nil, nil, false)
                tnp_action_request_cancel(player, train, {"tnp_train_cancelled_wrongstation"})
                return
            end

            tnp_message(tnpdefines.loglevel.standard, player, {"tnp_train_arrived"})
            tnp_action_train_arrival(player, train)

        elseif status == tnpdefines.train.status.redispatched then
            -- This was an redispatch station -- so wait for the passenger to disembark
            tnp_action_train_rearrival(player, train)
        end

    elseif train.state == defines.train_state.manual_control_stop or train.state == defines.train_state.manual_control then
        -- Train has been switched to manual control.  Handle these together, as if a train is already stopped
        -- we wont see defines.train_state.manual_control_stop.

        -- Check to see if we made this change ourselves
        local expect = tnp_state_train_get(train, 'expect_manualmode')
        if expect then
            tnp_state_train_set(train, 'expect_manualmode', false)
            return
        end

        if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched or status == tnpdefines.train.status.redispatched then
            -- If we're dispatching the train, we need to cancel the request and restore its original schedule
            tnp_train_enact(train, true, nil, nil, nil)
            tnp_action_request_cancel(player, train, {"tnp_train_cancelled_manual"})

        elseif status == tnpdefines.train.status.arrived then
            -- Train had arrived, but we still need to restore the schedule.
            tnp_train_enact(train, true, nil, nil, nil)
            tnp_action_request_cancel(player, train, {"tnp_train_cancelled_manual"})
        end
    end
end

-- tnp_action_timeout()
--   Loops through trains and applies any timeout actions for dispatched trains.
function tnp_action_timeout()
    local trains = tnp_state_train_timeout()

    if not trains or #trains == 0 then
        return
    end

    for _, train in pairs(trains) do
        local player = tnp_state_train_get(train, 'player')
        local status = tnp_state_train_get(train, 'status')

        if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
            tnp_train_enact(train, true, nil, nil, false)
            tnp_action_request_cancel(player, train, {"tnp_train_cancelled_timeout_arrival"})
        end
    end
end