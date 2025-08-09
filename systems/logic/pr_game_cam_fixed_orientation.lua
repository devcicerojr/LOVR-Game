local pr_ecs = require'../core/pr_ecs'
local pr_camera = require'pr_camera'
local SPRING_STIFFNESS = 40
local SPRING_DAMPING = 10 -- You can tweak this value for more/less smoothing
local ROT_SMOOTHING = 6 -- You can tweak this value for more/less smoothing

-- Camera follows entity from a distance with fixed orientation (forward)

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
    -- entity.game_cam.game_cam_offset:setOrientation(quat(1, 0, 1, 0) -- make sure game_cam looks forward

    -- game_cam_pos_offset:rotate(entity_rot)
    local cur_cam_pos = lovr.math.vec3(pr_camera.game_cam:getPosition())
    local target_cam_pos = lovr.math.vec3(entity_transform:getPosition()):add(game_cam_pos_offset)
    -- Spring-damper for position only
    -- entity.game_cam.cam_vel = entity.game_cam.cam_vel or lovr.math.vec3(0,0,0)
    -- local to_target = target_cam_pos - cur_cam_pos
    -- local accel = to_target * SPRING_STIFFNESS - entity.game_cam.cam_vel * SPRING_DAMPING
    -- entity.game_cam.cam_vel:add(accel * dt)
    -- local new_pos = cur_cam_pos + entity.game_cam.cam_vel * dt


    -- Smooth orientation using slerp
    -- local game_cam_rot_offset = lovr.math.quat(entity.game_cam.game_cam_offset:getOrientation())
    -- game_cam_rot_offset = entity_rot:mul(game_cam_rot_offset)
    -- local target_rot = lovr.math.quat(game_cam_rot_offset)
    -- pr_camera.game_cam:setOrientation(quat(0, 0, 1, 0))
    -- local cur_rot = lovr.math.quat(pr_camera.game_cam:getOrientation())
    -- local t = 1 - math.exp(-ROT_SMOOTHING * dt)
    -- local new_rot = cur_rot:slerp(target_rot, t)
    -- pr_camera.game_cam:set(new_pos, lovr.math.vec3(1,1,1), new_rot)
    local added_y_rotation = ((target_cam_pos.x) * k_pi / 180)
    target_cam_pos.x = target_cam_pos.x / 1.5
    local cam_rotation = quat(k_pi + added_y_rotation, 0, 1, 0) * quat(- k_pi / 6, 1, 0, 0) 
    pr_camera.game_cam:set(target_cam_pos, lovr.math.vec3(1,1,1), cam_rotation)
  end
}