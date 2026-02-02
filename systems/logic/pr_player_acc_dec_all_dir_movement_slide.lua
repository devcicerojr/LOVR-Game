local ecs = require'../core/pr_ecs'
local lovr_world = require'../core/pr_world'

-- Constants for acceleration and deceleration (tweak as needed)
local ACCELERATION = 50
local DECELERATION = 90

return {
  phase = "logic",
  requires = {"player_controls", "collider", "velocity", "transform", "acc_dec_movement", "aabb_sensor", "all_dir_controls"},
  update_fn = function(id, c, dt) --update function
    local entity = ecs.entities[id]
    local collider = ecs.entities[id].collider.collider
    local velocity = ecs.entities[id].velocity.velocity
    local aabb_sensor = ecs.entities[id].aabb_sensor
    local acc_dec = entity.acc_dec_movement
    local moving_forward = lovr.system.isKeyDown("i")
    local moving_backward = lovr.system.isKeyDown("k")
    local desired_dir = lovr.math.newVec3(0, 0, 0)
    local desired_rot = lovr.math.newQuat(0, 0 , 0, 1)
    local desired_speed = 0
    local forward_vec = vec3(0, 0, 1)

    local minx, maxx, miny, maxy, minz, maxz = collider:getAABB()

    local col_width = maxx - minx
    local col_height = maxy - miny
    local col_depth = maxz - minz
    local player_controlling = false

    moving_forward = true
    if moving_forward then
      desired_dir:add(0, 0, 1)
      player_controlling = true
    end
    if moving_backward then
      desired_dir:add(0, 0, -1)
      player_controlling = true
    end
    if lovr.system.isKeyDown("j") then
      desired_dir:add(1, 0, 0)
      player_controlling = true
    end
    if  lovr.system.isKeyDown("l") then
      desired_dir:add(-1, 0, 0)
      player_controlling = true
    end
    local rotation_angle = 0
    if lovr.system.isKeyDown("k") then
      desired_dir:set(0, 0, 0) -- stop movement if both forward and backward keys are pressed
      player_controlling = false
      rotation_angle = vec3(0, 0, 1):angle(vec3(0, 0, -1))
    end
    if desired_dir:length() == 0 then
      desired_dir:set(0, 0, 1) -- default forward direction
    else
      rotation_angle = vec3(desired_dir):angle(forward_vec)
      if desired_dir:dot(vec3(1, 0, 0)) < 0 then
        rotation_angle = -rotation_angle
      end
    end
    desired_rot = quat(rotation_angle, 0, 1, 0)

    if player_controlling then
      desired_speed = vec3(desired_dir):normalize():length() * velocity.z
      -- entity.transform.transform:set(vec3(entity.transform.transform:getPosition()), desired_rot)
    else
      desired_dir = vec3(0, 0, 0)
      desired_speed = 0
    end
    local current_speed_len = acc_dec.current_speed:length()
    local current_dir = current_speed_len > 0 and vec3(acc_dec.current_speed):normalize() or quat(entity.transform.transform:getOrientation()):direction()
    if desired_speed > 0 then
      -- Accelerate towards desired direction and speed
      local dot = acc_dec.current_speed:dot(desired_dir)
      local accel_vec = desired_dir * ((dot < 0) and (ACCELERATION + DECELERATION) or ACCELERATION) * dt
      acc_dec.current_speed:add(accel_vec)
      -- Clamp to max speed
      if acc_dec.current_speed:length() > desired_speed then
        acc_dec.current_speed:set(vec3(acc_dec.current_speed):normalize() * desired_speed)
      end
    else
      -- No input: decelerate to zero
      if current_speed_len > 0 then
        local decel = DECELERATION * dt
        if current_speed_len <= decel then
          acc_dec.current_speed:set(0,0,0)
        else
          acc_dec.current_speed:add(current_dir * -decel)
        end
      end
    end




    local translate_val = vec3(acc_dec.current_speed) * dt
    local movement_angle = translate_val:angle(forward_vec)
    if translate_val:dot(vec3(1, 0, 0)) < 0 then
      movement_angle = -movement_angle
    end
    local movement_rot = quat(movement_angle, 0, 1, 0)
    local direction = vec3(translate_val):normalize()

    if collider:isKinematic() then

      local position = vec3(entity.transform.transform:getPosition())

      local aabb_rotated_offset = vec3(aabb_sensor.sensor_offset):rotate(movement_rot)
      local aabb_sensor_pos = position + translate_val + aabb_rotated_offset
      local collided_c = lovr_world:queryBox(aabb_sensor_pos , vec3(aabb_sensor.width, aabb_sensor.height, aabb_sensor.depth), 'wall')
      if collided_c ~= nil then
        aabb_sensor.is_active = true
        -- find out the normal of the collision
        local ray_endpoint = aabb_sensor_pos + direction
        local collided_middle, shape_md, cx_md, cy_md, cz_md, nx_md, ny_md, nz_md, triangle_md = lovr_world:raycast(aabb_sensor_pos , ray_endpoint, 'wall')

        local left_ray_sensor_dir = vec3(direction):rotate(math.pi / 2.5 , 0 , 1 , 0)
        local right_ray_sensor_dir = vec3(direction):rotate(-math.pi / 2.5  , 0 , 1 , 0)

        ray_endpoint = aabb_sensor_pos + left_ray_sensor_dir
        -- Check for collision on the left side
        local left_sensor_pos = vec3(aabb_sensor_pos):add(vec3(col_width/2, col_height / 2,  -col_depth/2 ))
        local collided_left_side, shape_ls, cx_ls, cy_ls, cz_ls, nx_ls, ny_ls, nz_ls, triangle_ls = lovr_world:raycast(left_sensor_pos , ray_endpoint , 'wall')

        ray_endpoint = aabb_sensor_pos + right_ray_sensor_dir
        local right_sensor_pos = vec3(aabb_sensor_pos):add(vec3(-col_width/2, col_height/2, -col_depth/2 ))
        local collided_right_side, shape_rs, cx_rs, cy_rs, cz_rs, nx_rs, ny_rs, nz_rs, triangle_rs = lovr_world:raycast(right_sensor_pos , ray_endpoint, 'wall')
        local norm_vec = lovr.math.vec3(0,0,0)
        if collided_middle then
          print("middle")
          norm_vec = lovr.math.vec3(nx_md, ny_md, nz_md)
        elseif collided_left_side then
          print("left")
          acc_dec.current_speed.x = 0
          norm_vec = lovr.math.vec3(nx_ls, ny_ls, nz_ls)
        elseif collided_right_side then
          print("right")
          acc_dec.current_speed.x = 0
          norm_vec = lovr.math.vec3(nx_rs, ny_rs, nz_rs)
        end

        -- Adjust direction to be perpendicular to the normal vector
        direction = direction - norm_vec * direction:dot(norm_vec)
        translate_val = direction * acc_dec.current_speed:length() * dt
        aabb_sensor_pos = position + translate_val + aabb_rotated_offset
        -- second check for collision after adjusting direction
        local collided_c2 = lovr_world:queryBox(aabb_sensor_pos, lovr.math.vec3(aabb_sensor.width, aabb_sensor.height, aabb_sensor.depth), 'wall')
        if not collided_c2 then position:add(translate_val) end
      else
        aabb_sensor.is_active = false
        position:add(translate_val)
      end
      entity.transform.transform:set(position, desired_rot) -- move the entity transform (kinematic)
      lovr.audio.setPose(position, lovr.math.newQuat(math.pi ,0,1,0)) -- update audio listener position
    else
      -- local collider_rotation_offset = lovr.math.quat(1, 0, 0, 0)
      -- local collider_pos_offset = lovr.math.vec3(0, 0, 0)
      -- if acc_dec.current_speed:length() > 0 then
      --   direction = lovr.math.newVec3(acc_dec.current_speed)
      --   collider_rotation_offset = lovr.math.quat(entity.collider.transform_offset:getOrientation())
      --   collider_pos_offset = lovr.math.vec3(entity.collider.transform_offset:getPosition())
      --   direction:rotate(lovr.math.quat(collider:getOrientation()) * (lovr.math.quat(collider_rotation_offset:unpack())):conjugate())
      --   translate_val = direction * dt
      --   collider:setPosition(lovr.math.vec3(collider:getPosition()):add(translate_val))
      -- end
    end
  end
}