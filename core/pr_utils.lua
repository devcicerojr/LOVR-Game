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
  end

}

return pr_utils
