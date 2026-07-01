local pr_component = require'../components/pr_components'
local lovr_world   = require'../core/pr_world'

local RADIUS       = 1.0
local HOVER_HEIGHT = 6.0
local RINGS        = 10
local SEGMENTS     = 14

-- Builds a UV sphere without degenerate pole triangles.
-- Uses a single vertex for each pole and triangle fans there instead of
-- duplicated-position ring vertices, which crash Jolt's mesh collider.
local function build_sphere(radius, rings, segments)
  local verts = {}
  local idxs  = {}

  -- index 1: north pole
  table.insert(verts, { 0, radius, 0, 0.5, 0 })

  -- latitude rings, excluding the poles (r = 1 .. rings-1)
  for r = 1, rings - 1 do
    local phi    = math.pi * r / rings
    local sinPhi = math.sin(phi)
    local cosPhi = math.cos(phi)
    for s = 0, segments - 1 do
      local theta = 2 * math.pi * s / segments
      local x = radius * sinPhi * math.cos(theta)
      local y = radius * cosPhi
      local z = radius * sinPhi * math.sin(theta)
      table.insert(verts, { x, y, z, s / segments, r / rings })
    end
  end

  -- last index: south pole
  table.insert(verts, { 0, -radius, 0, 0.5, 1 })

  local n_pole = 1
  local s_pole = #verts
  local ring_base = function(r) return 2 + (r - 1) * segments end  -- 1-indexed start of ring r

  -- north cap fan
  for s = 0, segments - 1 do
    local a = ring_base(1) + s
    local b = ring_base(1) + (s + 1) % segments
    table.insert(idxs, n_pole); table.insert(idxs, a); table.insert(idxs, b)
  end

  -- middle quad strips
  for r = 1, rings - 2 do
    for s = 0, segments - 1 do
      local a = ring_base(r)     + s
      local b = ring_base(r + 1) + s
      local c = ring_base(r + 1) + (s + 1) % segments
      local d = ring_base(r)     + (s + 1) % segments
      table.insert(idxs, a); table.insert(idxs, b); table.insert(idxs, c)
      table.insert(idxs, a); table.insert(idxs, c); table.insert(idxs, d)
    end
  end

  -- south cap fan
  for s = 0, segments - 1 do
    local a = ring_base(rings - 1) + s
    local b = ring_base(rings - 1) + (s + 1) % segments
    table.insert(idxs, a); table.insert(idxs, s_pole); table.insert(idxs, b)
  end

  return verts, idxs
end

return function(ecs, spawn_pos)
  local id = ecs:newEntity()
  spawn_pos = spawn_pos or lovr.math.newVec3(0, 0, 0)

  local format = {
    { 'VertexPosition', 'vec3' },
    { 'VertexUV',       'vec2' },
  }

  local verts, idxs = build_sphere(RADIUS, RINGS, SEGMENTS)

  local mesh = lovr.graphics.newMesh(format, verts)
  mesh:setIndices(idxs)

  local center = lovr.math.newVec3(spawn_pos.x, HOVER_HEIGHT, spawn_pos.z)

  -- Jolt does not support kinematic bodies with mesh shapes (only static).
  -- A sphere collider is the correct kinematic-safe shape for a sphere enemy.
  local collider = lovr_world:newSphereCollider(center, RADIUS)
  collider:setKinematic(true)
  collider:setSleepingAllowed(false)
  collider:setTag('enemy_1')

  local entity_transform = lovr.math.newMat4(center, lovr.math.quat(0, 0, 0, 1))
  local mesh_color = lovr.math.newVec4(0.9, 0.1, 0.9, 1)

  ecs:addComponent(id, pr_component.Health(15, 15))
  ecs:addComponent(id, pr_component.TexturedMesh(mesh, nil, mesh_color))
  ecs:addComponent(id, pr_component.Transform(entity_transform))
  ecs:addComponent(id, pr_component.Collider(collider, "sphere", lovr.math.newMat4()))
  ecs:addComponent(id, pr_component.IsEnemy1())
  ecs:addComponent(id, pr_component.StateMachine({
    current             = "idle",
    x_direction         = (math.random(0, 1) == 0) and 1 or -1,
    x_time              = 0,
    x_change_threshold  = 1.0 + math.random() * 2.0,  -- 1–3 s before first direction change
  }))

  return id
end
