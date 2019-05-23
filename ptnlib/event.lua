-- ptn_handle_request()
--   Handles a request for a PTN Train via input
function ptn_handle_request(event)
    local player = game.players[event.player_index]

    if not player.surface then
        player.print({"ptn_error_location_surface", player.name})
        return
    end
    
    if not player.position then
        player.print({"ptn_error_location_position", player.name})
        return
    end
    
    ptn_action_request(player)
end

-- ptn_handle_shortcut()
--   Handles a shortcut being pressed
function ptn_handle_shortcut(event)
    if event.prototype_name == "ptn-handle-request" then
        ptn_handle_request(event)
    end
end

-- ptn_handle_train_schedulechange()
--   Handles a trains schedule being changed
function ptn_handle_train_schedulechange(event)
    local player = game.players[1]

    if ptnlib_state_train_query(event.train) then
        local player = nil
        if event.player_index and game.players[event.player_index] then
            player = game.players[event.player_index]
        end

        ptn_action_external_schedulechange(event.train, player)
    end
end