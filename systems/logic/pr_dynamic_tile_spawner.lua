local pr_ecs = require'../core/pr_ecs'
local player_id = nil

return {
  phase = "logic",
  requires = {"dynamic_spawner", "is_terrain", "terrain_collider"},
  update_fn = function(id, c, dt) --update function
    if not player_id then
      return
    end
    local player = pr_ecs.entities[player_id]
    local player_pos_z = select(3 , player.transform.transform:getPosition())
    local entity = pr_ecs.entities[id]
    local collider = entity.terrain_collider.terrain_collider

    local pos_x, pos_y, pos_z = collider:getPosition()
    if player_pos_z - pos_z >= 200 then
      collider:destroy()
      pr_ecs.entities[id] = nil
      local spawn_pos = lovr.math.newVec3(pos_x, pos_y, pos_z + 400)
      local spanwned_tile = (require'../entities/tiles/pr_tiled_ground')(pr_ecs, spawn_pos)
      -- collider:setPosition(pos_x, pos_y, pos_z + 400)
      -- print("got here")
    end

  end,
  set_player_id = function(p_id) player_id = p_id end
}