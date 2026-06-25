
-- local ecs = require'../core/pr_ecs'
-- Custom Types

-- Save original print
local original_print = print


-- Override print
function print(...)
  local info = debug.getinfo(2, "Sl")
  local source = info.short_src or "?"
  local line = info.currentline or "?"

  -- Clean up source path
  source = source:gsub("^@", "")       -- remove leading '@'
  source = source:gsub("^/+", "")     -- collapse multiple leading slashes

  local args = {...}
  for i = 1, #args do
    args[i] = tostring(args[i])
  end

  original_print(string.format("[%s:%d]", source, line), table.concat(args, "\t"))
end

local pr_Colora_mt = {
  __index = {
    toString = function(self)
      return string.format("pr_utils.colora(%.2f, %.2f, %.2f, %.2f)", self.r, self.g, self.b, self.a)
    end
  },

  __type = "colora" 
}

local pr_utils = {
  colora = function(r , g , b , a)
    return setmetatable({r = r or 1.0, g = g or 1.0, b = b or 1.0, a = a or 1.0}, pr_Colora_mt)
  end,

  composeTransform = function(position, rotation, scale)
    scale = scale or lovr.math.newVec3(1,1,1)
    local mat = lovr.math.newMat4()
    mat:translate(position)
    mat:rotate(rotation)
    mat:scale(scale)
    return mat
  end ,
  
  applyTransform = function(entity_transform , transform)
    entity_transform = entity_transform * transform
  end ,

  moved = function(id, translated, rotated)
    local collider = ecs.entities[id].collider.collider
    if collider and not collider:isKinematic() then
      translated = translated or lovr.math.vec3(0, 0, 0)
      rotated = rotated or lovr.math.quat(1, 0, 0 ,0)
      -- collider:setKinematic(true)
      local collider_position = lovr.math.newVec3(collider:getPosition())
      local collider_orientation = lovr.math.newQuat(collider:getOrientation())
      collider_position = collider_position + translated
      collider_orientation = collider_orientation * rotated
      collider:setPose(lovr.math.vec3(collider_position:unpack()), lovr.math.quat(collider_orientation:unpack()))
      -- collider:setKinematic(false)
    end

  end,

  -- Parses an .obj file and returns a Mesh usable with world:newMeshCollider().
  -- Only position data is extracted; UVs and normals are ignored (colliders don't need them).
  -- The returned Mesh uses the same coordinate space as the .obj file — no transform is applied.
  -- USAGE:
  --
  -- local model        = lovr.graphics.newModel('assets/mymodel.obj')
  -- local collider_mesh = obj_to_collider_mesh('assets/mymodel.obj')
  
  -- local collider = lovr_world:newMeshCollider(collider_mesh)
  -- collider:setPosition(spawn_pos)
  -- collider:setKinematic(true)
  -- collider:setTag('obstacle')

  obj_to_collider_mesh = function(path)
    local src = lovr.filesystem.read(path)
    assert(src, 'pr_utils.obj_to_collider_mesh: could not read ' .. path)
    local pos  = {}
    local tris = {}

    for line in (src .. '\n'):gmatch('([^\n]*)\n') do
      local t = line:match('^%s*(%S+)')
      if t == 'v' then
        local x, y, z = line:match('v%s+(%S+)%s+(%S+)%s+(%S+)')
        pos[#pos + 1] = { tonumber(x), tonumber(y), tonumber(z) }
      elseif t == 'f' then
        local vi = {}
        for tok in line:sub(2):gmatch('%S+') do
          vi[#vi + 1] = tonumber(tok:match('^(%d+)'))  -- position index only (strips /uv/normal)
        end
        for i = 2, #vi - 1 do  -- fan-triangulate quads/ngons
          tris[#tris + 1] = vi[1]
          tris[#tris + 1] = vi[i]
          tris[#tris + 1] = vi[i + 1]
        end
      end
    end

    local mesh = lovr.graphics.newMesh({ { 'VertexPosition', 'vec3' } }, pos)
    mesh:setIndices(tris)
    return mesh
  end

}

return pr_utils
