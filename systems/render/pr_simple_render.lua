local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "model" , "transform" , "static_prop"},
  update_fn = function(id , c , pass) -- draw function
    -- pass:setShader()
    local model = ecs.entities[id].model.model
    local transform = ecs.entities[id].transform.transform
    pass:draw(model , transform)
  end
}