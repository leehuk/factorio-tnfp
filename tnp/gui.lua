-- tnp_gui_stationselect()
--   Draws the station select gui
function tnp_gui_stationselect(player, train)
    if not train.schedule or not train.schedule.records then
        player.print("error")
        -- error?
        return
    end

    local gui_top = player.gui.center.add({
        name = "tnp-gui-stationselect-top",
        caption = "TNfP Station Select",
        type = "frame",
        direction = "vertical"
    })

    tnp_state_player_set(player, 'gui', gui_top)

    local gui_scroll = gui_top.add({
        name = "tnp-gui-stationselect-scroller",
        type = "scroll-pane",
        horizontal_scroll_policy = "auto-and-reserve-space"
    })

    local gui_table = gui_scroll.add({
        name = "tnp-gui-stationselect-table",
        type = "table",
        column_count = 1,
        draw_vertical_lines = true
    })

    for i, ent in ipairs(train.schedule.records) do
        local gui_button = gui_table.add({
            name = "tnp-gui-stationselect-" .. i,
            type = "button",
            caption = ent.station
        })

        tnp_state_gui_set(gui_button, player, 'station', i)
    end
end

-- tnp_gui_stationselect_close()
--   Destroys a station select gui
function tnp_gui_stationselect_close(player)
    local gui = tnp_state_player_get(player, 'gui')
    if gui and gui.valid then
        gui.destroy()
    end

    tnp_state_player_delete(player, 'gui')
    _tnp_state_gui_prune()
end
