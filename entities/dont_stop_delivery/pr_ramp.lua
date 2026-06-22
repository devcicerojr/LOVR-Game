local pr_component = require'../components/pr_components'
local lovr_world = require'../core/pr_world'


return function(ecs, spawn_pos, width, height, depth, slope)
  local id = ecs:newEntity()
  local width = width or 4
  local height = height or 0.1
  local depth = depth or 8
  local slope = slope or 0.3491 -- 20 degrees in radians
  local sinval, cosval, tanval = math.sin(slope), math.cos(slope), math.tan(slope)

  local sloped_height = tanval * depth
  local total_height = height + sloped_height
  spawn_pos = spawn_pos or vector.zero

  local format = {
    { 'VertexPosition', 'vec3' },
    { 'VertexUV', 'vec2' }
  }
  
  local vertices = {
  -- Front face
  { -width/2, -total_height/2,  -depth/2, 1, 0 },
  {  width/2, -total_height/2,  -depth/2, 0, 0 },
  {  width/2,  -total_height/2 + height,  -depth/2, 0, 1 },
  { -width/2,  -total_height/2 + height,  -depth/2, 1, 1 },
  
    -- Back face
  { -width/2, -total_height/2, depth/2, 0, 0 },
  {  width/2, -total_height/2, depth/2, 1, 0 },
  {  width/2,  total_height/2, depth/2, 1, 1 },
  { -width/2,  total_height/2, depth/2, 0, 1 },
  
  
  -- Left face
  { -width/2, -total_height/2, depth/2, 1, 0 },
  { -width/2, -total_height/2, -depth/2, 1, 1 },
  { -width/2,  -total_height/2 + height,  -depth/2, 0, 1 },
  { -width/2, total_height/2,  depth/2, 0, 0 },
  
  -- Right face
  {  width/2, -total_height/2,  depth/2, 0, 0 },
  {  width/2, -total_height/2, -depth/2, 0, 1 },
  {  width/2,  total_height/2,  depth/2, 1, 1 },  -- HIGH at far (+Z)
  {  width/2, -total_height/2 + height, -depth/2, 1, 0 },  -- LOW at near (-Z)

  -- Top face (slope surface, player walks here)
  { -width/2, -total_height/2 + height, -depth/2, 1, 1 },  -- left  near LOW
  {  width/2, -total_height/2 + height, -depth/2, 0, 1 },  -- right near LOW
  {  width/2,  total_height/2,  depth/2, 0, 0 },           -- right far  HIGH
  { -width/2,  total_height/2,  depth/2, 1, 0 },           -- left  far  HIGH
  
  -- Bottom face
  { -width/2, -total_height/2, -depth/2, 1, 0 },
  {  width/2, -total_height/2, -depth/2, 0, 0 },
  {  width/2, -total_height/2,  depth/2, 0, 1 },
  { -width/2, -total_height/2,  depth/2, 1, 1 }
  }
  
  local indices = {
   1,  2,  3,   1,  3,  4,  -- front (-Z, near/entry)
   5,  6,  7,   5,  7,  8,  -- back  (+Z, far/exit)
  10,  9, 12,  10, 12, 11,  -- left  (-X)
  13, 14, 16,  13, 16, 15,  -- right (+X)
  17, 20, 19,  17, 19, 18,  -- top   (+Y slope, player walks here)
  21, 22, 23,  21, 23, 24,  -- bottom (-Y)
  }
  
  local mesh = lovr.graphics.newMesh(format, vertices)
  mesh:setIndices(indices)

  local texture_path = texture_path or "assets/neutral.png"
  if texture == nil then
    texture = lovr.graphics.newTexture(texture_path)
  end
  local material = lovr.graphics.newMaterial({texture = texture,
  uvScale = {1, width / height},})

  -- Box center positioned so the front-top edge aligns with spawn_pos at ground level.
  -- The ramp rises in the +Z direction over height units, gaining height*sin(12°) ≈ 2.5 units of height.
  local cx = spawn_pos.x
  local cy = spawn_pos.y + (total_height) / 2
  local cz = spawn_pos.z -- + (depth / 2) * sinval + (height / 2) * cosval
  local center = lovr.math.newVec3(cx, cy, cz)

  mesh:setMaterial(texture)
  local collider = lovr_world:newMeshCollider(mesh)
  collider:setPosition(center)
  collider:setKinematic(true)
  collider:setTag('ramp')

  local entity_transform = lovr.math.newMat4(center, vector.one, lovr.math.quat(0, 1, 0, 0))

  -- local collider = lovr_world:newBoxCollider(center, width, total_height, depth)
  -- collider:setKinematic(true)
  -- collider:setSleepingAllowed(true)
  -- collider:setTag('ramp')
  -- collider:setPose(center, slope_quat)

  local mesh_color = lovr.math.newVec4(0.5, 0.5, 0.5, 1)
  ecs:addComponent(id, pr_component.TexturedMesh(mesh, texture, mesh_color))
  ecs:addComponent(id, pr_component.Transform(entity_transform))
  -- ecs:addComponent(id, pr_component.Collider(collider, "box", lovr.math.newMat4()))
  ecs:addComponent(id, pr_component.IsRamp(width, height, depth))
  return id
end



