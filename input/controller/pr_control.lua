local pr_camera = require'pr_camera'
local gc = require "../../external/libraries/game_controller/game_controller"
local num_devices = gc.getDeviceCount()
local ffi = require( "ffi" )


pr_control = {}

pr_control.w_pressed = false
pr_control.a_pressed = false
pr_control.s_pressed = false
pr_control.d_pressed = false
pr_control.zero_pressed = false
pr_control.nine_pressed = false
pr_control.space_pressed = false
pr_control.enter_pressed = false


pr_control.gc_dpad_up    = false
pr_control.gc_dpad_right = false
pr_control.gc_dpad_down  = false
pr_control.gc_dpad_left  = false
pr_control.gc_btn_1              = false  -- A / Cross
pr_control.gc_btn_1_just_pressed = false
pr_control.gc_btn_8              = false  -- Start / Menu
pr_control.gc_btn_8_just_pressed = false


pr_control.spectate = false
pr_control.axes = {  0.0, 0.0, 0.0, 0.0, 0.0, 0.0 }


function pr_control.isKeyDown(key)
  return lovr.system.isKeyDown(key)
end

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
  elseif key == "8" then
    pr_control.eight_pressed = true
    print("eight pressed")
  elseif key == "9" then
    pr_control.nine_pressed = true
    print("nine pressed")
  elseif key == "11" then
    pr_control.gc_dpad_up = true
    print("dpad-UP pressed")
  elseif key == "12" then
    pr_control.gc_dpad_right = true
    print("dpad-RIGHT pressed")
  elseif key == "13" then
    pr_control.gc_dpad_down = true
    print("dpad-DOWN pressed")
  elseif key == "14" then
    pr_control.gc_dpad_left = true
    print("dpad-LEFT pressed")
  elseif key == "space" then
    pr_control.space_pressed = true
    print("space pressed")
  elseif key == "return" then
    pr_control.enter_pressed = true
    print("enter pressed")
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
  elseif key == "8" then
    pr_control.eight_pressed = false;
    print("eight released")
  elseif key == "9" then
    pr_control.nine_pressed = false;
    print("nine released")
  elseif key == "11" then
    pr_control.gc_dpad_up = false;
    print("dpad-UP released")
  elseif key == "12" then
    pr_control.gc_dpad_right = false;
    print("dpad-RIGHT released")
  elseif key == "13" then
    pr_control.gc_dpad_down = false;
    print("dpad-DOWN released")
  elseif key == "14" then
    pr_control.gc_dpad_left = false;
    print("dpad-LEFT released")
  elseif key == "space" then
    pr_control.space_pressed = false
    print("space released")
  elseif key == "return" then
    pr_control.enter_pressed = false
    print("enter released")
  end
end

function pr_control.wheelmoved(dx , dy)
  if dy > 0 then
    pr_camera.zoomIn()
  elseif dy < 0 then
    pr_camera.zoomOut()
  end
end

function pr_control.load()
  print("pr_control loaded")
  
  print( "Number of devices: " .. num_devices )
	for i = 1, num_devices do
		local name = "-N/A-"
		if gc.isDeviceGamepad( i ) then
			name = gc.getGamepadName( i )
		end
		print( "Index: " .. i .. ", GUID: " .. gc.getDeviceGUID( i ) .. ", Name: " .. gc.getDeviceName( i ) .. ", Gamepad name: " .. name )
	end
end


function pr_control.update(dt)
  if is_dev_build and pr_control.zero_pressed == true then
    pr_camera.toggleSpec()
    pr_control.zero_pressed = false
  end
  if is_dev_build and pr_control.eight_pressed == true then
    draw_wireframes = not draw_wireframes
    pr_control.eight_pressed = false
  end


  local ok, err = pcall(function()
    local result, event_type, device = gc.configurationChanged()
    if result then
      print( "Device: " .. tostring(device) .. " was " .. tostring(event_type) )
    end

    if gc.isDevicePresent( 1 ) then
      local btn_count = gc.getButtonCount( 1 )
      pr_control.gc_dpad_up    = gc.getButtonState( 1, 11 ) == 1
      pr_control.gc_dpad_right = gc.getButtonState( 1, 12 ) == 1
      pr_control.gc_dpad_down  = gc.getButtonState( 1, 13 ) == 1
      pr_control.gc_dpad_left  = gc.getButtonState( 1, 14 ) == 1
      local prev_btn_1   = pr_control.gc_btn_1
      pr_control.gc_btn_1 = gc.getButtonState( 1, 1 ) == 1
      pr_control.gc_btn_1_just_pressed = pr_control.gc_btn_1 and not prev_btn_1
      local prev_btn_8   = pr_control.gc_btn_8
      pr_control.gc_btn_8 = gc.getButtonState( 1, 8 ) == 1
      pr_control.gc_btn_8_just_pressed = pr_control.gc_btn_8 and not prev_btn_8
      for i = 1, btn_count do
        if gc.getButtonState( 1, i ) == 1 then
          print( "Button " .. i .. " is down" )
        end
      end
      local axis_count = gc.getAxesCount( 1 )
      for i = 1, axis_count do
        pr_control.axes[i] = gc.getAxisValue( 1, i )
      end
    else
      pr_control.gc_dpad_up            = false
      pr_control.gc_dpad_right         = false
      pr_control.gc_dpad_down          = false
      pr_control.gc_dpad_left          = false
      pr_control.gc_btn_1              = false
      pr_control.gc_btn_1_just_pressed = false
      pr_control.gc_btn_8              = false
      pr_control.gc_btn_8_just_pressed = false
      pr_control.axes = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 }
    end
  end)

  if not ok then
    print( "Controller error: " .. tostring(err) )
    pr_control.gc_dpad_up    = false
    pr_control.gc_dpad_right = false
    pr_control.gc_dpad_down  = false
    pr_control.gc_dpad_left  = false
    pr_control.gc_btn_1              = false
    pr_control.gc_btn_8              = false
    pr_control.gc_btn_8_just_pressed = false
    pr_control.axes = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 }
  end
end

return pr_control