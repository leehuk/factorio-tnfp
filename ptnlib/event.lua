-- ptn_handle_request()
--   Handles a request for a PTN Train
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