local lovr_world = require'../core/pr_world'
local pr_component = require'../components/pr_components'
local pr_utils = require'../core/pr_utils'


return function(ecs, scale, mesh_color)
  local id = ecs:newEntity()
  -- ecs:addComponent(id , pr_component.Position(0, 0, 0))
  
  local image = lovr.data.newImage('assets/heightmap_2.png')
  local width = image:getWidth()
  local height = image:getHeight()
  local scale = scale or lovr.math.vec3(1.0, 10, 1.0)
  local mesh_color = mesh_color or lovr.math.newVec3(0.5, 0.5, 0.5, 1.0) -- gray

  local vertices = {}

  -- Calculate the center offset
  local offset_x = (width - 1) * scale.x / 2
  local offset_z = (height - 1) * scale.z / 2

  for z = 0, height - 1 do
    for x = 0, width - 1 do
      local r, g, b, a = image:getPixel(x, z)
      local y = r * scale.y
      table.insert(vertices, { x * scale.x - offset_x, y, z * scale.z - offset_z })
    end
  end


  local indices = {}

  for z = 0, height - 2 do
    for x = 0, width - 2 do
      local i = z * width + x + 1
      table.insert(indices, i)
      table.insert(indices, i + width)
      table.insert(indices, i + 1)

      table.insert(indices, i + 1)
      table.insert(indices, i + width)
      table.insert(indices, i + width + 1)
    end
  end

  local mesh = lovr.graphics.newMesh({{ 'VertexPosition', 'vec3' },
  { 'VertexNormal', 'vec3' }}, vertices)
  mesh:setIndices(indices)


  ecs:addComponent(id, pr_component.Mesh(mesh, mesh_color))
  ecs:addComponent(id, pr_component.TerrainCollider(lovr_world:newTerrainCollider( width, image, scale.y )))
  ecs:addComponent(id, pr_component.IsTerrain())
  return id
end