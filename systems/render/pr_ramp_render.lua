return {
  phase = "render",
  requires = {"is_ramp", "textured_mesh"},
  update_fn = function(ecs, id, c, pass)
    local entity = ecs.entities[id]
    local color = entity.textured_mesh.base_color
    local mesh = entity.textured_mesh.mesh
    local texture = entity.textured_mesh.texture
    local t = entity.transform.transform
    local px, py, pz = t:getPosition()
    
    pass:push('transform')
    pass:push('state')
    pass:setMaterial(texture)
    pass:setColor(1, 1, 1, 1)
    pass:draw(mesh, px, py, pz)
    pass:pop('state')
    pass:pop('transform')
  end
}
