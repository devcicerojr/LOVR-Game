local lovr_world = require'../core/pr_world'
local pr_component = require'../components/pr_components'

return function(ecs, spawn_pos, width, height, depth)
  local id = ecs:newEntity()
  local spawn_pos = spawn_pos or lovr.math.newVec3(0, 0, 0)
  local width = width or 20.0
  local height = height or 10.0
  local depth = depth or 2
  local collider = lovr_world:newBoxCollider(spawn_pos, width, height, depth)
  collider:setKinematic(true)
  collider:setTag('wall')
  ecs:addComponent(id, pr_component.Collider(collider, "box", spawn_pos))
  ecs:addComponent(id, pr_component.IsBrush())
  return id
end