-- tnp_action_trainstate()
--   Handles any required actions from a train changing driving state
function tnp_action_trainstate(player, train)
    local config = settings.get_player_settings(player)

    local status = tnp_state_train_get(train, 'status')
    local supplymode = tnp_state_train_get(train, 'supplymode')

    if train.state == defines.train_state.on_the_path then
        -- TNfP Train is on the move event
        if status == tnpdefines.train.status.dispatching then
            -- This was a train awaiting dispatch
            tnp_state_train_set(train, 'status', tnpdefines.train.status.dispatched)
            tnp_message(tnpdefines.loglevel.standard, player, {"tnp_train_dispatched"})

        elseif status == tnpdefines.train.status.dispatched then
            -- This train had stopped for some reason.
            if not supplymode then
                tnp_message(tnpdefines.loglevel.detailed, player, {"tnp_train_status_onway"})
            end

        elseif status == tnpdefines.train.status.arrived then
            -- Train has now departed after arrival.  This could be a timeout, or someone has manually
            -- moved it to another station without changing the schedule.
            tnp_train_enact(train, true, nil, nil, nil)
            tnp_request_cancel(player, train, {"tnp_train_cancelled_left"})

        elseif status == tnpdefines.train.status.rearrived then
            -- Train has now departed after rearrival.  The passenger has either disembarked, or someone
            -- moved it to another station without changing the schedule.  Either way we just reset
            -- the schedule.
            tnp_train_enact(train, true, nil, nil, nil)
            tnp_request_cancel(player, train, nil)

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
            tnp_request_cancel_supply(player, train, supplymode, {"tnp_train_cancelled_nopath"})

        -- Train has no path, but we need to restore the schedule anyway.
        elseif status == tnpdefines.train.status.arrived then
            tnp_train_enact(train, true, nil, nil, nil)
            tnp_request_cancel(player, train, {"tnp_train_cancelled_timeout_boarding"})

        elseif status == tnpdefines.train.status.redispatched then
            tnp_train_enact(train, true, nil, nil, nil)
            tnp_request_cancel(player, train, {"tnp_train_cancelled_nopath"})

        end
        -- elseif train.state == defines.train_state.arrive_signal
        -- Train has arrived at a signal.

    elseif train.state == defines.train_state.wait_signal then
        -- Train is now held at signals
        if not supplymode then
            tnp_message(tnpdefines.loglevel.detailed, player, {"tnp_train_status_heldsignal"})
        end

        -- elseif train.state == defines.train_state.arrive_station then
        -- Train is arriving at a station, await its actual arrival

    elseif train.state == defines.train_state.wait_station then
        -- Train has arrived at a station

        if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
            -- This is an arrival to a station, after we've dispatched it.
            local target = tnp_state_train_get(train, 'station')

            -- The target we were dispatching to is no longer valid
            if not target or not target.valid then
                tnp_train_enact(train, true, nil, nil, nil)
                tnp_request_cancel_supply(player, train, supplymode, {"tnp_train_cancelled_invalidstation"})
                return
            end

            -- Our train has arrived at a different station.
            if target.type == "straight-rail" then
                tnp_action_train_arrival(player, train, false, supplymode)
            else
                local station_train = target.get_stopped_train()
                if not station_train or not station_train.valid or not station_train.id == train.id then
                    if train.station ~= nil and train.station.valid and train.station.backer_name == target.backer_name then
                        if config['tnp-train-arrival-path'].value then
                            tnp_draw_path(player, train.station)
                        end

                        tnp_action_train_arrival(player, train, true, supplymode)
                    else
                        tnp_train_enact(train, true, nil, nil, false)
                        tnp_request_cancel(player, train, supplymode, {"tnp_train_cancelled_wrongstation"})
                    end
                else
                    tnp_action_train_arrival(player, train, false, supplymode)
                end
            end

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
            -- if the train is stopping, do not clear the expectation as we will see both manual_control_stop and manual_control
            if train.state == defines.train_state.manual_control then
                tnp_state_train_set(train, 'expect_manualmode', false)
            end
            return
        end

        if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched or status == tnpdefines.train.status.redispatched then
            -- If we're dispatching the train, we need to cancel the request and restore its original schedule
            tnp_train_enact(train, true, nil, nil, nil)
            tnp_request_cancel(player, train, {"tnp_train_cancelled_manual"})

        elseif status == tnpdefines.train.status.arrived then
            -- Train had arrived, but we still need to restore the schedule.
            tnp_train_enact(train, true, nil, nil, nil)
            tnp_request_cancel(player, train, {"tnp_train_cancelled_manual"})

        elseif status == tnpdefines.train.status.rearrived then
            tnp_train_enact(train, true, nil, nil, nil)
            tnp_request_cancel(player, train, {"tnp_train_complete_manual"})
        end
    end
end