-- tnp_stop_check()
--   Validates if a stop is assigned for tnp
function tnp_stop_check(stop)
    local signals = stop.get_merged_signals(defines.circuit_connector_id.combinator_input)
    if signals then
        for _, signal in pairs(signals) do
            if signal.signal.type == "virtual" and signal.signal.name == "tnp-station" then
                return true
            end
        end
    end

    return false
end

-- tnp_stop_find()
--   Finds a suitable tnp location using an existing train stop
function tnp_stop_find(player)
    local config = settings.get_player_settings(player)

    -- Order of preference is:
    --   - Any train station with a TNfP train stopped
    --   - A TNfP station without a train
    --   - A normal station without a train

    local valid_stops_train = {}
    local valid_stops_tnp = {}
    local valid_stops_std = {}

    local entities = player.surface.find_entities_filtered({
        area = Position.expand_to_area(player.position, config['tnp-train-search-radius'].value),
        name = "train-stop"
    })

    for _, ent in pairs(entities) do
        if ent.valid then
            local train = ent.get_stopped_train()
            if train then
                -- Disallow train stations blocked by non-TNfP trains
                if tnp_train_check(player, train) then
                    table.insert(valid_stops_train, ent)
                end
            else
                if tnp_stop_check(ent) then
                    table.insert(valid_stops_tnp, ent)
                else
                    table.insert(valid_stops_std, ent)
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
    end

    return nil
end

-- tnp_stop_getall()
--   Returns an array of all tnp train stops
function tnp_stop_getall(player)
    local tnp_stops = {}

    local entities = player.surface.find_entities_filtered({
        type = "train-stop"
    })
    for _, ent in pairs(entities) do
        if tnp_stop_check(ent) then
            table.insert(tnp_stops, ent)
        end
    end

    return tnp_stops
end
