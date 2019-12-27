-- tnp_action_trainstate()
--   Handles any required actions from a train changing driving state
function tnp_action_trainstate(player, train)
    local config = settings.get_player_settings(player)

    local status = tnp_state_train_get(train, 'status')
    local supplymode = tnp_state_train_get(train, 'supplymode')

    -- We have now seen a state change request for one of our railtool tests
    if status == tnpdefines.train.status.railtooltest then
        tnp_state_train_delete(train, 'timeout_railtooltest')
    end

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

        elseif status == tnpdefines.train.status.railtooltest then
            -- The temporary station the railtool is dispatching to works.
            local dynamicstop = tnp_state_player_get(player, 'dynamicstop')
            local dynamicstatus = tnp_state_train_get(train, 'dynamicstatus')

            if not dynamicstop then
                tnp_request_cancel(player, train, {"tnp_train_cancelled_invalidstate"})
                return
            end

            -- We have an alternate stop -- remove that
            local altstop = tnp_state_dynamicstop_get(dynamicstop, 'altstop')
            if altstop then
                if altstop.valid then
                    altstop.destroy()
                end

                tnp_state_dynamicstop_delete(dynamicstop, 'altstop')
            end

            tnp_state_train_set(train, 'status', dynamicstatus)
            tnp_state_train_delete(train, 'dynamicstatus')
            tnp_state_train_delete(train, 'expect_manualmode')

            if dynamicstatus == tnpdefines.train.status.dispatched then
                tnp_message(tnpdefines.loglevel.core, player, {"tnp_train_requested", dynamicstop.backer_name})
            end
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

        elseif status == tnpdefines.train.status.railtooltest then
            -- We were attempting to dispatch to a dynamic stop and that failed.  If we have an alternate, try that.
            tnp_train_enact(train, true, nil, nil, nil)
            tnp_state_train_delete(train, 'timeout_arrival')

            local dynamicstop = tnp_state_player_get(player, 'dynamicstop')
            local altstop = tnp_state_dynamicstop_get(dynamicstop, 'altstop')
            local keep_position = tnp_state_train_get(train, 'keep_position')

            if not dynamicstop then
                tnp_request_cancel(player, train, {"tnp_train_cancelled_invalidstate"})
                return
            end

            tnp_state_dynamicstop_delete(dynamicstop)
            dynamicstop.destroy()

            if not altstop then
                tnp_request_cancel(player, train, {"tnp_train_cancelled_nolocation"})
                return
            end

            tnp_dynamicstop_setup(player, train, altstop, nil)
            tnp_request_railtooltest(player, altstop, train)

            if keep_position then
                tnp_state_train_set(train, 'keep_position', true)
            end
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
            local station = tnp_state_train_get(train, 'station')

            -- The station we were dispatching to is no longer valid
            if not station or not station.valid then
                tnp_train_enact(train, true, nil, nil, nil)
                tnp_request_cancel_supply(player, train, supplymode, {"tnp_train_cancelled_invalidstation"})
                return
            end

            -- Our train has arrived at a different station.
            local station_train = station.get_stopped_train()
            if not station_train or not station_train.valid or not station_train.id == train.id then
                if train.station ~= nil and train.station.valid and train.station.backer_name == station.backer_name then
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

        elseif status == tnpdefines.train.status.redispatched then
            -- This was an redispatch station -- so wait for the passenger to disembark
            tnp_action_train_rearrival(player, train)

        elseif status == tnpdefines.train.status.railtooltest then
            -- This was a railtool test we didnt get a status update about (?)
            -- For now, correct the status and re-fire the event.
            local dynamicstatus = tnp_state_train_get(train, 'dynamicstatus')
            if not dynamicstatus then
                -- !!! error??
                return
            end

            tnp_state_train_set(train, 'status', dynamicstatus)
            tnp_action_train_statechange(train)
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