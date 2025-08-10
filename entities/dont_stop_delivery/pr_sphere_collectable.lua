local pr_component = require'../components/pr_components'
local lovr_world = require'../core/pr_world'


local SPHERE_RADIUS = 0.3

return function(ecs, spawn_pos)
  local id = ecs:newEntity()
  local spawn_pos = spawn_pos or lovr.math.newVec3(0 , 0 , 0)
  local entity_transform = lovr.math.newMat4(spawn_pos , quat(0 , 0 , 0 , 1))
  local transform_offset = lovr.math.newMat4()
  local collider = lovr_world:newSphereCollider(spawn_pos, SPHERE_RADIUS)
  collider:setDegreesOfFreedom("xyz", "y")
  collider:setKinematic(true)
  ecs:addComponent(id, pr_component.TracksCollider())
  ecs:addComponent(id, pr_component.IsKinematic())

  ecs:addComponent(id, pr_component.Transform(entity_transform))
  ecs:addComponent(id, pr_component.Collider(collider, "sphere", transform_offset))
  print("pos: " .. spawn_pos.x .. " " .. spawn_pos.y .. " " .. spawn_pos.z)
  return id
end