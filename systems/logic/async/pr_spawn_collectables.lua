
local spawn_collectables_system = {
  phase = "async",
  requires = {},
  update_fn = function (id, c, dt) --async
    
  end
}

pr_event_bus:on('terrain_tile_spawned', function(ecs, spawn_pos)
  local collectable_pos = vec3(spawn_pos)
  collectable_pos.y = 1
  collectable_pos.x = math.random(-15, 15)
  local spanwned_collectable = (require'../entities/dont_stop_delivery/pr_sphere_collectable')(ecs, collectable_pos)
end)

return spawn_collectables_system