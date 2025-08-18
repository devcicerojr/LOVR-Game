local ecs = require'../core/pr_ecs'

return {
  phase = "logic",
  requires = {"is_collectable", "transform"},
  update_fn = function(id, c, dt) -- update function
    local entity_transform = ecs.entities[id].transform.transform
    local position = entity_transform:getPosition()
    entity_transform:rotate(quat(3.2 * dt, 0, 1, 0))
    -- Logic for collectable behavior can be added here
    -- For example, checking if the collectable is picked up by the player
    -- and then removing it from the ECS or changing its state.
    
  end
}