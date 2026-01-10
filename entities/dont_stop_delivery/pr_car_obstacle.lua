local pr_component = require'../components/pr_components'
local lovr_world = require'../core/pr_world'

local WIDTH = 3
local HEIGHT = 3
local DEPTH = 3

local ENGINE_SOUND_FILE = 'assets/sound_fx/loud_engine.wav'
local ENGINE_SOUND_RADIUS = 800

return function(ecs, spanw_pos)
  local id = ecs:newEntity()
  local spawn_pos = spanw_pos or lovr.math.newVec3(0 , 0 , 0)
  local entity_transform = lovr.math.newMat4(spawn_pos , quat(0 , 0 , 0 , 1))
  local transform_offset = lovr.math.newMat4()
  local collider = lovr_world:newBoxCollider(spanw_pos, WIDTH, HEIGHT, DEPTH)
  collider:setDegreesOfFreedom("xyz", "y")
  collider:setKinematic(true)
  collider:setUserData(id)
  collider:setTag('car')

  local source = lovr.audio.newSource(ENGINE_SOUND_FILE, { effects = {'spatialization', 'attenuation'} })
  source:setRadius(ENGINE_SOUND_RADIUS)
  source:setLooping(true)
  source:setPosition(spawn_pos)

  ecs:addComponent(id, pr_component.TracksCollider())
  ecs:addComponent(id, pr_component.IsKinematic())
  ecs:addComponent(id, pr_component.Model(lovr.graphics.newModel('assets/models/car_one.glb')))
  ecs:addComponent(id, pr_component.Transform(entity_transform))
  ecs:addComponent(id, pr_component.Collider(collider, "box", transform_offset))
  ecs:addComponent(id, pr_component.AudioSource(source))
  ecs:addComponent(id, pr_component.IsCarObstacle())
  return id
end