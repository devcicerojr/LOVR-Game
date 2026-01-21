local pr_ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "sensors_array", "transform"},
  update_fn = function(id, c, pass)

    if not is_dev_build then
      return
    end
    local entity_transform = mat4(pr_ecs.entities[id].transform.transform)
    local entity_orientation = entity_transform:getOrientation()
    local ground_sensor = pr_ecs.entities[id].sensors_array.sensors["ground_sensor"]
    
    for _, sensor in pairs(pr_ecs.entities[id].sensors_array.sensors) do
      local origin = lovr.math.vec3(entity_transform:getPosition()):add(ground_sensor.origin_offset:rotate(entity_orientation))
      local endpoint = lovr.math.vec3(entity_transform:getPosition()):add(ground_sensor.endpoint_offset:rotate(entity_orientation))

      if is_dev_build and draw_wireframes then
        pass:setColor(1, 0, 0, 1)
        pass:line(origin.x, origin.y, origin.z, endpoint.x, endpoint.y, endpoint.z)
        pass:setColor(1, 1, 1, 1)
      end
    end
  end
}