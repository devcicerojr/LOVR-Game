local ecs = require'../core/pr_ecs'
local pr_utils = require'../core/pr_utils'

return {
  phase = "logic", 
  requires = {"player_controls", "collider", "velocity", "transform", "classic_tank_movement"},
  update_fn = function(id, c, dt) --update function
    local entity = ecs.entities[id]
    local collider = ecs.entities[id].collider.collider
    local velocity = ecs.entities[id].velocity.velocity
    local movement = lovr.math.vec3(velocity:unpack()):normalize()
    movement.y = 0;
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
      if lovr.system.isKeyDown("i") then
        direction = lovr.math.vec3(0, 0, 1) -- forward LOVR world
        direction:rotate(orientation):mul(velocity.z * dt)
        translate_val = direction
      elseif lovr.system.isKeyDown("k") then
        direction = lovr.math.vec3(0, 0, -1) -- backward LOVR world
        direction:rotate(orientation):mul(velocity.z * dt)
        translate_val = direction
      end
      position:add(translate_val)
      entity.transform.transform = lovr.math.newMat4(position, orientation) -- move the entity transform (kinematic)
    else
      local collider_rotation_offset = lovr.math.quat(1, 0, 0, 0) 
      local collider_pos_offset = lovr.math.vec3(0, 0, 0)
      if lovr.system.isKeyDown("i") then
        direction = lovr.math.vec3(0, 0, 1) -- forward LOVR world
        collider_rotation_offset = lovr.math.quat(entity.collider.transform_offset:getOrientation())
        collider_pos_offset = lovr.math.vec3(entity.collider.transform_offset:getPosition())
        direction:mul(velocity)
        direction:rotate(lovr.math.quat(collider:getOrientation()) * (lovr.math.quat(collider_rotation_offset:unpack())):conjugate())
        translate_val = direction * velocity.z * dt
        collider:setPosition(lovr.math.vec3(collider:getPosition()):add(translate_val))
      elseif lovr.system.isKeyDown("k") then
        direction = lovr.math.vec3(0, 0, -1) -- backward LOVR world
        collider_rotation_offset = lovr.math.quat(entity.collider.transform_offset:getOrientation())
        collider_pos_offset = lovr.math.vec3(entity.collider.transform_offset:getPosition())
        direction:mul(velocity)
        direction:rotate(lovr.math.quat(collider:getOrientation()) * (lovr.math.quat(collider_rotation_offset:unpack())):conjugate())
        translate_val = direction * velocity.z * dt
        collider:setPosition(lovr.math.vec3(collider:getPosition()):add(translate_val))   -- move the collider (non-kinematic)
      end
    end
  end
}