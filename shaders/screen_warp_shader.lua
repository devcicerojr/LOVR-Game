-- Post-process screen-space curve warp.
-- Applied during the gTexture → window blit so it runs entirely in the
-- fragment shader with zero vertex / physics changes.
--
-- The UV is shifted horizontally by an amount that grows quadratically toward
-- the top of the screen (UV.y ≈ 0 in Vulkan / LOVR = horizon).
-- Near the bottom (player's feet) the warp is effectively zero, so close
-- geometry looks straight while the distant road visually curves away.

screen_warp_shader = {}
screen_warp_shader.shader = lovr.graphics.newShader(
  'unlit',
  [[
    uniform float bendStrength;

    vec4 lovrmain() {
      vec2 uv = UV;

      float horizon_factor = 1.0 - uv.y;
      horizon_factor = horizon_factor * horizon_factor;

      uv.x -= bendStrength * horizon_factor;
      uv = clamp(uv, vec2(0.0), vec2(1.0));
      return getPixel(ColorTexture, uv);
    }
  ]]
)

-- bend_norm: normalised bend value in [-1, 1] from pr_curve_manager.
-- scale controls how many screen-widths the horizon shifts at full bend.
function screen_warp_shader.send(pass, bend_norm, scale)
  scale = scale or 0.22
  pass:send('bendStrength', bend_norm * scale)
end

return screen_warp_shader
