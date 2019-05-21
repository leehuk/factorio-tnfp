local Entity = require('__stdlib__/stdlib/entity/entity')
local Event = require('__stdlib__/stdlib/event/event')
local Position = require('__stdlib__/stdlib/area/position')
local Table = require('__stdlib__/stdlib/utils/table')

-- ptnlib_direction_iscardinal()
--   Determines if a given direction is cardinal (N/E/S/W)
function ptnlib_direction_iscardinal(direction)
    if direction == defines.direction.north or direction == defines.direction.east or direction == defines.direction.south or direction == defines.direction.west then
        return true
    end
    
    return false
end

-- ptnlib_direction_closest()
--   Returns the closest entity from an array
function ptnlib_direction_closest(player, entities)
    local closest_ent = nil
    local closest_distance = 0
    
    for _, ent in pairs(entities) do
        if closest_ent then
            distance = Position.distance(player.position, ent.position)
            if distance < closest_distance then
                closest_ent = ent
                closest_distance = distance
            end
        else
            closest_ent = ent
            closest_distance = Position.distance(player.position, ent.position)
        end
    end
    
    return closest_ent
end

-- ptnlib_stop_isptn()
--   Validates if a stop is assigned for PTN
function ptnlib_stop_isptn(stop)
    local signals = stop.get_merged_signals(defines.circuit_connector_id.combinator_input)
    if signals then
        for _, signal in pairs(signals) do
            if signal.signal.type == "virtual" and signal.signal.name == "ptn-station" then
                return true
            end
        end
    end
    
    return false
end

-- ptnlib_stop_getall()
--   Returns an array of all PTN train stops
function ptnlib_stop_getall(player)
    local ptn_stops = {}
    
    local entities = player.surface.find_entities_filtered({
        name = "train-stop"
    })
    for _, ent in pairs(entities) do
        if ptnlib_stop_isptn(ent) then
            table.insert(ptn_stops, ent)
        end
    end
    
    return ptn_stops
end

-- ptnlib_train_isptn()
--   Determines if a given train is one allocated to PTN
function ptnlib_train_isptn(player, train)
    -- Train schedules are not entity references but string based stop names, so go the long way round.
    local ptn_trains = ptnlib_train_getall(player)
    if ptn_trains then
        for _, v in pairs(ptn_trains) do
            if train.id == v.id then
                return true
            end
        end
    end
    
    return false
end

-- ptnlib_train_getall()
--    Returns an array of all trains allocated to PTN
function ptnlib_train_getall(player)
    local ptn_trains = {}
    local ptn_train_ids = {}
    
    local ptn_stops = ptnlib_stop_getall(player)
    for _, ent in pairs(ptn_stops) do        
        local trains = ent.get_train_stop_trains()
        if trains then
            for _, train in pairs(trains) do
                if not ptn_train_ids[train.id] then
                    table.insert(ptn_trains, train)
                    ptn_train_ids[train.id] = true
                end
            end
        end
    end
    
    return ptn_trains
end

function ptnlib_flytext(player, position, text)
    player.surface.create_entity({
        name = "flying-text",
        type = "flying-text",
        text = text,
        flags = { "not-on-map" },
        position = position,
        time_to_live = 150,
        speed = 0.05
    })
end

-- ptn_find_usable_stop()
--   Finds a suitable PTN location using an existing train stop
function ptn_find_usable_stop(player)
    -- Order of preference is:
    --   - Any train station with a PTN train stopped
    --   - A PTN station without a train
    --   - A normal station without a train
    
    local valid_stops_train = {}
    local valid_stops_ptn = {}
    local valid_stops_std = {}
    
    local entities = player.surface.find_entities_filtered({
        area = Position.expand_to_area(player.position, 32),
        name = "train-stop"
    })
    
    for _, ent in pairs(entities) do
        local train = ent.get_stopped_train()
        if train then
            -- Disallow train stations blocked by non-PTN trains
            if ptnlib_train_isptn(player, train) then
                ptnlib_flytext(player, ent.position, "Valid PTN train") 
                table.insert(valid_stops_train, ent)
            else
                ptnlib_flytext(player, ent.position, "Ignoring")
            end
        else
            if ptnlib_stop_isptn(ent) then
                ptnlib_flytext(player, ent.position, "PTN Train Station: Valid")
                table.insert(valid_stops_ptn, ent)
            else
                ptnlib_flytext(player, ent.position, "Train Station: Valid")
                table.insert(valid_stops_std, ent)
            end
        end
    end
    
    if #valid_stops_train > 0 then
        return ptnlib_direction_closest(player, valid_stops_train)
    elseif #valid_stops_ptn > 0 then
        return ptnlib_direction_closest(player, valid_stops_ptn)
    elseif #valid_stops_std > 0 then
        return ptnlib_direction_closest(player, valid_stops_std)
    end
    
    return nil
end

function ptn_find_usable_train(player, target)
    -- Ok, we actually need to dispatch a train
    local ptn_trains = ptnlib_train_getall(player)
    
    if #ptn_trains == 0 then
        player.print({"ptn_error_train_none", player.name})
        return
    end
    
    local ptn_train
    local ptn_train_distance = 0
    
    repeat
        local ptn_cand = ptn_trains[#ptn_trains]
        table.remove(ptn_trains)
        
        if not ptn_cand.front_rail or not ptn_cand.back_rail then
            break
        end
        
        distance = Position.distance(target.position, ptn_cand.front_rail.position)
        if ptn_train and distance >= ptn_train_distance then
            break
        end
        
        ptn_train = ptn_cand
        ptn_train_distance = distance
    until #ptn_trains == 0
    
    return ptn_train
end

function ptn_dispatch(player, target, train)
    local schedule = Table.deep_copy(train.schedule)
    
    local schedule_found = false

    -- Trains must have a schedule, as otherwise PTN wouldnt find them
    for i, ent in ipairs(schedule.records) do
        if ent.station == target.backer_name then
            schedule.current = i
            schedule_found = true
        end
    end

    if not schedule_found then
        table.insert(schedule.records, {
            station = target.backer_name,
            wait_conditions = {
                {
                    type = "passenger_present",
                    compare_type = "and"
                },
                {
                    type = "inactivity",
                    compare_type = "and",
                    ticks = 600
                },
                {
                    type="inactivity",
                    compare_type = "or",
                    ticks = 3000
                }
            }
        })

        schedule.current = #schedule.records
    end

    train.schedule = schedule
    if train.manual_mode then
        train.manual_mode = false
    end

    player.print({"ptn_train_called", player.name, target.backer_name})
end

function ptn_call(event)
    local player = game.players[event.player_index]
    if not player then
        player.print({"ptn_error_player", 'unk'})
        return
    end
    
    if not player.surface then
        player.print({"ptn_error_location_surface", player.name})
        return
    end
    
    if not player.position then
        player.print({"ptn_error_location_position", player.name})
        return
    end
    
    local target = ptn_find_usable_stop(player)
    if target then
        local train = target.get_stopped_train()
        if train then
            player.print({"ptn_train_waiting", player.name, target.backer_name})
            return
        end
        
        local train = ptn_find_usable_train(player, target)
        if not train then
            player.print({"ptn_error_train_find", player.name})
            return
        end
        
        ptn_dispatch(player, target, train)
    end
    
end

-- Input Handling
Event.register("ptn-call", ptn_call)