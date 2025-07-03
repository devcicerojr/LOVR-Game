local pr_ecs = require'../core/pr_ecs'
local pr_camera = require'pr_camera'
local pos_smoothing = 100000
local rot_smoothing = 1000
return {
  phase = "logic",
  requires = {"game_cam", "transform", "collider" , "is_kinematic"},
  update_fn = function(id, c, dt) --update function
    local entity = pr_ecs.entities[id]
    local collider = pr_ecs.entities[id].collider.collider
    
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
    local cur_cam_pos = lovr.math.vec3(pr_camera.game_cam:getPosition())
    local cur_cam_orient = lovr.math.quat(pr_camera.game_cam:getOrientation())
    local target_cam_pos = lovr.math.vec3(entity_transform:getPosition()):add(game_cam_pos_offset)
    local target_cam_orient = lovr.math.quat(game_cam_rot_offset)
    local new_pos = cur_cam_pos:lerp(target_cam_pos, 1 - math.exp(-pos_smoothing * dt))
    local new_rot = cur_cam_orient:slerp(target_cam_orient, 1, - math.exp(-rot_smoothing * dt))
    pr_camera.game_cam:set(new_pos, lovr.math.vec3(1,1,1), new_rot)
    
  end
}