-- tnp_gui_stationselect_destroy()
--   Destroys a station select gui
function tnp_gui_stationselect_destroy(button)
    button.parent.parent.parent.destroy()
    _tnp_state_gui_prune()
end

-- tnp_gui_stationselect()
--   Draws the station select gui
function tnp_gui_stationselect(player, train)
    if not train.schedule or not train.schedule.records then
        player.print("error")
        -- error?
        return
    end

    local gui_top = player.gui.center.add({
        name = "tpn-gui-stationselect-top",
        caption = "TPN Station Select",
        type = "frame",
        direction = "vertical"
    })

    local gui_scroll = gui_top.add({
        name = "tpn-gui-stationselect-scroller",
        type = "scroll-pane",
        horizontal_scroll_policy = "auto-and-reserve-space"
    })

    local gui_table = gui_scroll.add({
        name = "tpn-gui-stationselect-table",
        type = "table",
        column_count = 1,
        draw_vertical_lines = true
    })

    for i, ent in ipairs(train.schedule.records) do
        local gui_button = gui_table.add({
            name = "tpn-gui-stationselect-" .. i,
            type = "button",
            caption = ent.station
        })

        tnp_state_gui_set(gui_button, 'station', i)
    end
end