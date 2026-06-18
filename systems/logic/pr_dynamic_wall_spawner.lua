-- local ecs = require'../core/pr_ecs'
local player_id = nil

pr_event_bus:on('dynamic_wall_despawned', function(ecs, id)
  local entity_collider = ecs.entities[id].collider.collider
  if not entity_collider:isDestroyed() then
    entity_collider:destroy()
    entity_collider = nil
  end
  table.insert(ecs.ids_for_deletion, id)
end)

return {
  phase = "logic",
  requires = {"raw_brush", "collider", "brush", "dynamic_spawner"},
  update_fn = function(ecs, id, c, dt) --update function
    if not player_id then
      player_id = ecs:getEntityByTag('is_player')
      if not player_id then return end
    end
    local player = ecs.entities[player_id]
    local player_pos_z = select(3 , player.transform.transform:getPosition())
    local entity = ecs.entities[id]
    local collider = entity.collider.collider

    local pos_x, pos_y, pos_z = collider:getPosition()
    if player_pos_z - pos_z >= 200 then
      pr_event_bus:emit('dynamic_wall_despawned', ecs, id)
      local spawn_pos = lovr.math.newVec3(pos_x, pos_y, pos_z + 400)
      local spanwned_tile = (require'../entities/brushes/pr_wall')(ecs, spawn_pos, 1, 20, 20)
    end

  end
}