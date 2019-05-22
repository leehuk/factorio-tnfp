-- ptnlib_action_cancel()
--   Cancels a PTN request, optionally restoring the trains original schedule
function ptnlib_action_cancel(player, train, restore_schedule)
    ptnlib_state_player_delete(player, false)

    if restore_schedule then
        ptnlib_train_restoreschedule(train)
    end

    ptnlib_state_train_delete(train, false)
end

-- ptn_action_request()
--   Attempts to action a request for a PTN Train
function ptn_action_request(player)
    local target = ptn_find_usable_stop(player)
    if target then
        local train = target.get_stopped_train()
        if train then
            player.print({"ptn_train_waiting", player.name, target.backer_name})
            return
        end
        
        local train = ptn_find_usable_train(player, target)
        if not train then
            player.print({"ptn_error_train_find", player.name})
            return
        end
        
        ptn_dispatch(player, target, train)
    end
end