local pr_components = {}

-- Custom Types
function pr_Offset(x, y, z) 
  return setmetatable({x = x or 0, y = y or 0, z = z or 0}, pr_Offset_mt)
end

pr_Offset_mt = {
  __index = {
    toString = function(self)
      return string.format("pr_Offset(%.2f, %.2f, %.2f)", self.x, self.y, self.z)
    end,

    magnitude = function(self)
      return math.sqrt(self.x^2 + self.y^2 + self.z^2)
    end
  },

  __type = "pr_Offset"  -- Optional: for custom type detection
}



-- Components

pr_components.Position = function (x, y, z)
  return {type = "position" , data = { x = x or 0 , y = y or 0 , z = z or 0 }}
end

pr_components.Animated = function ()
  return {type = "animated" , data = {}}
end

pr_components.Model = function ( model )
  return {type = "model" , data = {model = model or nil}}
end

pr_components.Velocity = function (x, y, z)
  return {type = "velocity" , data = {x = x or 0 , y = y or 0 , z = z or 0}}
end

pr_components.Collider = function (collider , shape , offset)
  return {type = "collider" , data = {collider = collider or nil,
  shape = shape or "box"}, offset = offset or pr_Offset(0, 0, 0)}
end

pr_components.Scallable = function (x, y, z)
  return {type = "scallable", data = {x = x or 0, y = y or 0, z = z or 0}}
end

pr_components.SkyboxTexture = function (texture)
  return {type = "skybox_texture", data = {cube = texture or nil}}
end

return pr_components
