local IDLE_SPEED          = 3.0
local ALERT_SPEED         = 40.0   -- fallback speed when player is impaired
local FOLLOW_GAIN         = 3.0    -- proportional gain for distance controller
local MAX_FOLLOW_SPEED    = 80.0   -- clamp so enemy can't overshoot wildly
local X_SPEED             = 4.0
local ALERT_TRIGGER_DIST  = 25.0
local ALERT_RELEASE_DIST  = 300.0
local X_MIN, X_MAX        = -18.0, 18.0

pr_event_bus:on('enemy_1_went_out_of_range', function(ecs, id)
  local collider = ecs.entities[id].collider.collider
  if not collider:isDestroyed() then collider:destroy() end
  table.insert(ecs.ids_for_deletion, id)
end)

return {
  phase    = "logic",
  requires = { "is_enemy_1", "transform", "collider", "state_machine" },
  update_fn = function(ecs, id, c, dt)
    local entity           = ecs.entities[id]
    local entity_transform = entity.transform.transform
    local collider         = entity.collider.collider
    local sm               = entity.state_machine.state_machine

    -- Dead state: mark for deletion once and stop all further processing.
    if sm.current == "dead" then return end
    if entity.health and entity.health.current <= 0 then
      sm.current = "dead"
      if not collider:isDestroyed() then collider:destroy() end
      table.insert(ecs.ids_for_deletion, id)
      pr_event_bus:emit('enemy_1_defeated')
      return
    end

    local player = ecs:getEntityByTag('is_player')
    if not player then return end

    local ex = select(1, entity_transform:getPosition())
    local ez = select(3, entity_transform:getPosition())
    local pz = select(3, ecs.entities[player].transform.transform:getPosition())

    -- State transitions
    local dist_z = ez - pz  -- positive when enemy is ahead of player
    if sm.current == "idle" then
      if dist_z >= 0 and dist_z < ALERT_TRIGGER_DIST then
        sm.current = "alert"
        sm.x_time  = 0
        sm.x_change_threshold = 1.0 + math.random() * 2.0
      end
    elseif sm.current == "alert" then
      if dist_z >= ALERT_RELEASE_DIST or dist_z < 0 then
        sm.current = "idle"
      end
    end

    -- X movement (alert only)
    local dx = 0
    if sm.current == "alert" then
      sm.x_time = sm.x_time + dt

      local at_boundary = (sm.x_direction > 0 and ex >= X_MAX)
                       or (sm.x_direction < 0 and ex <= X_MIN)

      if at_boundary or sm.x_time >= sm.x_change_threshold then
        sm.x_direction        = -sm.x_direction
        sm.x_time             = 0
        sm.x_change_threshold = 1.0 + math.random() * 2.0
      end

      local next_x = math.max(X_MIN, math.min(X_MAX, ex + sm.x_direction * X_SPEED * dt))
      dx = next_x - ex
    end

    -- Z movement
    local dz
    if sm.current == "alert" then
      local acc_dec       = ecs.entities[player].acc_dec_movement
      local player_impaired = acc_dec and acc_dec.car_hit or false

      if player_impaired then
        -- Player was just hit; keep moving forward at fixed speed so enemy
        -- doesn't slow down with the player and becomes easy to avoid.
        dz = ALERT_SPEED * dt
      else
        -- Proportional controller: match player's Z speed, then correct for
        -- distance error so the enemy settles at ALERT_TRIGGER_DIST ahead.
        local player_vz   = acc_dec and acc_dec.current_speed.z or ALERT_SPEED
        local error       = dist_z - ALERT_TRIGGER_DIST  -- positive = too far ahead
        local target_vz   = player_vz - FOLLOW_GAIN * error
        target_vz         = math.max(-IDLE_SPEED, math.min(MAX_FOLLOW_SPEED, target_vz))
        dz                = target_vz * dt
      end
    else
      -- Idle: enemy drifts backward (-Z) toward the oncoming player.
      dz = -IDLE_SPEED * dt
    end

    entity_transform:translate(lovr.math.newVec3(dx, 0, dz))
    ecs.entities[id].transform.transform = entity_transform

    local new_col_transform = mat4(entity_transform) * mat4(entity.collider.transform_offset)
    collider:setPose(
      vector.pack(new_col_transform:getPosition()),
      lovr.math.quat(new_col_transform:getOrientation())
    )

    -- Tick down health bar visibility timer
    if entity.health and entity.health.hit_display_timer > 0 then
      entity.health.hit_display_timer = math.max(0, entity.health.hit_display_timer - dt)
    end

    -- Destroy when 200 m behind player (player has moved 200 m past enemy in +Z)
    if pz - ez >= 200 then
      pr_event_bus:emit('enemy_1_went_out_of_range', ecs, id)
    end
  end
}
