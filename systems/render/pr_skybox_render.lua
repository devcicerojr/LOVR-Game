local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = {"skybox_texture"},
  update_fn = function(id , c , pass) -- draw function
    pass:setShader() -- when drawing skybox, use no custom shader
    pass:skybox(ecs.entities[id].skybox_texture.cube)
    pass:setShader(environment_shader.shader)
    environment_shader.setDefaultVals(pass)
  end
}