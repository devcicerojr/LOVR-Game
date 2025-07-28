local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "brush" , "collider", "no_mesh"},
  update_fn = function(id, c, pass) -- draw function
    local entity = ecs.entities[id]
    local collider = entity.collider.collider

    if entity.collider.shape == "box" then
      local collider_pos = lovr.math.vec3(collider:getPosition())
      local collider_quat = lovr.math.quat(collider:getOrientation())
      local width, height, depth = collider:getShape():getDimensions()
      local angle, ax, ay, az = collider_quat:unpack()
      pass:setMaterial(ecs:getMaterial("wall_material"))
      pass:box(collider_pos.x, collider_pos.y, collider_pos.z, width, height, depth, angle, ax, ay, az, 'fill')
      pass:setMaterial()
    end
  end
}