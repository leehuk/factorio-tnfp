-- tnp_action_cancel()
--   Cancels a TNfP request, optionally restoring the trains original schedule
function tnp_action_cancel(player, train, restore_schedule)
    tnp_state_player_delete(player, false)
    
    if restore_schedule then
        tnp_train_schedule_restore(train)
    end
    
    tnp_state_train_delete(train, false)
end

-- tnp_action_request()
--   Attempts to action a request for a TNfP Train
function tnp_action_request(player)
    local target = tnp_find_usable_stop(player)
    if target then
        local train = target.get_stopped_train()
        if train then
            player.print({"tnp_train_waiting", player.name, target.backer_name})
            return
        end
        
        local train = tnp_find_usable_train(player, target)
        if not train then
            player.print({"tnp_error_train_find", player.name})
            return
        end
        
        tnp_dispatch(player, target, train)
    end
end

-- tnp_action_external_schedulechange()
--   Performs any checks and actions required when a trains schedule is changed.
function tnp_action_external_schedulechange(train, event_player)
    local player = tnp_state_train_get(train, 'player')
    local status = tnp_state_train_get(train, 'status')
    
    if event_player then
        -- The schedule was changed by a player, on a train we're dispatching.
        
        -- If we're dispatching this train, cancel the request -- but leave the schedule alone, as its changed.
        if status == tnpdefines.train.status.dispatching or status == tnpdefines.train.status.dispatched then
            -- We were dispatching this train and its not arrived.  Leave the schedule alone as its changed, but cancel the request.
            tnp_action_cancel(player, train, false)
            tnp_flytext(player, player.position, "TNfP Train Cancelled: Schedule was changed by " .. event_player.name)
        elseif status == tnpdefines.train.status.arrived then
            -- This train already arrived at its station -- so we don't need to do anything other than cancel the pending boarding.
            tnp_action_cancel(player, train, false)
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