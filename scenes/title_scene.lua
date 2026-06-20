local title_scene = {}

title_scene.start_requested = false

local W = 1080
local H = 720

local BTN_W  = 280
local BTN_H  = 56

function title_scene.load()
  title_scene.start_requested = false
end

function title_scene.unload()
  title_scene.start_requested = false
end

function title_scene.update(dt)
  local confirm = pr_control.space_pressed
                  or pr_control.enter_pressed
                  or pr_control.gc_btn_1
                  or pr_control.gc_btn_8
  if confirm then
    title_scene.start_requested = true
    pr_control.space_pressed = false
    pr_control.enter_pressed = false
  end
end

local function draw_button(pass, cx, cy, label, active)
  if active then
    pass:setColor(0.95, 0.75, 0.1, 1)
  else
    pass:setColor(0.22, 0.22, 0.22, 1)
  end
  pass:plane(cx, cy, 0, BTN_W, BTN_H)

  if active then
    pass:setColor(0.08, 0.04, 0.0, 1)
  else
    pass:setColor(0.5, 0.5, 0.5, 1)
  end
  pass:text(label, cx, cy, 0, 34)
end

function title_scene.draw(pass)
  pass:setShader()
  pass:setDepthTest()
  pass:setDepthWrite(false)
  pass:setViewPose(1, lovr.math.mat4())
  pass:setProjection(1, lovr.math.mat4():orthographic(0, W, 0, H, -1, 1))

  -- Title
  pass:setColor(1, 0.75, 0.1, 1)
  pass:text("Dont Stop Delivery", W / 2, H * 0.65, 0, 90)

  -- Buttons
  draw_button(pass, W / 2, H * 0.46, "Start Game", true)
  draw_button(pass, W / 2, H * 0.34, "Options",    false)

  pass:setColor(1, 1, 1, 1)
  pass:setDepthWrite(true)
end

return title_scene
