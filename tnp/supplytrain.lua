-- tnp_supplytrain_clear()
--   Clears gui elements and state tracking when a supply train request is cancelled
function tnp_supplytrain_clear(player)
    if not player or not player.valid then
        return
    end

    tnp_speechbubble_destroy(player)

    tnp_state_player_delete(player, 'supplyselection')
    tnp_state_player_delete(player, 'supplyselected')
end

-- tnp_supplytrain_select()
--   Sets up the available selections of supply trains and displays the first bubble
function tnp_supplytrain_select(player)
    tnp_supplytrain_clear()

    local supplytrains = tnp_train_getsupply(player)
    if #supplytrains == 0 then
        tnp_message(tnpdefines.loglevel.core, player, {"tnp_train_invalid"})
        return
    end

    local train = supplytrains[1]

    tnp_state_player_set(player, 'supplyselected', train)
    tnp_state_player_set(player, 'supplyselection', supplytrains)

    tnp_speechbubble(player, {"tnp_supplytrain_source", tnp_train_stationname(train)})

    return true
end

-- tnp_supplytrain_select_next()
--   Iterates the bubble and selection to next available supply train
function tnp_supplytrain_select_next(player)
    tnp_speechbubble_destroy(player)

    local selected = tnp_state_player_get(player, 'supplyselected')
    local options = tnp_state_player_get(player, 'supplyselection')
    local next = false

    for _, train in pairs(options) do
        if train.valid then
            if next then
                tnp_speechbubble(player, {"tnp_supplytrain_source", tnp_train_stationname(train)})
                tnp_state_player_set(player, 'supplyselected', train)
                return
            elseif train == selected then
                next = true
            end
        end
    end

    -- We've looped round once, return the first valid train we can find
    for _, train in pairs(options) do
        if train.valid then
            tnp_speechbubble(player, {"tnp_supplytrain_source", tnp_train_stationname(train)})
            tnp_state_player_set(player, 'supplyselected', train)
            return
        end
    end
end