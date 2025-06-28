local pr_component = require'../components/pr_components'

return function(ecs)
  local id = ecs:newEntity()

  ecs:addComponent(id , pr_component.SkyboxTexture(lovr.graphics.newTexture({
  left = 'assets/skybox/desert_skybox_right.png' ,
  right = 'assets/skybox/desert_skybox_left.png' ,
  top = 'assets/skybox/desert_skybox_top.png' ,
  bottom = 'assets/skybox/desert_skybox_down.png' ,
  front = 'assets/skybox/desert_skybox_front.png' ,
  back = 'assets/skybox/desert_skybox_back.png'
  })))


  return id
end