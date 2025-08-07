test_shader = {}
test_shader.shader = lovr.graphics.newShader(
  [[
    out vec2 screenUV;
    out vec4 fragmentClip;

    vec4 lovrmain() {
      vec3 position = VertexPosition.xyz;
      fragmentClip = ClipFromLocal * vec4(position, 1.);
      vec2 ndc = fragmentClip.xy / fragmentClip.w;
      screenUV = ndc * 0.5 + 0.5;
      return fragmentClip;
    } 
  ]], 
  [[
    /* FRAGMENT shader */
    in vec4 fragmentClip;
    in vec2 screenUV;

    uniform vec3 fogColor;
    uniform bool isObstructing;

    float dither(vec2 uv) {
      // Scale UV to screen resolution or grid size
      vec2 gridPos = uv * Resolution;
      int x = int(mod(gridPos.x, 4.0));
      int y = int(mod(gridPos.y, 4.0));
      int index = y * 4 + x;

      // Normalize index to [0, 1] range
      return float(index) / 16.0;
    }


    vec4 lovrmain() {
      vec4 texColor = getPixel(ColorTexture, UV);
      vec4 baseColor = vec4(Color.rgb, Color.a) * texColor;

      // Dithering transparency logic
      if (isObstructing) {
        float threshold = dither(screenUV);
        float noise = fract(sin(dot(screenUV ,vec2(12.9898,78.233))) * 43758.5453);
        if (noise > threshold)
          discard;
      }

      // Fog blending based on clip-space depth
      float fogAmount = atan(length(fragmentClip) * 0.02) * 2.0 / PI;
      vec3 finalColor = mix(baseColor.rgb, fogColor.rgb, fogAmount);

      return vec4(finalColor, baseColor.a);
    }

  ]]
)

function test_shader.setDefaultVals(pass)
  print("GOT HERE")
  local fog_color = vec3(0.1 , 0.4, 1.0)
  pass:send('fogColor', fog_color)
end

function test_shader.send(pass , fog_color)
  local fog_color = fog_color or vec3(1.0 , 1.0, 1.0)
  pass:send('fogColor', fog_color)
end


return test_shader

