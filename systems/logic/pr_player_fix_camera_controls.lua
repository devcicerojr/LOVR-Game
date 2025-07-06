local ecs = require'../core/pr_ecs'
local pr_utils = require'../core/pr_utils'

return {
  phase = "logic", 
  requires = {"player_controls", "collider", "velocity", "transform", "adjacent_tank_movement"},
  update_fn = function(id, c, dt) --update function
    -- TODO: 
  end
}