local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "model" , "animated" },
  update_fn = function(id , c , pass) -- draw function
    -- pass:setShader()
    pass:draw(ecs.entities[id].model.model , 
    ecs.entities[id].position.x , ecs.entities[id].position.y , ecs.entities[id].position.z,
    1 , 0)
    ecs.entities[id].model.model:animate('walking', lovr.timer.getTime() % 
    ecs.entities[id].model.model:getAnimationDuration('walking'))
  end
}