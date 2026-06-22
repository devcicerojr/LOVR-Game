-- Track playable X range: -10 to +10 (20 units wide)
-- Car collider half-width = 2, so car at X blocks [X-2, X+2]
-- Each pattern guarantees at least one corridor >= 3 units wide
-- Coin z offsets place a trail within the tile (tile depth = 20 units)
--
-- Car spawn Z derivation:
--   coins are stationary at coin_z; player reaches them in t = (coin_z - player_z) / player_speed
--   car must also arrive at coin_z in t:  car_z - CAR_SPEED * t = coin_z
--   => car_z = coin_z + CAR_SPEED * t

local CAR_SPEED        = 100  -- must match pr_car_obstacle_update.lua
local MIN_PLAYER_SPEED = 2.0  -- prevents huge spawns when player is nearly still

local player_id = nil

pr_event_bus:on('game_scene_unloaded', function()
  player_id     = nil
  EVENT_COUNTER = 0
end)

local PATTERNS = require'../systems/data/pr_spawn_patterns_data'

local PATTERN_INTERVAL = 5
local EVENT_COUNTER    = 0

pr_event_bus:on('terrain_tile_spawned', function(ecs, spawn_pos)
  EVENT_COUNTER = EVENT_COUNTER + 1
  if EVENT_COUNTER % PATTERN_INTERVAL ~= 0 then return end

  if not player_id then
    player_id = ecs:getEntityByTag('is_player')
  end
  if not player_id then return end

  local player_entity = ecs.entities[player_id]
  local player_z      = select(3, player_entity.transform.transform:getPosition())
  local player_speed  = math.max(player_entity.acc_dec_movement.current_speed:length(), MIN_PLAYER_SPEED)

  local pattern  = PATTERNS[math.random(#PATTERNS)]
  local coin_z   = spawn_pos.z
  local t        = (coin_z - player_z) / player_speed
  local car_z    = coin_z + CAR_SPEED * t

  for _, obs in ipairs(pattern.obstacles) do
    local pos = lovr.math.newVec3(obs.x, 0.5, car_z)
    ;(require'../entities/dont_stop_delivery/pr_car_obstacle')(ecs, pos)
  end

  for _, coin in ipairs(pattern.coins) do
    local pos   = vec3(spawn_pos)
    pos.x = coin.x
    pos.y = 1
    pos.z = coin_z + coin.z
    ;(require'../entities/dont_stop_delivery/pr_sphere_collectable')(ecs, pos)
  end

  for _, ramp in ipairs(pattern.ramps or {}) do
    local pos = lovr.math.newVec3(ramp.x, 0, coin_z)
    ;(require'../entities/dont_stop_delivery/pr_ramp')(ecs, pos)
  end
end)

return {
  phase    = "async",
  requires = {},
  update_fn = function(ecs, id, c, dt) end,
}
