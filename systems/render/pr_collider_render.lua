-- local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "collider" },
  update_fn = function(ecs, id, c, pass) -- draw function
    if not is_dev_build or not draw_wireframes then
      return
    end
    local entity = ecs.entities[id]
    local the_collider = entity.collider.collider
    local collider_pos = vector.pack(the_collider:getPosition())
    local collider_quat = lovr.math.quat(the_collider:getOrientation())
    
    pass:push('state')
    pass:setColor(0.9, 0.9, 0.9, 0.9)
    pass:setDepthTest('none')
    if entity.collider.shape == "capsule" then
      local radius = the_collider:getShape():getRadius()
      local length = the_collider:getShape():getLength()     
      if is_dev_build and draw_wireframes then
        pass:setWireframe(true)
        pass:capsule(collider_pos.x, collider_pos.y, collider_pos.z , radius, length , the_collider:getOrientation())
        pass:setWireframe(false)
      end   
    end
    if entity.collider.shape == "box" then
      local width, height, depth = the_collider:getShape():getDimensions()
      local angle, ax, ay, az = collider_quat:unpack()
      pass:box(collider_pos.x, collider_pos.y, collider_pos.z, width, height, depth, angle, ax, ay, az, 'line')
    end
    if entity.collider.shape == "sphere" then
      local radius = the_collider:getShape():getRadius()
      local angle, ax, ay, az = collider_quat:unpack()
      pass:sphere(collider_pos.x, collider_pos.y, collider_pos.z, radius,  angle, ax, ay, az)
    end
    if entity.collider.shape == "mesh" and entity.textured_mesh then
      local px, py, pz = entity.transform.transform:getPosition()
      pass:setWireframe(true)
      pass:draw(entity.textured_mesh.mesh, px, py, pz)
      pass:setWireframe(false)
    end
    pass:pop('state')

  end
}
