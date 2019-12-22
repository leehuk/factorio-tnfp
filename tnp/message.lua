tnpdefines.loglevel = {
    core            = 1,
    standard        = 2,
    detailed        = 3
}

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

-- tnp_message()
--   Creates a message for a player
function tnp_message(msglevel, player, message, entity)
    local config_msglevel = settings.global['tnp-message-level'].value
    local config_msgtarget = settings.global['tnp-message-target'].value

    if not player.valid then
        return
    end

    local loglevel = tnpdefines.loglevel.detailed

    if config_msglevel == 'core' then
        loglevel = 1
    elseif config_msglevel == 'standard' then
        loglevel = 2
    end

    if msglevel > loglevel then
        return
    end

    -- determine where this message is going.  check for flying text first
    if entity or config_msgtarget == 'flying text' or
    (config_msgtarget == 'mixed core' and msglevel > tnpdefines.loglevel.core) or
    (config_msgtarget == 'mixed standard' and msglevel > tnpdefines.loglevel.standard) then
        if entity then
            tnp_message_flytext(player, entity.position, message)
        else
            tnp_message_flytext(player, player.position, message)
        end
    else
        player.print(message)
    end
end

-- tnp_speechbubble()
--   Displays a speechbubble above the player
function tnp_speechbubble(player, message)
    local bubble = tnp_state_player_get(player, 'speechbubble')
    if bubble and bubble.valid then
        bubble.destroy()
    end

    bubble = player.surface.create_entity({
        name = "tnp-speechbubble",
        type = "speech-bubble",
        text = message,
        position = player.position,
        target = player.character
    })
    tnp_state_player_set(player, 'speechbubble', bubble)
end

-- tnp_speechbubble_destroy()
--   Destroys a players speechbubble
function tnp_speechbubble_destroy(player)
    local bubble = tnp_state_player_get(player, 'speechbubble')

    if bubble then
        if bubble.valid then
            bubble.destroy()
        end

        tnp_state_player_delete(player, 'speechbubble')
    end
end