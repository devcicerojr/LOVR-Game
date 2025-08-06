local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = {"skybox_texture"},
  update_fn = function(id , c , pass) -- draw function
    pass:setShader(environment_shader.shader)
    environment_shader.send(pass, vec3(0.8, 0.8, 0.8))
    pass:skybox(ecs.entities[id].skybox_texture.cube)
  end
}