local pr_component = require'../components/pr_components'
local lovr_world = require'../core/pr_world'


local SPHERE_RADIUS = 0.3

return function(ecs)
  local id = ecs:newEntity()
  local track_transform_offset = lovr.math.newMat4(vec3(0 , 2 , 0) , quat(0 , 0 , 0 , 1))
  local player_id = ecs:getEntityByTag('is_player')
  ecs:addComponent(id, pr_component.TracksEntity(player_id, track_transform_offset))
  ecs:addComponent(id, pr_component.Model(lovr.graphics.newModel('assets/models/collectable.glb')  ))
  ecs:addComponent(id, pr_component.Rotation(lovr.math.newQuat(0, 0, 0, 1)))
  return id
end