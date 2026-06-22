local pr_component = require'../components/pr_components'

return function(ecs , position, scale)
  local id = ecs:newEntity()
  local position = position or lovr.math.newVec3(0, 0, 0)
  local model = lovr.graphics.newModel('assets/models/props/poste.obj')
  local scale = scale or lovr.math.vec3(1.0, 1.0, 1.0)
  local transform = lovr.math.newMat4(position, scale,  lovr.math.newQuat())

  ecs:addComponent(id, pr_component.Model(model))
  ecs:addComponent(id, pr_component.Transform(transform))
  ecs:addComponent(id, pr_component.StaticProp())
end
