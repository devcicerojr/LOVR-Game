local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "model" , "animation_state", "transform", "tracks_collider"},
  update_fn = function(id , c , pass) -- draw function
    -- pass:setShader()
    local entity = ecs.entities[id]

    if entity.collider.collider:isKinematic() == false then
      local cx, cy, cz = entity.collider.collider:getPosition()
      local collider_quat =  lovr.math.quat(entity.transform.transform:getOrientation()) * lovr.math.quat(entity.collider.collider:getOrientation())
  
      local collider_rotation_offset = lovr.math.quat(entity.collider.transform_offset:getOrientation())
      local collider_pos_offset = lovr.math.vec3(entity.collider.transform_offset:getPosition())
  
      local model_quat = collider_quat * (lovr.math.quat(collider_rotation_offset:unpack())):conjugate()
      local model_pos = lovr.math.vec3(collider_pos_offset:unpack()):mul(-1,-1,-1):rotate(model_quat):add(cx, cy, cz)
      entity.transform.transform = lovr.math.newMat4(model_pos, model_quat)
    end
    

    pass:draw(entity.model.model, entity.transform.transform)
    local cur_animation = nil
    if entity.animation_state.current > 0 then
      cur_animation = entity.model.model:getAnimationName(entity.animation_state.current)
      if cur_animation then
        entity.model.model:animate(cur_animation, lovr.timer.getTime() % 
        entity.model.model:getAnimationDuration(cur_animation))
      end
    else
      entity.model.model:animate(1, 0)
    end
    -- print("Cur Animation: " .. (cur_animation and cur_animation or "idle"))
    end
}