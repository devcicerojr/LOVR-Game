local ecs = require'../core/pr_ecs'

local skyColor = { 0.308, 0.258, 0.475 }
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
  float fogAmount = atan(length(fragmentClip) * 0.1) * 0.8 / PI;
  return vec4(mix(Color.rgb, fogColor, fogAmount), Color.a) * getPixel(ColorTexture, UV);
}]]}

local shader  = lovr.graphics.newShader(unpack(shaderCode))

return {
  phase = "render",
  requires =  { "textured_mesh" , "is_terrain"},
  update_fn = function(id, c, pass) -- draw function
    local color = ecs.entities[id].textured_mesh.base_color
    local mesh = ecs.entities[id].textured_mesh.mesh
    local texture = ecs.entities[id].textured_mesh.texture


    pass:setShader(shader)
    pass:send('fogColor', { lovr.math.gammaToLinear(unpack(skyColor)) })
    pass:setColor(1.0, 1.0, 1.0)
    -- pass:setDepthOffset(-10000) -- Ensures wireframe stays on top
    pass:setMaterial(texture)
    pass:draw(mesh)
    -- pass:setDepthOffset()
    -- pass:setWireframe(true)
    -- pass:setColor(0.788, 0.502, 0.712, 0.2)
    -- pass:draw(mesh)

  end
}