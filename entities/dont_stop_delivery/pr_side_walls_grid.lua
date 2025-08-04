local pr_component = require'../components/pr_components'

return function(ecs)
  local id = ecs:newEntity()
  local x_distance = 40
  local z_length = 20
  local width = 2 -- 1 to the left, 1 to the right
  local height = 20 -- 10 lines forward, 10 lines backwards

  for x = 1, width do
    
    for z = 1, height do
      local spawn_pos = lovr.math.newVec3()
      spawn_pos.x = ( x_distance/(3 - x) - (x_distance/(x) ) )
      spawn_pos.y = 5
      spawn_pos.z = (z - 1) * z_length + (z_length / 2) - height/2 * (z_length)
      local sie_wall_id = (require'../entities/brushes/pr_convex_hull_wall')(ecs , spawn_pos, 1, 10, 20)
    end
  end



  return id
end