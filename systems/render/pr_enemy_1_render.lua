return {
  phase = "render",
  requires = { "is_enemy_1", "textured_mesh", "transform" },
  update_fn = function(ecs, id, c, pass)
    local entity = ecs.entities[id]
    local color  = entity.textured_mesh.base_color
    local mesh   = entity.textured_mesh.mesh
    local t      = entity.transform.transform
    local px, py, pz = t:getPosition()

    pass:push('transform')
    pass:push('state')
    pass:setShader()
    pass:setColor(color.x, color.y, color.z, color.w)
    pass:draw(mesh, px, py, pz)
    pass:pop('state')
    pass:pop('transform')
  end
}
