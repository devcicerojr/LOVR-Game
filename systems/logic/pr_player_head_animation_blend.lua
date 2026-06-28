-- Extract yaw (Y-axis rotation) from a quaternion using raw components.
local function get_yaw(q)
  local qx, qy, qz, qw = q:unpack(true)   -- raw x, y, z, w components
  return math.atan2(2 * (qw * qy + qx * qz),
                    1 - 2 * (qy * qy + qz * qz))
end

local initial_orientation = nil
local initial_yaw = nil
return {
  phase = "logic",
  requires = {"is_player", "model", "transform"},
  update_fn = function(ecs, id, c, dt)
    local entity = ecs.entities[id]
    local model  = entity.model.model

    local q          = lovr.math.quat(entity.transform.transform:getOrientation())
    local player_yaw = get_yaw(q)

    -- Counter-rotate the head by the negative of the player's yaw so the head
    -- always faces world-forward regardless of how the player model is oriented.
    if not initial_yaw then
      initial_orientation = lovr.math.quat(model:getNodeOrientation('head'))
      initial_orientation = initial_orientation * (lovr.math.quat(math.pi , 0, 1, 0))
      initial_yaw = get_yaw(initial_orientation)
    end
    
    model:setNodeOrientation('head', lovr.math.quat(initial_yaw - player_yaw * 0.7 , 0, 1, 0), 0.4)
  end
}
