local pr_components = {}
require'../core/pr_utils'

-- Components

pr_components.AABBSensor = function (sensor_offset, label, width, height, depth)
  return {type = "aabb_sensor", data = {sensor_offset = sensor_offset or lovr.math.newVec3(0, 0, 0),
    label = label or "none",
    width = width or 1,
    height = height or 1,
    depth = depth or 1,
    is_active = false}}
end

pr_components.AnimationState = function (current)
  return {type = "animation_state" , data = {current = current or 1}}
end

pr_components.AccDecMovement = function (current_speed)
  return {type = "acc_dec_movement" , data = {current_speed = current_speed or 0}}
end

pr_components.Brush = function (texture)
  return {type = "brush", data = {texture = texture or nil, setTexture = function(self, tex) 
    tex = tex or nil 
    self.texture = tex
  end}}
end

pr_components.Collider = function (collider , shape , transform_offset)
  return {type = "collider" , data = {collider = collider or nil,
  shape = shape or "box", transform_offset = transform_offset or lovr.math.newMat4()}}
end

pr_components.ClassicTankMovement = function()
  return {type = "classic_tank_movement", data = {}}
end

pr_components.Gamecam = function (game_cam_offset, cam_vel, ang_vel, is_active)
  return {type = "game_cam" , data = {game_cam_offset = game_cam_offset or lovr.math.newMat4(),
  cam_vel = cam_vel or lovr.math.newVec3(), ang_vel = ang_vel or lovr.math.newVec3(), is_active = is_active or true}}
end

pr_components.Gravity = function (gravity_acc, grounded)
  return {type = "gravity" , data = {gravity_acc = gravity_acc or -9.81, grounded = grounded or false}}
end

pr_components.Grid = function (grid)
  return {type = "grid", data = {grid = grid or {tiles = {},
    width = 1,
    height = 1,
    tileSize = 20}}}
end

pr_components.HasGroundSensor = function ()
  return {type = "has_ground_sensor", data = {}}
end

pr_components.IsKinematic = function ()
  return {type = "is_kinematic", data = {}}
end

pr_components.IsTerrain = function ()
  return {type = "is_terrain", data = {}}
end

pr_components.IsPlayer = function ()
  return {type = "is_player", data = {}}
end

pr_components.Model = function ( model )
  return {type = "model" , data = {model = model or nil}}
end

pr_components.Mesh = function (mesh , base_color)
  return {type = "mesh" , data = {mesh = mesh or nil, base_color = base_color or lovr.math.newVec4(1,1,1,1)}}
end

pr_components.NoMesh = function ()
  return {type = "no_mesh", data = {}}
end

pr_components.PlayerControls = function ()
  return {type = "player_controls" , data = {}}
end

pr_components.RayColliderSensor = function (origin_offset, endpoint_offset, label)
  local sensor_data = {origin_offset = origin_offset or lovr.math.newVec3(0, 0, 0),
    endpoint_offset = endpoint_offset or lovr.math.newVec3(0, -1, 0),
    no_detection_period = 0,
    label = label or "none",
    is_active = false,
    callback_ctx_data = {id = nil, cb_function = nil}}
  sensor_data.callback_ctx_data.sensor_ref = sensor_data
  return {type = "ray_collider_sensor", data = sensor_data}
end

pr_components.Position = function (x, y, z)
  return {type = "position" , data = { x = x or 0 , y = y or 0 , z = z or 0 }}
end

pr_components.SensorsArray = function ()
  return {type = "sensors_array", data = {sensors = {}}}
end

pr_components.Scallable = function (x, y, z)
  return {type = "scallable", data = {x = x or 0, y = y or 0, z = z or 0}}
end

pr_components.SkyboxTexture = function (texture)
  return {type = "skybox_texture", data = {cube = texture or nil}}
end

pr_components.StaticProp = function()
  return {type = "static_prop", data = {}}
end

pr_components.TexturedMesh = function (mesh , texture, base_color)  -- Format includes UV
  return {type = "textured_mesh" , data = {mesh = mesh or nil, texture = texture or nil, base_color = base_color or lovr.math.newVec4(1.0,1.0,1.0,1.0)}}
end

pr_components.Transform = function (transform)
  return {type = "transform", data = {transform = transform or lovr.math.newMat4()}}
end

pr_components.TracksCollider = function()
  return {type = "tracks_collider", data = {}}
end


pr_components.TerrainCollider = function (terran_collider)
  return {type = "terrain_collider", data = {collider = terrain_collider or nil}}
end

pr_components.Velocity = function (velocity)
  return {type = "velocity" , data = {velocity = velocity or lovr.math.newVec3(1, 1, 1)}}
end  


return pr_components
