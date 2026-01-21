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
      local entity_transform = lovr.math.mat4(entity.transform.transform)
      local collider = entity.collider.collider
      local collider_transform_offset = entity.collider.transform_offset
      local new_collider_transform = mat4(entity_transform):mul(mat4(collider_transform_offset))
      -- print(lovr.math.vec3(new_collider_transform:getPosition()).y)
      collider:setPose(vec3(new_collider_transform:getPosition()), quat(new_collider_transform:getOrientation()))
    end

  end
}