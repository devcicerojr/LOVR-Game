local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "aabb_sensor", "collider" },
  update_fn = function(id, c, pass) -- draw function
    if not is_dev_build or not draw_wireframes then
      return
    end
    local entity = ecs.entities[id]
    local aabb_sensor = entity.aabb_sensor
    local collider = entity.collider.collider
  
    local collider_pos = lovr.math.vec3(collider:getPosition())
    local line_points = {
      lovr.math.vec3(collider_pos) , lovr.math.vec3(collider_pos + lovr.math.vec3(0, 2, 0):rotate(collider:getOrientation()))
    }

    pass:setColor(0, 1, 0)
    
    pass:box(collider_pos.x, collider_pos.y, collider_pos.z, aabb_sensor.width, aabb_sensor.height, aabb_sensor.depth, 1, 0, 0, 0, 'line')
    pass:line(line_points)
  end
}