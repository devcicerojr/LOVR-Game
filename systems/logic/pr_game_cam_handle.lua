local pr_ecs = require'../core/pr_ecs'
local pr_camera = require'pr_camera'

return {
  phase = "logic",
  requires = {"game_cam", "transform"},
  update_fn = function(id, c, dt) --update function
    local entity = pr_ecs.entities[id]
    local entity_transform = entity.transform.transform
    local entity_pos = lovr.math.vec3(entity_transform:getPosition())
    local entity_rot = lovr.math.quat(entity_transform:getOrientation())
    local game_cam_pos_offset = lovr.math.vec3(entity.game_cam.game_cam_offset:getPosition())
    local game_cam_rot_offset = lovr.math.quat(entity.game_cam.game_cam_offset:getOrientation())
    game_cam_pos_offset:rotate(entity_rot)
    game_cam_rot_offset = entity_rot:mul(game_cam_rot_offset)
    -- game_cam_rot_offset:mul(entity_rot)
    -- local new_game_cam_pose = lovr.math.newMat4(entity_transform:unpack())
    -- local game_cam_pos_rotated_offset = lovr.math.vec3(game_cam_offset:getPosition()):rotate(entity_transform:getOrientation())
    pr_camera.game_cam:set(lovr.math.vec3(entity_transform:getPosition()):add(game_cam_pos_offset), lovr.math.vec3(1,1,1), lovr.math.quat(game_cam_rot_offset))

  end
}