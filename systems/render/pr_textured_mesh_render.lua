local ecs = require'../core/pr_ecs'

local skyColor = { 0.60, 0.6, 0.6 }


return {
  phase = "render",
  requires =  { "textured_mesh" , "is_terrain"},
  update_fn = function(id, c, pass) -- draw function
    local color = ecs.entities[id].textured_mesh.base_color
    local mesh = ecs.entities[id].textured_mesh.mesh
    local texture = ecs.entities[id].textured_mesh.texture

    -- pass:setShader(cel_shader.shader)
    pass:setColor(1 , 1 , 1 , 1 )
    pass:setShader(environment_shader.shader)
    environment_shader.send(pass, vec3(.05, 0.05, 0.08))
    -- pass:setShader(default_shader.shader)
    -- default_shader.setDefaultVals(pass)
    -- pass:setColor(0.5, 0.5, 0.5)
    -- pass:setDepthOffset(-10000) -- Ensures wireframe stays on top
    pass:setMaterial(texture)
    -- pass:setDepthOffset(-1000)
    pass:setWireframe(false)
    pass:draw(mesh)
    -- pass:setDepthOffset()
    -- pass:setDepthOffset()
    -- pass:setWireframe(true)
    -- pass:setColor(0.788, 0.502, 0.712, 0.2)
    -- pass:draw(mesh)
    -- pass:setShader(default_shader.shader)
    -- default_shader.setDefaultVals(pass)
    pass:setShader()
  end
}