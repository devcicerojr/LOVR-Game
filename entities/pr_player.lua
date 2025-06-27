return function(ecs)
  local id = ecs:newEntity()
  ecs:addComponent(id , "position" , {x = 0 , y = 0 , z = 0} )
  ecs:addComponent(id , "animated" , {} )
  ecs:addComponent(id , "model" , {model = lovr.graphics.newModel('assets/models/Test.glb')} )
  ecs:addComponent(id , "velocity" , {x = 0 , y = 0 , z = 0} )
  ecs:addComponent(id , "collider" , {radius = 0.5 , length = 0.5 , "capsule"})
  ecs:addComponent(id , "scallable" , {x = 1.0 , y = 1.0 , z = 1.0 })
  return id
end