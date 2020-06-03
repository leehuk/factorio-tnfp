-- devent_activate()
--   Handles activating all dynamic events during on_load
function devent_activate()
    if not global.dynamic_events then
        return
    end

    for k, v in pairs(global.dynamic_events) do
        if v.enabled == true then
            if k == "gui_switch_state_changed" then
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
        if name == "gui_switch_state_changed" then
            script.on_event(global.dynamic_events[name].def, tnp_handle_gui_switch)
        elseif name == "player_cursor_stack_changed" then
            script.on_event(global.dynamic_events[name].def, tnp_handle_player_cursor_stack_changed)
        end
    end
end

-- devent_populate()
--   Populates the dynamic event handling table during first load or upgrades
function devent_populate()
    if not global.dynamic_events then
        global.dynamic_events = {}
    end

    if not global.dynamic_events["gui_switch_state_changed"] then
        global.dynamic_events["gui_switch_state_changed"] = {
            def = defines.events.on_gui_switch_state_changed,
            enabled = false
        }
    else
        global.dynamic_events["gui_switch_state_changed"]["def"] = defines.events.on_gui_switch_state_changed
    end

    if not global.dynamic_events["player_cursor_stack_changed"] then
        global.dynamic_events["player_cursor_stack_changed"] = {
            def = defines.events.on_player_cursor_stack_changed,
            enabled = false
        }
    else
        global.dynamic_events["player_cursor_stack_changed"]["def"] = defines.events.on_player_cursor_stack_changed
    end
end