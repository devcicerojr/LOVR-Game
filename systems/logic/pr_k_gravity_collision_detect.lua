local pr_ecs = require'../core/pr_ecs'

return {
  phase = "logic",
  requires = {"gravity", "collider", "is_kinematic", "ray_collider_sensor"},
  update_fn = function(id, c, dt) -- update function
    local collider = pr_ecs.entities[id].collider.collider
    local shape = collider:getShape()
    local shape_type = shape:getType()
    local shape_center = shape:getPose()
    local ray_origin = pr_ecs.entities[id].ray_collider_sensor.origin
    local ray_endpoint = pr_ecs.entities[id].ray_collider_sensor.endpoint

    -- update ray sensor position according to collider position (that might have been updated)
    
    
    if shape == "capsule" then
      local radius = shape:getRadius()
      local length = shape:getLength()
      ray_origin:set(collider:getPosition())
      ray_endpoint:set(ray_origin.x , ray_origin.y -radius - length, ray_origin.z)
    end
    

  end
}
