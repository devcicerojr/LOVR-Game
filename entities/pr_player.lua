local lovr_world = require'../core/pr_world'

return function(ecs)
  local id = ecs:newEntity()
  ecs:addComponent(id , "position" , {x = 0 , y = 0 , z = 0} )
  ecs:addComponent(id , "animated" , {} )
  ecs:addComponent(id , "model" , {model = lovr.graphics.newModel('assets/models/Test.glb')} )
  ecs:addComponent(id , "velocity" , {x = 0 , y =
   0 , z = 0} )
  ecs:addComponent(id , "collider" , {collider = lovr_world:newCapsuleCollider(0, 2, -3, 0.5, 0.5) , shape = "capsule" , 
  offset_x = 0 , offset_y = 0 , offset_z = 0 })
  ecs:addComponent(id , "scallable" , {x = 1.0 , y = 1.0 , z = 1.0 })
  return id
end