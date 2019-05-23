-- tnp_train_schedule_enact()
--   Helper function to enact a schedule change, including required markers
function tnp_train_schedule_enact(train, schedule)
    tnp_state_train_set(train, 'expect_schedulechange', true)
    train.schedule = Table.deep_copy(schedule)
end

-- tnp_train_schedule_restore()
--   Attempts to restore a trains schedule to saved state
function tnp_train_schedule_restore(train)
    local state = tnp_state_train_get(train, 'state')
    if state and state.schedule then
        tnp_train_schedule_enact(train, state.schedule)
        return true
    end

    return false
end