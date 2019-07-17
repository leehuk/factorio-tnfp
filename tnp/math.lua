-- tnp_math_distance()
--   Returns standard euclidean distance between two points
function tnp_math_distance(position1, position2)
    -- Euclidean distance: sqrt((x2-x1)^2 + (y2-y1)^2))
    local distance_squared = (position2.x - position1.x)^2 + (position2.y - position1.y)^2
    return distance_squared^0.5
end

-- tnp_math_postoarea()
--   Returns an area given a position and radius
function tnp_math_postoarea(position, radius)
    local area = {
        left_top = {
            position.x - radius,
            position.y - radius
        },
        right_bottom = {
            position.x + radius,
            position.y + radius
        }
    }

    return area
end