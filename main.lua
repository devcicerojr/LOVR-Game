default_shader = require'shaders/default_shader'
local pr_control = require'pr_control'
local pr_camera = require'pr_camera'
local game_scene = require'scenes/game_scene'
local terrainMesh = {}

is_dev_build = false


-- local target_fps = 58
-- local target_delta = 1 / target_fps
-- local accumulator = 0


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
  -- accumulator = accumulator + dt
  -- while accumulator >= target_delta do
    pr_control.update(dt)
    game_scene.update(dt)
    -- accumulator = accumulator - target_delta
  -- end
  -- local frame_time = lovr.timer.getTime()
  -- local sleep_time = target_delta - (lovr.timer.getTime() - frame_time)
  -- if sleep_time > 0 then
    -- lovr.timer.sleep(sleep_time)
  -- end

 
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

end