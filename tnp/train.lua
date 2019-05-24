-- tnp_train_check()
--   Determines if a given train is one allocated to TNfP
function tnp_train_check(player, train)
    -- Train schedules are not entity references but string based stop names, so go the long way round.
    local tnp_trains = tnp_train_getall(player)
    if tnp_trains then
        for _, v in pairs(tnp_trains) do
            if train.id == v.id then
                return true
            end
        end
    end
    
    return false
end

-- tnp_train_find()
--   Finds a train usable by tnp
function tnp_train_find(player, target)
    -- Ok, we actually need to dispatch a train
    local tnp_trains = tnp_train_getall(player)

    if #tnp_trains == 0 then
        return
    end
    
    local tnp_train
    local tnp_train_distance = 0
    
    repeat
        local tnp_cand = tnp_trains[#tnp_trains]
        table.remove(tnp_trains)
        
        if not tnp_cand.front_rail or not tnp_cand.back_rail then
            break
        end
        
        distance = Position.distance(target.position, tnp_cand.front_rail.position)
        if tnp_train and distance >= tnp_train_distance then
            break
        end
        
        tnp_train = tnp_cand
        tnp_train_distance = distance
    until #tnp_trains == 0
    
    return tnp_train
end

-- tnp_train_getall()
--    Returns an array of all trains allocated to tnp
function tnp_train_getall(player)
    local tnp_trains = {}
    local tnp_train_ids = {}
    
    local tnp_stops = tnp_stop_getall(player)
    for _, ent in pairs(tnp_stops) do        
        local trains = ent.get_train_stop_trains()
        if trains then
            for _, train in pairs(trains) do
                if not tnp_train_ids[train.id] then
                    table.insert(tnp_trains, train)
                    tnp_train_ids[train.id] = true
                end
            end
        end
    end
    
    return tnp_trains
end

-- tnp_train_schedule_enact()
--   Helper function to enact a schedule change, including required markers
function tnp_train_schedule_enact(train, schedule)
    tnp_state_train_set(train, 'expect_schedulechange', true)
    train.schedule = Table.deep_copy(schedule)
end

-- tnp_train_schedule_restore()
--   Attempts to restore a trains schedule to saved state
function tnp_train_schedule_restore(train)
    local state = tnp_state_train_get(train, 'state')
    if state and state.schedule then
        tnp_train_schedule_enact(train, state.schedule)
        return true
    end

    return false
end