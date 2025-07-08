default_shader = require'shaders/default_shader'
local pr_control = require'pr_control'
local pr_camera = require'pr_camera'
local game_scene = require'scenes/game_scene'
local map_parser = require'tools/map_parser'
local terrainMesh = {}

is_dev_build = false
draw_wireframes = false


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
  for _, value in ipairs(arg) do
    if value == 'DEVBUILD' then
      is_dev_build = true
      draw_wireframes = true
      print("running in DEVBUILD mode")
    end
    if value == 'NO_WIREFRAMES' then
      draw_wireframes = false
      print("no wireframes mode")
    end
  end

  local brushes = map_parser.parse_map('levels/unnamed.map')
  print("Parsed brushes:", #brushes)
  if #brushes > 0 then
    print("First brush has faces:", #brushes[1])
    for i, face in ipairs(brushes[1]) do
      print("Face " .. i, face.p1[1], face.p1[2], face.p1[3], "Texture:", face.texture)
      if i >= 3 then break end -- Only print first 3 faces for brevity
    end
  end

  game_scene.load()

  pr_camera.init()
end

function lovr.update(dt)
  -- accumulator = accumulator + dt
  -- while accumulator >= target_delta do
    pr_control.update(dt)
    if pr_control.nine_pressed then
      game_scene:player_respawn()
    end
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