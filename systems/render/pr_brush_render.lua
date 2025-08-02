local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "brush" , "collider", "textured_mesh"},
  update_fn = function(id, c, pass) -- draw function
    local entity = ecs.entities[id]
    local collider = entity.collider.collider
    local shape = entity.collider.shape
    local mesh = entity.textured_mesh.mesh
    local texture = entity.textured_mesh.texture
    local mesh_color = entity.textured_mesh.color

    local collider_pos = lovr.math.vec3(collider:getPosition())
    local collider_quat = lovr.math.quat(collider:getOrientation())
    if shape == "mesh" then
      local angle, ax, ay, az = collider_quat:unpack()
      pass:draw(mesh , collider_pos.x, collider_pos.y, collider_pos.z, 1 , angle, ax, ay, az)
    elseif shape == "convex_shape" then
      pass:draw(mesh, collider_pos.x, collider_pos.y, collider_pos.z, 1, angle, ax, ay, az)
    end
  end
}