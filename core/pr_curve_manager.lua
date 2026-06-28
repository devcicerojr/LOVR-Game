-- Drives the visual world-bend illusion.  The bend is purely cosmetic: the
-- physics path stays straight, but the environment_shader shifts distant
-- vertices sideways so the road appears to curve left or right.
--
-- bend_strength  : signed float for the shader uniform 'bendStrength'.
--                  Used with a quadratic formula: x += ahead² * bendStrength.
--                  At 200 units ahead, max bend ≈ 20 units lateral.
--                  At 400 units ahead, max bend ≈ 80 units lateral (full road width).
-- bend_norm      : bend_strength normalised to [-1, 1] — use this for camera lean.
-- player_z       : updated each frame so the shader knows which Z is "near".

local cm = {}
cm.bend_strength = 0
cm.bend_norm     = 0    -- normalised -1..1; use this for camera and other effects
cm.player_z      = 0

local target_bend  = 0
local curve_timer  = 5          -- seconds until next direction change
local MAX_BEND     = 0.0005     -- quadratic scale: ahead² × MAX_BEND = shift in units
local LERP_SPEED   = 0.55       -- how fast the bend transitions (higher = snappier)

-- Simple LCG for reproducible, math.random-free sequence.
local rng = 42317
local function lcg()
  rng = (rng * 1664525 + 1013904223) % 4294967296
  return rng / 4294967296
end

local function pick_next()
  local r = lcg()
  if r < 0.25 then
    target_bend = 0                         -- straight section
    curve_timer = 2.0 + lcg() * 2.5
  elseif r < 0.625 then
    target_bend = MAX_BEND                  -- right curve
    curve_timer = 3.5 + lcg() * 4.0
  else
    target_bend = -MAX_BEND                 -- left curve
    curve_timer = 3.5 + lcg() * 4.0
  end
end

function cm.update(dt, player_z)
  if player_z then cm.player_z = player_z end
  curve_timer = curve_timer - dt
  if curve_timer <= 0 then pick_next() end
  -- Smooth exponential approach to target
  local alpha = math.min(1.0, dt * LERP_SPEED)
  cm.bend_strength = cm.bend_strength + (target_bend - cm.bend_strength) * alpha
  cm.bend_norm     = cm.bend_strength / MAX_BEND
end

function cm.reset()
  cm.bend_strength = 0
  cm.bend_norm     = 0
  target_bend      = 0
  curve_timer      = 5
  rng              = 42317
  cm.player_z      = 0
end

pr_event_bus:on('game_scene_unloaded', function() cm.reset() end)

cm.reset()
return cm
