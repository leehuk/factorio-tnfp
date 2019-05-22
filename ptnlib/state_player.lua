-- _ptnlib_state_player_prune()
--   Prune the state player data of any invalid players
function _ptnlib_state_player_prune()
    if not global.player_data then
        global.player_data = {}
        return
    end

    for id, data in pairs(global.player_data) do
        if not data or not data.player or not data.player.valid then
            global.player_data[id] = nil
        end
    end
end

-- ptnlib_state_player_delete()
--   Deletes state information about a LuaPlayer, optionally by key
function ptnlib_state_player_delete(player, key)
    _ptnlib_state_player_prune()

    -- Deliberately accept invalid players here(?).
    -- The idea is they may potentially invalid but hopefully still have their index
    -- so we can do cleanup work.

    if key then
        if global.player_data[player.index] then
            global.player_data[player.index][key] = nil
        end
    else
        if global.player_data[player.index] then
            global.player_data[player.index] = nil
        end
    end
end

-- ptnlib_state_player_get()
--   Gets state information about a LuaPlayer by key
function ptnlib_state_player_get(player, key)
    _ptnlib_state_player_prune()
    
    if not player.valid then
        return false
    end
    
    if global.player_data[player.index] and global.player_data[player.index][key] then
        return global.player_data[player.index][key]
    end
    
    return nil
end

-- ptnlib_state_player_set()
--   Saves state informationa bout a LuaPlayer by key
function ptnlib_state_player_set(player, key, value)
    _ptnlib_state_player_prune()

    if not player.valid then
        return false
    end

    if not global.player_data[player.index] then
        global.player_data[player.index] = {}
        global.player_data[player.index]['player'] = player
    end

    global.player_data[player.index][key] = value
    return true
end
