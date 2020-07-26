-- tnp_stop_check()
--   Validates if a stop is assigned for tnp, returning an array of bool statuses in the form
--   result[tnp = bool, home = bool, supply = bool, supplyidx = int]
function tnp_stop_check(stop)
    local result = {
        tnp       = false,
        home      = false,
        supply    = false,
        supplyidx = 0
    }

    -- tnp can only be assigned to vanilla stops
    if stop.name ~= "train-stop" then
        return result
    end

    local signals = stop.get_merged_signals(defines.circuit_connector_id.combinator_input)
    if signals then
        for _, signal in pairs(signals) do
            if signal.signal.type == "virtual" then
                if signal.signal.name == "tnp-station" then
                    result.tnp = true
                end
                if signal.signal.name == "tnp-station-home" then
                    result.home = true
                end
                if signal.signal.name == "tnp-station-supply" then
                    result.supply = true
                    result.supplyidx = signal.count
                end
            end
        end
    end

    return result
end

-- tnp_stop_danger(stop)
--   Checks whether a stop needs to be marked 'dangerous' or not for compatibility with other mods.
--   Other mods may rewrite a trains schedule, which would conflict with tnfps dispatch and make the stop 'dangerous' to use.
function tnp_stop_danger(stop)
    -- Vanilla train stops are always safe
    if stop.name == "train-stop" then
        return false
    end

    -- TSM (Train Supply Manager)
    -- Supplier train stops are always dangerous as they rewrite schedules.
    -- Provider train stops in theory are safe, but the tsm train counters only update if the stop a train is
    -- departing from is the previous one in its schedule.. which isnt true for tnp.
    if stop.name == "subscriber-train-stop" then
        return true
    elseif stop.name == "publisher-train-stop" then
        return true
    end

    -- LTN (Logistic Train Network)
    if stop.name == "logistic-train-stop" then
        if settings.global['tnp-trainstop-mod-behaviour'].value == "ignore" or tnp_state_ltnstop_get(stop, 'depot') then
            return true
        else
            return false
        end
    end

    -- No explicit compatibility, so fall back to the default mod setting.
    if settings.global['tnp-trainstop-mod-behaviour'].value == "safe" then
        return true
    else
        return false
    end
end

-- tnp_stop_find()
--   Finds a suitable tnp location using an existing train stop
function tnp_stop_find(player)
    local config = settings.get_player_settings(player)

    -- Order of preference is:
    --   - Any train station with a TNfP train stopped
    --   - A TNfP station without a train
    --   - A normal station (non-dangerous) without a train
    --   - An LTN station

    local valid_stops_train = {}
    local valid_stops_tnp = {}
    local valid_stops_std = {}
    local valid_stops_ltn = {}

    local entities = player.surface.find_entities_filtered({
        area = tnp_math_postoarea(player.position, config['tnp-train-search-radius'].value),
        type = "train-stop"
    })

    for _, ent in pairs(entities) do
        if ent.valid then
            local train = ent.get_stopped_train()
            if train then
                -- Disallow train stations blocked by non-TNfP trains
                if tnp_train_check(player, train) then
                    if ent.name == "logistic-train-stop" then
                        table.insert(valid_stops_ltn, ent)
                    else
                        table.insert(valid_stops_train, ent)
                    end
                end
            else
                local is_tnp = tnp_stop_check(ent)
                if is_tnp.tnp == true or is_tnp.home == true then
                    table.insert(valid_stops_tnp, ent)
                elseif tnp_stop_danger(ent) == false then
                    if ent.name == "logistic-train-stop" then
                        table.insert(valid_stops_ltn, ent)
                    else
                        table.insert(valid_stops_std, ent)
                    end
                end
            end
        end
    end

    if #valid_stops_train > 0 then
        return tnp_direction_closest(player, valid_stops_train)
    elseif #valid_stops_tnp > 0 then
        return tnp_direction_closest(player, valid_stops_tnp)
    elseif #valid_stops_std > 0 then
        return tnp_direction_closest(player, valid_stops_std)
    elseif #valid_stops_ltn > 0 then
        return tnp_direction_closest(player, valid_stops_ltn)
    end

    return nil
end

-- tnp_stop_getall()
--   Returns an array of all tnp train stops
function tnp_stop_getall(player)
    local tnp_stops = {}

    -- tnp train stops must be vanilla train stops, so search by name instead of type
    local entities = player.surface.find_entities_filtered({
        name = "train-stop"
    })
    for _, ent in pairs(entities) do
        local is_tnp = tnp_stop_check(ent)
        if is_tnp.tnp == true or is_tnp.home == true then
            table.insert(tnp_stops, ent)
        end
    end

    return tnp_stops
end

-- tnp_stop_getsupply()
--   Returns a hash of tnp supply train stops, in the form [{stop = LuaEntity, supplyidx = int}]
function tnp_stop_getsupply(player)
    local tnp_stops = {}

    -- tnp train stops must be vanilla train stops, so search by name instead of type
    local entities = player.surface.find_entities_filtered({
        name = "train-stop"
    })
    for _, ent in pairs(entities) do
        local is_tnp = tnp_stop_check(ent)
        if is_tnp.supply == true then
            tnp_stops[is_tnp.supplyidx] = ent
        end
    end

    return tnp_stops

end

-- tnp_stop_name()
--   Returns the name of a stop or creates one based off locations for rails
function tnp_stop_name(target)
    if not target or not target.valid then
        return "?"
    end

    if target.type == "straight-rail" then
        return "[" .. target.position.x .. "," .. target.position.y .. "]"
    else
        return target.backer_name
    end
end