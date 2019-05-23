-- ptn_train_schedule_enact()
--   Helper function to enact a schedule change, including required markers
function ptn_train_schedule_enact(train, schedule)
    ptnlib_state_train_set(train, 'expect_schedulechange', true)
    train.schedule = Table.deep_copy(schedule)
end

-- ptn_train_schedule_restore()
--   Attempts to restore a trains schedule to saved state
function ptn_train_schedule_restore(train)
    local state = ptnlib_state_train_get(train, 'state')
    if state and state.schedule then
        ptn_train_schedule_enact(train, state.schedule)
        return true
    end

    return false
end