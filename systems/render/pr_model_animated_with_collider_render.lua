local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "model" , "animation_state", "transform", "tracks_collider"},
  update_fn = function(id , c , pass) -- draw function
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
    
    local cur_animation = nil
    if entity.animation_state.current > 0 then
      cur_animation = entity.model.model:getAnimationName(entity.animation_state.current)
      if cur_animation then
        entity.model.model:animate(cur_animation, lovr.timer.getTime() * 3 % 
        entity.model.model:getAnimationDuration(cur_animation))
      end
    else
      entity.model.model:animate(1, 0)
    end
    
    -- pass:setShader(outline_shader.shader)
    -- outline_shader.setDefaultVals(pass)
    -- pass:setSampler('nearest')
    -- pass:setCullMode('front')
    -- pass:setDepthTest('gequal')
    -- pass:setDepthWrite(true)
    -- pass:setColor(0, 0, 0, 1)
    -- pass:send('outlineColor', {0.0, 0.0, 0.0, 1.0})
    -- pass:send('outlineThickness', 0.01)
    
    -- pass:setDepthOffset(-10000, 1)
    -- pass:setSampler('linear')
    -- pass:draw(entity.model.model, entity.transform.transform)
    -- pass:setWireframe(false)
    -- pass:setDepthOffset()

    
    pass:setSampler('nearest')
    pass:setShader(environment_shader.shader)
    environment_shader.send(pass, vec3(0.45, 0.45, 0.45))
    pass:setColor(0.7, 0.7, 0.7)
    pass:setBlendMode('alpha', 'alphamultiply')
    pass:setCullMode('back')
    pass:setDepthTest('gequal')
    pass:setDepthWrite(true)
    pass:draw(entity.model.model, entity.transform.transform)

    pass:setShader()
    pass:setCullMode('none')

    -- print("Cur Animation: " .. (cur_animation and cur_animation or "idle"))
    end
}