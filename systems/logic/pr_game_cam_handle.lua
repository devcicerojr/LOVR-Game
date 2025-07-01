local pr_ecs = require'../core/pr_ecs'
local pr_camera = require'pr_camera'

return {
  phase = "logic",
  requires = {"game_cam", "transform"},
  update_fn = function(id, c, dt) --update function
    local entity = pr_ecs.entities[id]
    local entity_transform = entity.transform.transform
    local game_cam_pose = entity.game_cam.game_cam_pose
    pr_camera.game_cam:set(game_cam_pose:getPosition(), 1, 1, 1, game_cam_pose:getOrientation())

  end
}