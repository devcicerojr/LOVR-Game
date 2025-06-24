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
  t.graphics.debug = true
  t.graphics.vsync = false
  t.graphics.stencil = false
  t.graphics.antialias = true
  t.graphics.shadercache = true

  t.modules.headset =  true
  -- Configure the desktop window
  t.window.width = 0
  t.window.height = 0
  t.window.resizable = true
  t.window.title = 'JFJR-Game'
  t.window.icon = nil
  t.window.fullscreen = false
end