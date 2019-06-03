-- So this code really does exist.  There is no natural way through lua to determine what "direction"
-- trains may run in on any given piece of rail.  On a vertical rail they may run north to south or
-- south to north and as the signals may be LHD or RHD and we cant tell which, there's no way to
-- know how to orient the train station.  So we guess.
--
-- Firstly, we require that its possible to place a train stop on both sides of the rail, as if we can't
-- place a train stop due to a signal being in the way, we'd only be able to place on the 'invalid' side.
--
-- Once we know we can access both sides of the rails, we place an invisible train stop on either side and
-- then have our train attempt to path to them in turn.  At least one of them should hopefully work.


-- tnp_dynamicstop_calculate()
--   Calculates the position of a train stop, given the direction
function tnp_dynamicstop_calculate(position, direction)
    if direction == defines.direction.north then
        return { x = position.x + 2, y = position.y }
    elseif direction == defines.direction.south then
        return { x = position.x -2, y = position.y }
    end
end

-- tnp_dynamicstop_create()
--   Attempts to create a trainstop against a rail.
function tnp_dynamicstop_create(player, rail, train)
    if not rail or not rail.valid then
        return false
    end

    if rail.direction == defines.direction.north or rail.direction == defines.direction.south then
        local place_north = tnp_dynamicstop_place_check(player, rail, defines.direction.north)
        local place_south = tnp_dynamicstop_place_check(player, rail, defines.direction.south)

        if not place_north or not place_south then
            return false
        end

        local station_north = tnp_dynamicstop_place(player, rail, defines.direction.north)
        local station_south = tnp_dynamicstop_place(player, rail, defines.direction.south)
    elseif rail.direction == defines.direction.east or rail.direction == defines.direction.west then
    else
        -- err what?
        return false
    end
end

-- tnp_dynamicstop_dispatch()
--   Dispatches the train to the given stop
function tnp_dynamicstop_dispatch(player, station, train)
end

-- tnp_dynamicstop_place()
--   Runs a check to confirm if a train stop can be placed.
function tnp_dynamicstop_place(player, rail, direction)
    local position = tnp_dynamicstop_calculate(rail.position, direction)
    local station = player.surface.create_entity({
        name = "train-stop",
        position = position,
        direction = direction,
        force = player.force
    })

    if not station or not station.valid then
        return false
    end

    local name = "zTNfP Temporary [" .. position.x .. "," .. position.y .. "]"
    station.backer_name = name
end

-- tnp_dynamicstop_place_check()
--   Runs a check to confirm if a train stop can be placed.
function tnp_dynamicstop_place_check(player, rail, direction)
    return player.surface.can_place_entity({
        name = "train-stop",
        position = tnp_dynamicstop_calculate(rail.position, direction),
        direction = direction,
        force = player.force
    })
end