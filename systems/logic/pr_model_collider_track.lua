local ecs = require'../core/pr_ecs'
local pr_utils = require'../core/pr_utils'


-- Makes sure the collider is updated with the entity's transform
-- This is necessary for kinematic colliders to work properly
return {
  phase = "logic",
  requires = {"model", "transform", "collider"},
  update_fn = function(id, c, dt) -- update function
    local entity = ecs.entities[id]
    
    
    if entity.collider.collider:isKinematic() then
      local entity_transform = lovr.math.mat4(ecs.entities[id].transform.transform)
      local collider = ecs.entities[id].collider.collider
      local collider_transform_offset = ecs.entities[id].collider.transform_offset
      local new_collider_transform = lovr.math.mat4(entity_transform):mul(lovr.math.mat4(collider_transform_offset))
      -- print(lovr.math.vec3(new_collider_transform:getPosition()).y)
      collider:setPose(lovr.math.vec3(new_collider_transform:getPosition()), lovr.math.quat(new_collider_transform:getOrientation()))
    end
    
    -- local cx, cy, cz = entity.collider.collider:getPosition()
    -- local collider_quat = lovr.math.quat(entity.collider.collider:getOrientation())

    -- local collider_rotation_offset = lovr.math.quat(entity.collider.transform_offset:getOrientation())
    -- local collider_pos_offset = lovr.math.vec3(entity.collider.transform_offset:getPosition())

    -- local model_quat = collider_quat * (lovr.math.quat(collider_rotation_offset:unpack())):conjugate()
    -- local model_pos = lovr.math.vec3(collider_pos_offset:unpack()):rotate(model_quat):add(cx, cy, cz)
    -- -- entity.transform.transform = lovr.math.newMat4(model_pos, model_quat)

  end
}