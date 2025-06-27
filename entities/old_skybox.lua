local desert_skybox = {}
desert_skybox.cube = {}

function desert_skybox.init()
  desert_skybox.cube = lovr.graphics.newTexture({
  left = 'assets/skybox/desert_skybox_right.png' ,
  right = 'assets/skybox/desert_skybox_left.png' ,
  top = 'assets/skybox/desert_skybox_top.png' ,
  bottom = 'assets/skybox/desert_skybox_down.png' ,
  front = 'assets/skybox/desert_skybox_front.png' ,
  back = 'assets/skybox/desert_skybox_back.png'
  })
end

function desert_skybox.draw(pass)
  pass:setShader()
  pass:skybox(desert_skybox.cube)
  pass:setShader(default_shader.shader)

  default_shader.setDefaultVals(pass)
end

return desert_skybox