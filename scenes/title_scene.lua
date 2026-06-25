local title_scene = {}

title_scene.start_requested = false

local W = 1080
local H = 720

local BTN_W = 280
local BTN_H = 56

local BUTTONS = { "Start Game", "Options", "Exit" }
local BTN_Y   = { H * 0.50,    H * 0.59,  H * 0.68 }

local selected      = 1
local prev_dpad_up  = false
local prev_dpad_down = false
local prev_w        = false
local prev_s        = false

function title_scene.load()
  title_scene.start_requested = false
  selected      = 1
  prev_dpad_up  = false
  prev_dpad_down = false
  prev_w        = false
  prev_s        = false
end

function title_scene.unload()
  title_scene.start_requested = false
end

function title_scene.update(dt)
  local nav_up   = (pr_control.w_pressed     and not prev_w)
                or (pr_control.gc_dpad_up    and not prev_dpad_up)
  local nav_down = (pr_control.s_pressed     and not prev_s)
                or (pr_control.gc_dpad_down  and not prev_dpad_down)
  prev_w         = pr_control.w_pressed
  prev_s         = pr_control.s_pressed
  prev_dpad_up   = pr_control.gc_dpad_up
  prev_dpad_down = pr_control.gc_dpad_down

  if nav_up   then selected = 1 + (selected - 2) % #BUTTONS end
  if nav_down then selected = 1 + (selected)     % #BUTTONS end

  local confirm = pr_control.space_pressed
               or pr_control.enter_pressed
               or pr_control.gc_btn_1_just_pressed
               or pr_control.gc_btn_8_just_pressed
  if confirm then
    pr_control.space_pressed         = false
    pr_control.enter_pressed         = false
    pr_control.gc_btn_1_just_pressed = false
    pr_control.gc_btn_8_just_pressed = false
    if selected == 1 then
      title_scene.start_requested = true
    elseif selected == 3 then
      lovr.event.quit()
    end
    -- Options (2) intentionally does nothing yet
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

  pass:setColor(1, 0.75, 0.1, 1)
  pass:text("Dont Stop Delivery", W / 2, H * 0.34, 0, 90)

  for i, label in ipairs(BUTTONS) do
    draw_button(pass, W / 2, BTN_Y[i], label, i == selected)
  end

  pass:setColor(1, 1, 1, 1)
  pass:setDepthWrite(true)
end

return title_scene
