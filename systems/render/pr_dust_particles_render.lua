local pr_camera = require'pr_camera'

local SPAWN_INTERVAL = 0.08
local MAX_LIFE       = 0.3
local START_RADIUS   = 0.1
local END_RADIUS     = 0.55
local DRIFT_Y        = 0.5
local BASE_ALPHA     = 0.55
local MIN_SPEED      = 1.0

local particles  = {}
local last_spawn = 0.0

return {
  phase    = "render",
  requires = {"transform", "acc_dec_movement", "player_controls"},
  update_fn = function(ecs, id, c, pass)
    local entity = ecs.entities[id]
    local now    = game_anim_time

    for i = #particles, 1, -1 do
      if now - particles[i].born_at >= MAX_LIFE then
        table.remove(particles, i)
      end
    end

    local speed = entity.acc_dec_movement.current_speed:length()
    if speed >= MIN_SPEED and now - last_spawn >= SPAWN_INTERVAL then
      local pos = vec3(entity.transform.transform:getPosition())
      for _ = 1, 2 do
        table.insert(particles, {
          x       = pos.x + (math.random() - 0.5) * 0.4,
          y       = pos.y + 0.01,
          z       = pos.z + (math.random() - 0.5) * 0.4,
          born_at = now,
        })
      end
      last_spawn = now
    end

    if #particles == 0 then return end

    local cx, cy, cz = pr_camera.game_cam:getPosition()

    pass:setShader()
    pass:setDepthTest()
    pass:setDepthWrite(false)
    pass:setBlendMode('alpha', 'alphamultiply')

    for _, p in ipairs(particles) do
      local age    = now - p.born_at
      local t      = age / MAX_LIFE
      local alpha  = BASE_ALPHA * (1 - t)
      local radius = START_RADIUS + (END_RADIUS - START_RADIUS) * t
      local y      = p.y + DRIFT_Y * age

      -- Billboard: rotate default circle normal (0,0,1) toward camera.
      -- cross((0,0,1), to_cam) = (-to_cam.y, to_cam.x, 0)
      local dx = cx - p.x
      local dy = cy - y
      local dz = cz - p.z
      local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
      if dist > 0.0001 then dx = dx/dist; dy = dy/dist; dz = dz/dist end

      local ax, ay  = -dy, dx          -- cross product axis (z component is 0)
      local axis_len = math.sqrt(ax*ax + ay*ay)
      local angle    = math.acos(math.max(-1, math.min(1, dz)))  -- dot with (0,0,1) = dz

      pass:setColor(1, 1, 1, alpha)
      if axis_len < 0.0001 then
        pass:plane(p.x, y, p.z, radius, radius, dz > 0 and 0 or math.pi, 0, 1, 0)
      else
        pass:plane(p.x, y, p.z, radius, radius, angle, ax/axis_len, ay/axis_len, 0)
      end
    end

    pass:setDepthTest('gequal')
    pass:setDepthWrite(true)
    pass:setBlendMode('none')
    pass:setColor(1, 1, 1, 1)
    pass:setShader(environment_shader.shader)
    environment_shader.setDefaultVals(pass)
  end
}
