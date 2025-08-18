local lovr_world = require'../core/pr_world'
local pr_component = require'../components/pr_components'
local texture = nil

return function(ecs, spawn_pos, width, height, depth, texture_path)
  local id = ecs:newEntity()
  local width = width or 10.0
  local height = height or 5.0
  local depth = depth or 2
  local spawn_pos = spawn_pos or lovr.math.newVec3(0, height / 2, 0)
  local collider = lovr_world:newBoxCollider(spawn_pos, width, height, depth)
  if texture_path then
    if texture == nil then
      texture = lovr.graphics.newTexture(texture_path)
    end
    local material = lovr.graphics.newMaterial({texture = texture,
      uvScale = {1, width / height},})
    ecs:addMaterial("wall_material", material)  
  end
  collider:setKinematic(true)
  collider:setTag('wall')
  ecs:addComponent(id, pr_component.Collider(collider, "box", spawn_pos))
  ecs:addComponent(id, pr_component.Brush(texture))
  ecs:addComponent(id, pr_component.RawBrush())
  ecs:addComponent(id, pr_component.DynamicSpawner())
  return id
end