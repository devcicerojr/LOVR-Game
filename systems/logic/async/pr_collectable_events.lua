
local current_pitch     = 1.0
local last_collect_time = -math.huge
local PITCH_STEP        = 0.03
local RESET_DELAY       = 1.5

local SFX_POOL_SIZE = 3
local sfx_pool  = {}
local sfx_index = 1
for i = 1, SFX_POOL_SIZE do
  local s = lovr.audio.newSource('assets/sound_fx/collecting2.wav', {spatial = false, decode = true})
  s:setVolume(0.7)
  s:setLooping(false)
  sfx_pool[i] = s
end

local collectable_events_system = {
  phase = "async",
  requires = {},
  update_fn = function(ecs, id, c, dt)
    if current_pitch > 1.0 and (lovr.timer.getTime() - last_collect_time) >= RESET_DELAY then
      current_pitch = 1.0
      for i = 1, SFX_POOL_SIZE do sfx_pool[i]:setPitch(1.0) end
    end
  end
}

pr_event_bus:on('coin_collected', function(ecs, id)
  local effect_id = ecs:getEntityByTag('is_collected_coin_effect')
  ecs.entities[effect_id].state_machine.state_machine.current_state = "visible"
  for i = 1, SFX_POOL_SIZE do sfx_pool[i]:setPitch(current_pitch) end
  sfx_pool[sfx_index]:stop()
  sfx_pool[sfx_index]:play()
  sfx_index = (sfx_index % SFX_POOL_SIZE) + 1
  current_pitch     = current_pitch + PITCH_STEP
  last_collect_time = lovr.timer.getTime()

  local collider = ecs.entities[id].collider.collider
  if not collider:isDestroyed() then
    collider:destroy()
  end
  table.insert(ecs.ids_for_deletion, id)
end)


pr_event_bus:on('coin_expired', function(ecs, id)
  local collider = ecs.entities[id].collider.collider
  if not collider:isDestroyed() then
    collider:destroy()
  end
  table.insert(ecs.ids_for_deletion, id)
end)



return collectable_events_system
