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
      float fogAmount = atan(length(fragmentClip) * 0.1) * 2.0 / PI;
      return vec4(mix(Color.rgb, fogColor, fogAmount), Color.a);
    }
  ]]
)

function environment_shader.setDefaultVals(pass)

end

function environment_shader.send(fog_color)

end


return environment_shader
