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

    float bayerDither16x16(vec2 fragCoord) {
      int x = int(mod(fragCoord.x, 16.0));
      int y = int(mod(fragCoord.y, 16.0));
      int index = y * 16 + x;
      float threshold = float(
        int[](
          0,128,32,160,8,136,40,168,2,130,34,162,10,138,42,170,
          192,64,224,96,200,72,232,104,194,66,226,98,202,74,234,106,
          48,176,16,144,56,184,24,152,50,178,18,146,58,186,26,154,
          240,112,208,80,248,120,216,88,242,114,210,82,250,122,218,90,
          12,140,44,172,4,132,36,164,14,142,46,174,6,134,38,166,
          204,76,236,108,196,68,228,100,206,78,238,110,198,70,230,102,
          60,188,28,156,52,180,20,148,62,190,30,158,54,182,22,150,
          252,124,220,92,244,116,212,84,254,126,222,94,246,118,214,86,
          3,131,35,163,11,139,43,171,1,129,33,161,9,137,41,169,
          195,67,227,99,203,75,235,107,193,65,225,97,201,73,233,105,
          51,179,19,147,59,187,27,155,49,177,17,145,57,185,25,153,
          243,115,211,83,251,123,219,91,241,113,209,81,249,121,217,89,
          15,143,47,175,7,135,39,167,13,141,45,173,5,133,37,165,
          207,79,239,111,199,71,231,103,205,77,237,109,197,69,229,101,
          63,191,31,159,55,183,23,151,61,189,29,157,53,181,21,149,
          255,127,223,95,247,119,215,87,253,125,221,93,245,117,213,85
        )[index]
      ) / 256.0;
      return threshold;
    }

    float bayerDither8x8(vec2 fragCoord) {
      int x = int(mod(fragCoord.x, 8.0));
      int y = int(mod(fragCoord.y, 8.0));
      int index = y * 8 + x;
      float threshold = float(
        int[]( 0, 32, 8, 40, 2, 34, 10, 42,
              48, 16, 56, 24, 50, 18, 58, 26,
              12, 44, 4, 36, 14, 46, 6, 38,
              60, 28, 52, 20, 62, 30, 54, 22,
              3, 35, 11, 43, 1, 33, 9, 41,
              51, 19, 59, 27, 49, 17, 57, 25,
              15, 47, 7, 39, 13, 45, 5, 37,
              63, 31, 55, 23, 61, 29, 53, 21
        )[index]
      ) / 64.0;
      return threshold;
    }

  vec4 lovrmain() {
    vec4 texColor = getPixel(ColorTexture, UV);
    vec4 baseColor = vec4(Color.rgb, Color.a) * texColor;

    // Dithering transparency logic
    if (isObstructing) {
      float threshold = bayerDither16x16(gl_FragCoord.xy);
      if (threshold > 0.3) // 0. = desired transparency level
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

