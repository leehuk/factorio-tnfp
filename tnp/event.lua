-- tnp_handle_request()
--   Handles a request for a TNfP Train via input
function tnp_handle_request(event)
    local player = game.players[event.player_index]

    if not player.surface then
        player.print({"tnp_error_location_surface", player.name})
        return
    end
    
    if not player.position then
        player.print({"tnp_error_location_position", player.name})
        return
    end
    
    tnp_action_request(player)
end

-- tnp_handle_shortcut()
--   Handles a shortcut being pressed
function tnp_handle_shortcut(event)
    if event.prototype_name == "tnp-handle-request" then
        tnp_handle_request(event)
    end
end

-- tnp_handle_train_schedulechange()
--   Handles a trains schedule being changed
function tnp_handle_train_schedulechange(event)
    local player = game.players[1]

    if tnp_state_train_query(event.train) then
        local player = nil
        if event.player_index and game.players[event.player_index] then
            player = game.players[event.player_index]
        end

        tnp_action_external_schedulechange(event.train, player)
    end
end