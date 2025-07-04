local pr_ecs = require'../core/pr_ecs'
local lovr_world = require'../core/pr_world'

local createCallbackCtx = function(id)
  return {
    sensor_callback = function(collider, shape, x, y, z, nx, ny, nz, tri, fraction)
      if collider ~= nil then
        if collider:getShape():getType() == "terrain" then
          pr_ecs.entities[id].ray_collider_sensor.no_detection_period = 0
          pr_ecs.entities[id].gravity.grounded = true
          pr_ecs.entities[id].velocity.velocity.y = 0
          pr_ecs.entities[id].transform.transform:set(lovr.math.vec3(x, y  , z), lovr.math.quat(pr_ecs.entities[id].transform.transform:getOrientation()))
        end
      end
      return 1.0
    end ,
    id = id
  }
end

-- local callback_context  = {
--   sensor_callback = function(collider, shape, x, y, z, nx, ny, nz, tri, fraction)
--     print("collided")
--     if collider ~= nil then
--       print("collided and grounded: " .. tostring(pr_ecs.entities[id].gravity.grounded))
--       pr_ecs.entities[id].gravity.grounded = true
--       pr_ecs.entities[id].velocity.velocity.y = 0
--       entity_transform:set(lovr.math.vec3(x, y + radius + length/2, z), lovr.math.quat(entity_transform:getOrientation()))
--     else
--       print("Not coliding")
--       pr_ecs.entities[id].gravity.grounded = false
--     end
--     return 
--   end ,
--   extra_data = {}
-- }

return {
  phase = "logic",
  requires = {"gravity", "collider", "transform", "is_kinematic", "velocity", "ray_collider_sensor"},
  update_fn = function(id, c, dt) -- update function
    local ray_collider_sensor = pr_ecs.entities[id].ray_collider_sensor
    local collider = pr_ecs.entities[id].collider.collider
    local shape = collider:getShape()
    local shape_type = shape:getType()
    local shape_center = shape:getPose()
    local entity_transform = pr_ecs.entities[id].transform.transform
    local ray_origin = lovr.math.newVec3(entity_transform:getPosition()):add(pr_ecs.entities[id].ray_collider_sensor.origin_offset)
    local ray_endpoint = lovr.math.vec3(ray_origin):add(ray_collider_sensor.endpoint_offset)
    local grounded = pr_ecs.entities[id].gravity.grounded

    if shape_type == "capsule" then
      local radius = shape:getRadius()
      local length = shape:getLength()
      local cb_obj = createCallbackCtx(id)
      local c_collider = lovr_world:raycast(ray_origin, ray_endpoint, nil, cb_obj.sensor_callback)
      if c_collider == nil then
        -- count a timer, and set grounded to false if timer increased enough
        ray_collider_sensor.no_detection_period = ray_collider_sensor.no_detection_period + dt
        if ray_collider_sensor.no_detection_period > 0.2 then
          pr_ecs.entities[id].gravity.grounded = false
        end
      end
    end
    
  end
}
