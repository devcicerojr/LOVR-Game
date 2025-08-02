local lovr_world = require'../core/pr_world'
local pr_component = require'../components/pr_components'
local pr_utils = require'../core/pr_utils'

return function(ecs, spawn_pos, tile_size, texture_path, mesh_color)
  local id = ecs:newEntity()
  local spawn_pos = spawn_pos or lovr.math.newVec3(0, 0, 0)
  local tile_size = tile_size or 20.0
  local texture_path = texture_path or "assets/neutral.png"
  local mesh_color = mesh_color or lovr.math.newVec4(0.5, 0.5, 0.5, 1.0) -- gray
  
  local format = {
    { 'VertexPosition', 'vec3' },
    { 'VertexUV', 'vec2' }
  }
  local vertices = {
      { -(tile_size/2) + spawn_pos.x, spawn_pos.y, -(tile_size/2) + spawn_pos.z, 0, 1},  -- bottom-left
      {  (tile_size/2) + spawn_pos.x, spawn_pos.y, -(tile_size/2) + spawn_pos.z, 1, 1},  -- bottom-right
      {  (tile_size/2) + spawn_pos.x, spawn_pos.y,  (tile_size/2) + spawn_pos.z, 1, 0},  -- top-right
      { -(tile_size/2) + spawn_pos.x, spawn_pos.y,  (tile_size/2) + spawn_pos.z, 0, 0}   -- top-left
  }

  local indices = {1, 2, 3, 1, 3, 4} -- two triangles
  local mesh = lovr.graphics.newMesh(format, vertices)

  local texture = lovr.graphics.newTexture(texture_path)

  mesh:setIndices(indices)

  local terrain_collider = lovr_world:newTerrainCollider(tile_size):setPosition(spawn_pos)

  ecs:addComponent(id, pr_component.TexturedMesh(mesh, texture, mesh_color))
  ecs:addComponent(id, pr_component.TerrainCollider(terrain_collider))
  ecs:addComponent(id, pr_component.IsTerrain())
  ecs:addComponent(id, pr_component.IsDynamicSpawn())
  return id
end