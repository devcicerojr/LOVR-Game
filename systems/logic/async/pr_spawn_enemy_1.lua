local TILE_SPAWN_FACTOR = 6
local MAX_ENEMIES       = 3
local EVENT_COUNTER     = 0

pr_event_bus:on('game_scene_unloaded', function()
  EVENT_COUNTER = 0
end)

pr_event_bus:on('terrain_tile_spawned', function(ecs, spawn_pos)
  EVENT_COUNTER = EVENT_COUNTER + 1
  if EVENT_COUNTER % TILE_SPAWN_FACTOR ~= 0 then return end

  local enemy_count = 0
  for _, e in pairs(ecs.entities) do
    if e.is_enemy_1 then enemy_count = enemy_count + 1 end
  end
  if enemy_count >= MAX_ENEMIES then return end

  local pos = lovr.math.newVec3(spawn_pos)
  pos.x = math.random(-8, 8)
  ;(require'../entities/dont_stop_delivery/pr_enemy_1')(ecs, pos)
end)

return {
  phase    = "async",
  requires = {},
  update_fn = function(ecs, id, c, dt) end,
}
