--[[
    State Table:
        expect_schedulechange      = bool, marker to note we've made a schedule change which we'll see an event handler for
        player                     = LuaPlayer, player requesting the train.  Cross-referenced by ptn_state_player
        state                      = hash, stored information about a train we've modified such as schedule
        station                    = LuaEntity, train station we're dispatching to
        status                     = int, current dispatching status
]]

ptndefines.train = {
    status = {
        dispatching         = 1,
        dispatched          = 2,
        arrived             = 3
    }
}

-- _ptnlib_state_train_prune()
--   Prune the state train data of any invalid trains
function _ptnlib_state_train_prune()
    if not global.train_data then
        global.train_data = {}
        return
    end

    for id, data in pairs(global.train_data) do
        if not data or not data.train or not data.train.valid then
            global.train_data[id] = nil
        end
    end
end

-- ptnlib_state_train_delete()
--   Deletes state information about a LuaTrain, optionally by key
function ptnlib_state_train_delete(train, key)
    _ptnlib_state_train_prune()

    -- Accept invalid trains(?) for same reason as invalid players.

    if key then
        if global.train_data[train.id] then
            global.train_data[train.id][key] = nil
        end
    else
        if global.train_data[train.id] then
            global.train_data[train.id] = nil
        end
    end
end

-- ptnlib_state_train_get()
--   Gets state information about a LuaTrain by key
function ptnlib_state_train_get(train, key)
    _ptnlib_state_train_prune()
    
    if not train.valid then
        return false
    end
    
    if global.train_data[train.id] and global.train_data[train.id][key] then
        return global.train_data[train.id][key]
    end
    
    return nil
end

-- ptnlib_state_train_query()
--   Determines if a given train is being tracked by PTN
function ptnlib_state_train_query(train)
    if not train.valid then
        return false
    end

    if global.train_data[train.id] then
        return true
    end

    return false
end
-- ptnlib_state_train_set()
--   Saves state informationa bout a LuaTrain by key
function ptnlib_state_train_set(train, key, value)
    _ptnlib_state_train_prune()

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

-- ptnlib_state_train_setstate()
--   Saves state information about a LuaTrain
function ptnlib_state_train_setstate(train)
    local state = {
        manual_mode = train.manual_mode,
        schedule = Table.deep_copy(train.schedule),
        state = train.state
    }

    return ptnlib_state_train_set(train, 'state', state)
end