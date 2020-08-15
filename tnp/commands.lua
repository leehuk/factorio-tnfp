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

    if global.prefs_data['redispatch_circuit'] == true then
        global.prefs_data['redispatch_circuit'] = nil
        player.print({"tnp_command_toggle_redispatch_circuit_disabled"})
    else
        global.prefs_data['redispatch_circuit'] = true
        player.print({"tnp_command_toggle_redispatch_circuit_enabled"})
    end
end