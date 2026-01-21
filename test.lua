local time = 0

local firefly = {
  basePosition = lovr.math.newVec3(0, 0, -2),
  position     = lovr.math.newVec3(),
  phase        = math.random() * math.pi * 2
}

function lovr.load()
  lovr.graphics.setBackgroundColor(0.02, 0.02, 0.04)
end

function lovr.update(dt)
  time = time + dt

  -- Start from the base position every frame
  firefly.position:set(firefly.basePosition)

  -- Procedural floating motion (local offset)
  firefly.position.x = firefly.position.x + math.sin(time * 0.7) * 0.05
  firefly.position.y = firefly.position.y + math.sin(time * 1.3) * 0.05
end

function lovr.draw(pass)
  -- Get camera position (desktop + VR safe)
  local cx, cy, cz = pass:getViewPose(1)
  local camPos = lovr.math.newVec3(cx, cy, cz)

  local toCam = (camPos - firefly.position):normalize()

  -- Pulse (brightness animation)
  local pulse = 0.5 + 0.5 * math.sin(time * 3 + firefly.phase)

  -- ===============================
  -- Emissive core
  -- ===============================
  pass:setBlendMode('alpha')
  pass:setColor(1.0, 0.9, 0.4, 1.0)

  pass:sphere(
    firefly.position,
    0.015 * (0.8 + pulse * 0.4)
  )

  -- ===============================
  -- Glow halo (additive billboard)
  -- ===============================
  pass:setBlendMode('add')
  pass:setColor(1.0, 0.9, 0.5, 0.35 * pulse)

  pass:circle(
    firefly.position,-- face camera
    0.15 * (0.6 + pulse)         -- size
  )

  -- Restore default blend mode
  pass:setBlendMode('alpha')
end
