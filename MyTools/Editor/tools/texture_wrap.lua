local M = {}

-- Ramp defaults matching the game entity
local RAMP_WIDTH  = 4
local RAMP_HEIGHT = 0.1
local RAMP_DEPTH  = 8
local RAMP_SLOPE  = 0.3491  -- 20 degrees

-- Panel layout
local PANEL_W   = 260
local ITEM_H    = 22
local FONT_SIZE = 14
local UV_H      = ITEM_H * 7   -- header + face-selector + 4 param rows + flip row

-- Mount point for game assets inside LOVR's virtual filesystem
local MOUNT_PT = '/game_assets'

-- State
local ramp_mesh
local ramp_texture = nil
local ui_font

local cam = {
  yaw      = 0.5,
  pitch    = 0.35,
  distance = 14,
  target   = { x = 0, y = 0.5, z = 0 },
}

local drag = { active = false }

local browser = {
  current_dir   = MOUNT_PT,
  items         = {},
  scroll        = 0,
  selected_path = nil,
  mounted       = false,
}

-- UV editing state
local face_order  = { 'top', 'front', 'back', 'left', 'right', 'bottom' }
local face_labels = { top='Slope', front='Front', back='Back', left='Left', right='Right', bottom='Bottom' }
local uv_face_idx = 1

local uv_params = {
  top    = { us = 1.0, vs = 1.0, uo = 0.0, vo = 0.0, swap = false },
  front  = { us = 1.0, vs = 1.0, uo = 0.0, vo = 0.0, swap = false },
  back   = { us = 1.0, vs = 1.0, uo = 0.0, vo = 0.0, swap = false },
  left   = { us = 1.0, vs = 1.0, uo = 0.0, vo = 0.0, swap = false },
  right  = { us = 1.0, vs = 1.0, uo = 0.0, vo = 0.0, swap = false },
  bottom = { us = 1.0, vs = 1.0, uo = 0.0, vo = 0.0, swap = false },
}

local param_labels = { 'U Scale', 'V Scale', 'U Offset', 'V Offset' }
local param_keys   = { 'us',      'vs',      'uo',       'vo'       }
local UV_STEP = 0.1

-- UV row button pixel positions (within PANEL_W=260)
local BTN_W    = 22
local BTN_L    = 108   -- left [-] button: x = 108..130
local BTN_R    = 230   -- right [+] button: x = 230..252
local LABEL_CX = 52    -- center X for the label column
local VAL_CX   = (BTN_L + BTN_W + BTN_R) / 2  -- center between buttons

-- ------------------------------------------------------------------ mesh

local function apply_uv(face, u, v)
  local p = uv_params[face]
  if p.swap then u, v = v, u end
  return u * p.us + p.uo, v * p.vs + p.vo
end

local function make_vertices()
  local w  = RAMP_WIDTH
  local h  = RAMP_HEIGHT
  local d  = RAMP_DEPTH
  local th = h + math.tan(RAMP_SLOPE) * d
  local uv = apply_uv

  return {
    -- front (-Z)
    {  w/2, -th/2,      -d/2, uv('front', 1, 0) },
    {  -w/2, -th/2,      -d/2, uv('front', 0, 0) },
    {  -w/2, -th/2 + h,  -d/2, uv('front', 0, 1) },
    {  w/2, -th/2 + h,  -d/2, uv('front', 1, 1) },
    -- back (+Z)
    { -w/2, -th/2,       d/2, uv('back', 0, 0) },
    {  w/2, -th/2,       d/2, uv('back', 1, 0) },
    {  w/2,  th/2,       d/2, uv('back', 1, 1) },
    { -w/2,  th/2,       d/2, uv('back', 0, 1) },
    -- left (-X)
    { -w/2, -th/2,       d/2, uv('left', 1, 0) },
    { -w/2, -th/2,      -d/2, uv('left', 1, 1) },
    { -w/2, -th/2 + h,  -d/2, uv('left', 0, 1) },
    { -w/2,  th/2,       d/2, uv('left', 0, 0) },
    -- right (+X)
    {  w/2, -th/2,       d/2, uv('right', 0, 0) },
    {  w/2, -th/2,      -d/2, uv('right', 0, 1) },
    {  w/2,  th/2,       d/2, uv('right', 1, 1) },
    {  w/2, -th/2 + h,  -d/2, uv('right', 1, 0) },
    -- top / slope (player walks here)
    { -w/2, -th/2 + h,  -d/2, uv('top', 0, 1) },
    {  w/2, -th/2 + h,  -d/2, uv('top', 1, 1) },
    {  w/2,  th/2,       d/2, uv('top', 1, 0) },
    { -w/2,  th/2,       d/2, uv('top', 0, 0) },
    -- bottom
    { -w/2, -th/2,      -d/2, uv('bottom', 1, 0) },
    {  w/2, -th/2,      -d/2, uv('bottom', 0, 0) },
    {  w/2, -th/2,       d/2, uv('bottom', 0, 1) },
    { -w/2, -th/2,       d/2, uv('bottom', 1, 1) },
  }
end

local function build_ramp_mesh()
  local fmt = {
    { 'VertexPosition', 'vec3' },
    { 'VertexUV',       'vec2' },
  }
  local m = lovr.graphics.newMesh(fmt, make_vertices())
  m:setIndices({
     1,  2,  3,   1,  3,  4,
     5,  6,  7,   5,  7,  8,
    10,  9, 12,  10, 12, 11,
    13, 14, 16,  13, 16, 15,
    17, 20, 19,  17, 19, 18,
    21, 22, 23,  21, 23, 24,
  })
  return m
end

local function rebuild_uvs()
  ramp_mesh:setVertices(make_vertices())
end

-- ------------------------------------------------------------------ file browser

local function is_image(name)
  return name:match('%.[pP][nN][gG]$')
      or name:match('%.[jJ][pP][eE]?[gG]$')
end

local function load_dir(vdir)
  browser.current_dir = vdir
  browser.items = {}
  browser.scroll = 0

  local entries = lovr.filesystem.getDirectoryItems(vdir)
  if not entries then return end

  for _, name in ipairs(entries) do
    local full = vdir .. '/' .. name
    if lovr.filesystem.isDirectory(full) then
      table.insert(browser.items, { label = '[' .. name .. ']', path = full, is_dir = true })
    elseif is_image(name) then
      table.insert(browser.items, { label = name, path = full, is_dir = false })
    end
  end

  table.sort(browser.items, function(a, b)
    if a.is_dir ~= b.is_dir then return a.is_dir end
    return a.label < b.label
  end)

  if vdir ~= MOUNT_PT then
    local parent = vdir:match('^(.+)/[^/]+$') or MOUNT_PT
    if #parent < #MOUNT_PT then parent = MOUNT_PT end
    table.insert(browser.items, 1, { label = '..', path = parent, is_dir = true })
  end
end

-- ------------------------------------------------------------------ load

function M.load()
  ramp_mesh = build_ramp_mesh()
  ui_font = lovr.graphics.newFont(FONT_SIZE)
  ui_font:setPixelDensity(1)

  local src = lovr.filesystem.getSource()
  local game_assets = src .. '/../../assets'
  browser.mounted = lovr.filesystem.mount(game_assets, MOUNT_PT, false)
  if browser.mounted then
    load_dir(MOUNT_PT)
  else
    browser.items = { { label = '(mount failed — check path)', path = nil, is_dir = false } }
  end
end

-- ------------------------------------------------------------------ update

function M.update(dt) end

-- ------------------------------------------------------------------ camera

local function camera_transform()
  local m = lovr.math.newMat4()
  m:translate(cam.target.x, cam.target.y, cam.target.z)
  m:rotate(cam.yaw,    0, 1, 0)
  m:rotate(-cam.pitch, 1, 0, 0)
  m:translate(0, 0, cam.distance)
  return m
end

-- ------------------------------------------------------------------ draw

local function draw_grid(pass)
  pass:setShader('unlit')
  pass:setColor(0.28, 0.28, 0.32)
  for i = -10, 10 do
    pass:line(i, 0, -10,  i, 0, 10)
    pass:line(-10, 0, i,  10, 0, i)
  end
end

local function draw_ramp(pass)
  pass:push('state')
  pass:setShader('unlit')
  pass:setCullMode('back')
  if ramp_texture then
    pass:setMaterial(ramp_texture)
  else
    pass:setColor(0.55, 0.55, 0.60)
  end
  pass:draw(ramp_mesh, 0, 0, 0)
  pass:pop('state')
end

local function draw_uv_row(pass, cy, label, value)
  pass:setColor(0.72, 0.72, 0.78, 1)
  pass:text(label, LABEL_CX, cy, 0)

  pass:setColor(0.22, 0.22, 0.28, 1)
  pass:plane(BTN_L + BTN_W / 2, cy, 0, BTN_W, ITEM_H - 4)
  pass:setColor(0.90, 0.55, 0.55, 1)
  pass:text('-', BTN_L + BTN_W / 2, cy, 0)

  pass:setColor(0.92, 0.92, 0.95, 1)
  pass:text(string.format('%.2f', value), VAL_CX, cy, 0)

  pass:setColor(0.22, 0.22, 0.28, 1)
  pass:plane(BTN_R + BTN_W / 2, cy, 0, BTN_W, ITEM_H - 4)
  pass:setColor(0.55, 0.90, 0.55, 1)
  pass:text('+', BTN_R + BTN_W / 2, cy, 0)
end

local function draw_ui(pass)
  local sw, sh = lovr.system.getWindowDimensions()
  local uv_div = sh - 36 - UV_H   -- Y where UV section starts

  pass:origin()
  pass:setShader()
  pass:setDepthTest('none')
  pass:setCullMode('none')
  pass:setFont(ui_font)
  pass:setViewPose(1, mat4():identity())
  pass:setProjection(1, mat4():orthographic(0, sw, 0, sh, -10, 10))

  -- Panel background
  pass:setColor(0.14, 0.14, 0.17, 1)
  pass:plane(PANEL_W / 2, sh / 2, 0, PANEL_W, sh)

  -- Title bar
  pass:setColor(0.20, 0.20, 0.25, 1)
  pass:plane(PANEL_W / 2, 18, 0, PANEL_W, 36)
  pass:setColor(0.85, 0.85, 0.90, 1)
  pass:text('Texture Browser', PANEL_W / 2, 18, 0)
  pass:setColor(0.35, 0.35, 0.42, 1)
  pass:line(0, 36, 0, PANEL_W, 36, 0)

  -- Current directory
  local rel_dir = browser.current_dir:gsub('^' .. MOUNT_PT, 'assets')
  pass:setColor(0.55, 0.55, 0.65, 1)
  pass:text(rel_dir, PANEL_W / 2, 52, 0)
  pass:setColor(0.35, 0.35, 0.42, 1)
  pass:line(0, 64, 0, PANEL_W, 64, 0)

  -- File list (height capped above the UV section)
  local list_top = 70
  local max_vis  = math.floor((uv_div - list_top - 1) / ITEM_H)
  local total    = #browser.items
  browser.scroll = math.max(0, math.min(browser.scroll, math.max(0, total - max_vis)))

  for i = 1, math.min(max_vis, total) do
    local item = browser.items[i + math.floor(browser.scroll)]
    if not item then break end
    local iy = list_top + (i - 1) * ITEM_H

    if item.path == browser.selected_path then
      pass:setColor(0.22, 0.42, 0.65, 1)
      pass:plane(PANEL_W / 2, iy + ITEM_H / 2, 0, PANEL_W, ITEM_H)
    elseif i % 2 == 0 then
      pass:setColor(0.17, 0.17, 0.20, 1)
      pass:plane(PANEL_W / 2, iy + ITEM_H / 2, 0, PANEL_W, ITEM_H)
    end

    pass:setColor(item.is_dir and 0.65 or 0.88, item.is_dir and 0.82 or 0.88, item.is_dir and 1.0 or 0.88, 1)
    pass:text(item.label, PANEL_W / 2, iy + ITEM_H / 2, 0)
  end

  -- UV Controls section
  pass:setColor(0.35, 0.35, 0.42, 1)
  pass:line(0, uv_div, 0, PANEL_W, uv_div, 0)

  local hdr_y = uv_div + ITEM_H / 2
  pass:setColor(0.18, 0.18, 0.24, 1)
  pass:plane(PANEL_W / 2, hdr_y, 0, PANEL_W, ITEM_H)
  pass:setColor(0.65, 0.82, 1.0, 1)
  pass:text('UV Controls', PANEL_W / 2, hdr_y, 0)

  -- Face selector
  local face_y  = uv_div + ITEM_H + ITEM_H / 2
  local ARROW_W = 22
  pass:setColor(0.22, 0.22, 0.28, 1)
  pass:plane(ARROW_W / 2 + 4, face_y, 0, ARROW_W, ITEM_H - 4)
  pass:plane(PANEL_W - ARROW_W / 2 - 4, face_y, 0, ARROW_W, ITEM_H - 4)
  pass:setColor(0.85, 0.85, 0.90, 1)
  pass:text('<', ARROW_W / 2 + 4, face_y, 0)
  pass:text('>', PANEL_W - ARROW_W / 2 - 4, face_y, 0)
  pass:setColor(0.92, 0.92, 0.95, 1)
  pass:text(face_labels[face_order[uv_face_idx]], PANEL_W / 2, face_y, 0)

  -- Param rows (U Scale, V Scale, U Offset, V Offset)
  local cur = uv_params[face_order[uv_face_idx]]
  for i, label in ipairs(param_labels) do
    draw_uv_row(pass, uv_div + (i + 1) * ITEM_H + ITEM_H / 2, label, cur[param_keys[i]])
  end

  -- Swap U↔V toggle
  local swap_y  = uv_div + 6 * ITEM_H + ITEM_H / 2
  local active  = cur.swap
  pass:setColor(active and 0.20 or 0.22, active and 0.38 or 0.22, active and 0.55 or 0.28, 1)
  pass:plane(PANEL_W / 2, swap_y, 0, PANEL_W - 8, ITEM_H - 4)
  pass:setColor(active and 0.70 or 0.55, active and 0.88 or 0.55, active and 1.0 or 0.60, 1)
  pass:text(active and 'Swap UV: ON  (U<->V)' or 'Swap UV: OFF (U<->V)', PANEL_W / 2, swap_y, 0)

  -- Footer: selected texture name
  if browser.selected_path then
    pass:setColor(0.18, 0.18, 0.22, 1)
    pass:plane(PANEL_W / 2, sh - 18, 0, PANEL_W, 36)
    pass:setColor(0.55, 0.90, 0.55, 1)
    local fname = browser.selected_path:match('[^/]+$') or ''
    pass:text(fname, PANEL_W / 2, sh - 18, 0)
  end
end

function M.draw(pass)
  local sw, sh = lovr.system.getWindowDimensions()
  pass:setViewPose(1, camera_transform())
  -- far=0 → infinite reversed-Z, matching LOVR's default gequal depth test and 0.0 depth clear
  pass:setProjection(1, lovr.math.newMat4():perspective(math.pi / 4, sw / sh, 0.1, 0))
  draw_grid(pass)
  draw_ramp(pass)
  draw_ui(pass)
end

-- ------------------------------------------------------------------ input

function M.mousepressed(x, y, button)
  if x > PANEL_W then
    if button == 1 then drag.active = true end
    return
  end

  local _, sh = lovr.system.getWindowDimensions()
  local uv_div   = sh - 36 - UV_H
  local list_top = 70

  if y >= sh - 36 then return end   -- footer: no action

  if y >= uv_div then
    -- UV Controls section
    local row = math.floor((y - uv_div) / ITEM_H)
    if row == 1 then
      -- face selector arrows
      if x < 32 then
        uv_face_idx = ((uv_face_idx - 2) % #face_order) + 1
      elseif x > PANEL_W - 32 then
        uv_face_idx = (uv_face_idx % #face_order) + 1
      end
    elseif row >= 2 and row <= 5 then
      local ki   = row - 1   -- 1..4 → U Scale, V Scale, U Offset, V Offset
      local face = face_order[uv_face_idx]
      local key  = param_keys[ki]
      if x >= BTN_L and x <= BTN_L + BTN_W then
        uv_params[face][key] = uv_params[face][key] - UV_STEP
        rebuild_uvs()
      elseif x >= BTN_R and x <= BTN_R + BTN_W then
        uv_params[face][key] = uv_params[face][key] + UV_STEP
        rebuild_uvs()
      end
    elseif row == 6 then
      local face = face_order[uv_face_idx]
      uv_params[face].swap = not uv_params[face].swap
      rebuild_uvs()
    end
    return
  end

  -- Texture browser file list
  if y > list_top then
    local idx  = math.floor((y - list_top) / ITEM_H) + 1 + math.floor(browser.scroll)
    local item = browser.items[idx]
    if item then
      if item.is_dir and item.path then
        load_dir(item.path)
      elseif not item.is_dir and item.path then
        browser.selected_path = item.path
        local ok, tex = pcall(lovr.graphics.newTexture, item.path)
        if ok then ramp_texture = tex end
      end
    end
  end
end

function M.mousereleased(x, y, button)
  if button == 1 then drag.active = false end
end

function M.mousemoved(x, y, dx, dy)
  if drag.active then
    cam.yaw   = cam.yaw - dx * 0.005
    cam.pitch = math.max(-1.4, math.min(1.4, cam.pitch + dy * 0.005))
  end
end

function M.wheelmoved(dx, dy)
  local mx = lovr.mouse.getPosition()
  if mx < PANEL_W then
    browser.scroll = browser.scroll - dy * 2
  else
    cam.distance = math.max(2, math.min(60, cam.distance - dy * 0.8))
  end
end

return M
