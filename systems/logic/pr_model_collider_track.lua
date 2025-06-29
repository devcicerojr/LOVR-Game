local ecs = require'../core/pr_ecs'

local function composeTransform(position, rotation, scale)
  scale = scale or lovr.math.newVec3(1,1,1)
  local mat = lovr.math.newMat4()
  mat:translate(position)
  mat:rotate(rotation)
  mat:scale(scale)
  return mat
end


local function applyTransform(entity_transform , transform)
  -- Compose current transform into a matrix
  print("Current pos z: " .. entity_transform.position.z)
  local current = lovr.math.newMat4()
  current:translate(entity_transform.position)
  current:rotate(entity_transform.rotation)
  current:scale(entity_transform.scale)

  -- Apply the new transform on top
  current:mul(transform)

  -- Decompose back into position, rotation, and scale
  entity_transform.position = lovr.math.newVec3(current:getPosition())
  entity_transform.rotation = lovr.math.newQuat(current:getOrientation())
  entity_transform.scale = lovr.math.newVec3(current:getScale())
  print("Post pos z: "  .. entity_transform.position.z)

end

return {
  phase = "logic",
  requires = {"model", "transform", "collider"},
  update_fn = function(id, c, dt) -- update function
    local entity = ecs.entities[id]
    
    local cx, cy, cz = entity.collider.collider:getPosition()
    local collider_quat = lovr.math.quat(entity.collider.collider:getOrientation())

    local collider_rotation_offset = lovr.math.quat(entity.collider.transform_offset:getOrientation())
    local collider_pos_offset = lovr.math.vec3(entity.collider.transform_offset:getPosition())

    local model_quat = collider_quat * (lovr.math.quat(collider_rotation_offset:unpack())):conjugate()
    local model_pos = lovr.math.vec3(collider_pos_offset:unpack()):rotate(model_quat):add(cx, cy, cz)
    entity.transform.transform = lovr.math.newMat4(model_pos, model_quat)

  end
}