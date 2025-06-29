local lovr_world = require'../core/pr_world'
local pr_component = require'../components/pr_components'

return function(ecs)
  local id = ecs:newEntity()
  -- ecs:addComponent(id , pr_component.Position(0, 0, 0))
  
  local scale = 50
  local vertices = {
      { -scale, 0, -scale },  -- bottom-left
      {  scale, 0, -scale },  -- bottom-right
      {  scale, 0,  scale },  -- top-right
      { -scale, 0,  scale }   -- top-left
  }

  local indices = {1, 2, 3, 1, 3, 4} -- two triangles
  local mesh = lovr.graphics.newMesh(vertices)
  mesh:setIndices(indices)

  ecs:addComponent(id, pr_component.Mesh(mesh, pr_Colora(0.4, 0.8, 0.5, 1.0)))
  ecs:addComponent(id, pr_component.TerrainCollider(lovr_world:newTerrainCollider(scale)))
  return id
end