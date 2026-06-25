require'core/pr_event_bus'
default_shader = require'shaders/default_shader'
outline_shader = require'shaders/outline_shader'
environment_shader = require'shaders/environment_shader'
test_shader = require'shaders/test_shader'
cel_shader =  require'shaders/cel_shader'
lovr.mouse = require'external/libraries/lovr_mouse/lovr-mouse'


local pr_control  = require'./input/controller/pr_control'
local pr_camera   = require'pr_camera'
local title_scene = require'scenes/title_scene'
local game_scene  = require'scenes/game_scene'
local map_parser  = require'tools/map_parser'
local lovr_world  = require'core/pr_world'

local current_scene = title_scene

local function switch_to_title()
  current_scene.unload()
  current_scene = title_scene
  title_scene.load()
end

local function switch_to_game()
  current_scene.unload()
  current_scene = game_scene
  game_scene.load()
end


is_dev_build = false
draw_wireframes = false

-- function lovr.errorhandler(err)
--   local trace = debug.traceback(err, 2)
--   print(trace)
--   return trace
-- end

-- GLFW FFI setup — each declaration in its own pcall so that symbols already
-- registered by lovr-mouse don't cause the whole block to fail.
local ffi  = require 'ffi'
local glfw = ffi.os == 'Windows' and ffi.load('glfw3') or ffi.C
pcall(ffi.cdef, 'typedef struct GLFWwindow GLFWwindow;')
pcall(ffi.cdef, 'typedef struct GLFWmonitor GLFWmonitor;')
pcall(ffi.cdef, 'GLFWwindow* os_get_glfw_window(void);')
pcall(ffi.cdef, 'void glfwSetWindowAttrib(GLFWwindow* window, int attrib, int value);')
pcall(ffi.cdef, 'void glfwGetWindowPos(GLFWwindow* window, int* xpos, int* ypos);')
pcall(ffi.cdef, 'void glfwGetWindowSize(GLFWwindow* window, int* width, int* height);')
pcall(ffi.cdef, 'GLFWmonitor* glfwGetPrimaryMonitor(void);')
pcall(ffi.cdef, 'typedef struct { int width; int height; int redBits; int greenBits; int blueBits; int refreshRate; } GLFWvidmode;')
pcall(ffi.cdef, 'const GLFWvidmode* glfwGetVideoMode(GLFWmonitor* monitor);')
pcall(ffi.cdef, 'void glfwSetWindowMonitor(GLFWwindow* window, GLFWmonitor* monitor, int xpos, int ypos, int width, int height, int refreshRate);')
local glfw_window = ffi.C.os_get_glfw_window()

local function remove_window_decoration()
  glfw.glfwSetWindowAttrib(glfw_window, 0x00020005, 0)  -- GLFW_DECORATED = false
end

local is_fullscreen = false
local saved_x, saved_y, saved_w, saved_h

function toggle_fullscreen()
  if not is_fullscreen then
    local x, y = ffi.new('int[1]'), ffi.new('int[1]')
    local w, h = ffi.new('int[1]'), ffi.new('int[1]')
    glfw.glfwGetWindowPos(glfw_window, x, y)
    glfw.glfwGetWindowSize(glfw_window, w, h)
    saved_x, saved_y = x[0], y[0]
    saved_w, saved_h = w[0], h[0]
    local monitor = glfw.glfwGetPrimaryMonitor()
    local mode    = glfw.glfwGetVideoMode(monitor)
    glfw.glfwSetWindowMonitor(glfw_window, monitor, 0, 0, mode.width, mode.height, mode.refreshRate)
    is_fullscreen = true
  else
    glfw.glfwSetWindowMonitor(glfw_window, nil, saved_x, saved_y, saved_w, saved_h, 0)
    is_fullscreen = false
  end
end

function lovr.keypressed(key, scancode, rpt)
  if key == 'return' and (lovr.system.isKeyDown('lalt') or lovr.system.isKeyDown('ralt')) then
    toggle_fullscreen()
  end
  pr_control.keypressed(key, scancode, rpt)
end

function lovr.wheelmoved(dx, dy)
  -- pr_control.wheelmoved(dx, dy)
end

function lovr.keyreleased(key, scancode)
  pr_control.keyreleased(key, scancode)
end

function lovr.load(arg)
  remove_window_decoration()
  local window_pass = lovr.graphics.getWindowPass()
  window_pass:setViewCull(true)
  window_pass:setDepthTest('less')
  pr_control.load()
  
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

  features = lovr.graphics.getFeatures()
  
  if features.depthClamp then
    print("Depth clamping is supported and enabled.")
  else
    print("Depth clamping is not supported.")
  end

  title_scene.load()

  pr_camera.init()
end

function lovr.update(dt)
  if dt > 0.05 then dt = 0.05 end
  pr_control.update(dt)

  if current_scene == title_scene then
    if title_scene.start_requested then
      switch_to_game()
    end
  end

  if current_scene == game_scene then
    if pr_control.nine_pressed then
      game_scene:player_respawn()
    end
    if not game_scene.is_paused then
      lovr_world:update(dt)
    end
  end

  current_scene.update(dt)

  if current_scene == game_scene and game_scene.return_to_title_requested then
    switch_to_title()
  end
end

function lovr.draw(pass)
  pass:setDepthOffset(1.0, 1.0)
  pass:setDepthClamp(false)

  if current_scene == game_scene then
    if not pr_camera.spectate then
      pass:setViewPose(1, pr_camera.game_cam:getPose())
    else
      pr_camera.updateSpecCamPose()
    end
  end

  return current_scene.draw(pass)
end

-- function lovr.run()
--   local updates_per_draw = 1
--   local update_count = 0
--   if lovr.timer then lovr.timer.step() end
--   if lovr.load then lovr.load(arg) end
--   return function()
--     if lovr.system then lovr.system.pollEvents() end
--     if lovr.event then
--       for name, a, b, c, d in lovr.event.poll() do
--         if name == 'restart' then return 'restart', lovr.restart and lovr.restart()
--         elseif name == 'quit' and (not lovr.quit or not lovr.quit(a)) then return a or 0
--         elseif name ~= 'quit' and lovr.handlers[name] then lovr.handlers[name](a, b, c, d) end
--       end
--     end
--     local dt = 0
--     if lovr.timer then dt = lovr.timer.step() end
--     if lovr.headset and lovr.headset.isActive() then dt = lovr.headset.update() end
--     if lovr.update then 
--       lovr.update(dt) 
--       update_count = update_count + 1
--     end
--     if lovr.graphics  and update_count >= updates_per_draw then
--       update_count = 0
--       local headset = lovr.headset and lovr.headset.getPass()
--       if headset and (not lovr.draw or lovr.draw(headset)) then headset = nil end
--       local window = lovr.graphics.getWindowPass()
--       if window and (not lovr.mirror or lovr.mirror(window)) then window = nil end
--       lovr.graphics.submit(headset, window)
--       lovr.graphics.present()
--     end
--     if lovr.headset then lovr.headset.submit() end
--     if lovr.math then lovr.math.drain() end
--   end
-- end
