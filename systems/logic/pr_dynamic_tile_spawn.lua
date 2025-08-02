local pr_ecs = require'../core/pr_ecs'pr_ecs

return {
  phase = "logic",
  requires = {"dynamic_tiles_spawner"},
  update_fn = function(id, c, dt) --update function
    local entity = pr_ecs.entities[id]
    local spawner = entity.spawner
  end
}