local pr_component = require'../components/pr_components'

return function(ecs)
  local id = ecs:newEntity()

  ecs:addComponent(id , pr_component.SkyboxTexture(lovr.graphics.newTexture({
  -- left = 'assets/skybox/desert_skybox_right.png' ,
  -- right = 'assets/skybox/desert_skybox_left.png' ,
  -- top = 'assets/skybox/desert_skybox_top.png' ,
  -- bottom = 'assets/skybox/desert_skybox_down.png' ,
  -- front = 'assets/skybox/desert_skybox_front.png' ,
  -- back = 'assets/skybox/desert_skybox_back.png'
  left = 'assets/test_bg_left.png' ,
  right = 'assets/test_bg_right.png' ,
  top = 'assets/test_bg_top.png' ,
  bottom = 'assets/test_bg_bottom.png' ,
  front = 'assets/test_bg_front.png' ,
  back = 'assets/test_bg_back.png'
  })))


  return id
end