local pr_camera = require'pr_camera'

local GROUND_Y           = 0.0   -- terrain is always at y=0
local MAX_HEIGHT         = 12
local MAX_CAMERA_DIST_SQ = 40 * 40
local BASE_ALPHA         = 0.95

return {
  phase = "render",
  requires = {"transform", "collider", "model"},
  update_fn = function(ecs, id, c, pass)
    local entity     = ecs.entities[id]
    if entity.collider.collider:isDestroyed() then return end
    local entity_pos = vec3(entity.transform.transform:getPosition())

    -- Distance cull: skip entities too far from the camera
    local cam_pos = vec3(pr_camera.game_cam:getPosition())
    local dx = entity_pos.x - cam_pos.x
    local dy = entity_pos.y - cam_pos.y
    local dz = entity_pos.z - cam_pos.z
    if dx*dx + dy*dy + dz*dz > MAX_CAMERA_DIST_SQ then return end

    local height = entity_pos.y - GROUND_Y
    if height >= MAX_HEIGHT then return end

    local shadow_y = GROUND_Y + 0.02  -- just above terrain to avoid z-fighting

    -- Derive footprint radius from AABB footprint, capped for cars
    local minx, maxx, miny, maxy, minz, maxz = entity.collider.collider:getAABB()
    local base_radius = math.min(math.max(maxx - minx, maxz - minz) / 2, 2.0)

    -- Fade alpha and shrink radius as the entity rises above ground
    local t      = math.max(0, math.min(1, 1 - height / MAX_HEIGHT))
    local alpha  = BASE_ALPHA * t
    local radius = base_radius * (0.75 + 0.25 * t)

    -- Draw an unlit, alpha-blended circle flat on the ground.
    -- Rotate -pi/2 around X so the circle (default XY plane) lies flat on XZ.
    -- LÖVR uses reversed-Z (near=1, far=0), so 'gequal' is the standard depth test:
    -- it passes on the ground (same depth region) and fails where the model sits
    -- closer to the camera (larger depth value).
    pass:setShader()
    pass:setDepthTest('gequal')
    pass:setDepthWrite(false)
    pass:setBlendMode('alpha', 'alphamultiply')
    pass:setColor(0, 0, 0, alpha)
    pass:circle(entity_pos.x, shadow_y, entity_pos.z, radius, -math.pi / 2, 1, 0, 0)

    -- Restore pass state for subsequent systems
    pass:setDepthWrite(true)
    pass:setBlendMode('none')
    pass:setColor(1, 1, 1, 1)
    pass:setShader(environment_shader.shader)
    environment_shader.setDefaultVals(pass)
  end
}
