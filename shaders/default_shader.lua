return lovr.graphics.newShader([[
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