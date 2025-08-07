environment_shader = {}
environment_shader.shader = lovr.graphics.newShader(
  [[
    out vec4 fragmentClip;

    vec4 lovrmain() {
      vec3 position = VertexPosition.xyz;
      fragmentClip = ClipFromLocal * vec4(position, 1.);
      return fragmentClip;
    } 
  ]], 
  [[
    /* FRAGMENT shader */
    in vec4 fragmentClip;

    uniform vec3 fogColor;

    vec4 lovrmain() {
      float fogAmount = atan(length(fragmentClip) * 0.02) * 2 / PI;
      return vec4(mix(Color.rgb, fogColor, fogAmount ), Color.a) * getPixel(ColorTexture, UV);
    }
  ]]
)

function environment_shader.setDefaultVals(pass)
  print("GOT HERE")
  local fog_color = vec3(0.1 , 0.4, 1.0)
  pass:send('fogColor', fog_color)
end

function environment_shader.send(pass , fog_color)
  local fog_color = fog_color or vec3(1.0 , 1.0, 1.0)
  pass:send('fogColor', fog_color)
end


return environment_shader

