local ecs = require'../core/pr_ecs'
local pr_utils = require'../core/pr_utils'
local lovr_world = require'../core/pr_world'

-- Constants for acceleration and deceleration (tweak as needed)
local ACCELERATION = 7
local DECELERATION = 30

return {
  phase = "logic", 
  requires = {"player_controls", "collider", "velocity", "transform", "acc_dec_movement", "aabb_sensor", "free_controls"},
  update_fn = function(id, c, dt) --update function
    local entity = ecs.entities[id]
    local collider = ecs.entities[id].collider.collider
    local velocity = ecs.entities[id].velocity.velocity
    local aabb_sensor = ecs.entities[id].aabb_sensor
    local acc_dec = entity.acc_dec_movement
    local moving_forward = lovr.system.isKeyDown("i")
    local moving_backward = lovr.system.isKeyDown("k")
    local desired_dir = nil
    local desired_speed = 0

    local minx, maxx, miny, maxy, minz, maxz = collider:getAABB()
   
    local col_width = maxx - minx
    local col_height = maxy - miny
    local col_depth = maxz - minz

    if moving_forward then
      desired_dir = lovr.math.vec3(0, 0, 1)
      desired_speed = velocity.z
    elseif moving_backward then
      desired_dir = lovr.math.vec3(0, 0, -1)
      desired_speed = velocity.z
    end
    -- Calculate current speed along desired direction
    local current_speed_len = acc_dec.current_speed:length()
    local current_dir = current_speed_len > 0 and lovr.math.vec3(acc_dec.current_speed):normalize() or lovr.math.vec3(0,0,0)
    if desired_dir then
      -- Accelerate towards desired direction and speed
      local dot = acc_dec.current_speed:dot(desired_dir)
      local accel_vec = desired_dir * ((dot < 0) and (ACCELERATION + DECELERATION) or ACCELERATION) * dt
      acc_dec.current_speed:add(accel_vec)
      -- Clamp to max speed
      if acc_dec.current_speed:length() > desired_speed then
        acc_dec.current_speed:set(lovr.math.vec3(acc_dec.current_speed):normalize() * desired_speed)
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

    local direction = lovr.math.vec3()
    local translate_val = lovr.math.vec3()
    local desired_rot = lovr.math.quat()
    local adjusted_direction = false

    if collider:isKinematic() then
      if lovr.system.isKeyDown("j") then
        desired_rot = lovr.math.quat(k_pi * dt , 0, 1, 0)
      end
      if lovr.system.isKeyDown("l") then
        desired_rot = lovr.math.quat(-k_pi * dt , 0, 1 , 0)
      end
      entity.transform.transform:rotate(desired_rot)
      local orientation = lovr.math.quat(entity.transform.transform:getOrientation())
      local position = lovr.math.vec3(entity.transform.transform:getPosition())
      -- Move using current_speed in local forward/backward direction
      if acc_dec.current_speed:length() > 0 then
        direction = lovr.math.vec3(acc_dec.current_speed)
        direction:rotate(orientation)
      end
      translate_val = direction * dt
      local pitch, yaw, roll = orientation:getEuler()
      local aabb_rotated_offset = lovr.math.vec3(aabb_sensor.sensor_offset):rotate(orientation)
      local aabb_sensor_pos = position + translate_val + aabb_rotated_offset
      local collided_c = lovr_world:queryBox(aabb_sensor_pos , lovr.math.vec3(aabb_sensor.width, aabb_sensor.height, aabb_sensor.depth), 'wall')
      if collided_c ~= nil then
        aabb_sensor.is_active = true
        -- find out the normal of the collision
        local ray_endpoint = aabb_sensor_pos + direction
        local collided_middle, shape_md, cx_md, cy_md, cz_md, nx_md, ny_md, nz_md, triangle_md = lovr_world:raycast(aabb_sensor_pos , ray_endpoint, 'wall')
        local depth_offset_sig = -1
        
        local left_ray_sensor_dir = lovr.math.vec3(direction):rotate(math.pi / 2.5 , 0 , 1 , 0)
        local right_ray_sensor_dir = lovr.math.vec3(direction):rotate(-math.pi / 2.5  , 0 , 1 , 0)
        -- If move direction is opposite to the pleyers orientation (moving backwards)
        if direction:dot(orientation:direction()) > 0 then
          depth_offset_sig = 1
          left_ray_sensor_dir:rotate(math.pi , 0 , 1 , 0)
          right_ray_sensor_dir:rotate(math.pi , 0 , 1 , 0)
        end
        ray_endpoint = aabb_sensor_pos + left_ray_sensor_dir
        -- Check for collision on the left side
        local left_sensor_pos = lovr.math.vec3(aabb_sensor_pos):add(lovr.math.vec3(col_width/2, col_height / 2, depth_offset_sig * col_depth/2 ):rotate(orientation))
        local collided_left_side, shape_ls, cx_ls, cy_ls, cz_ls, nx_ls, ny_ls, nz_ls, triangle_ls = lovr_world:raycast(left_sensor_pos , ray_endpoint , 'wall')
        
        ray_endpoint = aabb_sensor_pos + right_ray_sensor_dir
        local right_sensor_pos = lovr.math.vec3(aabb_sensor_pos):add(lovr.math.vec3(-col_width/2, col_height/2, depth_offset_sig * col_depth/2 ):rotate(orientation))
        local collided_right_side, shape_rs, cx_rs, cy_rs, cz_rs, nx_rs, ny_rs, nz_rs, triangle_rs = lovr_world:raycast(right_sensor_pos , ray_endpoint, 'wall')
        local norm_vec = lovr.math.vec3(0,0,0)
        if collided_middle then
          norm_vec = lovr.math.vec3(nx_md, ny_md, nz_md)
        elseif collided_left_side then
          norm_vec = lovr.math.vec3(nx_ls, ny_ls, nz_ls)
        elseif collided_right_side then 
          norm_vec = lovr.math.vec3(nx_rs, ny_rs, nz_rs)
        end
        
        -- Adjust direction to be perpendicular to the normal vector
        direction = direction - norm_vec * direction:dot(norm_vec)
        translate_val = direction * dt
        aabb_sensor_pos = position + translate_val + aabb_rotated_offset
        -- second check for collision after adjusting direction
        local collided_c2 = lovr_world:queryBox(aabb_sensor_pos, lovr.math.vec3(aabb_sensor.width, aabb_sensor.height, aabb_sensor.depth), 'wall')
        if not collided_c2 then position:add(translate_val) end
      else
        aabb_sensor.is_active = false
        position:add(translate_val)
      end
      entity.transform.transform = lovr.math.newMat4(position, orientation) -- move the entity transform (kinematic)
    else
      local collider_rotation_offset = lovr.math.quat(1, 0, 0, 0) 
      local collider_pos_offset = lovr.math.vec3(0, 0, 0)
      if acc_dec.current_speed:length() > 0 then
        direction = lovr.math.newVec3(acc_dec.current_speed)
        collider_rotation_offset = lovr.math.quat(entity.collider.transform_offset:getOrientation())
        collider_pos_offset = lovr.math.vec3(entity.collider.transform_offset:getPosition())
        direction:rotate(lovr.math.quat(collider:getOrientation()) * (lovr.math.quat(collider_rotation_offset:unpack())):conjugate())
        translate_val = direction * dt
        collider:setPosition(lovr.math.vec3(collider:getPosition()):add(translate_val))
      end
    end
  end
}