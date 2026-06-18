-- local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "is_car_obstacle", "model" , "transform"},
  update_fn = function(ecs, id, c, pass) -- render
    local entity_transform = ecs.entities[id].transform.transform
    local model = ecs.entities[id].model.model

    if not model then
      return
    end

    local position = vec3(entity_transform:getPosition())
    local orientation = quat(entity_transform:getOrientation())

    pass:setColor(1, 1, 1, 1)
    pass:setDepthOffset(10000)
    pass:draw(model, position, vec3(2, 1, 1),  0, 0, 1, 0)
    pass:setDepthOffset()
  end
}