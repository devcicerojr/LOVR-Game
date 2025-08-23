cel_shader = {}
cel_shader.shader = lovr.graphics.newShader([[
    vec4 lovrmain() {
      return DefaultPosition;
    }
  ]], [[
    #define BANDS 12.0

    vec4 lovrmain() {
      const vec3 lightDirection = vec3(-1, -1, -1);
      vec3 L = normalize(-lightDirection);
      vec3 N = normalize(Normal);
      float ambient = 0.2;
      float normal = clamp(.5 + dot(N, L) * .5, 0.7, 1.0);


      // vec3 baseColor = Color.rgb * normal;
      vec3 baseColor = getPixel(ColorTexture, UV).rgb; // * normal;
      vec3 clampedColor = round(baseColor * BANDS) / BANDS;

      return vec4(clampedColor, Color.a);
    }
]])

function cel_shader.setDefaultVals(pass)
end

return cel_shader