local AUDIO_SCALE_FACTOR = 0.90

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
  requires = { "is_car_obstacle", "transform", "audio_source" },
  update_fn = function(ecs, id, c, dt)
    local entity_transform = ecs.entities[id].transform.transform
    local source = ecs.entities[id].audio_source.source

    if not source:isPlaying() then
      source:play()
    end

    local player = ecs:getEntityByTag('is_player')
    if not player then return end
    local player_position = vec3(ecs.entities[player].transform.transform:getPosition())
    local car_position    = vec3(entity_transform:getPosition())
    local distance_to_player = player_position - car_position

    if distance_to_player.z > 200 then
      source:stop()
      pr_event_bus:emit('car_went_out_of_range', ecs, id)
    else
      local new_source_pos = car_position + distance_to_player * AUDIO_SCALE_FACTOR
      source:setPosition(new_source_pos)
    end
  end
}
