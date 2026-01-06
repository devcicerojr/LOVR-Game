local ecs = require'../core/pr_ecs'

local skyColor = { 0.208, 0.208, 0.275 }
local shaderCode = {[[
out vec4 fragmentClip;

vec4 lovrmain() {
  vec3 position = VertexPosition.xyz;
  fragmentClip = ClipFromLocal * vec4(position, 1.);
  return fragmentClip;
} ]], [[
/* FRAGMENT shader */
in vec4 fragmentClip;

uniform vec3 fogColor;

vec4 lovrmain() {
  float fogAmount = atan(length(fragmentClip) * 0.1) * 2.0 / PI;
  return vec4(mix(Color.rgb, fogColor, fogAmount), Color.a);
}]]}

local shader  = lovr.graphics.newShader(unpack(shaderCode))

return {
  phase = "render",
  requires =  { "mesh" , "is_terrain"},
  update_fn = function(id, c, pass) -- draw function
    local color = ecs.entities[id].mesh.base_color
    -- pass:setShader(cel_shader.shader)
    -- print("GOT HERE")
    -- pass:setShader(shader)
    -- pass:send('fogColor', { lovr.math.gammaToLinear(unpack(skyColor)) })

    -- pass:setColor(color.r, color.g, color.b)
    -- pass:setDepthOffset(-10000) -- Ensures wireframe stays on top
    pass:draw(ecs.entities[id].mesh.mesh)
    -- pass:setDepthOffset()
    -- pass:setWireframe(true)
    -- pass:setColor(0.788, 0.502, 0.712, 0.2)
    -- pass:draw(ecs.entities[id].mesh.mesh)
    -- pass:setShader(environment_shader.shader)
    -- environment_shader.setDefaultVals(pass)
  end
}