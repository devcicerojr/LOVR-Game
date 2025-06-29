local pr_components = {}
require'../core/pr_utils'

-- Components

pr_components.Animated = function (cur_animation_idx)
  return {type = "animated" , data = {cur_animation_idx = cur_animation_idx or 1}}
end

pr_components.Collider = function (collider , shape , transform_offset)
  return {type = "collider" , data = {collider = collider or nil,
  shape = shape or "box", transform_offset = transform_offset or lovr.math.newMat4()}}
end

pr_components.Model = function ( model )
  return {type = "model" , data = {model = model or nil}}
end

pr_components.Mesh = function (mesh , base_color)
  return {type = "mesh" , data = {mesh = mesh or nil, base_color = base_color or pr_Colora(1.0,1.0,1.0,1.0)}}
end

pr_components.Position = function (x, y, z)
  return {type = "position" , data = { x = x or 0 , y = y or 0 , z = z or 0 }}
end

pr_components.Scallable = function (x, y, z)
  return {type = "scallable", data = {x = x or 0, y = y or 0, z = z or 0}}
end

-- pr_components.Transform = function (x, y, z, angle, ax, ay, az, scale)
--   return {type = "transform", data = {x = x or 0, y = y or 0, z = z or 0,
--   angle = angle or 1, ax = ax or 0, ay = ay or 0, az = az or 0,
--   scale = scale or 1.0}}
-- end

pr_components.Transform = function (transform)
  return {type = "transform", data = {transform = transform or lovr.math.newMat4()}}
end

pr_components.TracksCollider = function()
  return {type = "tracks_collider", data = {}}
end

pr_components.SkyboxTexture = function (texture)
  return {type = "skybox_texture", data = {cube = texture or nil}}
end

pr_components.TerrainCollider = function (terran_collider)
  return {type = "terrain_collider", data = {collider = terrain_collider or nil}}
end

pr_components.Velocity = function (x, y, z)
  return {type = "velocity" , data = {x = x or 0 , y = y or 0 , z = z or 0}}
end  

return pr_components
