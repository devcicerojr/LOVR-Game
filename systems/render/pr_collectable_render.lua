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

    pass:setShader()
    pass:setColor(1, 1, 1, 1)
    pass:draw(model, position, vec3(1.5, 1, 1),  lovr.timer.getTime() * 3, 0, 1, 0)
    pass:setShader(environment_shader.shader)
    environment_shader.setDefaultVals(pass)
  end
}