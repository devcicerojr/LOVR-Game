local AUDIO_SCALE_FACTOR = 0.90
local CAR_SPEED          = 100  -- units/s in -Z direction

pr_event_bus:on('game_paused_changed', function(ecs, is_paused)
  local volume = is_paused and 0.15 or 1.0
  for id, entity in pairs(ecs.entities) do
    if entity.is_car_obstacle and entity.audio_source then
      entity.audio_source.source:setVolume(volume)
    end
  end
end)

pr_event_bus:on('car_went_out_of_range', function(ecs, id)
  local collider = ecs.entities[id].collider.collider
  local source = ecs.entities[id].audio_source.source
  if source:isPlaying() then
    source:stop()
  end
  if not collider:isDestroyed() then
    collider:destroy()
  end
  lovr.log("Marking car for deletion. Id: " .. id, "debug")
  table.insert(ecs.ids_for_deletion, id)
end)

return {
  phase = "logic",
  requires = { "is_car_obstacle", "transform", "collider", "audio_source" },
  update_fn = function(ecs, id, c, dt)
    local entity        = ecs.entities[id]
    local entity_transform = entity.transform.transform
    local collider      = entity.collider.collider
    local source        = entity.audio_source.source

    if not source:isPlaying() then
      source:play()
    end

    entity_transform:translate(lovr.math.newVec3(0, 0, -CAR_SPEED * dt))
    ecs.entities[id].transform.transform = entity_transform
    local new_col_transform = mat4(entity_transform) * mat4(entity.collider.transform_offset)
    collider:setPose(vector.pack(new_col_transform:getPosition()), lovr.math.quat(new_col_transform:getOrientation()))

    local player = ecs:getEntityByTag('is_player')
    if not player then return end
    local car_pos        = vec3(entity_transform:getPosition())
    local player_position = vec3(ecs.entities[player].transform.transform:getPosition())
    local distance_to_player = player_position - car_pos

    if distance_to_player.z > 200 then
      source:stop()
      pr_event_bus:emit('car_went_out_of_range', ecs, id)
    else
      source:setPosition(car_pos + distance_to_player * AUDIO_SCALE_FACTOR)
    end
  end
}
