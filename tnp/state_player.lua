--[[
State Table:
    gui                     = LuaGuiElement, root gui element we're tracking
    gui_stationsearch       = LuaGuiElement, search element in a station select dialog
    gui_stationtableall     = LuaGuiElement, station table element we're tracking
    gui_stationtabletrain   = LuaGuiElement, station table element we're tracking
    gui_stationtabletnfp    = LuaGuiElement, station table element we're tracking
    player                  = LuaPlayer
    railtool                = string, item type of railtool we've provided the player
    speechbubble            = LuaElement, speechbubble we're tracking
    supplyselected          = LuaTrain, currently selected supply train
    supplyselection         = LuaTrain array, priority indexed array of available supply trains
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
            local children = {'train', 'gui', 'gui_stationsearch', 'gui_stationtableall', 'gui_stationtabletrain', 'gui_stationtabletnfp', 'speechbubble'}
            for _, child in pairs(children) do
                if data[child] and data[child].valid ~= true then
                    global.player_data[id][child] = nil
                end
            end

            if data['supplyselected'] and data['supplyselected'].valid ~= true then
                global.player_data[id]['supplyselected'] = nil
                global.player_data[id]['supplyselection'] = nil
            end

            local xdata = global.player_data[id]
            if not xdata['train'] and not xdata['gui'] and xdata['railtool'] == nil and not xdata['speechbubble'] and not xdata['supplyselected'] then
                global.player_data[id] = nil
            end
        end
    end
end

-- tnp_state_player_any()
--   Checks if we have state information of a given key for any player
function tnp_state_player_any(key)
    _tnp_state_player_prune()

    for id, data in pairs(global.player_data) do
        if data[key] then
            return true
        end
    end

    return false
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

    if global.player_data[player.index] and global.player_data[player.index]['train'] then
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

    if key == 'supplyselection' then
        global.player_data[player.index][key] = util.table.deepcopy(value)
    else
        global.player_data[player.index][key] = value
    end

    return true
end
