local lovr_world = require'../core/pr_world'
local pr_component = require'../components/pr_components'
local pr_utils = require'../core/pr_utils'


return function(ecs)
  local id = ecs:newEntity()
  -- ecs:addComponent(id , pr_component.Position(0, 0, 0))
  
  local image = lovr.data.newImage('assets/heightmap_2.png')
  local width = image:getWidth()
  local height = image:getHeight()

  local vertices = {}
  local scaleX, scaleZ = 1.0, 1.0     -- horizontal spacing
  local scaleY = 10                -- vertical exaggeration

  -- Calculate the center offset
  local offsetX = (width - 1) * scaleX / 2
  local offsetZ = (height - 1) * scaleZ / 2

  for z = 0, height - 1 do
    for x = 0, width - 1 do
      local r, g, b, a = image:getPixel(x, z)
      local y = r * scaleY
      table.insert(vertices, { x * scaleX - offsetX, y, z * scaleZ - offsetZ })
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


  ecs:addComponent(id, pr_component.Mesh(mesh, lovr.math.newVec4(0.4, 0.8, 0.5, 1.0)))
  ecs:addComponent(id, pr_component.TerrainCollider(lovr_world:newTerrainCollider( width, image, scaleY )))
  return id
end