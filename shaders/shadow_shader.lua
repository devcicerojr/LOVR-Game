shadow_shader = {}
shadow_shader.shader = lovr.graphics.newShader([[
  vec4 lovrmain() {
    return DefaultPosition;
  }
]], 
[[
  Constants {
    vec4 player;
    vec4 props[128];
  };

  bool isInShadow() {
    for (int i = 0; i < 128; i++) {
      vec4 prop = props[i];
      if (prop.w == 0.0) {
        break;
      }
      if (
        (length( prop.xz - PositionWorld.xz) <  prop.w   &&    prop.y > PositionWorld.y)
      ) {
        return true;
      }
    }
    return false;
  }

  vec4 lovrmain() {
    vec4 shadowMultiplyer;]
    
    if (
      (length( player.xz - PositionWorld.xz) <  player.w   &&    player.y > PositionWorld.y) ||
      (isInShadow())
    ) {
      shadowMultiplyer = vec4(.25, .625, 1, 1);
    } else {
      shadowMultiplyer = vec4(1, 1, 1, 1);
    }
    return shadowMultiplyer * Color * getPixel(ColorTexture, UV);
  }
]])