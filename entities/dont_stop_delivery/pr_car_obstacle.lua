local pr_component = require'../components/pr_components'
local lovr_world = require'../core/pr_world'

local SIZE = 2.4
local ENGINE_SOUND_FILE = 'assets/sound_fx/loud_engine.wav'
local ENGINE_SOUND_RADIUS = 3

return function(ecs, spawn_pos)
  local id = ecs:newEntity()
  spawn_pos = spawn_pos or lovr.math.newVec3(0, 0, 0)

  local s = SIZE / 2

  local format = {
    { 'VertexPosition', 'vec3' },
    { 'VertexUV', 'vec2' },
  }

  local vertices = {
    -- Front face (z = -s)
    {  s, -s, -s, 1, 0 }, { -s, -s, -s, 0, 0 }, { -s,  s, -s, 0, 1 }, {  s,  s, -s, 1, 1 },
    -- Back face (z = +s)
    { -s, -s,  s, 0, 0 }, {  s, -s,  s, 1, 0 }, {  s,  s,  s, 1, 1 }, { -s,  s,  s, 0, 1 },
    -- Left face (x = -s)
    { -s, -s,  s, 1, 0 }, { -s, -s, -s, 0, 0 }, { -s,  s, -s, 0, 1 }, { -s,  s,  s, 1, 1 },
    -- Right face (x = +s)
    {  s, -s, -s, 0, 0 }, {  s, -s,  s, 1, 0 }, {  s,  s,  s, 1, 1 }, {  s,  s, -s, 0, 1 },
    -- Top face (y = +s)
    { -s,  s, -s, 0, 0 }, {  s,  s, -s, 1, 0 }, {  s,  s,  s, 1, 1 }, { -s,  s,  s, 0, 1 },
    -- Bottom face (y = -s)
    { -s, -s,  s, 0, 0 }, {  s, -s,  s, 1, 0 }, {  s, -s, -s, 1, 1 }, { -s, -s, -s, 0, 1 },
  }

  local indices = {
     1,  2,  3,   1,  3,  4,
     5,  6,  7,   5,  7,  8,
     9, 10, 11,   9, 11, 12,
    13, 14, 15,  13, 15, 16,
    17, 18, 19,  17, 19, 20,
    21, 22, 23,  21, 23, 24,
  }

  local mesh = lovr.graphics.newMesh(format, vertices)
  mesh:setIndices(indices)

  local collider_mesh = lovr.graphics.newMesh(format, vertices)
  collider_mesh:setIndices(indices)

  local cx = spawn_pos.x
  local cy = spawn_pos.y + SIZE / 2
  local cz = spawn_pos.z
  local center = lovr.math.newVec3(cx, cy, cz)

  local collider = lovr_world:newMeshCollider(collider_mesh)
  collider:setPosition(center)
  collider:setKinematic(true)
  collider:setTag('car')

  local source = lovr.audio.newSource(ENGINE_SOUND_FILE, { spatial = true, pitchable = false })
  source:setSpatialization(1)
  source:setFalloff(0, 0)
  source:setRadius(ENGINE_SOUND_RADIUS)
  source:setLooping(true)
  source:setPosition(center)

  local entity_transform = lovr.math.newMat4(center, lovr.math.quat(0, 0, 0, 1))
  local mesh_color = lovr.math.newVec4(0.8, 0.3, 0.1, 1)

  ecs:addComponent(id, pr_component.TexturedMesh(mesh, nil, mesh_color))
  ecs:addComponent(id, pr_component.Transform(entity_transform))
  ecs:addComponent(id, pr_component.Collider(collider, "mesh", lovr.math.newMat4()))
  ecs:addComponent(id, pr_component.AudioSource(source))
  ecs:addComponent(id, pr_component.IsCarObstacle())

  return id
end
