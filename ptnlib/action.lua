-- ptnlib_action_cancel()
--   Cancels a PTN request, optionally restoring the trains original schedule
function ptnlib_action_cancel(player, train, restore_schedule)
    ptnlib_state_player_delete(player, false)

    if restore_schedule then
        ptnlib_train_restoreschedule(train)
    end

    ptnlib_state_train_delete(train, false)
end