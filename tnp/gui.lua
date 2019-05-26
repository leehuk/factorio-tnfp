-- tnp_gui_stationselect()
--   Draws the station select gui
function tnp_gui_stationselect(player, train)
    if not train.schedule or not train.schedule.records then
        player.print("error")
        -- error?
        return
    end

    local gui_top = player.gui.center.add({
        name = "tnp-gui-stationselect",
        type = "frame",
        direction = "vertical",
        style = "tnp_stationselect"
    })

    tnp_state_player_set(player, 'gui', gui_top)

    local gui_heading_bar = gui_top.add({
        name = "tnp-gui-stationselect-top",
        type = "flow",
        direction = "horizontal",
        style = "tnp_stationselect_top"
    })
    gui_heading_bar.add({
        name = "tnp-gui-stationselect-text",
        type = "label",
        caption = "TNfP Station Select",
        style = "tnp_stationselect_topheading"
    })
    local gui_close = gui_heading_bar.add({
        name = "tnp-gui-stationselect-close",
        type = "sprite-button",
        sprite = "tnp_close",
        style = "tnp_stationselect_topbutton"
    })
    tnp_state_gui_set(gui_close, player, 'close', true)

    local gui_scroll = gui_top.add({
        name = "tnp-gui-stationselect-scroller",
        type = "scroll-pane",
        style = "tnp_stationselect_mainscroll",
        horizontal_scroll_policy = "auto-and-reserve-space"
    })

    local gui_table = gui_scroll.add({
        name = "tnp-gui-stationselect-table",
        type = "table",
        column_count = 1,
        style = "tnp_stationselect_table"
    })

    for i, ent in ipairs(train.schedule.records) do
        local gui_button = gui_table.add({
            name = "tnp-gui-stationselect-" .. i,
            type = "button",
            caption = ent.station,
            style = "tnp_stationselect_station"
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
