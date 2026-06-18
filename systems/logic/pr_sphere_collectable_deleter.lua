-- local ecs = require'../core/pr_ecs'
local player_id = nil
return {
  phase = "logic",
  requires = {"transform", "is_collectable", "collider"},
  update_fn = function(ecs, id, c, dt) -- update function
    if not player_id then
      player_id = ecs:getEntityByTag('is_player')
      if not player_id then return end
    end
    local player = ecs.entities[player_id]
    local player_pos_x = select(1 , player.transform.transform:getPosition())
    local player_pos_z = select(3 , player.transform.transform:getPosition())
    local entity_transform = ecs.entities[id].transform.transform
    local position_x = select(1 , entity_transform:getPosition())
    local position_z = select(3 , entity_transform:getPosition())
    local collider = ecs.entities[id].collider.collider
    if math.abs(player_pos_z - position_z) < 0.5
       and math.abs(player_pos_x - position_x) < 0.8 then
      pr_event_bus:emit('coin_collected', ecs, id)
    end
    if player_pos_z - position_z > 200 then
      pr_event_bus:emit('coin_expired', ecs, id)
    end
  end
}