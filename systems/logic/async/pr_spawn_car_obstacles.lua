local spawn_car_obstacles_system = {
  phase = "async",
  requires = {},
  update_fn = function(ecs, dt)
    -- Spawning logic can be added here if needed
  end
}

local TILE_SPAWN_FACTOR = 8
local EVENT_COUNTER = 0

local source = lovr.audio.newSource('assets/sound_fx/car_coming.wav')
source:setLooping(false)

pr_event_bus:on('terrain_tile_spawned', function(ecs, spawn_pos)
  EVENT_COUNTER = EVENT_COUNTER + 1
  if EVENT_COUNTER % TILE_SPAWN_FACTOR ~= 0 then
    return
  end
  local obstacle_pos = vec3(spawn_pos)
  obstacle_pos.y = 0.5
  obstacle_pos.x = math.random(-15, 15)
  local spawned_obstacle = (require'../entities/dont_stop_delivery/pr_car_obstacle')(ecs, obstacle_pos)
  source:play()
end)

return spawn_car_obstacles_system