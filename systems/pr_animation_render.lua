local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "model" , "animated", "transform" },
  update_fn = function(id , c , pass) -- draw function
    -- pass:setShader()
    local entity = ecs.entities[id]
    pass:draw(entity.model.model, entity.transform.transform)
    entity.model.model:animate('walking', lovr.timer.getTime() % 
    entity.model.model:getAnimationDuration('walking'))
  end
}