local pr_ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "sensors_array", "transform"},
  update_fn = function(id, c, pass)

    if not is_dev_build then
      return
    end
    local entity_transform = pr_ecs.entities[id].transform.transform
    local ground_sensor = pr_ecs.entities[id].sensors_array.sensors["ground_sensor"]
  

    if ground_sensor then
      local origin = lovr.math.vec3(entity_transform:getPosition()):add(ground_sensor.origin_offset)
      local endpoint = lovr.math.vec3(origin):add(ground_sensor.endpoint_offset)

      if is_dev_build and draw_wireframes then
        pass:setColor(1, 0, 0, 1)
        pass:line(origin.x, origin.y, origin.z, endpoint.x, endpoint.y, endpoint.z)
      end
    end
  end
}