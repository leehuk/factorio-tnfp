-- tnp_train_check()
--   Determines if a given train is one allocated to TNfP
function tnp_train_check(player, train)
    if not train.valid then
        return nil
    end

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

-- tnp_train_enact()
--   Helper function to enact a schedule change and manual mode, including required markers
function tnp_train_enact(train, schedule_lookup, schedule, manual_mode_pre, manual_mode_post)
    if not train.valid then
        return
    end

    if schedule_lookup then
        local info = tnp_state_train_get(train, 'info')
        if info and info.schedule then
            schedule = info.schedule
        end
    end

    if manual_mode_pre == false or manual_mode_pre == true then
        if train.manual_mode ~= manual_mode_pre then
            if manual_mode_pre == true then
                tnp_state_train_set(train, 'expect_manualmode', true)
            end

            train.manual_mode = manual_mode_pre
        end
    end

    if schedule then
        tnp_state_train_set(train, 'expect_schedulechange', true)
        train.schedule = Table.deep_copy(schedule)
    end

    if manual_mode_post == false or manual_mode_post == true then
        if manual_mode_post ~= train.manual_mode then
            if manual_mode_post == true then
                tnp_state_train_set(train, 'expect_manualmode', true)
            end

            train.manual_mode = manual_mode_post
        end
    end
end

-- tnp_train_find()
--   Finds a train usable by tnp
function tnp_train_find(player, target)
    -- Ok, we actually need to dispatch a train
    local tnp_trains = tnp_train_getall(player)

    if #tnp_trains == 0 then
        return nil
    end

    local tnp_train = nil
    local tnp_train_distance = 0

    repeat
        local tnp_cand = tnp_trains[#tnp_trains]
        table.remove(tnp_trains)

        if not tnp_cand.front_rail or not tnp_cand.back_rail then
            break
        end

        -- Do not schedule trains assigned to other players
        local scheduled_player = tnp_state_train_get(tnp_cand, 'player')
        if scheduled_player and (not scheduled_player.valid or scheduled_player.index ~= player.index) then
            break
        end

        -- Do not scheduled trains other players are the passenger of
        if tnp_cand.passengers and #tnp_cand.passengers > 0 then
            break
        end

        local distance = 0
        -- If we dont know where we're dispatching to, accept the train choice will be random.
        if target then
            distance = tnp_math_distance(target.position, tnp_cand.front_rail.position)
            if tnp_train and distance >= tnp_train_distance then
                break
            end
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
                if train.valid and not tnp_train_ids[train.id] then
                    table.insert(tnp_trains, train)
                    tnp_train_ids[train.id] = true
                end
            end
        end
    end

    return tnp_trains
end

-- tnp_train_info_save()
--   Collates a trains information for save state, such as manual_mode and schedule
--
-- inputs       - train, LuaTrain.  Must be valid.
-- outputs      - boolean.  Whether state was successfully saved.
function tnp_train_info_save(train)
    local info = {
        manual_mode = train.manual_mode,
        schedule = tnp_train_schedule_copy(train),
        state = train.state
    }

    return tnp_state_train_set(train, 'info', info)
end

-- tnp_train_schedule_check()
-- Checks a train schedule to see if it has a given station, returning its position if so
--
-- inputs       - schedule, hash(TrainSchedule).  Schedule to search.
--              - stationname, string.  Station name to search for.
-- outputs      - uint, station index.  When stationname is found in schedule.
--              - boolean false.  When stationname is not found in schedule.
function tnp_train_schedule_check(schedule, stationname)
    if not schedule or not schedule.records or #schedule.records == 0 then
        return false
    end

    for i, ent in ipairs(schedule.records) do
        if ent.station == stationname then
            return i
        end
    end

    return false
end

-- tnp_train_schedule_copy()
--   Copys a trains schedule, removing any temporary stations.
--
-- inputs:      train, LuaTrain. Must be valid.
-- outputs:     hash(TrainSchedule).
function tnp_train_schedule_copy(train)
    if not train.schedule or not train.schedule.records or #train.schedule.records == 0 then
        return nil
    end

    local schedule = {}
    schedule.records = {}

    for _, record in pairs(train.schedule.records) do
        -- Temporary stations to locations end up invalid when copied, so discard them
        if not record.temporary or record.temporary == false then
            table.insert(schedule.records, {
                station = record.station,
                wait_conditions = Table.deep_copy(record.wait_conditions)
            })
        end
    end

    -- If by stripping the temporary stations we've ended up with a blank schedule, we need to
    -- return an overall nil schedule to avoid an error.
    if #schedule.records == 0 then
        return nil
    end

    -- As we may have removed temporary stations, check the current station is still in bounds
    if train.schedule.current <= #schedule.records then
        schedule.current = train.schedule.current
    else
        schedule.current = 1
    end

    return schedule
end