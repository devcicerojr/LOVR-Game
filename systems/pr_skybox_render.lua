package.path = package.path .. ".\\..\\core\\?.lua"

local ecs = require'pr_ecs'

return {
  phase = "render",
  requires = {"skybox_texture"},
  update_fn = function(id , c , pass) -- draw function
    pass:setShader()
    pass:skybox(ecs.entities[id].skybox_texture.cube)
    pass:setShader(default_shader.shader)
    default_shader.setDefaultVals(pass)
  end
}