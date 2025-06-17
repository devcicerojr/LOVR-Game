local ground = {}
ground.vertices = {}
ground.indices = {}
ground.terrainMesh = {}

function ground.init()
    print("entry ground.init()")

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


function ground.draw()
  pass:draw(ground.terrainMesh)
end

return ground