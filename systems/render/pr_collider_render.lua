local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "collider" },
  update_fn = function(id , c , pass) -- draw function
    if not is_dev_build then
      return
    end
    local entity = ecs.entities[id]
    local the_collider = entity.collider.collider
    local collider_pos = lovr.math.vec3(the_collider:getPosition())
    local collider_quat = lovr.math.quat(the_collider:getOrientation())
    
    if entity.collider.shape == "capsule" then
      local radius = the_collider:getShape():getRadius()
      local length = the_collider:getShape():getLength()     
      if (is_dev_build) then
        pass:setWireframe(true)
        pass:capsule(collider_pos.x, collider_pos.y, collider_pos.z , radius, length , collider_quat:unpack())
        pass:setWireframe(false)
      end   
    end
    
  end
}
