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
    uniform vec4 ambience;
    uniform vec4 lightColor;
    uniform vec3 lightPos;
    uniform float specularStrength;
    uniform float metallic;
    uniform int numDivs;

    vec4 lovrmain() {
      // Diffuse
      vec3 norm = normalize(Normal);
      vec3 lightDir = normalize(lightPos - PositionWorld);
      float diff = max(dot(norm, lightDir), 0.0);
      vec4 diffuse = diff * lightColor;

      // Specular
      vec3 viewDir = normalize(CameraPositionWorld - PositionWorld);
      vec3 reflectDir = reflect(-lightDir, norm);
      float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
      vec4 specular = specularStrength * spec * lightColor;

      float fogAmount = atan(length(fragmentClip) * 0.08) * 2 / PI;
      vec4 fragColor = vec4(mix(Color.rgb, fogColor, fogAmount ), Color.a) * getPixel(ColorTexture, UV);
      return fragColor * (ambience + diffuse + specular);
    }
  ]]
)

function environment_shader.setDefaultVals(pass)
  local fog_color = vec3(0.1 , 0.1, 0.1)
  local lightPos = vec3(10, 40.0, -20.0)
  pass:setAlphaToCoverage(false)
  pass:send('fogColor', fog_color)
  pass:send('ambience', {0.3, 0.3, 0.3, 1.0})
  pass:send('lightColor', {1.0, 1.0, 1.0, 1.0})
  pass:send('lightPos', lightPos)
  pass:send('specularStrength', 0.5) -- the higher the brighter
  pass:send('metallic', 256.0) -- 4.0 is brighter, 256 is less bright
end

function environment_shader.send(pass , fog_color)
  local fog_color = fog_color or vec3(1.0 , 1.0, 1.0)
  pass:send('fogColor', fog_color)
end


return environment_shader

