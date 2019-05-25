-- tnp_direction_iscardinal()
--   Determines if a given direction is cardinal (N/E/S/W)
function tnp_direction_iscardinal(direction)
    if direction == defines.direction.north or direction == defines.direction.east or direction == defines.direction.south or direction == defines.direction.west then
        return true
    end

    return false
end

-- tnp_direction_closest()
--   Returns the closest entity from an array
function tnp_direction_closest(player, entities)
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