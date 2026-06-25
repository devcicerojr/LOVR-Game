lovr.mouse = require '../../external/libraries/lovr_mouse/lovr-mouse'

local texture_wrap = require 'tools/texture_wrap'
local active_tool = texture_wrap

function lovr.load()
  lovr.graphics.setBackgroundColor(0.12, 0.12, 0.15)
  active_tool.load()
end

function lovr.update(dt)
  active_tool.update(dt)
end

function lovr.draw(pass)
  active_tool.draw(pass)
end

function lovr.mousepressed(x, y, button)
  if active_tool.mousepressed then active_tool.mousepressed(x, y, button) end
end

function lovr.mousereleased(x, y, button)
  if active_tool.mousereleased then active_tool.mousereleased(x, y, button) end
end

function lovr.mousemoved(x, y, dx, dy)
  if active_tool.mousemoved then active_tool.mousemoved(x, y, dx, dy) end
end

function lovr.wheelmoved(dx, dy)
  if active_tool.wheelmoved then active_tool.wheelmoved(dx, dy) end
end
