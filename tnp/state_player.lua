--[[
State Table:
    gui         = LuaGuiElement, root gui element we're tracking
    player      = LuaPlayer
    train       = LuaTrain, train we're dispatching for the player.  Cross-referenced by tnp_state_train
]]

-- _tnp_state_player_prune()
--   Prune the state player data of any invalid players
function _tnp_state_player_prune()
    if not global.player_data then
        return
    end

    for id, data in pairs(global.player_data) do
        if not data or not data.player then
            global.player_data[id] = nil
        elseif not data.player.valid then
            -- The player we're tracking is now invalid.  Check if we need to release their train
            if data.train then
                tnp_train_enact(data.train, true, nil, nil, false)
                tnp_action_request_cancel(nil, data.train, true)
            end

            -- Any gui elements should now be automatically invalid, so trigger a prune there
            if data.gui then
                _tnp_state_gui_prune()
            end

            global.player_data[id] = nil
        elseif not data.gui and not data.player then
            global.player_data[id] = nil
        end
    end
end

-- tnp_state_player_delete()
--   Deletes state information about a LuaPlayer, optionally by key
function tnp_state_player_delete(player, key)
    _tnp_state_player_prune()

    if not player.valid then
        return
    end

    if global.player_data and global.player_data[player.index] then
        if key then
            global.player_data[player.index][key] = nil

            -- If we're no longer tracking either a gui or train, clear the entire object.
            if not global.player_data[player.index]['gui'] and not global.player_data[player.index]['train'] then
                global.player_data[player.index] = nil
            end
        else
            global.player_data[player.index] = nil
        end
    end
end

-- tnp_state_player_get()
--   Gets state information about a LuaPlayer by key
function tnp_state_player_get(player, key)
    _tnp_state_player_prune()

    if not player.valid then
        return false
    end

    if global.player_data and global.player_data[player.index] and global.player_data[player.index][key] then
        return global.player_data[player.index][key]
    end

    return nil
end

-- tnp_state_player_query()
--   Determines if a given player is being tracked by tnp
function tnp_state_player_query(player)
    if not player.valid then
        return false
    end

    if global.player_data and global.player_data[player.index] then
        return true
    end

    return false
end


-- tnp_state_player_set()
--   Saves state informationa bout a LuaPlayer by key
function tnp_state_player_set(player, key, value)
    _tnp_state_player_prune()

    if not player.valid then
        return false
    end

    if not global.player_data then
        global.player_data = {}
    end

    if not global.player_data[player.index] then
        global.player_data[player.index] = {}
        global.player_data[player.index]['player'] = player
    end

    global.player_data[player.index][key] = value
    return true
end
