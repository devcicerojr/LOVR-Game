local pr_ecs = require'../core/pr_ecs'

local car_speed = lovr.math.newVec3(0, 0, -100)

local AUDIO_SCALE_FACTOR = 0.90  -- this makes the audio distance feel closer than the visual distance
-- 1.0 brings the listener to the audio source. 0.0 disables scale factor

return {
  phase = "logic",
  requires = { "is_car_obstacle", "model" , "transform", "audio_source"},
  update_fn = function(id, c, dt) -- update function
    local entity_transform = pr_ecs.entities[id].transform.transform

    local position = vec3(entity_transform:getPosition())
    local orientation = quat(entity_transform:getOrientation())
    local source = pr_ecs.entities[id].audio_source.source

    local applied_speed = vec3(0, 0, car_speed.z * dt)
    local speed_transform = lovr.math.newMat4():translate(applied_speed)

    entity_transform:mul(speed_transform)

    if source:isPlaying() == false then
      source:play()
    end

    local player = pr_ecs:getEntityByTag('is_player')
    local player_transform = pr_ecs.entities[player].transform.transform
    local player_position = vec3(player_transform:getPosition())
    local distance_to_player = vec3(player_position):sub(vec3(entity_transform:getPosition()))
    local translate_value = vec3(distance_to_player):mul(AUDIO_SCALE_FACTOR)
    local new_source_pos = nil
    if (math.abs(distance_to_player.z) > 200) then
      new_source_pos = lovr.math.newVec3(entity_transform:getPosition())
      source:stop()
    else
      new_source_pos = lovr.math.newVec3(vec3(entity_transform:getPosition()):add(translate_value))
    end

    -- update sound source position
    source:setPosition(new_source_pos)
    -- source:setPosition(entity_transform:getPosition())

  end
}