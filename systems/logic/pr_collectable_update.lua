local ecs = require'../core/pr_ecs'

return {
  phase = "logic",
  requires = {"is_collectable", "transform", "state_machine"},
  update_fn = function(id, c, dt) -- update function
    local entity_transform = ecs.entities[id].transform.transform
    local position = entity_transform:getPosition()
    entity_transform:rotate(quat(3.2 * dt, 0, 1, 0))
  end
}