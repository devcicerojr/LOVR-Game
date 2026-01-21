local pr_ecs = require'../core/pr_ecs'
local lovr_world = require'../core/pr_world'

local createCallbackCtx = function(id)
  return {
    sensor_callback = function(collider, shape, x, y, z, nx, ny, nz, tri, fraction)
      local entity = pr_ecs.entities[id]
      if collider ~= nil then
        if collider:getShape():getType() == "terrain" then
          entity.sensors_array.sensors["ground_sensor"].no_detection_period = 0
          entity.gravity.grounded = true
          entity.velocity.velocity.y = 0
          entity.transform.transform:set(lovr.math.newVec3(x, y, z), lovr.math.newQuat(entity.transform.transform:getOrientation()))
        end
      end
      return 1.0
    end ,
    id = id
  }
end

return {
  phase = "logic",
  requires = {"gravity", "collider", "transform", "is_kinematic", "velocity", "sensors_array", "has_ground_sensor"},
  update_fn = function(id, c, dt) -- update function
    local entity = pr_ecs.entities[id]
    local ground_sensor = entity.sensors_array.sensors["ground_sensor"]
    if ground_sensor.callback_ctx_data.cb_function == nil then
      ground_sensor.callback_ctx_data.cb_function = sensor_callback
    end
    local collider = entity.collider.collider
    local shape = collider:getShape() local shape_type = shape:getType()
    local entity_transform = mat4(entity.transform.transform)
    local ray_origin = vec3(entity_transform:getPosition()):add(ground_sensor.origin_offset)
    local ray_endpoint = vec3(ray_origin):add(ground_sensor.endpoint_offset)

    if shape_type == "capsule" then
      local radius = shape:getRadius()
      local length = shape:getLength()
      local cb_obj = createCallbackCtx(id)
      local c_collider = lovr_world:raycast(ray_origin, ray_endpoint, nil, cb_obj.sensor_callback)
      if c_collider == nil then
        -- count a timer, and set grounded to false if timer increased enough
        ground_sensor.no_detection_period = ground_sensor.no_detection_period + dt
        if ground_sensor.no_detection_period > 0.2 then
          entity.gravity.grounded = false
        end
      end
    end
  end
}
