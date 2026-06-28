local player_id = nil

pr_event_bus:on('ramp_went_out_of_range', function(ecs, id)
  local collider = ecs.entities[id].collider.collider
  if not collider:isDestroyed() then
    collider:destroy()
  end
  local side_id = ecs.entities[id].is_ramp.side_entity_id
  if side_id and ecs.entities[side_id] then
    table.insert(ecs.ids_for_deletion, side_id)
  end
  lovr.log("Marking ramp for deletion. Id: " .. id, "debug")
  table.insert(ecs.ids_for_deletion, id)
end)

return {
  phase = "logic",
  requires = {"is_ramp", "transform", "collider"},
  update_fn = function(ecs, id, c, dt)
    if not player_id then
      player_id = ecs:getEntityByTag('is_player')
      if not player_id then return end
    end
    local player_pos_z = select(3, ecs.entities[player_id].transform.transform:getPosition())
    local ramp_pos_z   = select(3, ecs.entities[id].transform.transform:getPosition())

    if player_pos_z - ramp_pos_z >= 200 then
      pr_event_bus:emit('ramp_went_out_of_range', ecs, id)
    end
  end
}
