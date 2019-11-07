--[[
State Table:
    dynamicstop             = LuaElement, dynamic stop we're tracking
    gui                     = LuaGuiElement, root gui element we're tracking
    gui_stationsearch       = LuaGuiElement, search element in a station select dialog
    gui_stationtableall     = LuaGuiElement, station table element we're tracking
    gui_stationtabletrain   = LuaGuiElement, station table element we're tracking
    gui_stationtabletnfp    = LuaGuiElement, station table element we're tracking
    player                  = LuaPlayer
    train                   = LuaTrain, train we're dispatching for the player.  Cross-referenced by tnp_state_train
]]

-- _tnp_state_player_prune()
--   Prune the state player data of any invalid players
function _tnp_state_player_prune()
    for id, data in pairs(global.player_data) do
        if not data then
            global.player_data[id] = nil
        elseif not data.player or not data.player.valid then
            global.player_data[id] = nil
        else
            if data.dynamicstop and not data.dynamicstop.valid then
                global.player_data[id]['dynamicstop'] = nil
            end

            if data.train and not data.train.valid then
                global.player_data[id]['train'] = nil
            end

            if data.gui and not data.gui.valid then
                global.player_data[id]['gui'] = nil
            end

            if data.gui_stationsearch and not data.gui_stationsearch.valid then
                global.player_data[id]['gui_stationsearch'] = nil
            end

            if data.gui_stationtableall and not data.gui_stationtableall.valid then
                global.player_data[id]['gui_stationtableall'] = nil
            end

            if data.gui_stationtabletrain and not data.gui_stationtabletrain.valid then
                global.player_data[id]['gui_stationtabletrain'] = nil
            end

            if data.gui_stationtabletnfp and not data.gui_stationtabletnfp.valid then
                global.player_data[id]['gui_stationtabletnfp'] = nil
            end

            local xdata = global.player_data[id]
            if not xdata['dynamicstop'] and not xdata['train'] and not xdata['gui'] and not xdata['gui_stationsearch'] and not xdata['gui_stationtableall'] and not xdata['gui_stationtabletrain'] and not xdata['gui_stationtabletnfp'] then
                global.player_data[id] = nil
            end
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

    if global.player_data[player.index] then
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
