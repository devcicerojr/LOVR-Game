function lovr.conf(t)

  -- Physics
  t.modules.physics = true

  -- Headset settings
  t.headset.drivers = { 'openxr', 'simulator' }
  t.headset.start = false
  t.headset.supersample = false
  t.headset.seated = false
  t.headset.antialias = true
  t.headset.stencil = false
  t.headset.submitdepth = true
  t.headset.overlay = false

  -- Graphics
  t.graphics.debug = false
  t.graphics.vsync = true
  t.graphics.stencil = false
  t.graphics.antialias = false
  t.graphics.shadercache = true

  t.modules.headset =  true
  -- Configure the desktop window
  t.window.width = 640
  t.window.height = 360
  t.window.resizable  = true
  t.window.title = 'JFJR-Game'
  t.window.icon = nil
  t.window.fullscreen = true
end