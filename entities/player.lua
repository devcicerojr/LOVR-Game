package.path = package.path .. "; .\\..\\common\\?.lua"

print(package.path)
local player = {}
-- Player must have refernece to the world in order to handle physics
player.world = {}
player.model = {}
player.collider = {}

local pr_math = require'pr_math'

local collider_radius = 0.5
local collider_length = 0.5
local col_model_offset = lovr.math.newVec3(0 , -collider_length/2  - collider_radius , 0)
local col_model_rot_offset = lovr.math.newQuat(k_pi/2 , 1 , 0 , 0)



function player.init()
  -- PLAYER
  player.model = lovr.graphics.newModel('assets/models/Test.glb')
  player.collider = player.world:newCapsuleCollider(0, 2, -3, collider_radius, collider_length)
  player.collider:setDegreesOfFreedom("xyz" , "y")
  player.collider:setOrientation(lovr.math.newQuat(player.collider:getOrientation()) * col_model_rot_offset)
end

function player.update(dt)
  local cur_collider_quat = lovr.math.quat(player.collider:getOrientation())
  -- player.collider:setOrientation(cur_collider_quat:mul(0.1, 0 , 1 , 0):unpack())
  player.collider:setOrientation(lovr.math.quat(0.1, 0 , 1 , 0) * cur_collider_quat)
end

function player.draw(pass)
  -- pass:setWireframe(true)
  -- pass:setWireframe(false)

  local x, y, z = player.collider:getPosition()
  local collider_quat = lovr.math.newQuat(player.collider:getOrientation())
  local radius = player.collider:getShape():getRadius()
  local length = player.collider:getShape():getLength()

  local model_quat = lovr.math.quat(collider_quat * lovr.math.quat(col_model_rot_offset:unpack()):conjugate())
  local rotated_pos_offset = lovr.math.newVec3(col_model_offset:unpack()):rotate(model_quat)

  pass:draw(player.model, x + rotated_pos_offset.x , y + rotated_pos_offset.y , z + rotated_pos_offset.z, 1, model_quat:unpack())
  player.model:animate('walking', lovr.timer.getTime() % player.model:getAnimationDuration('walking'))

  pass:setWireframe(true)
  pass:capsule( x , y , z , radius, length, collider_quat:unpack())
  pass:setWireframe(false)
end

return player