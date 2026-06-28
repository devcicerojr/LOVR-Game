local function get_yaw(q)
  local qx, qy, qz, qw = q:unpack(true)
  return math.atan2(2 * (qw * qy + qx * qz),
                    1 - 2 * (qy * qy + qz * qz))
end

local root_bind_quat = nil  -- captured on first frame; reset on scene unload

pr_event_bus:on('game_scene_unloaded', function()
  root_bind_quat = nil
end)

return {
  phase = "logic",
  requires = {"is_player", "model", "transform", "gravity"},
  update_fn = function(ecs, id, c, dt)
    local entity = ecs.entities[id]
    local model  = entity.model.model

    -- Capture the root node's natural bind-pose orientation before we ever
    -- override it, so we can compose the ramp rotation on top of it.
    if not root_bind_quat then
      root_bind_quat = lovr.math.newQuat(model:getNodeOrientation('root', 'parent'))
    end

    -- Ramp tilt: compose the bind-pose orientation with an X-axis rotation
    -- matching the slope angle. Skip the override when on flat ground so the
    -- bind pose (which may include an inherent Y rotation) shows through.
    local grav = entity.gravity
    

    if pr_control.s_pressed or pr_control.gc_dpad_down then return end

    local q          = lovr.math.quat(entity.transform.transform:getOrientation())
    local player_yaw = get_yaw(q)
    local counter_left_forearm  = lovr.math.quat(player_yaw * 0.7 - math.pi/6, 0, 1, 0)
    local counter_right_forearm = lovr.math.quat(-player_yaw + math.pi/4, 0, 1, 0)
    local counter_right_arm     = lovr.math.quat(player_yaw - math.pi/6, 0, 1, 0)
    local counter_left_arm      = lovr.math.quat(player_yaw - math.pi/6, 0, 1, 0)
    local counter_torso         = lovr.math.quat(-player_yaw * 0.3 - math.pi/4, 0, 1, 0)
    local counter_pelvis        = lovr.math.quat(player_yaw * 0.2 - math.pi/7, 0, 1, 0)

    model:setNodeOrientation('left_forearm',  counter_left_forearm, 0.5)
    model:setNodeOrientation('right_forearm', counter_right_forearm, 0.5)
    model:setNodeOrientation('right_arm', counter_right_arm * lovr.math.quat(-math.pi/4, 0, 0, 1), 0.5)
    model:setNodeOrientation('left_arm', counter_left_arm * lovr.math.quat(math.pi/4, 0, 0, 1), 0.5)
    model:setNodeOrientation('torso', counter_torso, 0.7)
    model:setNodeOrientation('pelvis', counter_pelvis, 0.8)

    if root_bind_quat then
      if grav.last_ground_was_ramp and grav.last_ground_normal then
        local gn         = grav.last_ground_normal
        local ramp_angle = math.atan2(-gn.nz, gn.ny)
        model:setNodeOrientation('root', root_bind_quat * lovr.math.quat(ramp_angle, 1, 0, 0), 1)
      else
        model:setNodeOrientation('root', root_bind_quat, 0.3)
      end
    end
  end
}
