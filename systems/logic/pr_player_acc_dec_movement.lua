local ecs = require'../core/pr_ecs'
local pr_utils = require'../core/pr_utils'
local lovr_world = require'../core/pr_world'

-- Constants for acceleration and deceleration (tweak as needed)
local ACCELERATION = 10
local DECELERATION = 12

return {
  phase = "logic", 
  requires = {"player_controls", "collider", "velocity", "transform", "acc_dec_movement"},
  update_fn = function(id, c, dt) --update function
    local entity = ecs.entities[id]
    local collider = ecs.entities[id].collider.collider
    local velocity = ecs.entities[id].velocity.velocity
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
      local collided_c = lovr_world:queryBox(position.x, position.y, position.z, col_width, col_height, col_depth, 'wall')
      -- moves only if doesnt collide with wall
      if collided_c ~= nil then
        -- find out the normal of the collision
        local shifted_val = lovr.math.vec3(0, 0, 0):rotate(orientation)
        local ray_endpoint = position + direction
        local collided_1, shape_1, cx_1, cy_1, cz_1, nx_1, ny_1, nz_1, triangle_1 = lovr_world:raycast(position + shifted_val, ray_endpoint, 'wall')
        shifted_val = lovr.math.vec3(col_width/2, 0, 0):rotate(orientation)
        local collided_2, shape_2, cx_2, cy_2, cz_2, nx_2, ny_2, nz_2, triangle_2 = lovr_world:raycast(position + shifted_val, ray_endpoint + shifted_val, 'wall')
        shifted_val = lovr.math.vec3(- col_width/2, 0, 0):rotate(orientation)
        local collided_3, shape_3, cx_3, cy_3, cz_3, nx_3, ny_3, nz_3, triangle_3 = lovr_world:raycast(position + shifted_val, ray_endpoint + shifted_val, 'wall')
        local norm_vec = lovr.math.vec3(0,0,0)
        if collided_1 then
          norm_vec = lovr.math.vec3(nx_1, ny_1, nz_1)
        elseif collided_2 then
          norm_vec = lovr.math.vec3(nx_2, ny_2, nz_2)
        elseif collided_3 then
          norm_vec = lovr.math.vec3(nx_3, ny_3, nz_3)
        end
        direction = direction - norm_vec * direction:dot(norm_vec)
      end
      translate_val = direction * dt
      position:add(translate_val)
      entity.transform.transform = lovr.math.newMat4(position, orientation) -- move the entity transform (kinematic)
    else
      local collider_rotation_offset = lovr.math.quat(1, 0, 0, 0) 
      local collider_pos_offset = lovr.math.vec3(0, 0, 0)
      if acc_dec.current_speed:length() > 0 then
        direction = acc_dec.current_speed:clone()
        collider_rotation_offset = lovr.math.quat(entity.collider.transform_offset:getOrientation())
        collider_pos_offset = lovr.math.vec3(entity.collider.transform_offset:getPosition())
        direction:rotate(lovr.math.quat(collider:getOrientation()) * (lovr.math.quat(collider_rotation_offset:unpack())):conjugate())
        translate_val = direction * dt
        collider:setPosition(lovr.math.vec3(collider:getPosition()):add(translate_val))
      end
    end
  end
}