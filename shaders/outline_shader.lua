local outline_shader = {}

outline_shader.shader = lovr.graphics.newShader([[
  Constants {
    float outlineThickness;
    vec4 outlineColor;
  };

  vec4 lovrmain() {

    vec3 inflated = VertexPosition.xyz + VertexNormal * outlineThickness;
    vec4 pos = vec4(inflated, 1.0);
    return ClipFromLocal * pos;
  }
]], [[
  Constants {
    float outlineThickness;
    vec4 outlineColor;
  };

  vec4 lovrmain() {
    return vec4(outlineColor.rgb, 1.0); // Ignore outlineColor.a
  }

]])

function outline_shader.setDefaultVals(pass)
  pass:setShader(outline_shader.shader)
  pass:setBlendMode('multiply', 'premultiplied')
end


return outline_shader