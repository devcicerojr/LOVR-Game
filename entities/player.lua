package.path = package.path .. "; .\\..\\common\\?.lua"

print(package.path)
local player = {}
-- Player must have refernece to the world in order to handle physics
player.world = {}
player.model = {}
player.collider = {}

local pr_math = require'pr_math'



function player.init()
  -- PLAYER
  player.model = lovr.graphics.newModel('assets/models/Test.glb')
  player.collider = player.world:newCapsuleCollider(0, 2, -3, 0.5, 0.5)
  player.collider:setOrientation(k_pi/2 , 1 , 0 , 0)
end

function player.update(dt)
end

function player.draw(pass)
  -- pass:setWireframe(true)
  -- pass:setWireframe(false)

  local x, y, z = player.collider:getPosition()
  local angle, ax, ay, az = player.collider:getOrientation()
  local radius = player.collider:getShape():getRadius()
  local length = player.collider:getShape():getLength()

  pass:draw(player.model, x, y - length/2 - radius, z, 1, 0)
  player.model:animate('walking', lovr.timer.getTime() % player.model:getAnimationDuration('walking'))

  pass:setWireframe(true)
  pass:capsule( x , y , z , radius, length, angle, ax , ay , az)
  pass:setWireframe(false)
end

return player