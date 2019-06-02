-- tnp_draw_path()
--   Draws a straight-line path between a player and an entity
function tnp_draw_path(player, entity)
    if not player or not player.valid or not player.character or not entity or not entity.valid then
        return
    end

    local config = settings.get_player_settings(player)

    local path_color = {
        r = 0.5,
        g = 0.5,
        b = 0.5,
        a = 0.5
    }
    local path_ttl = 120

    for _, target in pairs({player.character, entity}) do
        rendering.draw_circle({
            color = path_color,
            radius = 0.33,
            filled = true,
            target = target,
            surface = player.surface,
            time_to_live = path_ttl,
            players = {
                player
            }
        })
    end

    rendering.draw_line({
        color = path_color,
        width = 1,
        from = player.character,
        to = entity,
        surface = player.surface,
        time_to_live = path_ttl,
        players = {
            player
        }
    })
end