local shader = require'shaders/default_shader'
local pr_control = require'pr_control'
local pr_camera = require'pr_camera'
local game_scene = require'scenes.game_scene'
local terrainMesh

is_dev_build = false

function lovr.keypressed(key, scancode, rpt)
  pr_control.keypressed(key, scancode, rpt)
end

function lovr.wheelmoved(dx, dy)
  pr_control.wheelmoved(dx, dy)
end

function lovr.keyreleased(key, scancode)
  pr_control.keyreleased(key, scancode)
end

function lovr.load(arg)

  if arg[1] == 'DEVBUILD' then
    is_dev_build = true
    print("running in DEVBUILD mode")
  end

  game_scene.load()

  pr_camera.init()
end

function lovr.update(dt)
  pr_control.update(dt)
  game_scene.update(dt)
  pr_camera.updateCamPose(dt)
end

function lovr.draw(pass)

  if not pr_camera.spectate then
	  pass:setViewPose(1, pr_camera.game_cam.x , pr_camera.game_cam.y , pr_camera.game_cam.z, 
	  pr_camera.game_cam.angle, pr_camera.game_cam.ax, pr_camera.game_cam.ay, pr_camera.game_cam.az)
  end
  
  game_scene.draw(pass)
  local lightPos = vec3(10, 40.0, -20.0)
  local width = lovr.system.getWindowWidth()
  local height = lovr.system.getWindowHeight()
  pass:setShader(shader)
  pass:send('ambience', {0.4, 0.4, 0.4, 1.0})
  pass:send('lightColor', {1.0, 1.0, 1.0, 1.0})
  pass:send('lightPos', lightPos)
  pass:send('specularStrength', 60)
  pass:send('metallic', 200.0)
  pass:send('pixelSize' , 0.000001)
  pass:send('lovrResolution', { width, height })
  pass:send('numDivs' , 64)


  -- Set shader values

  pass:setBlendMode('alpha', 'alphamultiply')
  pass:setSampler('nearest')
  -- pass:setWireframe(true)
  pass:draw(model, 0, 0, -3, 1, 3.15)
  -- pass:setWireframe(false)
  model:animate('walking', lovr.timer.getTime() % model:getAnimationDuration('walking'))
 
  pass:setColor(1 , 1 , 1)
	pass:setShader() -- Reset to default/unlit
  pass:sphere(lightPos, -1, -3, 0.1) -- Represents light
end