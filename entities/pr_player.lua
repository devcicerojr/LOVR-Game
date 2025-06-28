local lovr_world = require'../core/pr_world'
local pr_component = require'../components/pr_components'

return function(ecs)
  local id = ecs:newEntity()
  ecs:addComponent(id , pr_component.Position(0, 0, 0))
  ecs:addComponent(id , pr_component.Animated())
  -- ecs:addComponent(id , "model" , {model = lovr.graphics.newModel('assets/models/Test.glb')} )
  ecs:addComponent(id , pr_component.Model(lovr.graphics.newModel('assets/models/Test.glb')))
  ecs:addComponent(id , pr_component.Velocity(0, 0, 0))
  -- ecs:addComponent(id , "collider" , {collider = lovr_world:newCapsuleCollider(0, 2, -3, 0.5, 0.5) , shape = "capsule" , 
  -- offset_x = 0 , offset_y = 0 , offset_z = 0 })
  ecs:addComponent(id , pr_component.Collider(lovr_world:newCapsuleCollider(0, 2, -3, 0.5, 0.5), "capsule", pr_Offset(0, 0, 0)))
  -- ecs:addComponent(id , "scallable" , {x = 1.0 , y = 1.0 , z = 1.0 })
  ecs:addComponent(id, pr_component.Scallable(1.0, 1.0, 1.0))
  return id
end