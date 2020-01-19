-- tnp_request_assign()
--   Assigns a parked train to a player, marked as arrived.
function tnp_request_assign(player, target, train)
    tnp_request_setup(player, target, train, tnpdefines.train.status.arrived, false)

    if target then
        tnp_message(tnpdefines.loglevel.standard, player, {"tnp_train_waiting", target.backer_name})
    end
end

-- tnp_request_cancel()
--   Cancels a tnp request and removes all state tracking
function tnp_request_cancel(player, train, message)
    if player then
        if player.valid then
            player.set_shortcut_toggled('tnp-handle-request', false)
            tnp_gui_stationlist_close(player)

            if message then
                tnp_message(tnpdefines.loglevel.standard, player, message)
            end
        end

        tnp_state_player_delete(player, 'train')
    end

    if train then
        local dynamicstop = tnp_state_train_get(train, 'dynamicstop')
        if dynamicstop then
            tnp_dynamicstop_destroy(dynamicstop)
        end

        tnp_state_train_delete(train, false)
    end
end

-- tnp_request_cancel_supply()
--   Cancels a tnp request and removes all state tracking, accomodating supply mode trains
function tnp_request_cancel_supply(player, train, supplymode, message)
    if supplymode then
        -- This is a supply train, only cancel the train state
        if player and player.valid and message then
            tnp_message(tnpdefines.loglevel.standard, player, message)
        end

        if train then
            tnp_state_train_delete(train, false)
        end
    else
        -- Standard request -- fall back to standard cancellation
        tnp_request_cancel(player, train, message)
    end

end

-- tnp_request_create()
--   Attempts to create a new request for a tnp train
function tnp_request_create(player, target)
    local config = settings.get_player_settings(player)

    local train = target.get_stopped_train()
    if train and train.valid then
        if config['tnp-train-arrival-path'].value then
            tnp_draw_path(player, target)
        end

        tnp_request_assign(player, target, train)
        return true
    end

    local train = tnp_train_find(player, target)
    if not train then
        tnp_message(tnpdefines.loglevel.core, player, {"tnp_train_invalid"})
        return false
    end

    if config['tnp-train-arrival-path'].value then
        tnp_draw_path(player, target)
    end

    tnp_request_dispatch(player, target, train, false)
    return true
end

-- tnp_request_dispatch()
--   Dispatches a train
function tnp_request_dispatch(player, target, train, supplymode)
    local config = settings.get_player_settings(player)
    local status = tnpdefines.train.status.dispatching

    tnp_request_setup(player, target, train, status, supplymode)
    tnp_state_train_set(train, 'timeout_arrival', config['tnp-train-arrival-timeout'].value)

    if supplymode then
        tnp_state_train_set(train, 'keep_position', true)
    end

    local schedule = tnp_train_schedule_copyamend(player, train, target, status, false, supplymode)
    tnp_train_enact(train, false, schedule, nil, false)

    if not supplymode then
        tnp_message(tnpdefines.loglevel.core, player, {"tnp_train_requested", target.backer_name})
    end
end

-- tnp_request_railtooltest()
--   Tests dispatching a train to a given location, looking for a path error.
function tnp_request_railtooltest(player, target, train)
    local config = settings.get_player_settings(player)

    local redispatch = false
    local dynamicstatus = tnpdefines.train.status.dispatched

    if player.vehicle and player.vehicle.train then
        redispatch = true
        dynamicstatus = tnpdefines.train.status.redispatched
    end

    tnp_state_train_set(train, 'timeout_railtooltest', 2)
    tnp_state_train_set(train, 'dynamicstatus', dynamicstatus)

    if not redispatch then
        tnp_state_train_set(train, 'timeout_arrival', config['tnp-train-arrival-timeout'].value)
    end

    local schedule = tnp_train_schedule_copyamend(player, train, target, dynamicstatus, true, false)
    -- We force the train into manual mode first, to ensure we generate an on-the-path status
    tnp_train_enact(train, false, schedule, true, false)
end

-- tnp_request_redispatch()
--   Redispatches a train for an onward journey
function tnp_request_redispatch(player, target, train)
    local status = tnpdefines.train.status.redispatched
    tnp_request_setup(player, target, train, status, false)

    -- Its a tnp train being dispatched to a station already in its schedule -- so make an extra
    -- effort to keep it there once complete
    if tnp_train_schedule_check(train.schedule, target.backer_name) and tnp_train_check(player, train) then
        tnp_state_train_set(train, 'keep_schedule', true)
    end

    local schedule = tnp_train_schedule_copyamend(player, train, target, status, false, false)
    tnp_train_enact(train, false, schedule, nil, false)
end

-- tnp_request_setup()
--   Handles common setup logic for a train
function tnp_request_setup(player, target, train, status, supplymode)
    tnp_state_train_reset(train)

    tnpdebug("tnp_request_setup(): Setting up request")
    if player and player.valid then
        tnpdebug("tnp_request_setup(): player: " .. tostring(player.index))
    end
    if target and target.valid then
        tnpdebug("tnp_request_setup(): target: " .. tostring(target.unit_number))
    end
    if train and train.valid then
        tnpdebug("tnp_request_setup(): train: " .. tostring(train.id))
    end

    tnp_state_train_set(train, 'player', player)

    if supplymode then
        tnp_state_train_set(train, 'supplymode', true)
    else
        tnp_state_player_set(player, 'train', train)
    end

    if target then
        tnp_state_train_set(train, 'station', target)
    end

    tnp_state_train_set(train, 'status', status)
    tnp_train_info_save(train)

    if not supplymode then
        player.set_shortcut_toggled('tnp-handle-request', true)
    end
end