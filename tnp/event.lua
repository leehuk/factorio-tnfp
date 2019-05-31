-- tnp_handle_gui_check()
--   Handles a gui checkbox/radiobutton being selected
function tnp_handle_gui_check(event)
    local player = game.players[event.player_index]

    if not player.valid then
        return
    end

    if event.element.name == "tnp-stationlist-stationtypetnfp" or event.element.name == "tnp-stationlist-stationtypetrain" or event.element.name == "tnp-stationlist-stationtypeall" then
        tnp_gui_stationlist_switch(player, event.element)
    end
end

-- tnp_handle_gui_click()
--   Handles a gui click
function tnp_handle_gui_click(event)
    local player = game.players[event.player_index]

    if not player.valid then
        return
    end

    if event.element.name == "tnp-stationlist-headingbuttonclose" then
        tnp_gui_stationlist_close(player)
    elseif string.find(event.element.name, "tnp-stationlist-dest", 1, true) ~= nil then
        -- Pull state information *before* we trash it
        local station = tnp_state_gui_get(event.element, player, 'station')

        tnp_gui_stationlist_close(player)

        -- Validate the player is on a train
        if station and player.vehicle and player.vehicle.train and player.vehicle.train.valid then
            tnp_action_train_redispatch(player, station, player.vehicle.train)
        end
    end
end

-- tnp_handle_input()
--   Handles a request via the custom input
function tnp_handle_input(event)
    tnp_handle_request(event, false)
end

-- tnp_handle_request()
--   Handles a request for a TNfP Train via input
function tnp_handle_request(event, shortcut)
    local player = game.players[event.player_index]

    if not player.valid then
        return
    end

    if not player.surface then
        tnp_message(tnpdefines.loglevel.core, player, {"tnp_error_location_surface", player.name})
        return
    end

    if not player.position then
        tnp_message(tnpdefines.loglevel.core, player, {"tnp_error_location_position", player.name})
        return
    end

    -- Determine whether we're already handling a request
    local train = tnp_state_player_get(player, 'train')
    if train then
        if shortcut then
            tnp_train_enact(train, true, nil, nil, false)
            tnp_action_request_cancel(player, train, {"tnp_train_cancelled"})
        else
            --- !!!: TODO
            tnp_action_request_status(player, train)
        end
    else
        tnp_action_request_create(player)
        player.set_shortcut_toggled('tnp-handle-request', true)
    end
end

-- tnp_handle_shortcut()
--   Handles a shortcut being pressed
function tnp_handle_shortcut(event)
    if event.prototype_name == "tnp-handle-request" then
        tnp_handle_request(event, true)
    end
end

-- tnp_handle_tick_timeout()
--   Handle a per-second event to timeout train deliveries
function tnp_handle_tick_timeout(event)
    tnp_action_timeout()
end

-- tnp_handle_player_vehicle()
--   Handles a player entering or exiting a vehicle
function tnp_handle_player_vehicle(event)
    local player = game.players[event.player_index]

    if not player.valid then
        return
    end

    -- This player doesnt have a request outstanding
    if not tnp_state_player_query(player) then
        return
    end

    -- Dont track entering non-train vehicles
    if not event.entity.train then
        return
    end

    if player.vehicle then
        local train = tnp_state_player_get(player, 'train')
        if not train or not train.valid then
            -- The train we were tracking is now invalid, and will have a limbo schedule unfortunately.
            tnp_message(tnpdefines.loglevel.core, player, {"tnp_train_cancelled_invalid"})
            tnp_action_request_cancel(player, nil, nil)
        elseif train.id == event.entity.train.id then
            -- Player has successfully boarded their tnp train
            tnp_action_request_board(player, train)
        end
    else
        -- Player has exited a train.
        -- Close the station select screen if its open.
        local gui = tnp_state_player_get(player, 'gui')
        if gui and gui.valid then
            tnp_gui_stationlist_close(player)
        end

        -- Check if we were redispatching for this player
        local train = tnp_state_player_get(player, 'train')
        if train and train.valid then
            local status = tnp_state_train_get(train, 'status')
            if status and status == tnpdefines.train.status.redispatched then
                tnp_train_enact(train, true, nil, nil, nil)
                tnp_action_request_cancel(player, train, nil)
            end
        end
    end
end


-- tnp_handle_train_schedulechange()
--   Handles a trains schedule being changed
function tnp_handle_train_schedulechange(event)
    -- A train we're not tracking
    if not tnp_state_train_query(event.train) then
        return
    end

    local player = nil
    if event.player_index and game.players[event.player_index] then
        player = game.players[event.player_index]
    end

    tnp_action_train_schedulechange(event.train, player)
end

-- tnp_handle_train_statechange()
--   Handles a trains state being changed
function tnp_handle_train_statechange(event)
    -- A train we're not tracking
    if not tnp_state_train_query(event.train) then
        return
    end

    tnp_action_train_statechange(event.train)
end