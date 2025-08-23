local ecs =   require'../core/pr_ecs'

return {
  phase = "logic",
  requires = {"tracks_entity", "rotation"},
  update_fn = function(id, c, dt) -- update function
    local entity_rotation = ecs.entities[id].rotation.rotation
    entity_rotation:mul(quat(20 * dt, 0, 1, 0))
    -- Logic for collectable behavior can be added here
    -- For example, checking if the collectable is picked up by the player
    -- and then removing it from the ECS or changing its state.
    
  end
}