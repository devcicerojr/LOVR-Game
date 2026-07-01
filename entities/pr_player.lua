local lovr_world = require'../core/pr_world'
local pr_component = require'../components/pr_components'
require '../core/pr_math'

local k_velocity = vector.pack(10, 0, 40)

return function(ecs, spawn_pos)
  
  local id = ecs:newEntity()
  local spawn_pos = spawn_pos or vector.pack(0, 20, 0)
  local entity_transform = lovr.math.newMat4(spawn_pos, lovr.math.quat(0, 0, 0 , 1))
  
  local collider_rotation_offset = quaternion.angleaxis(math.pi/2, 1, 0, 0)
  local collider_radius, collider_length = 0.5, 1.5
  local collider = lovr_world:newCapsuleCollider(0, 0, 0, collider_radius, collider_length)

  -- The offset transform that positions the collider correctly relative to the entity's transform 
  local transform_offset = lovr.math.newMat4()
  transform_offset:translate(0, collider_length/2 + collider_radius  , 0)
  transform_offset:rotate(collider_rotation_offset)

  local gravity_acc = -50 --m/s
  local current_speed = vector.zero
  
  local cam_transform_offset = lovr.math.newMat4()

  cam_transform_offset:setPose(vector.pack(0,4,-5), quaternion.angleaxis(math.pi, 0, 1, 0) * quaternion.angleaxis(0.9659, 0, 1, 0) )

  collider:setDegreesOfFreedom("xyz", "y")
  collider:setOrientation(lovr.math.quat(transform_offset:getOrientation()))
  collider:setKinematic(true)
  
  collider:setSleepingAllowed(false)
  collider:setContinuous(true)
  origin_offset = vector.pack(0, 1.0, 0)
  endpoint_offset = vector.pack(0, -1.5, 0)
  
  ecs:addComponent(id, pr_component.IsKinematic())
  ecs:addComponent(id, pr_component.IsPlayer())
  ecs:addComponent(id, pr_component.Model(lovr.graphics.newModel('assets/models/skater_sk.glb')))
  ecs:addComponent(id, pr_component.AnimationState())
  ecs:addComponent(id, pr_component.TracksCollider())
  ecs:addComponent(id, pr_component.PlayerControls())
  ecs:addComponent(id, pr_component.Velocity(k_velocity))
  ecs:addComponent(id, pr_component.Collider(collider, "capsule", transform_offset))
  ecs:addComponent(id, pr_component.Transform(entity_transform))
  ecs:addComponent(id, pr_component.Camera(cam_transform_offset))
  ecs:addComponent(id, pr_component.Gravity(gravity_acc, false))
  ecs:addComponent(id, pr_component.SensorsArray())

  local aabb_sensor_offset = vector.pack(0, collider_length / 2 + collider_radius, 0)
  ecs:addComponent(id, pr_component.AABBSensor(aabb_sensor_offset, "aabb_sensor", 2 * collider_radius, collider_length + 2 * collider_radius, 2 * collider_radius))
  -- sensor related components
  ecs:addComponent(id, pr_component.HasGroundSensor())
  ecs:addComponent(id, pr_component.RayColliderSensor(origin_offset , endpoint_offset, "ground_sensor")) -- requires sensors_array component to be present
  
  -- ecs:addComponent(id, pr_component.ClassicTankMovement())
  ecs:addComponent(id, pr_component.AccDecMovement(current_speed))

  -- ecs:addComponent(id, pr_component.FreeControls())
  -- ecs:addComponent(id, pr_component.AutoMoveForward())
  ecs:addComponent(id, pr_component.AllDirControls())
  ecs:addComponent(id, pr_component.Shooter(2))
  return id
end