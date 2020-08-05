--[[
    State Table:
        redispatch_circuit  - bool, marker to use circuit condition dispatch
        keep_position   - bool, marker to keep position on arrival after redispatch
        player          - LuaPlayer, player we're tracking preferences for
        stationpins     - LuaElement array, array of stations that are pinned
]]

-- _tnp_state_playerprefs_prune()
--   Clears invalid state information for player preferences
function _tnp_state_playerprefs_prune()
    for id, ent in pairs(global.playerprefs_data) do
        if not ent.player.valid then
            global.playerprefs_data[id] = nil
        else
            if not ent.stationpins and ent.keep_position == nil and ent.redispatch_circuit == nil then
                global.playerprefs_data[id] = nil
            else
                if ent.stationpins then
                    for sid, station in pairs(ent.stationpins) do
                        if not station.valid then
                            global.playerprefs_data[id]['stationpins'][sid] = nil
                        end
                    end

                    if table_size(ent.stationpins) == 0 then
                        global.playerprefs_data[id]['stationpins'] = nil
                    end
                end
            end
        end
    end
end

-- tnp_state_playerprefs_check()
--   Checks state information for a player preference, looping into arrays
function tnp_state_playerprefs_check(player, key, idx)
    _tnp_state_playerprefs_prune()

    if not player.valid then
        return false
    end

    if global.playerprefs_data[player.index] and global.playerprefs_data[player.index][key] and global.playerprefs_data[player.index][key][idx] then
        return true
    end

    return nil
end

-- tnp_state_playerprefs_delete()
--   Deletes state information for a player preference
function tnp_state_playerprefs_delete(player, key, idx)
    _tnp_state_playerprefs_prune()

    if not player.valid then
        return false
    end

    if global.playerprefs_data[player.index] then
        if key then
            if idx ~= nil then
                if global.playerprefs_data[player.index][key][idx] then
                    global.playerprefs_data[player.index][key][idx] = nil
                end
            else
                global.playerprefs_data[player.index][key] = nil
            end
        else
            global.playerprefs_data[player.index] = nil
        end
    end
end

-- tnp_state_playerprefs_get()
--   Returns state information for a player preference
function tnp_state_playerprefs_get(player, key)
    _tnp_state_playerprefs_prune()

    if not player.valid then
        return false
    end

    if global.playerprefs_data[player.index] and global.playerprefs_data[player.index][key] then
        return global.playerprefs_data[player.index][key]
    end

    return nil
end

-- tnp_state_playerprefs_set()
--   Sets state information for a player preferences
function tnp_state_playerprefs_set(player, key, value, idx)
    _tnp_state_playerprefs_prune()

    if not player.valid then
        return false
    end

    if not global.playerprefs_data[player.index] then
        global.playerprefs_data[player.index] = {}
        global.playerprefs_data[player.index]['player'] = player
    end

    if idx ~= nil then
        if not global.playerprefs_data[player.index][key] then
            global.playerprefs_data[player.index][key] = {}
        end

        global.playerprefs_data[player.index][key][idx] = value
    else
        global.playerprefs_data[player.index][key] = value
    end

    return true
end