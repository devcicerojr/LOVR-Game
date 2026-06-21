
local collectable_events_system = {
  phase = "async",
  requires = {},
  update_fn = function(ecs, id, c, dt) --async
    
  end
}

local SFX_POOL_SIZE = 3
local sfx_pool  = {}
local sfx_index = 1
for i = 1, SFX_POOL_SIZE do
  local s = lovr.audio.newSource('assets/sound_fx/collecting.wav', {spatial = false})
  s:setVolume(0.05)
  s:setLooping(false)
  sfx_pool[i] = s
end

pr_event_bus:on('coin_collected', function(ecs, id)
  local effect_id = ecs:getEntityByTag('is_collected_coin_effect')
  ecs.entities[effect_id].state_machine.state_machine.current_state = "visible"
  sfx_pool[sfx_index]:stop()
  -- sfx_pool[sfx_index]:play()
  sfx_index = (sfx_index % SFX_POOL_SIZE) + 1
  
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