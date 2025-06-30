
local ecs = require'../core/pr_ecs'
-- Custom Types



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
    -- Compose current transform into a matrix
    -- local current = lovr.math.newMat4()
    -- current:translate(entity_transform:getPosition())
    -- current:rotate(entity_transform:getOrientation())
    -- current:scale(entity_transform:getScale())
  
    -- Apply the new transform on top
    entity_transform:mul(transform)
  
    -- -- Decompose back into position, rotation, and scale
    -- entity_transform:set(current:getPosition(), current:getScale(), current:getOrientation())
  end ,

  moved = function(id, translated, rotated)
    local collider = ecs.entities[id].collider.collider
    if collider and not collider:isKinematic() then
      translated = translated or lovr.math.vec3(0, 0, 0)
      rotated = rotated or lovr.math.quat(1, 0, 0 ,0)
      -- collider:setKinematic(true)
      local collider_position = lovr.math.newVec3(collider:getPosition())
      local collider_orientation = lovr.math.newQuat(collider:getOrientation())
      collider_position:add(translated:unpack())
      collider_orientation:mul(rotated:unpack())
      collider:setPose(lovr.math.vec3(collider_position:unpack()), lovr.math.quat(collider_orientation:unpack()))
      -- collider:setKinematic(false)
    end

  end

}

return pr_utils
