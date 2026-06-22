local Z_DISTANCE = 14  -- distance between coins in Z axis

return {
  -- Single car, center — corridors on both flanks, coins right
  {
    obstacles = { {x = 0} },
    coins = { {x = 7, z = -Z_DISTANCE}, {x = 7, z = 0}, {x = 7, z = Z_DISTANCE} },
  },
  -- Single car, left-center — wide right corridor, coins right
  {
    obstacles = { {x = -4} },
    coins = { {x = 6, z = -Z_DISTANCE}, {x = 6, z = 0}, {x = 6, z = Z_DISTANCE} },
  },
  -- Single car, right-center — wide left corridor, coins left
  {
    obstacles = { {x = 4} },
    coins = { {x = -6, z = -Z_DISTANCE}, {x = -6, z = 0}, {x = -6, z = Z_DISTANCE} },
  },
  -- Single car, far left — very wide right corridor, coins center-right
  {
    obstacles = { {x = -7} },
    coins = { {x = 3, z = -Z_DISTANCE}, {x = 3, z = 0}, {x = 3, z = Z_DISTANCE} },
  },
  -- Single car, far right — very wide left corridor, coins center-left
  {
    obstacles = { {x = 7} },
    coins = { {x = -3, z = -Z_DISTANCE}, {x = -3, z = 0}, {x = -3, z = Z_DISTANCE} },
  },
  -- Two cars flanking both sides — open center corridor, coins center
  {
    obstacles = { {x = -7}, {x = 7} },
    coins = { {x = 0, z = -Z_DISTANCE}, {x = 0, z = 0}, {x = 0, z = Z_DISTANCE} },
  },
  -- Two cars bunched left — open right corridor, coins right
  {
    obstacles = { {x = -7}, {x = -2} },
    coins = { {x = 6, z = -Z_DISTANCE}, {x = 6, z = 0}, {x = 6, z = Z_DISTANCE} },
  },
  -- Two cars bunched right — open left corridor, coins left
  {
    obstacles = { {x = 2}, {x = 7} },
    coins = { {x = -6, z = -Z_DISTANCE}, {x = -6, z = 0}, {x = -6, z = Z_DISTANCE} },
  },
  -- No obstacles — sweeping coin arc across the track
  {
    obstacles = {},
    coins = { {x = -6, z = -Z_DISTANCE}, {x = 0, z = 0}, {x = 6, z = Z_DISTANCE} },
  },
  -- No obstacles — straight coin trail down the center
  {
    obstacles = {},
    coins = { {x = 0, z = -Z_DISTANCE}, {x = 0, z = 0}, {x = 0, z = Z_DISTANCE} },
  },
  -- Single car center, coins offered on both sides (player picks a corridor)
  {
    obstacles = { {x = 0} },
    coins = { {x = -7, z = -Z_DISTANCE}, {x = 7, z = 0}, {x = -7, z = Z_DISTANCE} },
  },

  -- Ramp: center ramp, clear flanks with coins on both sides
  -- Ramp x=0 spans [-2,+2]; coins at ±6 are clear
  {
    obstacles = {},
    coins = { {x = -6, z = -Z_DISTANCE}, {x = 6, z = Z_DISTANCE} },
    ramps = { {x = 0} },
  },
  -- Ramp: left ramp, wide right corridor with coin trail
  -- Ramp x=-6 spans [-8,-4]; coins at x=5 are clear
  {
    obstacles = {},
    coins = { {x = 5, z = -Z_DISTANCE}, {x = 5, z = 0}, {x = 5, z = Z_DISTANCE} },
    ramps = { {x = -6} },
  },
  -- Ramp: right ramp, wide left corridor with coin trail
  -- Ramp x=6 spans [+4,+8]; coins at x=-5 are clear
  {
    obstacles = {},
    coins = { {x = -5, z = -Z_DISTANCE}, {x = -5, z = 0}, {x = -5, z = Z_DISTANCE} },
    ramps = { {x = 6} },
  },
  -- Ramp: two ramps flanking, open center corridor with coins
  -- Left ramp x=-6 spans [-8,-4]; right ramp x=6 spans [+4,+8]; center x=-4..+4 is clear
  {
    obstacles = {},
    coins = { {x = 0, z = -Z_DISTANCE}, {x = 0, z = 0}, {x = 0, z = Z_DISTANCE} },
    ramps = { {x = -6}, {x = 6} },
  },
  -- Ramp: left ramp + car far right, coins through the middle
  -- Car x=7 blocks [+5,+9]; ramp x=-6 spans [-8,-4]; clear path x=-4..+5
  {
    obstacles = { {x = 7} },
    coins = { {x = 0, z = -Z_DISTANCE}, {x = 0, z = 0}, {x = 0, z = Z_DISTANCE} },
    ramps = { {x = -6} },
  },
  -- Ramp: right ramp + car far left, coins through the middle
  -- Car x=-7 blocks [-9,-5]; ramp x=6 spans [+4,+8]; clear path x=-5..+4
  {
    obstacles = { {x = -7} },
    coins = { {x = 0, z = -Z_DISTANCE}, {x = 0, z = 0}, {x = 0, z = Z_DISTANCE} },
    ramps = { {x = 6} },
  },
}
