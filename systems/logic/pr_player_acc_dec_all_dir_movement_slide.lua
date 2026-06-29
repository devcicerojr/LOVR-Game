-- local ecs = require'../core/pr_ecs'
local lovr_world = require'../core/pr_world'

-- Constants for acceleration and deceleration (tweak as needed)
local ACCELERATION = {x = 42, y = 0, z = 10}
local DECELERATION = 90
local STICK_DEAD_ZONE = 0.12
local JUMP_FORCE      = 14
local MAX_JUMP_HOLD   = 0.30   -- seconds the button can extend the jump
local JUMP_HOLD_BOOST = 38     -- extra upward acceleration (units/s²) while held

local OBSTACLE_FILTER      = 'wall'
local RAMP_SIDE_GRACE      = 0.3   -- seconds after leaving ramp before side check activates
local ramp_side_cooldown   = 0
local CAR_BRAKE_DECEL      = 20
local car_braking          = false

local function apply_dead_zone(val)
  if math.abs(val) < STICK_DEAD_ZONE then return 0 end
  local sign = val > 0 and 1 or -1
  return sign * (math.abs(val) - STICK_DEAD_ZONE) / (1 - STICK_DEAD_ZONE)
end

return {
  phase = "logic",
  requires = {"player_controls", "collider", "velocity", "transform", "acc_dec_movement", "aabb_sensor", "all_dir_controls"},
  update_fn = function(ecs, id, c, dt) --update function
    local entity = ecs.entities[id]
    local collider = ecs.entities[id].collider.collider
    local velocity = ecs.entities[id].velocity.velocity
    local aabb_sensor = ecs.entities[id].aabb_sensor
    local acc_dec = entity.acc_dec_movement
    local moving_forward = pr_control.up_pressed or pr_control.gc_dpad_up
    local moving_backward = pr_control.down_pressed or pr_control.gc_dpad_down
    local desired_dir = lovr.math.newVec3(0, 0, 0)
    local desired_rot = lovr.math.newQuat(0, 0 , 0, 1)
    local desired_speed = 0
    local forward_vec = vec3(0, 0, 1)

    print(entity.transform.transform:getPosition())
    -- Jump input
    local jump_held = lovr.system.isKeyDown("space") or pr_control.gc_btn_1
    if (pr_control.space_pressed or pr_control.gc_btn_1_just_pressed) and entity.gravity.grounded then
      local jump_vel = JUMP_FORCE
      -- On a ramp the slope pushes the player upward; add that momentum to the jump
      if entity.gravity.last_ground_was_ramp then
        local gn      = entity.gravity.last_ground_normal
        local acc_dec = entity.acc_dec_movement
        if gn and acc_dec and gn.ny > 0.01 then
          local vx       = acc_dec.current_speed.x
          local vz       = acc_dec.current_speed.z
          local launch_vy = -(gn.nx * vx + gn.nz * vz) / gn.ny
          if launch_vy > 0 then
            jump_vel = jump_vel + launch_vy * 0.5 -- using only half of launch_vy
          end
        end
      end
      entity.gravity.vertical_velocity = jump_vel
      entity.gravity.grounded = false
      entity.gravity.jump_cooldown = 0.15
      entity.gravity.is_jumping = true
      entity.gravity.jump_hold_time = 0
      pr_control.space_pressed = false
      pr_control.gc_btn_1_just_pressed = false
    end
    -- Variable height: hold button to keep boosting upward, up to MAX_JUMP_HOLD
    if entity.gravity.is_jumping and jump_held and entity.gravity.jump_hold_time < MAX_JUMP_HOLD then
      entity.gravity.jump_hold_time = entity.gravity.jump_hold_time + dt
      entity.gravity.vertical_velocity = entity.gravity.vertical_velocity + JUMP_HOLD_BOOST * dt
    end
    if not jump_held then
      entity.gravity.is_jumping = false
    end

    local minx, maxx, miny, maxy, minz, maxz = collider:getAABB()

    local col_width = maxx - minx
    local col_height = maxy - miny
    local col_depth = maxz - minz
    local player_controlling = false

    moving_forward = true
    if moving_forward then
      desired_dir = desired_dir + vec3(0, 0, 1)
      player_controlling = true
    end
    if moving_backward then
      desired_dir = desired_dir + vec3(0, 0, -1)
      player_controlling = true
    end
    if pr_control.a_pressed or pr_control.gc_dpad_left then
      desired_dir = desired_dir + vec3(1, 0, 0)
      player_controlling = true
    end
    if  pr_control.d_pressed or pr_control.gc_dpad_right then
      desired_dir = desired_dir + vec3(-1, 0, 0)
      player_controlling = true
    end
    local rotation_angle = 0
    if pr_control.s_pressed or pr_control.gc_dpad_down then
      desired_dir = vec3(0, 0, 0.1) -- stop movement if both forward and backward keys are pressed
      player_controlling = false
      -- rotation_angle = vec3(0, 0, 1):angle(vec3(0, 0, -1))
    end
    desired_dir = desired_dir + vec3(-apply_dead_zone(pr_control.axes[1] or 0), 0, 0)
    if desired_dir:length() > 0.001 then
      rotation_angle = vec3(desired_dir):angle(forward_vec)
      if desired_dir:dot(vec3(1, 0, 0)) < 0 then
        rotation_angle = -rotation_angle
      end
    end
    desired_rot = quat(rotation_angle, 0, 1, 0)

    if player_controlling then
      desired_speed = vec3(desired_dir):normalize():length() * velocity.z
      -- entity.transform.transform:set(vec3(entity.transform.transform:getPosition()), desired_rot)
    else
      desired_dir = vec3(0, 0, 0)
      desired_speed = 0
    end
    local current_speed_len = acc_dec.current_speed:length()
    local current_dir = current_speed_len > 0 and vec3(acc_dec.current_speed):normalize() or quat(entity.transform.transform:getOrientation()):direction()
    if car_braking then
      -- Decelerate Z gradually; X and Y unaffected
      acc_dec.current_speed.z = math.max(0, acc_dec.current_speed.z - CAR_BRAKE_DECEL * dt)
      if acc_dec.current_speed.z == 0 then car_braking = false end
    elseif desired_speed > 0 then
      -- Accelerate towards desired direction and speed (normalize so diagonal and
      -- cardinal inputs apply equal acceleration magnitude).
      local desired_dir_norm = vec3(desired_dir):normalize()
      local dot = acc_dec.current_speed:dot(desired_dir_norm)
      local opposing   = dot < 0
      local speed_ratio = math.min(current_speed_len / desired_speed, 1.0)
      local accel_x     = ACCELERATION.x * speed_ratio
      local accel_vec = vec3(
        desired_dir_norm.x * (opposing and (accel_x + DECELERATION) or accel_x),
        0,
        desired_dir_norm.z * (opposing and (ACCELERATION.z + DECELERATION) or ACCELERATION.z)
      ) * dt
      acc_dec.current_speed = acc_dec.current_speed + accel_vec
      -- Clamp to max speed
      if acc_dec.current_speed:length() > desired_speed then
        acc_dec.current_speed = vec3(acc_dec.current_speed):normalize() * desired_speed
      end
    else
      -- No input: decelerate to zero
      if current_speed_len > 0 then
        local decel = DECELERATION * dt
        if current_speed_len <= decel then
          acc_dec.current_speed = vec3(0, 0, 0)
        else
          acc_dec.current_speed = acc_dec.current_speed + current_dir * -decel
        end
      end
    end




    local translate_val = vec3(acc_dec.current_speed) * dt
    -- When grounded on a slope, add Y so the player follows the surface instead of sinking in
    if entity.gravity.grounded and entity.gravity.last_ground_was_ramp then
      local gn = entity.gravity.last_ground_normal
      if gn and gn.ny > 0.001 then
        translate_val.y = -(gn.nx * translate_val.x + gn.nz * translate_val.z) / gn.ny
      end
    end
    local translate_len = translate_val:length()
    local direction = translate_len > 0.0001 and vec3(translate_val):normalize() or vec3(0, 0, 1)
    local movement_angle = translate_len > 0.0001 and translate_val:angle(forward_vec) or 0
    if translate_val:dot(vec3(1, 0, 0)) < 0 then
      movement_angle = -movement_angle
    end
    local movement_rot = quat(movement_angle, 0, 1, 0)

    if collider:isKinematic() then

      local position = vec3(entity.transform.transform:getPosition())

      -- Keep cooldown alive while on ramp, count down after leaving
      if entity.gravity.grounded and entity.gravity.last_ground_was_ramp then
        ramp_side_cooldown = RAMP_SIDE_GRACE
      elseif ramp_side_cooldown > 0 then
        ramp_side_cooldown = ramp_side_cooldown - dt
      end

      -- Ramp side check: block X movement when player's capsule side touches the ramp mesh
      if translate_val.x ~= 0 and ramp_side_cooldown <= 0 then
        local x_dir = translate_val.x > 0 and 1 or -1
        -- Downward raycast: if ramp surface is below the player, they are above it — skip the check
        local tip_x = position.x + x_dir * col_width / 2
        local tip_z = position.z + col_depth / 2
        local ray_from = vec3(tip_x, position.y + 0.5, tip_z)
        local ray_to   = vec3(tip_x, position.y - 10,  tip_z)
        local ramp_below, _, _, hit_y = lovr_world:raycast(ray_from, ray_to, 'ramp')
        local above_ramp = ramp_below ~= nil and position.y > hit_y + 0.1

        if not above_ramp then
          local check_pos = vec3(
            position.x + x_dir * (col_width / 2 + 0.05),
            position.y,
            position.z
          )
          if lovr_world:queryBox(check_pos, vec3(0.15, col_height * 0.8, col_depth * 0.6), 'ramp') then
            translate_val.x = 0
            acc_dec.current_speed.x = 0
          end
        end
      end

      -- Car collision: trigger braking when player body overlaps a car collider
      if lovr_world:queryBox(position, vec3(col_width * 0.5, col_height * 0.8, col_depth * 0.5), 'car') and entity.gravity.grounded then
        car_braking = true
      end

      local aabb_rotated_offset = vec3(aabb_sensor.sensor_offset):rotate(movement_rot)
      local aabb_sensor_pos = position + translate_val + aabb_rotated_offset
      local collided_c = lovr_world:queryBox(aabb_sensor_pos , vec3(aabb_sensor.width, aabb_sensor.height, aabb_sensor.depth), OBSTACLE_FILTER)
      if collided_c ~= nil then
        aabb_sensor.is_active = true
        -- find out the normal of the collision
        local ray_endpoint = aabb_sensor_pos + direction
        local collided_middle, shape_md, cx_md, cy_md, cz_md, nx_md, ny_md, nz_md, triangle_md = lovr_world:raycast(aabb_sensor_pos , ray_endpoint, OBSTACLE_FILTER)

        local left_ray_sensor_dir = vec3(direction):rotate(math.pi / 2.5 , 0 , 1 , 0)
        local right_ray_sensor_dir = vec3(direction):rotate(-math.pi / 2.5  , 0 , 1 , 0)

        ray_endpoint = aabb_sensor_pos + left_ray_sensor_dir
        -- Check for collision on the left side
        local left_sensor_pos = vec3(aabb_sensor_pos) + vec3(col_width/2, col_height / 2,  -col_depth/2)
        local collided_left_side, shape_ls, cx_ls, cy_ls, cz_ls, nx_ls, ny_ls, nz_ls, triangle_ls = lovr_world:raycast(left_sensor_pos , ray_endpoint , OBSTACLE_FILTER)

        ray_endpoint = aabb_sensor_pos + right_ray_sensor_dir
        local right_sensor_pos = vec3(aabb_sensor_pos) + vec3(-col_width/2, col_height/2, -col_depth/2)
        local collided_right_side, shape_rs, cx_rs, cy_rs, cz_rs, nx_rs, ny_rs, nz_rs, triangle_rs = lovr_world:raycast(right_sensor_pos , ray_endpoint, OBSTACLE_FILTER)
        local norm_vec = lovr.math.vec3(0,0,0)
        if collided_middle then
          print("middle")
          norm_vec = lovr.math.vec3(nx_md, ny_md, nz_md)
        elseif collided_left_side then
          print("left")
          acc_dec.current_speed.x = 0
          norm_vec = lovr.math.vec3(nx_ls, ny_ls, nz_ls)
        elseif collided_right_side then
          print("right")
          acc_dec.current_speed.x = 0
          norm_vec = lovr.math.vec3(nx_rs, ny_rs, nz_rs)
        end

        -- Adjust direction to be perpendicular to the normal vector
        direction = direction - norm_vec * direction:dot(norm_vec)
        translate_val = direction * acc_dec.current_speed:length() * dt
        aabb_sensor_pos = position + translate_val + aabb_rotated_offset
        -- second check for collision after adjusting direction
        local collided_c2 = lovr_world:queryBox(aabb_sensor_pos, lovr.math.vec3(aabb_sensor.width, aabb_sensor.height, aabb_sensor.depth), OBSTACLE_FILTER)
        if not collided_c2 then position = position + translate_val end
      else
        aabb_sensor.is_active = false
        position = position + translate_val
      end
      -- entity.transform.transform:translate(translate_val)

      entity.transform.transform:set(position, desired_rot) -- move the entity transform (kinematic)
      -- Sync collider immediately so physics queries and model render both see the
      -- current position within the same frame (no model_collider_track lag).
      local col_mat = mat4(entity.transform.transform) * mat4(entity.collider.transform_offset)
      collider:setPose(vec3(col_mat:getPosition()), quat(col_mat:getOrientation()))
      lovr.audio.setPose(position, lovr.math.newQuat(math.pi ,0,1,0)) -- update audio listener position
    else
      -- local collider_rotation_offset = lovr.math.quat(1, 0, 0, 0)
      -- local collider_pos_offset = lovr.math.vec3(0, 0, 0)
      -- if acc_dec.current_speed:length() > 0 then
      --   direction = lovr.math.newVec3(acc_dec.current_speed)
      --   collider_rotation_offset = lovr.math.quat(entity.collider.transform_offset:getOrientation())
      --   collider_pos_offset = lovr.math.vec3(entity.collider.transform_offset:getPosition())
      --   direction:rotate(lovr.math.quat(collider:getOrientation()) * (lovr.math.quat(collider_rotation_offset:unpack())):conjugate())
      --   translate_val = direction * dt
      --   collider:setPosition(lovr.math.vec3(collider:getPosition()):add(translate_val))
      -- end
    end
  end
}