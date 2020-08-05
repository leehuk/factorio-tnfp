-- tnp_command_toggle_redispatch_circuit()
--   Toggles circuit conditions for redispatch vs "Passenger not present"
function tnp_command_toggle_redispatch_circuit(event)
    if not event.player_index then
        return
    end

    local player = game.players[event.player_index]
    if not player.valid then
        return
    end

    local state = tnp_state_playerprefs_get(player, 'redispatch_circuit')
    if not state or state == false then
        tnp_state_playerprefs_set(player, 'redispatch_circuit', true)
        player.print({"tnp_command_toggle_redispatch_circuit_enabled"})
    else
        tnp_state_playerprefs_delete(player, 'redispatch_circuit')
        player.print({"tnp_command_toggle_redispatch_circuit_disabled"})
    end
end