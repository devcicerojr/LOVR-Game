local current_angle = 0
local TURN_SPEED    = 6      -- radians per second
local THRESHOLD     = 0.01   -- below this angle (radians) the override is skipped,
                              -- letting the model's bind pose show naturally

pr_event_bus:on('game_scene_unloaded', function()
  current_angle = 0
end)

return {
  phase = "logic",
  requires = {"is_player", "model", "acc_dec_movement"},
  update_fn = function(ecs, id, c, dt)
    local entity = ecs.entities[id]
    local model  = entity.model.model
    local speed  = entity.acc_dec_movement.current_speed

    local sx, sz = speed.x, speed.z
    local target_angle = 0

    -- Only compute a non-zero target when there is meaningful horizontal velocity.
    -- Moving straight in +Z gives angle = 0 (forward = no rotation needed).
    if sx * sx + sz * sz > 0.01 then
      local dir    = lovr.math.newVec3(sx, 0, sz)
      local fwd    = lovr.math.newVec3(0, 0, 1)
      target_angle = dir:angle(fwd)
      if sx < 0 then target_angle = -target_angle end
    end

    -- Shortest-path smoothing with wrap-around.
    local diff = target_angle - current_angle
    if diff >  math.pi then diff = diff - 2 * math.pi end
    if diff < -math.pi then diff = diff + 2 * math.pi end

    local step = TURN_SPEED * dt
    if math.abs(diff) <= step then
      current_angle = target_angle
    else
      current_angle = current_angle + (diff > 0 and step or -step)
    end

    -- Skip the override when the angle is negligible so the model's natural
    -- bind-pose orientation is preserved (fixes the "angle at startup" issue
    -- and ensures straight movement leaves the torso untouched).
    if math.abs(current_angle) > THRESHOLD then
      model:setNodeOrientation('torso', lovr.math.quat(current_angle, 0, 1, 0), 1)
    end
  end
}
