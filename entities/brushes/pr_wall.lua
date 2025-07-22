local lovr_world = require'../core/pr_world'
local pr_component = require'../components/pr_components'

return function(ecs, spawn_pos, width, height, depth, texture_path)
  local id = ecs:newEntity()
  local spawn_pos = spawn_pos or lovr.math.newVec3(0, 0, 0)
  local width = width or 10.0
  local height = height or 10.0
  local depth = depth or 5
  local collider = lovr_world:newBoxCollider(spawn_pos, width, height, depth)
  local texture_path = texture_path or "assets/neutral.png"
  local texture = lovr.graphics.newTexture(texture_path)
  local material = lovr.graphics.newMaterial({texture = texture,
    uvScale = {1, width / height},})
  ecs:addMaterial("wall_material", material)
  collider:setKinematic(true)
  collider:setTag('wall')
  ecs:addComponent(id, pr_component.Collider(collider, "box", spawn_pos))
  ecs:addComponent(id, pr_component.Brush(texture))
  return id
end