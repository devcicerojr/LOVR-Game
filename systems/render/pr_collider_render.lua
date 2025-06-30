local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "collider" },
  update_fn = function(id , c , pass) -- draw function
    local entity = ecs.entities[id]
    
    local x, y, z = entity.collider.collider:getPosition()
    local collider_quat = lovr.math.quat(ecs.entities[id].collider.collider:getOrientation())
    
    if entity.collider.shape == "capsule" then
      local radius = entity.collider.collider:getShape():getRadius()
      local length = entity.collider.collider:getShape():getLength()      
      pass:setWireframe(true)
      pass:capsule(x, y, z, radius, length , collider_quat:unpack())
      pass:setWireframe(false)
    end
    
  end
}
