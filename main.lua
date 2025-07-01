default_shader = require'shaders/default_shader'
local pr_control = require'pr_control'
local pr_camera = require'pr_camera'
local game_scene = require'scenes/game_scene'
local terrainMesh = {}

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
end

function lovr.draw(pass)

  if not pr_camera.spectate then
	  pass:setViewPose(1, pr_camera.game_cam:getPose())
  else
    pr_camera.updateSpecCamPose() -- this is only needed because we want to have a track of headset pose inside pr_camera
  end
  pass:setBlendMode('alpha', 'alphamultiply')
  pass:setSampler('nearest')
 

  game_scene.draw(pass)
  
	-- pass:setShader()
end