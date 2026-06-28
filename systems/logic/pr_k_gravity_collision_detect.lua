-- local ecs = require'../core/pr_ecs'
local lovr_world = require'../core/pr_world'

local createCallbackCtx = function(ecs, id)
  return {
    sensor_callback = function(collider, shape, x, y, z, nx, ny, nz, tri, fraction)
      local entity = ecs.entities[id]
      if collider ~= nil then
        local tag = collider:getTag()
        local is_ground = collider:getShape():getType() == "terrain" or tag == "ramp"
        if is_ground and entity.gravity.jump_cooldown <= 0 and (entity.gravity.vertical_velocity <= 0 or tag == "ramp") then
          entity.sensors_array.sensors["ground_sensor"].no_detection_period = 0
          entity.gravity.grounded = true
          entity.gravity.vertical_velocity = 0
          entity.gravity.is_jumping = false
          entity.gravity.jump_hold_time = 0
          entity.gravity.last_ground_normal = {nx = nx, ny = ny, nz = nz}
          entity.gravity.last_ground_was_ramp = (tag == "ramp")
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
  update_fn = function(ecs, id, c, dt) -- update function
    local entity = ecs.entities[id]
    local ground_sensor = entity.sensors_array.sensors["ground_sensor"]
    if ground_sensor.callback_ctx_data.cb_function == nil then
      ground_sensor.callback_ctx_data.cb_function = sensor_callback
    end
    local collider = entity.collider.collider
    local shape = collider:getShape() local shape_type = shape:getType()
    local entity_transform = mat4(entity.transform.transform)
    local ray_origin = vec3(entity_transform:getPosition()) + ground_sensor.origin_offset
    local ray_endpoint = vec3(ray_origin) + ground_sensor.endpoint_offset

    if shape_type == "capsule" then
      local was_grounded = entity.gravity.grounded
      local cb_obj = createCallbackCtx(ecs, id)
      local c_collider = lovr_world:raycast(ray_origin, ray_endpoint, nil, cb_obj.sensor_callback)
      if c_collider == nil then
        ground_sensor.no_detection_period = ground_sensor.no_detection_period + dt
        local ramp_threshold = 0.05
        local ground_threshold = 0.2
        if was_grounded and entity.gravity.last_ground_was_ramp and entity.gravity.jump_cooldown <= 0
          and ground_sensor.no_detection_period > ramp_threshold then
          -- Ramp exit: apply launch velocity with minimal grace period to filter mesh false negatives
          local acc_dec = entity.acc_dec_movement
          local gn = entity.gravity.last_ground_normal
          if acc_dec and gn and gn.ny > 0.01 then
            local vx = acc_dec.current_speed.x
            local vz = acc_dec.current_speed.z
            local launch_vy = -(gn.nx * vx + gn.nz * vz) / gn.ny
            if launch_vy > 0 then
              entity.gravity.vertical_velocity = launch_vy
            end
          end
          entity.gravity.last_ground_was_ramp = false
          entity.gravity.grounded = false
        elseif ground_sensor.no_detection_period > ground_threshold then
          -- Regular terrain: longer grace period to avoid jitter on bumpy surfaces
          entity.gravity.grounded = false
        end
      end
    end
  end
}
