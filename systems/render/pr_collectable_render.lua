local pr_ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "is_collectable", "model" , "transform"},
  update_fn = function(id, c, pass) -- render
    local entity_transform = pr_ecs.entities[id].transform.transform
    local model = pr_ecs.entities[id].model.model

    if not model then
      return
    end

    local position = vec3(entity_transform:getPosition())
    local orientation = quat(entity_transform:getOrientation())

    pass:setColor(1, 1, 1, 1)
    pass:draw(model, position, vec3(1.5, 1, 1),  orientation)
  end
}