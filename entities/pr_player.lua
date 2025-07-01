local lovr_world = require'../core/pr_world'
local pr_component = require'../components/pr_components'
require '../core/pr_math'

return function(ecs)
  local id = ecs:newEntity()
  local collider_rotation_offset = lovr.math.newQuat(k_pi/2, 1, 0, 0)
  local entity_transform = lovr.math.newMat4(lovr.math.newVec3(0, 0, 0), lovr.math.newQuat(1, 0, 0 , 0))
  local collider_radius, collider_length = 0.5, 0.5
  local collider = lovr_world:newCapsuleCollider(0, 0, 0, collider_radius, collider_length)
  local transform_offset = lovr.math.newMat4()
  transform_offset:translate(0, collider_length/2 + collider_radius  , 0)
  transform_offset:rotate(k_pi/2, 1, 0, 0)
  -- collider:setKinematic(true)
  -- collider:setPose(transform_offset:getPose())
  collider:setDegreesOfFreedom("xyz", "y")
  collider:setOrientation(lovr.math.newQuat(collider:getOrientation()) * collider_rotation_offset)

  ecs:addComponent(id , pr_component.Model(lovr.graphics.newModel('assets/models/Test.glb')))
  ecs:addComponent(id , pr_component.AnimationState())
  ecs:addComponent(id , pr_component.TracksCollider())
  ecs:addComponent(id , pr_component.PlayerControls())
  ecs:addComponent(id , pr_component.Velocity(lovr.math.newVec3(1, 1, 1)))
  ecs:addComponent(id , pr_component.Collider(collider, "capsule", transform_offset))
  ecs:addComponent(id, pr_component.Transform(entity_transform))
  return id
end