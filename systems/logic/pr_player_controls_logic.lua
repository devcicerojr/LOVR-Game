local ecs = require'../core/pr_ecs'

return {
  phase = "logic", 
  requires = {"player_controls", "collider", "velocity", "transform"},
  update_fn = function(id, c, dt) --update function
    local entity = ecs.entities[id]
    local collider = ecs.entities[id].collider.collider
    local velocity = ecs.entities[id].velocity.velocity
    local movement = lovr.math.vec3(velocity:unpack()):normalize()
    movement.y = 0;
    local direction = lovr.math.vec3(0, 0, -1) -- forward LOVR world
    direction:rotate(entity.transform.transform:getOrientation())
    local translate_val = direction * velocity.z * dt
    direction:mul(velocity)
    direction:rotate()
    if collider:isKinematic() then
      if lovr.system.isKeyDown("w") then
        entity.transform.transform:translate(translate_val)

      end
    end
  end
}