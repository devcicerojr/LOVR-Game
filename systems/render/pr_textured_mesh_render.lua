local ecs = require'../core/pr_ecs'

local skyColor = { 0.308, 0.258, 0.475 }


return {
  phase = "render",
  requires =  { "textured_mesh" , "is_terrain"},
  update_fn = function(id, c, pass) -- draw function
    local color = ecs.entities[id].textured_mesh.base_color
    local mesh = ecs.entities[id].textured_mesh.mesh
    local texture = ecs.entities[id].textured_mesh.texture


    pass:setShader(environment_shader.shader)
    environment_shader.send(pass, vec3(0.45, 0.45, 0.45))
    -- pass:setShader(default_shader.shader)
    -- default_shader.setDefaultVals(pass)
    -- pass:send('fogColor', { lovr.math.gammaToLinear(unpack(skyColor)) })
    pass:setColor(1.0, 1.0, 1.0)
    -- pass:setDepthOffset(-10000) -- Ensures wireframe stays on top
    pass:setMaterial(texture)
    pass:draw(mesh)
    -- pass:setDepthOffset()
    -- pass:setWireframe(true)
    -- pass:setColor(0.788, 0.502, 0.712, 0.2)
    -- pass:draw(mesh)
    -- pass:setShader(default_shader.shader)
    -- default_shader.setDefaultVals(pass)
  end
}