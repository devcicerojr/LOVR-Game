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
  t.graphics.vsync = true
  t.graphics.stencil = false
  t.graphics.antialias = false
  t.graphics.shadercache = true

  t.modules.headset =  true
  -- Configure the desktop window
  t.window.fullscreen = true
  t.window.width = 1080
  t.window.height = 940
  t.window.resizable  = true
  t.window.title = 'JFJR-Game'
  t.window.icon = nil
  t.window.fullscreentype = 'desktop'
end