-- tnp_player_cursorstack()
--   Returns the item name under the cursor stack, or nil
function tnp_player_cursorstack(player)
    if not player or not player.valid then
        return
    end

    if player.cursor_stack and player.cursor_stack.valid and player.cursor_stack.valid_for_read then
        return player.cursor_stack.name
    end
end