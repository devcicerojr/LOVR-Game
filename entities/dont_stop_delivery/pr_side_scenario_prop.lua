local pr_component = require'../components/pr_components'

return function(ecs, transform)
  local id = ecs:newEntity()
  local transform = transform or lovr.math.newMat4()
  local spawn_pos = lovr.math.newVec3(transform:getPosition())
  local spawn_orientation = lovr.math.newQuat(transform:getOrientation())
  local model_transform = lovr.math.newMat4():rotate(spawn_orientation):translate(spawn_pos):scale(1, 1, 1)
  ecs:addComponent(id, pr_component.Model(lovr.graphics.newModel('assets/models/street.glb')))
  ecs:addComponent(id, pr_component.Transform(model_transform))
  ecs:addComponent(id, pr_component.StaticProp())
  return id
end