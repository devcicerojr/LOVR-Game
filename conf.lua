function lovr.conf(t)
  t.version = '0.18.0'
  t.identity = 'scout-rush'
  -- Physics
  t.modules.physics = true

  -- Headset settings
  t.headset.drivers = { 'openxr', 'simulator' }
  t.headset.start = false
  t.headset.supersample = false
  t.headset.seated = false
  t.headset.antialias = false
  t.headset.stencil = false
  t.headset.submitdepth = true
  t.headset.overlay = false

  -- Graphics
  t.graphics.debug = false
  t.graphics.vsync = true
  t.graphics.stencil = false
  t.graphics.antialias = true
  t.graphics.shadercache = true

  t.modules.headset =  true
  -- Configure the desktop window
  t.window.fullscreen = false
  t.window.width = 480
  t.window.height = 360
  t.window.resizable  = true
  t.window.title = 'JFJR-Game'
  t.window.icon = nil
  t.window.fullscreentype = 'desktop'
end