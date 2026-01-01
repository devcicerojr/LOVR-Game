
local spawn_collectables_system = {
  phase = "async",
  requires = {},
  update_fn = function (id, c, dt) --async
    
  end
}

local source = lovr.audio.newSource('assets/sound_fx/collecting.wav')
source:setLooping(false)

pr_event_bus:on('coin_collected', function(ecs)
  
  local effect_id = ecs:getEntityByTag('is_collected_coin_effect')
  ecs.entities[effect_id].state_machine.state_machine.current_state = "visible"
  source:play()
end)

return spawn_collectables_system