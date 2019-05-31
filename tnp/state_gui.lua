--[[
    State Table:
        close           = boolean, if this button closes the gui
        element         = LuaGuiElement
        name            = string, name of button
        player          = LuaPlayer, reference to player.
        station         = int, if this is a station gui its the station index
]]

-- _tnp_state_gui_prune()
--   Clears invalid state information about LuaGuiElements
function _tnp_state_gui_prune()
    if not global.gui_data then
        return
    end

    for id, ent in pairs(global.gui_data) do
        if not ent.element.valid then
            global.gui_data[id] = nil
        elseif not ent.player or not ent.player.valid then
            global.gui_data[id] = nil
        end
    end
end

-- tnp_state_gui_delete()
--   Deletes state information about a LuaGuiElement
function tnp_state_gui_delete(element)
    _tnp_state_gui_prune()

    if not element.valid then
        return
    end

    if global.gui_data and global.gui_data[element.index] then
        if key then
            global.gui_data[element.index][key] = nil
        else
            global.gui_data[element.index] = nil
        end
    end
end

-- tnp_state_gui_get()
--   Gets state information about a LuaGuiElement
function tnp_state_gui_get(element, player, key)
    _tnp_state_gui_prune()

    if not element.valid or not player.valid then
        return false
    end

    if global.gui_data and global.gui_data[element.index] and global.gui_data[element.index][key] then
        return global.gui_data[element.index][key]
    end

    return nil
end

-- tnp_state_gui_set()
--   Sets state information about a LuiGuiElement
function tnp_state_gui_set(element, player, key, value)
    _tnp_state_gui_prune()

    if not element.valid or not player.valid then
        return false
    end

    if not global.gui_data then
        global.gui_data = {}
    end

    if not global.gui_data[element.index] then
        global.gui_data[element.index] = {}
        global.gui_data[element.index]['element'] = element
        global.gui_data[element.index]['player'] = player
    end

    global.gui_data[element.index][key] = value
    return true
end