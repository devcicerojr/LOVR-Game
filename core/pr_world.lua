local settings = {
  tags = {'wall'},
  staticTags = {'wall'},
  maxColliders = 16384,
  threadSafe = true,
  allowSleep = false,
  stabilization = 0.2,
  maxPenetration = 0.01,
  restitutionThreshold = 1.0,
  velocitySteps = 10,
  positionSteps = 2,
}
local lovr_world = lovr.physics.newWorld(settings)


return lovr_world