local pr_camera  = require'pr_camera'
local lovr_world = require'../core/pr_world'

local GROUND_Y           = 0.0
local MAX_HEIGHT         = 12
local MAX_CAMERA_DIST_SQ = 40 * 40
local BASE_ALPHA         = 0.95

return {
  phase = "render",
  requires = {"transform", "collider", "model"},
  update_fn = function(ecs, id, c, pass)
    local entity     = ecs.entities[id]
    if entity.collider.collider:isDestroyed() then return end
    local entity_pos = vector.pack(entity.transform.transform:getPosition())

    local cam_pos = vec3(pr_camera.game_cam:getPosition())
    local dx = entity_pos.x - cam_pos.x
    local dy = entity_pos.y - cam_pos.y
    local dz = entity_pos.z - cam_pos.z
    if dx*dx + dy*dy + dz*dz > MAX_CAMERA_DIST_SQ then return end

    local height = entity_pos.y - GROUND_Y
    if height >= MAX_HEIGHT then return end

    -- Raycast downward to find actual surface below the entity
    local ray_origin   = vec3(entity_pos.x, entity_pos.y + 0.5, entity_pos.z)
    local ray_endpoint = vec3(entity_pos.x, entity_pos.y - MAX_HEIGHT, entity_pos.z)
    local hit_col, hit_shape, hx, hy, hz, nx, ny, nz = lovr_world:raycast(ray_origin, ray_endpoint)

    local shadow_x, shadow_y, shadow_z
    local rot_angle, rot_ax, rot_ay, rot_az

    if hit_col and hit_col ~= entity.collider.collider then
      -- Offset along normal to avoid z-fighting
      shadow_x = hx + nx * 0.02
      shadow_y = hy + ny * 0.02
      shadow_z = hz + nz * 0.02
      -- Rotation from (0,1,0) to surface normal: axis = cross((0,1,0), normal)
      local axis_x  = nz
      local axis_z  = -nx
      local axis_len = math.sqrt(axis_x * axis_x + axis_z * axis_z)
      if axis_len > 0.0001 then
        rot_angle = math.acos(math.max(-1, math.min(1, ny)))
        rot_ax = axis_x / axis_len
        rot_ay = 0
        rot_az = axis_z / axis_len
      else
        -- Normal is already (0,1,0) — standard flat rotation
        rot_angle = -math.pi / 2
        rot_ax, rot_ay, rot_az = 1, 0, 0
      end
      height = entity_pos.y - hy
    else
      -- Fallback: flat shadow on terrain level
      shadow_x = entity_pos.x
      shadow_y = GROUND_Y + 0.02
      shadow_z = entity_pos.z
      rot_angle = -math.pi / 2
      rot_ax, rot_ay, rot_az = 1, 0, 0
    end

    local minx, maxx, miny, maxy, minz, maxz = entity.collider.collider:getAABB()
    local base_radius = math.min(math.max(maxx - minx, maxz - minz) / 2, 2.0)

    local t      = math.max(0, math.min(1, 1 - height / MAX_HEIGHT))
    local alpha  = BASE_ALPHA * t
    local radius = base_radius * (0.75 + 0.25 * t)

    pass:setShader()
    pass:setDepthTest('gequal')
    pass:setDepthWrite(false)
    pass:setBlendMode('alpha', 'alphamultiply')
    pass:setColor(0, 0, 0, alpha)
    pass:circle(shadow_x, shadow_y, shadow_z, radius, rot_angle, rot_ax, rot_ay, rot_az)

    pass:setDepthWrite(true)
    pass:setBlendMode('none')
    pass:setColor(1, 1, 1, 1)
    pass:setShader(environment_shader.shader)
    environment_shader.setDefaultVals(pass)
  end
}
