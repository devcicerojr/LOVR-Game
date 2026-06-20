-- local ecs = require'../core/pr_ecs'

return {
  phase = "logic",
  requires = {"gravity", "transform", "is_kinematic" },
  update_fn = function(ecs, id, c, dt) -- update function

    local gravity = ecs.entities[id].gravity

    if gravity.jump_cooldown > 0 then
      gravity.jump_cooldown = gravity.jump_cooldown - dt
    end

    if gravity.grounded then
      return
    end

    gravity.vertical_velocity = gravity.vertical_velocity + gravity.gravity_acc * dt
    local entity_transform = ecs.entities[id].transform.transform
    local applied_velocity = vec3(0, gravity.vertical_velocity * dt, 0)
    local gravity_transform = mat4():translate(applied_velocity)
    ecs.entities[id].transform.transform = entity_transform * gravity_transform

  end
}