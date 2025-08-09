local pr_ecs = require'../core/pr_ecs'
local player_id = nil

return {
  phase = "logic",
  requires = {"textured_mesh", "collider", "brush", "dynamic_spawner"},
  update_fn = function(id, c, dt) --update function
    if not player_id then
      player_id = pr_ecs:getEntityByTag('is_player')
      if not player_id then return end
    end
    local player = pr_ecs.entities[player_id]
    local player_pos_z = select(3 , player.transform.transform:getPosition())
    local entity = pr_ecs.entities[id]
    local collider = entity.collider.collider

    local pos_x, pos_y, pos_z = collider:getPosition()
    if player_pos_z - pos_z >= 200 then
      collider:destroy()
      pr_ecs.entities[id] = nil
      local spawn_pos = lovr.math.newVec3(pos_x, pos_y, pos_z + 400)
      local spanwned_tile = (require'../entities/brushes/pr_convex_hull_wall')(pr_ecs, spawn_pos, 1, 20, 20)
    end

  end
}