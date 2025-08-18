local lovr_world = require'../core/pr_world'
local pr_component = require'../components/pr_components'

local texture = nil

return function(ecs, spawn_pos, width, height, depth, texture_path)
  local id = ecs:newEntity()
  local width = width or 10.0
  local height = height or 5.0
  local depth = depth or 2
  local spawn_pos = spawn_pos or lovr.math.newVec3(0, height / 2, 0)
  -- local collider = lovr_world:newBoxCollider(spawn_pos, width, height, depth)

  local format = {
    { 'VertexPosition', 'vec3' },
    { 'VertexUV', 'vec2' }
  }

  local vertices = {
  -- Back face
  { -width/2, -height/2, -depth/2, 0, 0 },
  {  width/2, -height/2, -depth/2, 1, 0 },
  {  width/2,  height/2, -depth/2, 1, 1 },
  { -width/2,  height/2, -depth/2, 0, 1 },

  -- Front face
  { -width/2, -height/2,  depth/2, 1, 0 },
  {  width/2, -height/2,  depth/2, 0, 0 },
  {  width/2,  height/2,  depth/2, 0, 1 },
  { -width/2,  height/2,  depth/2, 1, 1 },

  -- Left face
  { -width/2, -height/2, -depth/2, 1, 0 },
  { -width/2,  height/2, -depth/2, 1, 1 },
  { -width/2,  height/2,  depth/2, 0, 1 },
  { -width/2, -height/2,  depth/2, 0, 0 },

  -- Right face
  {  width/2, -height/2, -depth/2, 0, 0 },
  {  width/2,  height/2, -depth/2, 0, 1 },
  {  width/2,  height/2,  depth/2, 1, 1 },
  {  width/2, -height/2,  depth/2, 1, 0 },

  -- Top face
  { -width/2,  height/2, -depth/2, 1, 1 },
  {  width/2,  height/2, -depth/2, 0, 1 },
  {  width/2,  height/2,  depth/2, 0, 0 },
  { -width/2,  height/2,  depth/2, 1, 0 },

  -- Bottom face
  { -width/2, -height/2, -depth/2, 1, 0 },
  {  width/2, -height/2, -depth/2, 0, 0 },
  {  width/2, -height/2,  depth/2, 0, 1 },
  { -width/2, -height/2,  depth/2, 1, 1 }
}

local indices = {
  1, 2, 3, 1, 3, 4,     -- back
  5, 6, 7, 5, 7, 8,     -- front
  9,10,11, 9,11,12,     -- left ✅
 13,14,15,13,15,16,     -- right (optional fix too)
 17,18,19,17,19,20,     -- top ✅
 21,22,23,21,23,24      -- bottom (optional fix too)
}

  local mesh = lovr.graphics.newMesh(format, vertices)
  mesh:setIndices(indices)

  local texture_path = texture_path or "assets/neutral.png"
  if texture == nil then
    texture = lovr.graphics.newTexture(texture_path)
  end
  local material = lovr.graphics.newMaterial({texture = texture,
  uvScale = {1, width / height},})
  
  -- ecs:addMaterial("mesh_wall_material", material)
  mesh:setMaterial(texture)
  local collider = lovr_world:newMeshCollider(mesh)
  collider:setPosition(spawn_pos)
  collider:setKinematic(true)
  collider:setTag('wall')

  

  -- collider:setKinematic(true)
  -- collider:setTag('wall')
  local mesh_color = lovr.math.newVec4(0.5, 0.5, 0.5, 1)
  ecs:addComponent(id, pr_component.TexturedMesh(mesh, texture, mesh_color))
  ecs:addComponent(id, pr_component.Collider(collider, "mesh", spawn_pos))
  ecs:addComponent(id, pr_component.Brush(texture))
  return id
end