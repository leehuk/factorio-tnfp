-- tnpdebug()
--   Outputs debugging information to logs, if its enabled
function tnpdebug(output)
    if global.debug_mode then
        log(output)
    end
end

-- tnpdebug_state()
--   Outputs known state information to logs
function tnpdebug_state()
    tnpdebug("State Information")
    tnpdebug("global.dynamicstop_data" .. serpent.block(global.dynamicstop_data))
    tnpdebug("global.player_data" .. serpent.block(global.player_data))
    tnpdebug("global.playerprefs_data" .. serpent.block(global.playerprefs_data))
    tnpdebug("global.train_data" .. serpent.block(global.train_data))
end