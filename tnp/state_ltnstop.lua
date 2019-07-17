--[[
    State Table:
        stop            - LuaEntity, ltn stop we're tracking
        depot           - boolean, marks the ltn stop as a depot
]]

-- tnp_state_ltnstop_destroy()
--   Destroys all state for ltn stops
function tnp_state_ltnstop_destroy()
    global.ltnstop_data = {}
end

-- tnp_state_ltnstop_get()
--   Gets state information about a LuaEntity
function tnp_state_ltnstop_get(ent, key)
    if not ent.valid then
        return false
    end

    if global.ltnstop_data[ent.unit_number] and global.ltnstop_data[ent.unit_number][key] then
        return global.ltnstop_data[ent.unit_number][key]
    end

    return nil
end

-- tnp_state_ltnstop_set()
--   Sets state information about a LuaEntity
function tnp_state_ltnstop_set(ent, key, value)
    if not ent.valid then
        return false
    end

    if not global.ltnstop_data[ent.unit_number] then
        global.ltnstop_data[ent.unit_number] = {}
        global.ltnstop_data[ent.unit_number]['stop'] = ent
    end

    global.ltnstop_data[ent.unit_number][key] = value
    return true
end