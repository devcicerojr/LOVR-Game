local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "textured_mesh", "collider" },
  update_fn = function(id, c, pass) -- draw function
    -- local entity = ecs.entities[id]
    -- local shape = entity.collider.shape
    -- local textured_mesh = entity.textured_mesh.mesh
    -- local texture = entity.textured_mesh.texture
    -- local mesh_color = entity.textured_mesh.color
    -- local collider = entity.collider.collider

    -- if shape == "mesh" then
    --   local collider_pos = lovr.math.vec3(collider:getPosition())
    --   local collider_quat = lovr.math.quat(collider:getOrientation())
    --   local angle, ax, ay, az = collider_quat:unpack()

    --   -- pass:setMaterial(ecs:getMaterial("wall_material"))
    --   pass:draw(textured_mesh, collider_pos.x, collider_pos.y, collider_pos.z, 1 , angle, ax, ay, az)
    --   -- pass:setMaterial()
    -- end
  end
}