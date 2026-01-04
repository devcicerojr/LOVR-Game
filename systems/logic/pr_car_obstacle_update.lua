local pr_ecs = require'../core/pr_ecs'

local car_speed = lovr.math.newVec3(0, 0, 0)

return {
  phase = "logic",
  requires = { "is_car_obstacle", "model" , "transform"},
  update_fn = function(id, c, dt) -- update function
    local entity_transform = pr_ecs.entities[id].transform.transform

    local position = vec3(entity_transform:getPosition())
    local orientation = quat(entity_transform:getOrientation())

    local applied_speed = vec3(0, 0, car_speed.z * dt)
    local speed_transform = lovr.math.newMat4():translate(applied_speed)
    entity_transform:mul(speed_transform)
  end
}