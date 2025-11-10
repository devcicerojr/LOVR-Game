
local spawn_collectables_system = {
  phase = "async",
  requires = {},
  update_fn = function (id, c, dt) --async
    
  end
}

pr_event_bus:on('coin_collected', function(ecs)
  
  local effect_id = ecs:getEntityByTag('is_collected_coin_effect')
  ecs.entities[effect_id].state_machine.state_machine.current_state = "visible"
end)

return spawn_collectables_system