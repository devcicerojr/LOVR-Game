local pr_camera = require'pr_camera'
local pr_control = {}

pr_control.w_pressed = false
pr_control.a_pressed = false
pr_control.s_pressed = false
pr_control.d_pressed = false
pr_control.zero_pressed = false

pr_control.spectate = false
pr_control.spec_cam = { x = 0 , y = 0 , z = 0 , angle = 0 , ax = 0 , ay = 0 , az = 0 }


function pr_control.keypressed(key, scancode, rpt)
  -- your code here

  if key == "w" then
    pr_control.w_pressed = true
    print("w pressed")
  elseif key == "a" then
    pr_control.a_pressed = true
    print("a pressed")
  elseif key == "s" then
    pr_control.s_pressed = true
    print("s pressed")
  elseif key == "d" then
    pr_control.d_pressed = true
    print("d pressed")
  elseif key == "0" then
    pr_control.zero_pressed = true
    print("zero pressed")
  end
end

function pr_control.keyreleased(key , scancode)
  if key == "w" then
    pr_control.w_pressed = false
    print("w released")
  elseif key == "a" then
    pr_control.a_pressed = false
    print("a released")
  elseif key == "s" then
    pr_control.s_pressed = false
    print("s released")
  elseif key == "d" then
    pr_control.d_pressed = false
    print("d released")
  elseif key == "0" then
    pr_control.zero_pressed = false;
    print("zero released")
  end
end

function pr_control.update(dt)
  if pr_control.zero_pressed == true then
    pr_camera.toggleSpec()
    pr_control.zero_pressed = false
  end
end

return pr_control