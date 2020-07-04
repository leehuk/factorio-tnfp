-- devent_activate()
--   Handles activating all dynamic events during on_load
function devent_activate()
    if not global.dynamic_events then
        return
    end

    for k, v in pairs(global.dynamic_events) do
        if v.enabled == true then
            if k == "gui_selected_tab_changed" then
                script.on_event(v.def, tnp_handle_gui_tab)
            elseif k == "gui_switch_state_changed" then
                script.on_event(v.def, tnp_handle_gui_switch)
            elseif k == "player_cursor_stack_changed" then
                script.on_event(v.def, tnp_handle_player_cursor_stack_changed)
            end
        end
    end
end

-- devent_disable(name)
--   Disables a given event
function devent_disable(name)
    if global.dynamic_events[name] and global.dynamic_events[name].enabled == true then
        global.dynamic_events[name].enabled = false
        script.on_event(global.dynamic_events[name].def, nil)
    end
end

-- devent_enable(name)
--   Enables a given event
function devent_enable(name)
    if global.dynamic_events[name] and global.dynamic_events[name].enabled == false then
        global.dynamic_events[name].enabled = true
        if name == "gui_selected_tab_changed" then
            script.on_event(global.dynamic_events[name].def, tnp_handle_gui_tab)
        elseif name == "gui_switch_state_changed" then
            script.on_event(global.dynamic_events[name].def, tnp_handle_gui_switch)
        elseif name == "player_cursor_stack_changed" then
            script.on_event(global.dynamic_events[name].def, tnp_handle_player_cursor_stack_changed)
        end
    end
end

-- devent_populate()
--   Populates the dynamic event handling table during first load or upgrades
function devent_populate()
    local devents = {
        gui_switch_state_changed = defines.events.on_gui_switch_state_changed,
        gui_selected_tab_changed = defines.events.on_gui_selected_tab_changed,
        player_cursor_stack_changed = defines.events.on_player_cursor_stack_changed
    }

    if not global.dynamic_events then
        global.dynamic_events = {}
    end

    for k, v in pairs(devents) do
        if not global.dynamic_events[k] then
            global.dynamic_events[k] = {
                def = v,
                enabled = false
            }
        else
            global.dynamic_events[k].def = v
        end
    end
end