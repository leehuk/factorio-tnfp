Position = require('__stdlib__/stdlib/area/position')
Table = require('__stdlib__/stdlib/utils/table')

tnpdefines = {}

require('tnp/action')
require('tnp/event')
require('tnp/direction')
require('tnp/message')
require('tnp/state_player')
require('tnp/state_train')
require('tnp/stop')
require('tnp/train')

-- Event Handling
-----------------
-- Player Events
script.on_event(defines.events.on_player_driving_changed_state, tnp_handle_player_vehicle)
--script.on_event(defines.events.on_player_died, tnp_handle_player_exit)
--script.on_event(defines.events.on_player_kicked, tnp_handle_player_exit)
--script.on_event(defines.events.on_player_left_game, tnp_handle_player_exit)

-- Shortcut Events
script.on_event(defines.events.on_lua_shortcut, tnp_handle_shortcut)

-- Train Events
script.on_event(defines.events.on_train_changed_state, tnp_handle_train_statechange)
script.on_event(defines.events.on_train_schedule_changed, tnp_handle_train_schedulechange)

-- Input Handling
script.on_event("tnp-handle-request", tnp_handle_request)