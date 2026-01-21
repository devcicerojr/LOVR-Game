local pr_ecs = require'../core/pr_ecs'
local player_id = nil

pr_event_bus:on('dynamic_scenario_despawned', function(ecs, id, transform)
  table.insert(ecs.ids_for_deletion, id)
  local pos_x, pos_y, pos_z = transform:getPosition()
  -- print("Despawning scenario ID: " .. tostring(id))
  -- print("Despawning scenario at position: " .. tostring(pos_x) .. ", " .. tostring(pos_y) .. ", " .. tostring(pos_z))
  -- local new_scenario_id = (require'../entities/dont_stop_delivery/pr_side_scenario_prop')(pr_ecs, transform)
end)

return {
  phase = "logic",
  requires = {"dynamic_spawner", "is_pr_side_scenario", "transform"},
  update_fn = function(id, c, dt) --update function
    local entity = pr_ecs.entities[id]
    if entity == nil then return end
    local transform = entity.transform.transform
    if not player_id then
      player_id = pr_ecs:getEntityByTag('is_player')
      if not player_id then return end
    end
    local player = pr_ecs.entities[player_id]
    local player_pos_z = select(3 , player.transform.transform:getPosition())
    local spawn_transform = lovr.math.newMat4()
    spawn_transform:set(transform:getPosition(), 1, 1, 1, transform:getOrientation())
    
    
    local pos_x, pos_y, pos_z, ang, ax, ay, az = transform:getPose()
    -- print("Scenario position: " .. tostring(pos_x) .. ", " .. tostring(pos_y) .. ", " .. tostring(pos_z))
    -- print("Entity orientation: " .. tostring(ang) .. ", " .. tostring(ax) .. ", " .. tostring(ay) .. ", " .. tostring(az))
    if player_pos_z - pos_z >= 200 then
      transform:set(pos_x, pos_y, pos_z + 400, ang, ax, ay, az)
      -- table.insert(pr_ecs.ids_for_deletion, id)
      -- pr_event_bus:emit('dynamic_scenario_despawned', pr_ecs, id, transform)
    end

  end
}