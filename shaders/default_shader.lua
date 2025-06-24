default_shader = {}
default_shader.shader = lovr.graphics.newShader([[
  vec4 lovrmain() {
    return DefaultPosition;
  }
]], [[
  Constants {
    vec4 ambience;
    vec4 lightColor;
    vec3 lightPos;
    float specularStrength;
    int metallic;
    float pixelSize;
    vec2 lovrResolution;
    int numDivs;
  };

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

    // vec2 snappedUV = floor(UV / pixelSize) * pixelSize;
    // vec4 baseColor = Color * getPixel(ColorTexture, snappedUV);
    // return baseColor * (ambience + diffuse + specular);

    vec2 snappedUV = (vec2(ivec2(UV * float(numDivs))) + 0.5) / float(numDivs);
    vec4 baseColor = Color * getPixel(ColorTexture , snappedUV);
    return baseColor * (ambience + diffuse + specular);
  }
]])

function default_shader.setDefaultVals(pass)
  local lightPos = vec3(10, 40.0, -20.0)
  local width = lovr.system.getWindowWidth()
  local height = lovr.system.getWindowHeight()
  -- Set shader values

  
  pass:setShader(default_shader.shader)
  pass:send('ambience', {0.4, 0.4, 0.4, 1.0})
  pass:send('lightColor', {1.0, 1.0, 1.0, 1.0})
  pass:send('lightPos', lightPos)
  pass:send('specularStrength', 60)
  pass:send('metallic', 200.0)
  pass:send('pixelSize' , 0.000001)
  pass:send('lovrResolution', { width, height })
  pass:send('numDivs' , 64)
end

return default_shader