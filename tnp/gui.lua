-- tnp_gui_stationlist()
--   Draws the station select gui
function tnp_gui_stationlist(player, train)
    local config = settings.get_player_settings(player)

    -- If a GUI already exists destroy it
    for _, child in pairs(player.gui.screen.children) do
        if child.name == "tnp-stationlist" or child.name == "tnp-sl-top" then
            child.destroy()
        end
    end

    -- Top Frame
    local gui_top = player.gui.screen.add({
        name = "tnp-sl-top",
        type = "frame",
        direction = "vertical",
        style = "frame_without_footer"
    })
    gui_top.force_auto_center()
    tnp_state_player_set(player, 'gui', gui_top)

    -- Heading Title Bar
    local gui_heading_area = gui_top.add({
        name = "tnp-sl-heading-flow",
        type = "flow",
        direction = "horizontal",
        style = "tnp_sl_heading_flow"
    })
    local gui_heading_label = gui_heading_area.add({
        name = "tnp-sl-heading-label",
        type = "label",
        caption = {"tnp_gui_stationlist_heading"},
        style = "frame_title"
    })
    local gui_heading_filler = gui_heading_area.add({
        name = "tnp-sl-heading-filler",
        type = "empty-widget",
        style = "tnp_sl_heading_filler"
    })

    gui_heading_label.drag_target = gui_top
    gui_heading_filler.drag_target = gui_top

    gui_heading_area.add({
        name = "tnp-sl-railtoolbutton",
        type = "sprite-button",
        sprite = "tnp_button_rail",
        style = "frame_action_button"
    })
    -- TODO: Why is this stored in state?
    local gui_close = gui_heading_area.add({
        name = "tnp-sl-closebutton",
        type = "sprite-button",
        sprite = "tnp_button_close",
        style = "frame_action_button"
    })
    tnp_state_gui_set(gui_close, player, 'close', true)

    -- Main Frame
    local gui_main = gui_top.add({
        name = "tnp-sl-main",
        type = "frame",
        direction = "vertical",
        style = "inside_deep_frame_for_tabs"
    })

    -- Arrival Behaviour
    local gui_arrival_flow = gui_main.add({
        name = "tnp-sl-arrival-flow",
        type = "flow",
        direction = "horizontal",
        style = "tnp_sl_subheading_flow"
    })
    gui_arrival_flow.add({
        name = "tnp-sl-arrival-label",
        type = "label",
        caption = {"tnp_gui_stationlist_arrival"},
        style = "tnp_sl_subheading_label"
    })
    gui_arrival_flow.add({
        name = "tnp-sl-arrival-filler",
        type = "empty-widget",
        style = "tnp_sl_empty_filler"
    })

    local switch_state = 'left'
    if tnp_state_playerprefs_get(player, 'keep_position') == true then
        switch_state = 'right'
    end
    gui_arrival_flow.add({
        name = "tnp-sl-arrival-switch",
        type = "switch",
        allow_none_state = false,
        switch_state = switch_state,
        left_label_caption={"tnp_gui_stationlist_arrival_default"},
        right_label_caption={"tnp_gui_stationlist_arrival_manual"},
        style = "switch"
    })

    local gui_stationsearch_area = gui_main.add({
        name = "tnp-sl-search-flow",
        type = "flow",
        direction = "horizontal",
        style = "tnp_sl_subheading_flow"
    })

    local gui_stationsearch = gui_stationsearch_area.add({
        name = "tnp-sl-search-field",
        type = "textfield",
        style = "tnp_sl_search_field",
        selectable = true,
        clear_and_focus_on_right_click = true
    })
    tnp_state_player_set(player, 'gui_stationsearch', gui_stationsearch)

    if config['tnp-stationlist-focussearch'].value == true then
        gui_stationsearch.focus()
    end

    -- Station List Tabs
    local gui_tabs = gui_main.add({
        name = "tnp-sl-tabs",
        type = "tabbed-pane"
    })  

    -- Scheduled Stations
    local gui_tab_schedule = gui_tabs.add({
        name = "tnp-sl-tabschedule",
        type = "tab",
        caption = {"tnp_gui_stationlist_stationtype_schedule"}
    })
    local gui_scroll_schedule = gui_tabs.add({
        name = "tnp-sl-scroll-1",
        type = "scroll-pane",
        style = "tnp_sl_list_scroll",
        horizontal_scroll_policy = "never",
        vertical_scroll_policy = "always"
    })
    local gui_table_schedule = gui_scroll_schedule.add({
        name = "tnp-sl-tableschedule",
        type = "table",
        column_count = 1,
        style = "tnp_sl_list_table"
    })
    gui_tabs.add_tab(gui_tab_schedule, gui_scroll_schedule)

    -- TNfP Stations
    local gui_tab_tnfp = gui_tabs.add({
        name = "tnp-sl-tabtnfp",
        type = "tab",
        caption = {"tnp_gui_stationlist_stationtype_tnfp"}
    })
    local gui_scroll_tnfp = gui_tabs.add({
        name = "tnp-sl-scroll-2",
        type = "scroll-pane",
        style = "tnp_sl_list_scroll",
        horizontal_scroll_policy = "never",
        vertical_scroll_policy = "always"
    })
    local gui_table_tnfp = gui_scroll_tnfp.add({
        name = "tnp-sl-tabletnfp",
        type = "table",
        column_count = 1,
        style = "tnp_sl_list_table"
    })
    gui_tabs.add_tab(gui_tab_tnfp, gui_scroll_tnfp)

    -- All Stations
    local gui_tab_all = gui_tabs.add({
        name = "tnp-sl-taball",
        type = "tab",
        caption = {"tnp_gui_stationlist_stationtype_all"}
    })
    local gui_scroll_all = gui_tabs.add({
        name = "tnp-sl-scroll-3",
        type = "scroll-pane",
        style = "tnp_sl_list_scroll",
        horizontal_scroll_policy = "never",
        vertical_scroll_policy = "always"
    })
    local gui_table_all = gui_scroll_all.add({
        name = "tnp-sl-tableall",
        type = "table",
        column_count = 1,
        style = "tnp_sl_list_table"
    })
    gui_tabs.add_tab(gui_tab_all, gui_scroll_all)

    if config['tnp-stationlist-view'].value == 'train' then
        gui_tabs.selected_tab_index = 1
    elseif config['tnp-stationlist-view'].value == 'tnfp' then
        gui_tabs.selected_tab_index = 2
    else
        gui_tabs.selected_tab_index = 3
    end

    devent_enable('gui_selected_tab_changed')
    devent_enable('gui_switch_state_changed')

    tnp_state_player_set(player, 'gui_stationtableall', gui_table_all)
    tnp_state_player_set(player, 'gui_stationtabletnfp', gui_table_tnfp)
    tnp_state_player_set(player, 'gui_stationtabletrain', gui_table_schedule)

    tnp_gui_stationlist_build(player, train)
end

-- tnp_gui_stationlist_collate()
--   Collates a list of train stations and special flags they may have
function tnp_gui_stationlist_collate(player, stations_key, stations_map, stations_flags)
    -- Collate a full list of all stops, so we can sort them alphabetically
    local stations_unsorted = player.surface.find_entities_filtered({
        type = "train-stop"
    })

    for _, station in pairs(stations_unsorted) do
        if station.valid then
            if tnp_stop_danger(station) == false then
                if not stations_map[station.backer_name] then
                    table.insert(stations_key, station.backer_name)
                    stations_map[station.backer_name] = station

                    stations_flags[station.backer_name] = {}
                    stations_flags[station.backer_name]['count'] = 1

                    local is_tnp = tnp_stop_check(station)
                    if is_tnp.home == true then
                        stations_flags[station.backer_name]['home'] = true
                    end
                    if is_tnp.tnp == true then
                        stations_flags[station.backer_name]['tnfp'] = true
                    end
                    if tnp_state_playerprefs_check(player, 'stationpins', station.unit_number) == true then
                        stations_flags[station.backer_name]['pinned'] = true
                    end
                else
                    stations_flags[station.backer_name]['count'] = stations_flags[station.backer_name]['count'] + 1
                end
            end
        end
    end

    table.sort(stations_key)
end

-- tnp_gui_stationlist_build()
--   Loops over all train stations to build the relevant gui tables
function tnp_gui_stationlist_build(player, train)
    local gui_stationtable_all = tnp_state_player_get(player, 'gui_stationtableall')
    local gui_stationtable_tnfp = tnp_state_player_get(player, 'gui_stationtabletnfp')
    local gui_stationtable_train = tnp_state_player_get(player, 'gui_stationtabletrain')

    if not gui_stationtable_all or not gui_stationtable_all.valid or not gui_stationtable_tnfp or not gui_stationtable_tnfp.valid or not gui_stationtable_train or not gui_stationtable_train.valid then
        return
    end

    local stations_key = {}
    local stations_map = {}
    local stations_flags = {}

    tnp_gui_stationlist_collate(player, stations_key, stations_map, stations_flags)

    gui_stationtable_all.clear()
    gui_stationtable_tnfp.clear()
    gui_stationtable_train.clear()

    local stations_added = {}

    -- Add home stations first to the top of the tnp and all lists
    for i, stationname in ipairs(stations_key) do
        if stations_flags[stationname]['home'] then
            tnp_gui_stationlist_addentry(player, gui_stationtable_tnfp, "tnfp", i, stations_map[stationname], stations_flags[stationname]['count'], false, true)
            tnp_gui_stationlist_addentry(player, gui_stationtable_all, "all", i, stations_map[stationname], stations_flags[stationname]['count'], false, true)

            stations_added[i] = true
        end
    end

    -- Then add pinned stations to the top of the all and tnfp lists.  The pinning interface isnt available
    -- inside the tnfp list, but they'll still be promoted.
    for i, stationname in ipairs(stations_key) do
        if stations_added[i] == nil and stations_flags[stationname]['pinned'] then
            tnp_gui_stationlist_addentry(player, gui_stationtable_all, "all", i, stations_map[stationname], stations_flags[stationname]['count'], true, false)

            if stations_flags[stationname]['tnfp'] then
                tnp_gui_stationlist_addentry(player, gui_stationtable_tnfp, "tnfp", i, stations_map[stationname], stations_flags[stationname]['count'], true, false)
            end

            stations_added[i] = true
        end
    end

    -- Now iterate over the list of stations which are in alphabetical order, and add them to each
    -- relevant list as we go.
    for i, stationname in ipairs(stations_key) do
        -- The trains schedule is not a map to entities -- its just a set of string station names, so
        -- in order to fit our entity flow we'd have to map each one back to the entity.  Given we're
        -- looping over all train stops anyway, looping over the trains isnt unreasonable.
        local trains = stations_map[stationname].get_train_stop_trains()
        if trains then
            for _, stationtrain in pairs(trains) do
                if train.id == stationtrain.id then
                    tnp_gui_stationlist_addentry(player, gui_stationtable_train, "train", i, stations_map[stationname], stations_flags[stationname]['count'], false, false)
                end
            end
        end

        if stations_added[i] == nil then
            if stations_flags[stationname]['tnfp'] then
                tnp_gui_stationlist_addentry(player, gui_stationtable_tnfp, "tnfp", i, stations_map[stationname], stations_flags[stationname]['count'], false, false)
            end

            tnp_gui_stationlist_addentry(player, gui_stationtable_all, "all", i, stations_map[stationname], stations_flags[stationname]['count'], false, false)
        end
    end
end

-- tnp_gui_stationlist_rebuild_all()
--   Rebuilds the 'All' train station view, in response to pinning
function tnp_gui_stationlist_rebuild_all(player)
    local gui_stationtable_all = tnp_state_player_get(player, 'gui_stationtableall')

    if not gui_stationtable_all or not gui_stationtable_all.valid then
        return
    end

    local stations_key = {}
    local stations_map = {}
    local stations_flags = {}

    tnp_gui_stationlist_collate(player, stations_key, stations_map, stations_flags)

    gui_stationtable_all.clear()

    local stations_added = {}

    -- Add home stations first, then pinned, then the rest
    for i, stationname in ipairs(stations_key) do
        if stations_flags[stationname]['home'] then
            tnp_gui_stationlist_addentry(player, gui_stationtable_all, "all", i, stations_map[stationname], stations_flags[stationname]['count'], false, true)
            stations_added[i] = true
        end
    end

    for i, stationname in ipairs(stations_key) do
        if stations_added[i] == nil and stations_flags[stationname]['pinned'] then
            tnp_gui_stationlist_addentry(player, gui_stationtable_all, "all", i, stations_map[stationname], stations_flags[stationname]['count'], true, false)
            stations_added[i] = true
        end
    end

    for i, stationname in ipairs(stations_key) do
        if stations_added[i] == nil then
            tnp_gui_stationlist_addentry(player, gui_stationtable_all, "all", i, stations_map[stationname], stations_flags[stationname]['count'], false, false)
        end
    end
end

-- tnp_gui_stationlist_addentry()
--   Adds an entry to a given stationlist table
function tnp_gui_stationlist_addentry(player, stationtable, tablename, idx, station, count, pinned, home)
    local caption = station.backer_name
    if count > 1 then
        caption = caption .. " (" .. count .. ")"
    end

    local gui_row = stationtable.add({
        name = "tnp-stationlist-row" .. tablename .. "-" .. idx,
        type = "flow",
        direction = "horizontal",
        style = "tnp_stationlist_stationlistrow"
    })

    local gui_button = gui_row.add({
        name = "tnp-stationlist-dest" .. tablename .. "-" .. idx,
        type = "button",
        caption = caption,
        style = "tnp_stationlist_stationlistentry"
    })
    tnp_state_gui_set(gui_button, player, 'station', station)

    if tablename == "train" then
        return
    end

    if home == true then
        local gui_home_button = gui_row.add({
            name = "tnp-stationlist-pinhome-" .. idx,
            type = "sprite-button",
            sprite = "tnp_button_stationlist_home",
            style = "tnp_stationlist_stationlisthome",
            enabled = false
        })
    elseif tablename == "all" then
        local pinstyle = "tnp_stationlist_stationlistpin"
        if pinned == true then
            pinstyle = "tnp_stationlist_stationlistpinned"
        end

        local gui_pin_button = gui_row.add({
            name = "tnp-stationlist-pinall-" .. idx,
            type = "sprite-button",
            sprite = "tnp_button_stationlist_pin",
            style = pinstyle
        })
        tnp_state_gui_set(gui_pin_button, player, 'pinstation', station)
    end
end

-- tnp_gui_stationlist_close()
--   Destroys a station select gui
function tnp_gui_stationlist_close(player)
    if not player.valid then
        _tnp_state_gui_prune()
        return
    end

    local gui = tnp_state_player_get(player, 'gui')
    if gui and gui.valid then
        gui.destroy()
    end

    tnp_state_player_delete(player, 'gui')
    _tnp_state_gui_prune()

    if tnp_state_player_any('gui') == false then
        devent_disable('gui_selected_tab_changed')
        devent_disable('gui_switch_state_changed')
    end
end

-- tnp_gui_stationlist_update()
--   Updates a stationlist gui, generally as a result of a search or tab change
function tnp_gui_stationlist_update(player)
    local element = tnp_state_player_get(player, 'gui_stationsearch')

    if not element or not element.valid then
        return
    end

    local gui_main = element.parent.parent
    local search = element.text:lower()

    for _, gui_tabs in pairs(gui_main.children) do
        if gui_tabs.name == "tnp-sl-tabs" then
            local gui_scroll_target = "tnp-sl-scroll-" .. gui_tabs.selected_tab_index

            for _, gui_scroll in pairs(gui_tabs.children) do
                if gui_scroll.name == gui_scroll_target then
                    local stationtable = gui_scroll.children[1]
                    for _, row in pairs(stationtable.children) do
                        local station = row.children[1]
                        if search == "" or station.caption:lower():find(search, 1, true) ~= nil then
                            row.visible = true
                        else
                            row.visible = false
                        end
                    end
                end
            end
        end
    end
end

function tnp_gui_stationlist_search_confirm(player, element)
    element = element or tnp_state_player_get(player, 'gui_stationsearch')

    if not element or not element.valid then
        return
    end

    for _, gui_tabs in pairs(element.parent.parent.children) do
        if gui_tabs.name == "tnp-sl-tabs" then
            local gui_scroll_target = "tnp-sl-scroll-" .. gui_tabs.selected_tab_index

            for _, gui_scroll in pairs(gui_tabs.children) do
                if gui_scroll.name == gui_scroll_target then
                    local stationtable = gui_scroll.children[1]
                    for _, row in pairs(stationtable.children) do
                        if row and row.valid and row.visible then
                            return tnp_action_stationselect_redispatch(player, row.children[1])
                        end
                    end
                end
            end
        end
    end
end