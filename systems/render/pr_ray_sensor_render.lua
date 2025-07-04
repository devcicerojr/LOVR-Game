local pr_ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "ray_collider_sensor", "transform"},
  update_fn = function(id, c, pass)

    if not is_dev_build then
      return
    end
    local entity_transform = pr_ecs.entities[id].transform.transform


    local origin = lovr.math.vec3(entity_transform:getPosition()):add(pr_ecs.entities[id].ray_collider_sensor.origin_offset)
    local endpoint = lovr.math.vec3(origin):add(pr_ecs.entities[id].ray_collider_sensor.endpoint_offset)

    pass:setColor(1, 0, 0, 1)
    pass:line(origin.x, origin.y, origin.z, endpoint.x, endpoint.y, endpoint.z)
  end
}