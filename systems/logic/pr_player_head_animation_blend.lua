local ecs = require'../core/pr_ecs'

-- Somewhere at the top of your file:
local elapsedTime = 0

function getOscillatingValue(dt, frequency, phase)
  frequency = frequency or 1.0
  phase = phase or 0.0

  -- Update total elapsed time manually
  elapsedTime = elapsedTime + dt

  local amplitude = 0.2
  return amplitude * math.sin(2 * math.pi * frequency * elapsedTime + phase)
end



return {
  phase = "logic",
  requires = {"is_player", "model"},
  update_fn = function(id, c, dt) -- update function
    local entity = ecs.entities[id]
    local model = entity.model.model
    local transform = entity.transform.transform
    local position = transform:getPosition()
    local orientation = transform:getOrientation()
    local desired_orientation = lovr.math.quat(getOscillatingValue(dt, 0.5), 0, 1, 0):mul(lovr.math.quat(0.1, 1, 0 , 0))
    model:setNodeOrientation('head', desired_orientation , 1)
  end
}