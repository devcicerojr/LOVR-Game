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
      entity.transform.transform:set(model_pos, model_quat)
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
    
    pass:setShader(outline_shader.shader)
    outline_shader.setDefaultVals(pass)
    pass:setSampler('nearest')
    pass:setCullMode('front')
    pass:setDepthTest('greater')
    pass:setColor(0, 0, 0, 1)
    pass:send('outlineColor', {0.0, 0.0, 0.0, 1.0})
    pass:send('outlineThickness', 0.01)
    
    

    local collider_pos = vec3(entity.collider.collider:getPosition())
    local collider_quat = quat(entity.collider.collider:getOrientation())
    collider_quat = collider_quat * quat(entity.collider.transform_offset:getOrientation()):conjugate()
    collider_pos:add(vec3(entity.collider.transform_offset:getPosition()) * -1)
    

    -- pass:setDepthOffset(-1, 1)
    pass:setSampler('linear')
    pass:setAlphaToCoverage(true)
    pass:setCullMode('front')
    -- pass:setStencilWrite('replace', 1)
    -- pass:setStencilTest('lequal', 1, 255)
    pass:setBlendMode('none')
    pass:draw(entity.model.model, mat4(collider_pos, collider_quat))
    pass:setWireframe(false)

    pass:setSampler('nearest')
    pass:setShader(environment_shader.shader)
    environment_shader.send(pass, vec3(0.45, 0.45, 0.45))
    pass:setColor(0.7, 0.7, 0.7)
    pass:setBlendMode('alpha', 'alphamultiply')
    pass:setCullMode('back')
    pass:setDepthTest('gequal')
    pass:draw(entity.model.model, mat4(collider_pos, collider_quat))

    pass:setShader(environment_shader.shader)
    environment_shader.setDefaultVals(pass)
    pass:setCullMode('none')

    -- print("Cur Animation: " .. (cur_animation and cur_animation or "idle"))
    end
}