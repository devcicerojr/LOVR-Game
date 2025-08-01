local lovr_world = require'../core/pr_world'
local pr_component = require'../components/pr_components'
require '../core/pr_math'

return function(ecs, spawn_pos)
  
  local id = ecs:newEntity()
  local spawn_pos = spawn_pos or lovr.math.newVec3(0, 20, 0)
  local collider_rotation_offset = lovr.math.newQuat(k_pi/2, 1, 0, 0)
  local entity_transform = lovr.math.newMat4(spawn_pos, lovr.math.quat(1, 0, 0 , 0))
  local collider_radius, collider_length = 0.5, 1.5
  local collider = lovr_world:newCapsuleCollider(0, 0, 0, collider_radius, collider_length)
  local transform_offset = lovr.math.newMat4()
  local gravity_acc = -9.81 --m/s
  local current_speed = lovr.math.newVec3(0, 0, 0)
  local VELOCITY = lovr.math.newVec3(20 , 0 , 20)
  transform_offset:translate(0, collider_length/2 + collider_radius  , 0)
  transform_offset:rotate(k_pi/2, 1, 0, 0)
  -- collider:setPose(transform_offset:getPose())
  
  local game_cam_offset = lovr.math.newMat4(lovr.math.vec3(0,4,-4), lovr.math.vec3(1,1,1), lovr.math.quat(k_pi, 0, 1, 0):mul(lovr.math.quat(-0.436, 1, 0, 0)) )
  collider:setDegreesOfFreedom("xyz", "y")
  collider:setOrientation(lovr.math.newQuat(collider:getOrientation()) * collider_rotation_offset)
  
  collider:setKinematic(true)
  collider:setSleepingAllowed(false)
  origin_offset = lovr.math.newVec3(0, 0.1, 0)
  endpoint_offset = lovr.math.newVec3(0, -0.6, 0)
  
  ecs:addComponent(id, pr_component.IsKinematic())
  ecs:addComponent(id, pr_component.IsPlayer())
  ecs:addComponent(id, pr_component.Model(lovr.graphics.newModel('assets/models/xaublas.glb')))
  ecs:addComponent(id, pr_component.AnimationState())
  ecs:addComponent(id, pr_component.TracksCollider())
  ecs:addComponent(id, pr_component.PlayerControls())
  ecs:addComponent(id, pr_component.Velocity(VELOCITY))
  ecs:addComponent(id, pr_component.Collider(collider, "capsule", transform_offset))
  ecs:addComponent(id, pr_component.Transform(entity_transform))
  ecs:addComponent(id, pr_component.Gamecam(game_cam_offset))
  ecs:addComponent(id, pr_component.Gravity(gravity_acc, false))
  ecs:addComponent(id, pr_component.SensorsArray())

  local aabb_sensor_offset = lovr.math.newVec3(0, collider_length / 2 + collider_radius, 0)
  ecs:addComponent(id, pr_component.AABBSensor(aabb_sensor_offset, "aabb_sensor", 2 * collider_radius, collider_length + 2 * collider_radius, 2 * collider_radius))
  -- sensor related components
  ecs:addComponent(id, pr_component.HasGroundSensor())
  ecs:addComponent(id, pr_component.RayColliderSensor(origin_offset , endpoint_offset, "ground_sensor")) -- requires sensors_array component to be present
  
  
  -- ecs:addComponent(id, pr_component.ClassicTankMovement())
  ecs:addComponent(id, pr_component.AccDecMovement(current_speed))

  -- ecs:addComponent(id, pr_component.FreeControls())
  ecs:addComponent(id, pr_component.AutoMoveForward())
  return id
end