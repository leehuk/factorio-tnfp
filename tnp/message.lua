-- tnp_message_flytext()
--   Creates flying text against a player
function tnp_message_flytext(player, position, text)
    player.surface.create_entity({
        name = "flying-text",
        type = "flying-text",
        text = text,
        flags = { "not-on-map" },
        position = position,
        time_to_live = 250,
        speed = 0.05
    })
end
