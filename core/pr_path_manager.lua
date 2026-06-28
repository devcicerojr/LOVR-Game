-- Procedural curved path manager.
-- Tracks a series of path segments (each 20 units long) with a cumulative
-- heading, so spawners can position tiles/walls along a curving infinite path.
--
-- Heading convention: h=0 → moving in +Z (world forward).
--   forward dir = (sin(h), 0, cos(h))
--   right dir   = (cos(h), 0, -sin(h))

local pm = {}

local SEGMENT_LENGTH   = 20
local TURN_ANGLE       = 8 * math.pi / 180   -- 8° per curved segment
local STRAIGHT_MIN     = 8
local STRAIGHT_MAX     = 14
local CURVE_SEGS       = 7
local START_STRAIGHT   = 26  -- stay straight through the initial grid + buffer
local START_Z          = -190 -- center Z of the first tile row in the initial grid

-- Mutable state (all reset on game scene unload)
local segs        = {}  -- list of {x, z, h}
local curve_rem   = 0
local straight_rem = START_STRAIGHT
local curve_dir   = 1
local _seed       = 12345

local function rng()
  _seed = (_seed * 1664525 + 1013904223) % 4294967296
  return _seed / 4294967296
end

local function step_heading(h)
  if curve_rem > 0 then
    curve_rem = curve_rem - 1
    return h + curve_dir * TURN_ANGLE
  end
  straight_rem = straight_rem - 1
  if straight_rem <= 0 then
    curve_rem    = CURVE_SEGS
    curve_dir    = rng() > 0.5 and 1 or -1
    straight_rem = STRAIGHT_MIN + math.floor(rng() * (STRAIGHT_MAX - STRAIGHT_MIN + 1))
  end
  return h
end

local function extend_one()
  local last = segs[#segs]
  local x, z, h
  if last then
    h = step_heading(last.h)
    x = last.x + math.sin(h) * SEGMENT_LENGTH
    z = last.z + math.cos(h) * SEGMENT_LENGTH
  else
    h = 0
    x = 0
    z = START_Z
  end
  table.insert(segs, {x = x, z = z, h = h})
end

-- Ensure at least `n` segments exist.
function pm.ensure(n)
  while #segs < n do extend_one() end
end

-- Return segment at row `row` (1-based), extending the path if needed.
function pm.get(row)
  pm.ensure(row)
  return segs[row]
end

-- Compute world position (x, y, z) for a given row and lateral lane offset.
-- Lane > 0 is to the right of path centre; lane < 0 is to the left.
function pm.world_pos(row, lane)
  local seg = pm.get(row)
  local rx = math.cos(seg.h)   -- right vector X
  local rz = -math.sin(seg.h)  -- right vector Z
  return seg.x + rx * lane, 0, seg.z + rz * lane
end

-- Current player row (updated every frame by the movement system).
pm.player_row = 1

-- Find and record which segment the player is currently on.
-- Call once per frame from the movement system.
function pm.update_player(px, pz)
  local best  = pm.player_row
  local bestd = math.huge
  local s     = math.max(1, best - 2)
  local e     = math.min(#segs, best + 20)
  for i = s, e do
    local seg = segs[i]
    local d   = (px - seg.x) ^ 2 + (pz - seg.z) ^ 2
    if d < bestd then bestd = d; best = i end
  end
  pm.player_row = best
  pm.ensure(best + 60)  -- always keep segments available ahead
end

function pm.reset(seed)
  segs         = {}
  _seed        = seed or 12345
  curve_rem    = 0
  straight_rem = START_STRAIGHT
  curve_dir    = 1
  pm.player_row = 1
  pm.ensure(60)
end

pm.SEGMENT_LENGTH = SEGMENT_LENGTH

pr_event_bus:on('game_scene_unloaded', function()
  pm.reset()
end)

pm.reset()

return pm
