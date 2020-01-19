-- tnp_cmd_init()
--   Registers commands
function tnp_cmd_init()
    commands.add_command("tnp-toggle-debug", "Toggles tnfp debugging to log", tnp_cmd_toggle_debug)
    if global.debug_mode then
        tnpdebug_state()
    end
end

-- tnp_cmd_toggle_debug()
--   Command to toggle debugging mode
function tnp_cmd_toggle_debug(data)
    local player = game.players[data.player_index]

    if not player.valid then
        return false
    end

    if not global.debug_mode then
        global.debug_mode = true

        player.print("[TNfP] Enabled debug mode")
        tnpdebug_state()
    else
        global.debug_mode = false
        player.print("[TNfP] Disabled debug mode")
    end
end