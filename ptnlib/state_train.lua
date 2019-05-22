local Table = require('__stdlib__/stdlib/utils/table')

-- Status Table:
--   nil = Untracked
--   1   = Dispatching to player (awaiting confirmation)
--   2   = Dispatched to player (confirmed)
--   3   = Arrived at destination
--   4   = Player has boarded

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