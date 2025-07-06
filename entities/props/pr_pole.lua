local pr_component = require'../components/pr_components'

return function(ecs , position)
  local id = ecs:newEntity()

  local position = position or lovr.math.newVec3(0, 0, 0)

  local model = lovr.graphics.newModel('assets/models/props/poste.obj')

  local transform = lovr.math.newMat4(position, lovr.math.newQuat())

  ecs:addComponent(id, pr_component.Model(model))
  ecs:addComponent(id, pr_component.Transform(transform))
  ecs:addComponent(id, pr_component.StaticProp())
end
