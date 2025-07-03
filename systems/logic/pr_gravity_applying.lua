local pr_ecs = require'../core/pr_ecs'
local pr_utils = require'../core/pr_utils'

return {
  phase = "logic",
  requires = {"gravity", "transform", "velocity", "is_kinematic" },
  update_fn = function(id, c, dt) -- update function

    local grounded = pr_ecs.entities[id].gravity.grounded

    if grounded then
      return
    end

    local entity_gravity = pr_ecs.entities[id].gravity.gravity_acc
    local entity_transform = pr_ecs.entities[id].transform.transform
    local entity_velocity = pr_ecs.entities[id].velocity.velocity
  
    entity_velocity:add(0, entity_gravity * dt, 0)
    local gravity_transform = lovr.math.newMat4():translate(0, entity_velocity.y * dt, 0)
    entity_transform:mul(gravity_transform)
    -- entity_transform:set(lovr.math.vec3(), lovr.math.vec3(), lovr.math.quat())

  end
}