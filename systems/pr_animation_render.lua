local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "model" , "animated" },
  update_fn = function(id , c , pass) -- draw function
    -- pass:setShader()
    local entity = ecs.entities[id]
    pass:draw(entity.model.model , 
    entity.transform.x, entity.transform.y, entity.transform.z, 1,
    entity.transform.angle, entity.transform.ax, entity.transform.ay, entity.transform.az)
    entity.model.model:animate('walking', lovr.timer.getTime() % 
    entity.model.model:getAnimationDuration('walking'))
  end
}