-- ptnlib_train_restoreschedule
--   Attempts to restore a trains schedule to saved state
function ptnlib_train_restoreschedule(train)
    local state = ptnlib_state_train_get(train, 'state')
    if state and state.schedule then
        train.schedule = Table.deep_copy(state.schedule)
        return true
    end

    return false
end