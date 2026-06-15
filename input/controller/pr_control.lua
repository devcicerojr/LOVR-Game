local pr_camera = require'pr_camera'

local f                                = io.open( "./external/libraries/game_controller/gamecontrollerdb.txt", "r" )
if not f then
    print("Could NOT open file:", err)
end
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


pr_control.gc_dpad_up = false
pr_control.gc_dpad_right = false
pr_control.gc_dpad_down = false
pr_control.gc_dpad_left = false


pr_control.spectate = false
pr_control.spec_cam = { x = 0 , y = 0 , z = 0 , angle = 0 , ax = 0 , ay = 0 , az = 0 }


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
    pr_control.space_pressed = false;
    print("space released")
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


  local result, type, device = gc.configurationChanged()
	if result then
		print( "Device: " .. device .. " was " .. type )
	end

	if gc.isDevicePresent( 1 ) then
		local btn_count = gc.getButtonCount( 1 )
    pr_control.gc_dpad_up = gc.getButtonState( 1, 11 ) == 1
    pr_control.gc_dpad_right = gc.getButtonState( 1, 12 ) == 1
    pr_control.gc_dpad_down = gc.getButtonState( 1, 13 ) == 1
    pr_control.gc_dpad_left = gc.getButtonState( 1, 14 ) == 1
		for i = 1, btn_count do
			if gc.getButtonState( 1, i ) == 1 then
				-- print( "Button " .. i .. " is down" )
			end
		end
    local axis_count = gc.getAxesCount( 1 )
    -- print ("Axis count: " .. axis_count )
    local axis_value = 0.0
    for i = 1, axis_count do
      axis_value = gc.getAxisValue( 1, i )
      print( "Axis " .. i .. " value: " .. axis_value )
    end
	end
end

return pr_control