-- local ecs = require'../core/pr_ecs'

return {
  phase = "logic",
  requires = {"gravity", "transform", "is_kinematic" },
  update_fn = function(ecs, id, c, dt) -- update function

    local grounded = ecs.entities[id].gravity.grounded

    if grounded then
      return
    end

    local entity_gravity = ecs.entities[id].gravity.gravity_acc
    local entity_transform = ecs.entities[id].transform.transform
  
    local applied_velocity = vec3(0, entity_gravity * dt, 0)
    local gravity_transform = mat4():translate(applied_velocity)
    entity_transform:mul(gravity_transform)

  end
}