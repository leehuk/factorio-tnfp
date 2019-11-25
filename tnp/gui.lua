-- tnp_gui_stationlist()
--   Draws the station select gui
function tnp_gui_stationlist(player, train)
    local config = settings.get_player_settings(player)

    -- If a GUI already exists destroy it
    for _, child in pairs(player.gui.center.children) do
        if child.name == "tnp-stationlist" then
            child.destroy()
        end
    end

    -- Top Frame
    local gui_top = player.gui.center.add({
        name = "tnp-stationlist",
        type = "frame",
        direction = "vertical",
        style = "tnp_stationlist"
    })
    tnp_state_player_set(player, 'gui', gui_top)

    -- Heading Flow (Borderless)
    local gui_heading_area = gui_top.add({
        name = "tnp-stationlist-headingarea",
        type = "flow",
        direction = "horizontal",
        style = "tnp_stationlist_headingarea"
    })
    gui_heading_area.add({
        name = "tnp-stationlist-headingtext",
        type = "label",
        caption = {"tnp_gui_stationlist_heading"},
        style = "tnp_stationlist_headingtext"
    })

    local gui_heading_buttonarea = gui_heading_area.add({
        name = "tnp-stationlist-headingbuttonarea",
        type = "flow",
        direction = "horizontal",
        style = "tnp_stationlist_headingbuttonarea"
    })
    local gui_railtool = gui_heading_buttonarea.add({
        name = "tnp-stationlist-headingbutton-railtool",
        type = "sprite-button",
        sprite = "tnp_button_railtool",
        style = "tnp_stationlist_headingbutton_railtool"
    })
    gui_heading_buttonarea.add({
        name = "tnp-stationlist-headingbutton-spacer1",
        type = "flow",
        direction = "horizontal",
        style = "tnp_stationlist_headingbutton_spacer"
    })
    local gui_close = gui_heading_buttonarea.add({
        name = "tnp-stationlist-headingbutton-close",
        type = "sprite-button",
        sprite = "tnp_button_close",
        style = "tnp_stationlist_headingbutton_close"
    })
    tnp_state_gui_set(gui_close, player, 'close', true)

    gui_top.add({
        name = "tnp-stationlist-heading-line",
        type = "line",
        direction = "horizontal"
    })

    -- Station Type Frame
    local gui_stationtype_area = gui_top.add({
        name = "tnp-stationlist-stationtypearea",
        type = "flow",
        direction = "horizontal",
        style = "tnp_stationlist_stationtypearea"
    })
    gui_stationtype_area.add({
        name = "tnp-stationlist-stationtypetext",
        type = "label",
        caption = {"tnp_gui_stationlist_stationtype"},
        style = "tnp_stationlist_stationtypetext"
    })
    local gui_stationtype_table = gui_stationtype_area.add({
        name = "tnp-stationlist-stationtypetable",
        type = "table",
        column_count = 3,
        style = "tnp_stationlist_stationtypetable"
    })
    local gui_stationtype_train = gui_stationtype_table.add({
        name = "tnp-stationlist-stationtypetrain",
        type = "radiobutton",
        caption = {"tnp_gui_stationlist_stationtype_schedule"},
        state = false,
        style = "tnp_stationlist_stationtyperadio"
    })
    local gui_stationtype_tnfp = gui_stationtype_table.add({
        name = "tnp-stationlist-stationtypetnfp",
        type = "radiobutton",
        caption = {"tnp_gui_stationlist_stationtype_tnfp"},
        state = false,
        style = "tnp_stationlist_stationtyperadio"
    })
    local gui_stationtype_all = gui_stationtype_table.add({
        name = "tnp-stationlist-stationtypeall",
        type = "radiobutton",
        caption = {"tnp_gui_stationlist_stationtype_all"},
        state = false,
        style = "tnp_stationlist_stationtyperadio"
    })

    if config['tnp-stationlist-view'].value == 'tnfp' then
        gui_stationtype_tnfp.state = true
    elseif config['tnp-stationlist-view'].value == 'train' then
        gui_stationtype_train.state = true
    else
        gui_stationtype_all.state = true
    end

    local gui_stationsearch_area = gui_top.add({
        name = "tnp-stationlist-searcharea",
        type = "flow",
        direction = "vertical",
        style = "tnp_stationlist_searcharea"
    })

    local gui_stationsearch = gui_stationsearch_area.add({
        name = "tnp-stationlist-search",
        type = "textfield",
        style = "tnp_stationlist_search",
        selectable = true,
        clear_and_focus_on_right_click = true
    })
    tnp_state_player_set(player, 'gui_stationsearch', gui_stationsearch)

    if config['tnp-stationlist-focussearch'].value == true then
        gui_stationsearch.focus()
    end

    -- Station Lists, scroll panes
    local gui_stationlist_tnfp = gui_top.add({
        name = "tnp-stationlist-stationlisttnfp",
        type = "scroll-pane",
        style = "tnp_stationlist_stationlistscroll",
        horizontal_scroll_policy = "auto-and-reserve-space",
        visible = false
    })
    local gui_stationtable_tnfp = gui_stationlist_tnfp.add({
        name = "tnp-stationlist-stationtabletnfp",
        type = "table",
        column_count = 1,
        style = "tnp_stationlist_stationlisttable"
    })
    local gui_stationlist_train = gui_top.add({
        name = "tnp-stationlist-stationlisttrain",
        type = "scroll-pane",
        style = "tnp_stationlist_stationlistscroll",
        horizontal_scroll_policy = "auto-and-reserve-space",
        visible = false
    })
    local gui_stationtable_train = gui_stationlist_train.add({
        name = "tnp-stationlist-stationtabletrain",
        type = "table",
        column_count = 1,
        style = "tnp_stationlist_stationlisttable"
    })
    local gui_stationlist_all = gui_top.add({
        name = "tnp-stationlist-stationlistall",
        type = "scroll-pane",
        style = "tnp_stationlist_stationlistscroll",
        horizontal_scroll_policy = "auto-and-reserve-space",
        visible = false
    })
    local gui_stationtable_all = gui_stationlist_all.add({
        name = "tnp-stationlist-stationtableall",
        type = "table",
        column_count = 1,
        style = "tnp_stationlist_stationlisttable"
    })

    tnp_state_player_set(player, 'gui_stationtableall', gui_stationtable_all)
    tnp_state_player_set(player, 'gui_stationtabletnfp', gui_stationtable_tnfp)
    tnp_state_player_set(player, 'gui_stationtabletrain', gui_stationtable_train)

    if gui_stationtype_tnfp.state == true then
        gui_stationlist_tnfp.visible = true
    elseif gui_stationtype_train.state == true then
        gui_stationlist_train.visible = true
    elseif gui_stationtype_all.state == true then
        gui_stationlist_all.visible = true
    end

    tnp_gui_stationlist_build(player, train)
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

    -- Collate a full list of all stops, so we can sort them alphabetically
    local stations_unsorted = player.surface.find_entities_filtered({
        type = "train-stop"
    })
    local stations_key = {}
    local stations_map = {}
    local stations_map_count = {}

    for _, station in pairs(stations_unsorted) do
        if tnp_stop_danger(station) == false then
            if not stations_map[station.backer_name] then
                table.insert(stations_key, station.backer_name)
                stations_map[station.backer_name] = station
                stations_map_count[station.backer_name] = 1
            else
                stations_map_count[station.backer_name] = stations_map_count[station.backer_name] + 1
            end
        end
    end
    table.sort(stations_key)

    gui_stationtable_all.clear()
    gui_stationtable_tnfp.clear()
    gui_stationtable_train.clear()

    -- For optimisation we want to make as few passes over the circuit network as possible, so we loop once
    -- over our list to collate all the special statuses a stop may have affecting the gui.
    local stations_added = {}
    local stations_pinned = {}
    local stations_tnfp = {}
    local stations_tnfphome = {}

    for i, stationname in ipairs(stations_key) do
        local is_tnp = tnp_stop_check(stations_map[stationname])
        if is_tnp == 2 then
            -- Home stations are not marked as pinned, or normal tnfp stations.
            stations_tnfphome[i] = true
        else
            if is_tnp == 1 then
                stations_tnfp[i] = true
            end

            if tnp_state_stationpins_check(player, stations_map[stationname]) == true then
                stations_pinned[i] = true
            end
        end
    end

    -- Add home stations first to the top of the tnp and all lists
    for i, stationname in ipairs(stations_key) do
        if stations_tnfphome[i] == true then
            tnp_gui_stationlist_addentry(player, gui_stationtable_tnfp, "tnfp", i, stations_map[stationname], stations_map_count[stationname], false, true)
            tnp_gui_stationlist_addentry(player, gui_stationtable_all, "all", i, stations_map[stationname], stations_map_count[stationname], false, true)

            stations_added[i] = true
        end
    end

    -- Then add pinned stations to the top of the all list
    for i, stationname in ipairs(stations_key) do
        if stations_pinned[i] == true then
            tnp_gui_stationlist_addentry(player, gui_stationtable_all, "all", i, stations_map[stationname], stations_map_count[stationname], true, false)
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
                    tnp_gui_stationlist_addentry(player, gui_stationtable_train, "train", i, stations_map[stationname], stations_map_count[stationname], false, false)
                end
            end
        end

        if stations_added[i] == nil then
            if stations_tnfp[i] == true then
                tnp_gui_stationlist_addentry(player, gui_stationtable_tnfp, "tnfp", i, stations_map[stationname], stations_map_count[stationname], false, false)
            end

            tnp_gui_stationlist_addentry(player, gui_stationtable_all, "all", i, stations_map[stationname], stations_map_count[stationname], false, false)
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
end

-- tnp_gui_stationlist_search()
--   Handles filtering the list of stations in the stationselect
function tnp_gui_stationlist_search(player, element)
    element = element or tnp_state_player_get(player, 'gui_stationsearch')

    if not element or not element.valid then
        return
    end

    local gui_stationsearch_area = element.parent
    local gui_top = gui_stationsearch_area.parent
    local search = element.text:lower()

    for _, stationlist in pairs(gui_top.children) do
        if stationlist.name:sub(1, 27) == "tnp-stationlist-stationlist" then
            local stationtable = stationlist.children[1]
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

function tnp_gui_stationlist_search_confirm(player, element)
    element = element or tnp_state_player_get(player, 'gui_stationsearch')

    if not element or not element.valid then
        return
    end

    local gui_stationsearch_area = element.parent
    local gui_top = gui_stationsearch_area.parent

    for _, stationlist in pairs(gui_top.children) do
        if stationlist.name:sub(1, 27) == "tnp-stationlist-stationlist" then
            local stationtable = stationlist.children[1]
            for _, row in pairs(stationtable.children) do
                if row and row.valid and row.visible then
                    local station = row.children[1]
                    return tnp_action_stationselect_redispatch(player, station)
                end
            end
        end
    end
end

-- tnp_gui_stationlist_switch()
--   Switches the type of stationlist shown
function tnp_gui_stationlist_switch(player, element)
    -- First, we need to switch off the other radio buttons
    local gui_stationtype_table = element.parent
    if gui_stationtype_table.name == "tnp-stationlist-stationtypetable" then
        for _, child in pairs(gui_stationtype_table.children) do
            if child.index ~= element.index then
                child.state = false
            end
        end
    end

    -- Now we need to sort the scroll areas out
    local gui_top = gui_stationtype_table.parent.parent
    for _, child in pairs(gui_top.children) do
        if child.name == "tnp-stationlist-stationlisttnfp" then
            if element.name == "tnp-stationlist-stationtypetnfp" then
                child.visible = true
            else
                child.visible = false
            end
        elseif child.name == "tnp-stationlist-stationlisttrain" then
            if element.name == "tnp-stationlist-stationtypetrain" then
                child.visible = true
            else
                child.visible = false
            end
        elseif child.name == "tnp-stationlist-stationlistall" then
            if element.name == "tnp-stationlist-stationtypeall" then
                child.visible = true
            else
                child.visible = false
            end
        end
    end
end