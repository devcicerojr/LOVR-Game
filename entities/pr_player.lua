local lovr_world = require'../core/pr_world'
local pr_component = require'../components/pr_components'
require '../core/pr_math'

return function(ecs)
  local id = ecs:newEntity()
  local collider_rotation_offset = lovr.math.newQuat(k_pi/2, 1, 0, 0)
  local x, y, z, angle, ax, ay, az, scale = 0, 2, -3, 1, 0, 0, 0, 1.0
  local collider_radius, collider_length = 0.5, 0.5
  local collider = lovr_world:newCapsuleCollider(0, 2, -3, collider_radius, collider_length)
  collider:setDegreesOfFreedom("xyz", "y")
  collider:setOrientation(lovr.math.newQuat(collider:getOrientation()) * collider_rotation_offset)



  -- ecs:addComponent(id , pr_component.Position(0, 0, 0))
  ecs:addComponent(id , pr_component.Model(lovr.graphics.newModel('assets/models/Test.glb')))
  ecs:addComponent(id , pr_component.Animated())
  ecs:addComponent(id , pr_component.Velocity(0, 0, 0))
  ecs:addComponent(id , pr_component.Collider(collider, "capsule", lovr.math.newVec3(0, -collider_length/2 - collider_radius  , 0), collider_rotation_offset))
  -- ecs:addComponent(id, pr_component.Scallable(1.0, 1.0, 1.0))
  ecs:addComponent(id, pr_component.Transform(x, y, z, angle, ax, ay, az, scale))
  return id
end