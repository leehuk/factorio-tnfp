--[[
    State Table:
        dynamicstatus              = int, actual dispatching status
        expect_manualmode          = bool, marker to note a self-triggered event will fire for manual_mode
        expect_schedulechange      = bool, marker to note a self-triggered event will fire for a schedule change
        info                       = hash, stored information about a train we've modified such as schedule
        keep_schedule              = bool, marker to not reset the trains schedule when handling completion
        player                     = LuaPlayer, player requesting the train.  Cross-referenced by tnp_state_player
        station                    = LuaEntity, train station we're dispatching to
        status                     = int, current dispatching status
        timeout_arrival            = int, arrival timeout before cancelling the request
        timeout_railtooltest       = int, timeout before we expect a state change for railtool testing
        train                      = LuaTrain, the train we're tracking
]]

tnpdefines.train = {
    status = {
        dispatching         = 1,
        dispatched          = 2,
        arrived             = 3,
        redispatched        = 4,
        rearrived           = 5,
        railtooltest        = 6
    }
}

-- _tnp_state_train_prune()
--   Prune the state train data of any invalid trains
function _tnp_state_train_prune()
    for id, data in pairs(global.train_data) do
        if not data then
            global.train_data[id] = nil
        elseif not data.train then
            global.train_data[id] = nil
        elseif not data.train.valid then
            -- The train we were tracking is invalid, but we still have a player reference.  Notify them
            if data.player and data.player.valid then
                tnp_request_cancel(data.player, nil, {"tnp_train_cancelled_invalid"})
            end

            global.train_data[id] = nil
        elseif not data.player or not data.player.valid then
            -- The player we were tracking is invalid -- but the trains ok.  Cancel any dispatching.
            tnp_train_enact(train, true, nil, nil, false)
            global.train_data[id] = nil
        end
    end
end

-- tnp_state_train_delete()
--   Deletes state information about a LuaTrain, optionally by key
function tnp_state_train_delete(train, key)
    _tnp_state_train_prune()

    if not train.valid then
        return
    end

    if global.train_data[train.id] then
        if key then
            global.train_data[train.id][key] = nil
        else
            global.train_data[train.id] = nil
        end
    end
end

-- tnp_state_train_get()
--   Gets state information about a LuaTrain by key
function tnp_state_train_get(train, key)
    _tnp_state_train_prune()

    if not train.valid then
        return false
    end

    if global.train_data[train.id] and global.train_data[train.id][key] then
        return global.train_data[train.id][key]
    end

    return nil
end

-- tnp_state_train_query()
--   Determines if a given train is being tracked by TNfP
function tnp_state_train_query(train)
    if not train.valid then
        return false
    end

    if global.train_data[train.id] then
        return true
    end

    return false
end

-- tnp_state_train_reset()
--   Resets non-core state information about a LuaTrain
function tnp_state_train_reset(train)
    _tnp_state_train_prune()

    if not train.valid then
        return false
    end

    if global.train_data[train.id] then
        local player = global.train_data[train.id]['player']

        global.train_data[train.id] = {}
        global.train_data[train.id]['train'] = train
        global.train_data[train.id]['player'] = player
    end
end

-- tnp_state_train_set()
--   Saves state informationa bout a LuaTrain by key
function tnp_state_train_set(train, key, value)
    _tnp_state_train_prune()

    if not train.valid then
        return false
    end

    if not global.train_data[train.id] then
        global.train_data[train.id] = {}
        global.train_data[train.id]['train'] = train
    end

    global.train_data[train.id][key] = value
    return true
end

-- tnp_state_train_timeout()
--   Drops timeouts on all trains and returns a list of any now expired requests
function tnp_state_train_timeout()
    local trains = {
        arrival = {},
        railtooltest = {}
    }

    for id, data in pairs(global.train_data) do
        -- Exclude any trains pending a prune, or without a timeout
        if data.train.valid then
            if data.timeout_arrival and data.timeout_arrival >= 0 then
                data.timeout_arrival = data.timeout_arrival - 1
                if data.timeout_arrival <= 0 then
                    table.insert(trains.arrival, data.train)
                end
            end

            if data.timeout_railtooltest and data.timeout_railtooltest >= 0 then
                data.timeout_railtooltest = data.timeout_railtooltest - 1
                if data.timeout_railtooltest <= 0 then
                    table.insert(trains.railtooltest, data.train)
                end
            end
        end
    end

    return trains
end