--[[
    State Table:
        player          - LuaPlayer, player we're tracking pins for
        stations        - LuaElement array, array of stations that are pinned
]]

-- _tnp_state_stationpins_prune()
--   Clears invalid state information about pinned stations
function _tnp_state_stationpins_prune()
    for id, ent in pairs(global.stationpins_data) do
        if not ent.player.valid then
            global.stationpins_data[id] = nil
        else
            for sid, station in pairs(ent.stations) do
                if not station.valid then
                    global.stationpins_data[id]['stations'][sid] = nil
                end
            end
        end
    end
end

-- tnp_state_stationpins_check()
--   Checks whether a given station is pinned for a player
function tnp_state_stationpins_check(player, station)
    _tnp_state_stationpins_prune()

    if not player.valid or not station.valid then
        return false
    end

    if global.stationpins_data[player.index] and global.stationpins_data[player.index]['stations'][station.unit_number] then
        return true
    end

    return nil
end

-- tnp_state_stationpins_delete()
--   Deletes state information about a pinned station
function tnp_state_stationpins_delete(player, station)
    _tnp_state_stationpins_prune()

    if not player.valid or not station.valid then
        return false
    end

    if global.stationpins_data[player.index] then
        if global.stationpins_data[player.index]['stations'][station.unit_number] then
            global.stationpins_data[player.index]['stations'][station.unit_number] = nil
        end
    end
end

-- tnp_state_stationpins_set()
--   Sets state information for a pinned station
function tnp_state_stationpins_set(player, station)
    _tnp_state_stationpins_prune()

    if not player.valid or not station.valid then
        return false
    end

    if not global.stationpins_data[player.index] then
        global.stationpins_data[player.index] = {}
        global.stationpins_data[player.index]['player'] = player
        global.stationpins_data[player.index]['stations'] = {}
    end

    global.stationpins_data[player.index]['stations'][station.unit_number] = station
    return true
end