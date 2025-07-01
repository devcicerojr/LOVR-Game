local pr_ecs = require'../core/pr_ecs'
local pr_camera = require'pr_camera'

return {
  phase = "logic",
  requires = {"game_cam", "transform"},
  update_fn = function(id, c, dt) --update function
    local entity = pr_ecs.entities[id]
    local entity_transform = entity.transform.transform
    local game_cam_offset = entity.game_cam.game_cam_offset
    -- local new_game_cam_pose = lovr.math.newMat4(entity_transform:unpack())

    pr_camera.game_cam:set(lovr.math.vec3(entity_transform:getPosition()):add(game_cam_offset:getPosition()), lovr.math.vec3(1,1,1), lovr.math.quat(game_cam_offset:getOrientation()))

  end
}