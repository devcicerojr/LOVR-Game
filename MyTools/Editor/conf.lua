function lovr.conf(t)
  t.version = '0.19.0'
  t.identity = 'lovr-editor'
  t.modules.physics = false
  t.modules.audio = false
  t.modules.headset = false
  t.graphics.vsync = true
  t.graphics.antialias = true
  t.window.width = 1280
  t.window.height = 720
  t.window.resizable = true
  t.window.title = 'LOVR Editor'
end
