local pr_ecs = require'../core/pr_ecs'
local player_id = nil

local latest_z_val = -99999999999

pr_event_bus:on('dynamic_tile_despawned', function(ecs, id)
  local entity_collider = ecs.entities[id].terrain_collider.terrain_collider
  if not entity_collider:isDestroyed() then
    entity_collider:destroy()
    entity_collider = nil
  end
  table.insert(ecs.ids_for_deletion, id)
end)

return {
  phase = "logic",
  requires = {"dynamic_spawner", "is_terrain", "terrain_collider"},
  update_fn = function(id, c, dt) --update function
    if not player_id then
      player_id = pr_ecs:getEntityByTag('is_player')
      if not player_id then return end
    end
    local player = pr_ecs.entities[player_id]
    local player_pos_z = select(3 , player.transform.transform:getPosition())
    local entity = pr_ecs.entities[id]
    local collider = entity.terrain_collider.terrain_collider
    local entity_transform = entity.transform.transform

    local pos_x, pos_y, pos_z = entity_transform:getPosition()
    if player_pos_z - pos_z >= 200 then
      pr_event_bus:emit('dynamic_tile_despawned', pr_ecs, id)
      
      local spawn_pos = lovr.math.newVec3(pos_x, pos_y, pos_z + 400)
      local spawned_tile = nil
      if spawn_pos.x == -10 then
        spawned_tile = (require'../entities/tiles/pr_tiled_ground')(pr_ecs, spawn_pos, 20, "assets/left_side_asphalt.png")
      elseif spawn_pos.x == 10 then
        spawned_tile = (require'../entities/tiles/pr_tiled_ground')(pr_ecs, spawn_pos, 20, "assets/right_side_asphalt.png")
      else
        spawned_tile = (require'../entities/tiles/pr_tiled_ground')(pr_ecs, spawn_pos)
      end
      if pos_z > latest_z_val then
        latest_z_val = pos_z
        pr_event_bus:emit('terrain_tile_spawned', pr_ecs, spawn_pos)
      end
    end

  end
}