local ground = {}
ground.vertices = {}
ground.indices = {}
ground.terrainMesh = {}

function ground.init()
    ground.vertices = {
      { -50, 0, -50 },  -- bottom-left
      {  50, 0, -50 },  -- bottom-right
      {  50, 0,  50 },  -- top-right
      { -50, 0,  50 }   -- top-left
    }

    ground.indices = { 1, 2, 3, 1, 3, 4 } -- two triangles

    ground.terrainMesh = lovr.graphics.newMesh(ground.vertices)
    ground.terrainMesh:setIndices(ground.indices)
end


function ground.draw(pass)
  pass:setColor(0.4, 0.8, 0.4) -- grassy green
  pass:draw(ground.terrainMesh)
  pass:setColor(1 , 1 , 1)
end

return ground