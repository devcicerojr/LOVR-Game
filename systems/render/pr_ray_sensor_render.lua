local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "ray_collider_sensor"},
  update_fn = function(id, c, pass)
     local origin = lovr.math.vec3(ecs.entities[id].ray_collider_sensor.origin)
     local endpoint = lovr.math.vec3(ecs.entities[id].ray_collider_sensor.endpoint)
     local collider = ecs.entities[id].collider.collider
     pass:setColor(1, 0, 0, 1)
     origin:add(collider:getPosition())
     endpoint:add(collider:getPosition())
     pass:line(origin.x, origin.y, origin.z, endpoint.x, endpoint.y, endpoint.z)
  end
}