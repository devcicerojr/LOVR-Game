function lovr.load()
  model = lovr.graphics.newModel('assets/models/car_one.glb')
end

function lovr.draw(pass)
  pass:setShader('unlit')
  pass:setSampler('nearest')
  pass:draw(model, 0, -1, -6, 1, lovr.timer.getTime())
end
