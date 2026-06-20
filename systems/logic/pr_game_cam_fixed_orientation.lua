-- local ecs = require'../core/pr_ecs'
local pr_camera = require'pr_camera'

local DEAD_ZONE   = 0.12
local MAX_YAW     = math.pi / 4   -- ±45° horizontal
local MAX_PITCH   = math.pi / 7.2 -- ±25° vertical
local BASE_PITCH  = -math.pi / 10  -- fixed 18° downward tilt

local function dead_zone(val)
  if math.abs(val) < DEAD_ZONE then return 0 end
  local sign = val > 0 and 1 or -1
  return sign * (math.abs(val) - DEAD_ZONE) / (1 - DEAD_ZONE)
end

-- Camera follows entity from a distance with fixed orientation (forward)
-- Right stick adds a limited yaw/pitch offset so the player can look around.

return {
  phase = "logic",
  requires = {"camera", "transform"},
  update_fn = function(ecs, id, c, dt)
    local entity = ecs.entities[id]
    local entity_transform = mat4(entity.transform.transform)
    local game_cam_pos_offset = vec3(entity.camera.cam_transform_offset:getPosition())

    local target_cam_pos = vec3(entity_transform:getPosition()) + game_cam_pos_offset
    local new_pos = target_cam_pos

    local entity_pos = vec3(entity_transform:getPosition())
    local added_y_rotation = entity_pos.x * math.pi / 180
    new_pos.x = entity_pos.x / 1.5

    local stick_x = dead_zone(pr_control.axes[3] or 0)
    local stick_y = dead_zone(pr_control.axes[4] or 0)

    local yaw_offset   = -stick_x * MAX_YAW
    local pitch_offset = -stick_y * MAX_PITCH

    local cam_rotation = quat(math.pi + added_y_rotation + yaw_offset, 0, 1, 0)
                       * quat(BASE_PITCH + pitch_offset, 1, 0, 0)
    pr_camera.game_cam:set(new_pos, lovr.math.vec3(1,1,1), cam_rotation)
  end
}