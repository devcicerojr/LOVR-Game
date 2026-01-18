local pr_component = require'../components/pr_components'

return function(ecs)
  local id = ecs:newEntity()
  local x_distance = 41 -- distance between walls in X axis
  local z_length = 20 -- how many lines of entities on z axis
  local width = 2 -- 1 to the left, 1 to the right
  local height = 20 -- 10 lines forward, 10 lines backwards

  for x = 1, width do
    
    for z = 1, height do
      local spawn_pos = lovr.math.newVec3()
      spawn_pos.x = ( x_distance/(3 - x) - (x_distance/(x) ) )
      spawn_pos.y = 10
      spawn_pos.z = (z - 1) * z_length + (z_length / 2) - height/2 * (z_length)
      local side_wall_id = (require'../entities/brushes/pr_wall')(ecs , spawn_pos, 1, 20, 20)
      spawn_pos.y = 0
      local scenario_y_rotation =  -((2 * math.pi) - x * (math.pi) - (math.pi / 2))
      local scenario_transform = lovr.math.newMat4():rotate(scenario_y_rotation, 0, 1, 0):translate(spawn_pos)
      local side_scenario_right_id = (require'../entities/dont_stop_delivery/pr_side_scenario_prop')(ecs, scenario_transform)
    end
  end



  return id
end