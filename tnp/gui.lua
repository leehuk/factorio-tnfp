-- tnp_gui_stationlist()
--   Draws the station select gui
function tnp_gui_stationlist(player, train)
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
        caption = "TNfP Station Select",
        style = "tnp_stationlist_headingtext"
    })
    local gui_close = gui_heading_area.add({
        name = "tnp-stationlist-headingbuttonclose",
        type = "sprite-button",
        sprite = "tnp_close",
        style = "tnp_stationlist_headingbutton"
    })
    tnp_state_gui_set(gui_close, player, 'close', true)

    -- Station Type Frame
    local gui_stationtype_area = gui_top.add({
        name = "tnp-stationlist-stationtypearea",
        type = "flow",
        direction = "vertical",
        style = "tnp_stationlist_stationtypearea"
    })
    local gui_stationtype_tnfp = gui_stationtype_area.add({
        name = "tnp-stationlist-stationtypetnfp",
        type = "radiobutton",
        caption = "Show TNfP Stations",
        state = false,
        style = "tnp_stationlist_stationtyperadio"
    })
    local gui_stationtype_train = gui_stationtype_area.add({
        name = "tnp-stationlist-stationtypetrain",
        type = "radiobutton",
        caption = "Show Stations from Train",
        state = false,
        style = "tnp_stationlist_stationtyperadio"
    })
    local gui_stationtype_all = gui_stationtype_area.add({
        name = "tnp-stationlist-stationtypeall",
        type = "radiobutton",
        caption = "Show All Stations",
        state = true,
        style = "tnp_stationlist_stationtyperadio"
    })

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
        name = "tnp-stationlist-stationtabletnfp",
        type = "table",
        column_count = 1,
        style = "tnp_stationlist_stationlisttable"
    })

    if gui_stationtype_tnfp.state == true then
        gui_stationlist_tnfp.visible = true
    elseif gui_stationtype_train == true then
        gui_stationlist_train.visible = true
    elseif gui_stationtype_all.state == true then
        gui_stationlist_all.visible = true
    end

    -- Ok, populate the trains station lists.
    -- First up, TNfP Stations
    local stations_unsorted = tnp_stop_getall(player)
    local stations_key = {}
    local stations_map = {}
    local stations_map_count = {}

    for _, station in pairs(stations_unsorted) do
        if not stations_map[station.backer_name] then
            table.insert(stations_key, station.backer_name)
            stations_map[station.backer_name] = station
            stations_map_count[station.backer_name] = 1
        else
            stations_map_count[station.backer_name] = stations_map_count[station.backer_name] + 1
        end
    end
    table.sort(stations_key)

    for i, station in ipairs(stations_key) do
        local caption = station
        if stations_map_count[station] > 1 then
            caption = caption .. " (" .. stations_map_count[station] .. ")"
        end

        local gui_button = gui_stationtable_tnfp.add({
            name = "tnp-stationlist-desttnfp-" .. i,
            type = "button",
            caption = caption,
            style = "tnp_stationlist_stationlistentry"
        })

        tnp_state_gui_set(gui_button, player, 'station', stations_map[station])
    end

    -- Secondly and thirdly, the stops this train has and the all list.  Both use the same data.
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

    for i, station in ipairs(stations_key) do
        -- The trains schedule is not a map to entities -- its just a set of string station names, so
        -- in order to fit our entity flow we'd have to map each one back to the entity.  Given we're
        -- looping over all train stops anyway, looping over the trains isnt unreasonable.
        local trains = stations_map[station].get_train_stop_trains()
        if trains then
            for _, stationtrain in pairs(trains) do
                if train.id == stationtrain.id then
                    local caption = station
                    if stations_map_count[station] > 1 then
                        caption = caption .. " (" .. stations_map_count[station] .. ")"
                    end

                    local gui_button = gui_stationtable_train.add({
                        name = "tnp-stationlist-desttrain-" .. i,
                        type = "button",
                        caption = caption,
                        style = "tnp_stationlist_stationlistentry"
                    })
                    tnp_state_gui_set(gui_button, player, 'station', stations_map[station])
                end
            end
        end

        local caption = station
        if stations_map_count[station] > 1 then
            caption = caption .. " (" .. stations_map_count[station] .. ")"
        end

        local gui_button = gui_stationtable_all.add({
            name = "tnp-stationlist-destall-" .. i,
            type = "button",
            caption = caption,
            style = "tnp_stationlist_stationlistentry"
        })
        tnp_state_gui_set(gui_button, player, 'station', stations_map[station])
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

-- tnp_gui_stationlist_switch()
--   Switches the type of stationlist shown
function tnp_gui_stationlist_switch(player, element)
    -- First, we need to switch off the other radio buttons
    local gui_stationtype_area = element.parent
    if gui_stationtype_area.name == "tnp-stationlist-stationtypearea" then
        for _, child in pairs(gui_stationtype_area.children) do
            if child.index ~= element.index then
                child.state = false
            end
        end
    end

    -- Now we need to sort the scroll areas out
    local gui_top = gui_stationtype_area.parent
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