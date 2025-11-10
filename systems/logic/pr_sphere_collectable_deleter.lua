local pr_ecs = require'../core/pr_ecs'
local player_id = nil

return {
  phase = "logic",
  requires = {"transform", "is_collectable", "collider"},
  update_fn = function(id, c, dt) -- update function
    if not player_id then
      player_id = pr_ecs:getEntityByTag('is_player')
      if not player_id then return end
    end
    local player = pr_ecs.entities[player_id]
    local player_pos_z = select(3 , player.transform.transform:getPosition())
    local entity_transform = pr_ecs.entities[id].transform.transform
    local position_z = select(3 , entity_transform:getPosition())
    local collider = pr_ecs.entities[id].collider.collider
    
    if player_pos_z - position_z >= 200 then
      print("Deleting collectable")
      pr_ecs.entities[id] = nil
      collider:destroy()
      pr_event_bus:emit('coin_collected', pr_ecs)
    end
  end
}