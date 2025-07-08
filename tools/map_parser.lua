local ecs = require'../core/pr_ecs'

local map_parser = {}

-- Utility: Read file contents
local function read_file(path)
  local f = io.open(path, 'r')
  if not f then error('Could not open file: ' .. path) end
  local content = f:read('*a')
  f:close()
  return content
end

-- Parse a .map file and return a table of brushes (faces)
function map_parser.parse_map(path)
  local text = read_file(path)
  local brushes = {}
  local inside_worldspawn = false
  local inside_brush = false
  local current_faces = {}
  
  for line in text:gmatch("[^\r\n]+") do
    line = line:match("^%s*(.-)%s*$") -- trim

    if line == '{' and not inside_worldspawn then
      inside_worldspawn = true
      current_faces = {}
    elseif inside_worldspawn and line:match('^"classname"%s+"worldspawn"$') then
      -- still inside worldspawn header
    elseif inside_worldspawn and line == '{' then
      inside_brush = true
      current_faces = {}
    elseif inside_worldspawn and line == '}' and inside_brush then
      table.insert(brushes, current_faces)
      inside_brush = false
    elseif inside_worldspawn and line == '}' and not inside_brush then
      -- closing worldspawn
      inside_worldspawn = false
    elseif inside_brush then
      if not line:match("^//") then
        local x1, y1, z1, x2, y2, z2, x3, y3, z3, texture =
          line:match('%( *([%-%d%.]+) +([%-%d%.]+) +([%-%d%.]+) *%) +' ..
                     '%( *([%-%d%.]+) +([%-%d%.]+) +([%-%d%.]+) *%) +' ..
                     '%( *([%-%d%.]+) +([%-%d%.]+) +([%-%d%.]+) *%) +' ..
                     '([%w_./-]+)')
        if x1 then
          table.insert(current_faces, {
            p1 = { tonumber(x1), tonumber(y1), tonumber(z1) },
            p2 = { tonumber(x2), tonumber(y2), tonumber(z2) },
            p3 = { tonumber(x3), tonumber(y3), tonumber(z3) },
            texture = texture
          })
        end
      end
    end
  end

  print("Parsed brush count: " .. #brushes)
  return brushes
end


return map_parser

