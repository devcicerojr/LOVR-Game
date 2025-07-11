local ecs = require'../core/pr_ecs'
local pr_utils = require'../core/pr_utils'

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
        translate_val = direction * dt
      end
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