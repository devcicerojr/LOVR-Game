local pr_ecs = require'../core/pr_ecs'
local pr_camera = require'pr_camera'

-- Camera follows entity from a distance with fixed orientation (forward)

return {
  phase = "logic",
  requires = {"game_cam", "transform"},
  update_fn = function(id, c, dt) --update function
    local entity = pr_ecs.entities[id]
    local entity_transform = mat4(entity.transform.transform)
    local game_cam_pos_offset = vec3(entity.game_cam.game_cam_offset:getPosition())
    
    local target_cam_pos = vec3(entity_transform:getPosition()):add(game_cam_pos_offset)
    local new_pos = target_cam_pos

    local entity_pos = vec3(entity_transform:getPosition())
    local added_y_rotation = ((entity_pos.x) * math.pi / 180)
    new_pos.x = entity_pos.x / 1.5
    local cam_rotation = quat(math.pi + added_y_rotation, 0, 1, 0) * quat(- math.pi / 6, 1, 0, 0) 
    pr_camera.game_cam:set(new_pos, lovr.math.vec3(1,1,1), cam_rotation)
  end
}