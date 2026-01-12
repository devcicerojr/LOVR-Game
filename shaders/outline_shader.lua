local outline_shader = {}

outline_shader.shader =  lovr.graphics.newShader([[
Constants {
  float outlineThickness;
  vec4 outlineColor;
};

vec4 lovrmain() {
  // Transform position to view space
  vec4 viewPos = ViewFromLocal * vec4(VertexPosition.xyz, 1.0);

  // Transform normal to view space (ignore translation)
  vec3 viewNormal = normalize((ViewFromLocal * vec4(VertexNormal, 0.0)).xyz);

  // Extrude in view space
  viewPos.xyz += viewNormal * outlineThickness;

  // Project to clip space
  return ClipFromView * viewPos;
}
]], [[
  Constants {
    float outlineThickness;
    vec4 outlineColor;
  };

  vec4 lovrmain() {
    return outlineColor;
  }
]])





function outline_shader.setDefaultVals(pass)
  pass:setShader(outline_shader.shader)
  pass:setBlendMode('multiply', 'premultiplied')
end


return outline_shader