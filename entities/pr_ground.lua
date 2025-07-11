local lovr_world = require'../core/pr_world'
local pr_component = require'../components/pr_components'
local pr_utils = require'../core/pr_utils'

return function(ecs , width, mesh_color)
  local id = ecs:newEntity()
  local width = width or 20
  local scale = width / 2
  local mesh_color = mesh_color or lovr.math.vec4(0.5, 0.5, 0.5, 1.0) -- gray
 
  local vertices = {
      { -scale, 0, -scale },  -- bottom-left
      {  scale, 0, -scale },  -- bottom-right
      {  scale, 0,  scale },  -- top-right
      { -scale, 0,  scale }   -- top-left
  }

  local indices = {1, 2, 3, 1, 3, 4} -- two triangles
  local mesh = lovr.graphics.newMesh(vertices)

  mesh:setIndices(indices)

  ecs:addComponent(id, pr_component.Mesh(mesh, mesh_color))
  ecs:addComponent(id, pr_component.TerrainCollider(lovr_world:newTerrainCollider(width)))
  ecs:addComponent(id, pr_component.IsTerrain())
  return id
end