-- tnp_request_assign()
--   Assigns a parked train to a player, marked as arrived.
function tnp_request_assign(player, target, train)
    tnp_request_setup(player, target, train, tnpdefines.train.status.arrived)

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

        local dynamicstop = tnp_state_player_get(player, 'dynamicstop')
        if dynamicstop then
            tnp_dynamicstop_destroy(player, dynamicstop)
        end

        tnp_state_player_delete(player, 'train')
    end

    if train then
        tnp_state_train_delete(train, false)
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

    tnp_request_dispatch(player, target, train)
    return true
end

-- tnp_request_dispatch()
--   Dispatches a train
function tnp_request_dispatch(player, target, train)
    local config = settings.get_player_settings(player)

    tnp_request_setup(player, target, train, tnpdefines.train.status.dispatching)
    tnp_state_train_set(train, 'timeout_arrival', config['tnp-train-arrival-timeout'].value)

    local schedule = tnp_train_schedule_copy(train)
    local schedule_found = tnp_train_schedule_check(schedule, target.backer_name)

    if not schedule then
        schedule = {}
        schedule.records = {}
    end

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

-- tnp_request_railtooltest()
--   Tests dispatching a train to a given location, looking for a path error.
function tnp_request_railtooltest(player, target, train)
    local config = settings.get_player_settings(player)

    local redispatch = false
    if player.vehicle and player.vehicle.train then
        redispatch = true
    end

    tnp_request_setup(player, target, train, tnpdefines.train.status.railtooltest)
    tnp_state_train_set(train, 'timeout_railtooltest', 2)
    if redispatch then
        tnp_state_train_set(train, 'dynamicstatus', tnpdefines.train.status.redispatched)
    else
        tnp_state_train_set(train, 'dynamicstatus', tnpdefines.train.status.dispatched)
        tnp_state_train_set(train, 'timeout_arrival', config['tnp-train-arrival-timeout'].value)
    end

    local schedule = tnp_train_schedule_copy(train)

    if not schedule then
        schedule = {}
        schedule.records = {}
    end

    local wait_conditions

    if redispatch then
        wait_conditions = {
            {
                type="passenger_not_present",
                compare_type = "or"
            }
        }
    else
        wait_conditions = {
            {
                type="time",
                compare_type = "or",
                ticks = config['tnp-train-boarding-timeout'].value*60
            }
        }
    end

    table.insert(schedule.records, {
        station = target.backer_name,
        wait_conditions = wait_conditions,
        temporary = true
    })

    schedule.current = #schedule.records
    -- We force the train into manual mode first, to ensure we generate an on-the-path status
    tnp_train_enact(train, false, schedule, true, false)
end

-- tnp_request_redispatch()
--   Redispatches a train for an onward journey
function tnp_request_redispatch(player, target, train)
    tnp_request_setup(player, target, train, tnpdefines.train.status.redispatched)

    local schedule = tnp_train_schedule_copy(train)
    local schedule_found = tnp_train_schedule_check(schedule, target.backer_name)

    if not schedule then
        schedule = {}
        schedule.records = {}
    end

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
        -- Its a tnp train being redispatched to a station already in its schedule -- so make an extra
        -- effort to keep it there once complete
        if tnp_train_check(player, train) then
            tnp_state_train_set(train, 'keep_schedule', true)
        end

        schedule.current = schedule_found
    end

    tnp_train_enact(train, false, schedule, nil, false)
end

-- tnp_request_setup()
--   Handles common setup logic for a train
function tnp_request_setup(player, target, train, status)
    tnp_state_train_set(train, 'player', player)
    tnp_state_player_set(player, 'train', train)

    if target then
        tnp_state_train_set(train, 'station', target)
    end

    tnp_state_train_set(train, 'status', status)
    tnp_train_info_save(train)

    tnp_state_train_delete(train, 'keep_schedule')

    player.set_shortcut_toggled('tnp-handle-request', true)
end