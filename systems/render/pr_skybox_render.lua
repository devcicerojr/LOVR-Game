local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = {"skybox_texture"},
  update_fn = function(id , c , pass) -- draw function
    -- pass:setShader()
    pass:skybox(ecs.entities[id].skybox_texture.cube)
  end
}