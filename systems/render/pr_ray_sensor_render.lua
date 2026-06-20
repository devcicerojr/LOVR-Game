-- local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "sensors_array", "transform"},
  update_fn = function(ecs, id, c, pass)

    if not is_dev_build then
      return
    end
    local entity_transform = mat4(ecs.entities[id].transform.transform)
    local entity_orientation = entity_transform:getOrientation()
    local ground_sensor = ecs.entities[id].sensors_array.sensors["ground_sensor"]
    
    for _, sensor in pairs(ecs.entities[id].sensors_array.sensors) do
      local origin = lovr.math.vec3(entity_transform:getPosition()) + ground_sensor.origin_offset:rotate(entity_orientation)
      local endpoint = lovr.math.vec3(entity_transform:getPosition()) + ground_sensor.endpoint_offset:rotate(entity_orientation)

      if is_dev_build and draw_wireframes then
        pass:push('state')
        pass:setColor(1, 0, 0, 1)
        pass:line(origin.x, origin.y, origin.z, endpoint.x, endpoint.y, endpoint.z)
        pass:pop('state')
      end
    end
  end
}