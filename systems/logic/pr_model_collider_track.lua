local ecs = require'../core/pr_ecs'

return {
  phase = "logic",
  requires = {"model", "transform", "collider"},
  update_fn = function(id, c, dt) -- update function
    local entity = ecs.entities[id]
    local cx, cy, cz = entity.collider.collider:getPosition()
    local collider_quat = lovr.math.quat(entity.collider.collider:getOrientation())
    local model_quat = collider_quat * (lovr.math.quat(entity.collider.quat_rot_offset:unpack())):conjugate()
    local rotated_pos_offset = lovr.math.vec3(entity.collider.offset:unpack()):rotate(model_quat)
    local angle, ax, ay, az = model_quat:unpack()
    entity.transform = {x = cx + rotated_pos_offset.x, y = cy + rotated_pos_offset.y,
    z = cz + rotated_pos_offset.z, angle = angle, ax = ax, ay = ay, az = az,  scale = entity.transform.scale}
  end
}