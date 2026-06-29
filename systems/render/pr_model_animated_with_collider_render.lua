-- local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "model" , "animation_state", "transform", "tracks_collider"},
  update_fn = function(ecs, id, c, pass) -- draw function
    local entity = ecs.entities[id]
    local car_hit_time = entity.animation_state.car_hit_time
    if car_hit_time and car_hit_time > 0 then
      local dur = entity.model.model:getAnimationDuration('falling')
      entity.model.model:animate('falling', car_hit_time % dur)
    elseif entity.animation_state.current <= 0 then
      entity.model.model:animate(1, 0)
    end
    -- current > 0: body blend system owns the pose via setNodeOrientation()
    
    pass:setShader(outline_shader.shader)
    outline_shader.setDefaultVals(pass)
    pass:setSampler('nearest')
    pass:setCullMode('front')
    pass:setDepthTest('greater')
    pass:setColor(0, 0, 0, 1)
    pass:send('outlineColor', {0.0, 0.0, 0.0, 1.0})
    pass:send('outlineThickness', 0.02)
    
    

    local entity_pos = vec3(entity.transform.transform:getPosition())
    local entity_quat = quat(entity.transform.transform:getOrientation())

    -- pass:setDepthOffset(-1, 1)
    pass:setSampler('nearest')
    pass:setAlphaToCoverage(true)
    pass:setCullMode('front')
    -- pass:setStencilWrite('replace', 1)
    -- pass:setStencilTest('lequal', 1, 255)
    pass:setBlendMode('none')
    pass:draw(entity.model.model, mat4(entity_pos, entity_quat))
    pass:setWireframe(false)

    pass:setSampler('nearest')
    pass:setShader(environment_shader.shader)
    environment_shader.send(pass, vec3(0.45, 0.45, 0.45))
    pass:setColor(0.7, 0.7, 0.7)
    pass:setBlendMode('alpha', 'alphamultiply')
    pass:setCullMode('back')
    pass:setDepthTest('gequal')
    pass:draw(entity.model.model, mat4(entity_pos, entity_quat))

    pass:setShader(environment_shader.shader)
    environment_shader.setDefaultVals(pass)
    pass:setCullMode('none')

    -- print("Cur Animation: " .. (cur_animation and cur_animation or "idle"))
    end
}