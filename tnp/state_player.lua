--[[
State Table:
    player      = LuaPlayer
    train       = LuaTrain, train we're dispatching for the player.  Cross-referenced by tnp_state_train
]]

-- _tnp_state_player_prune()
--   Prune the state player data of any invalid players
function _tnp_state_player_prune()
    if not global.player_data then
        global.player_data = {}
        return
    end

    for id, data in pairs(global.player_data) do
        if not data or not data.player then
            global.player_data[id] = nil
        elseif not data.player.valid then
            -- The player we're tracking is now invalid.  Check if we need to release their train
            if data.train then
                if data.train.valid then
                    tnp_train_schedule_restore(train)
                end

                tnp_state_train_delete(train, false)
            end

            global.player_data[id] = nil
        end
    end
end

-- tnp_state_player_delete()
--   Deletes state information about a LuaPlayer, optionally by key
function tnp_state_player_delete(player, key)
    _tnp_state_player_prune()
    
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

-- tnp_state_player_get()
--   Gets state information about a LuaPlayer by key
function tnp_state_player_get(player, key)
    _tnp_state_player_prune()
    
    if not player.valid then
        return false
    end
    
    if global.player_data[player.index] and global.player_data[player.index][key] then
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
    
    if not global.player_data then
        return false
    end
    
    if global.player_data[player.index] then
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
    
    if not global.player_data[player.index] then
        global.player_data[player.index] = {}
        global.player_data[player.index]['player'] = player
    end
    
    global.player_data[player.index][key] = value
    return true
end
