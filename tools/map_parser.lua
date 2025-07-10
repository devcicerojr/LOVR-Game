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
  local first_entity = true
  local reading_worldspawn = false
  local inside_worldspawn = false
  local inside_brush = false
  local current_faces = {}
  local entities = {}
  local entities_count = 0
  local reading_entity = false
  
  for line in text:gmatch("[^\r\n]+") do
    line = line:match("^%s*(.-)%s*$") -- trim

    if line == '{' and first_entity then
      first_entity = false
      reading_worldspawn = true
      -- inside_worldspawn = true
      current_faces = {}
    elseif line == '{' and not first_entity and not reading_worldspawn and not inside_worldspawn then
      entities_count = entities_count + 1
      reading_entity = true
    elseif reading_entity and line:match('^"classname"%s+"[^"]+"$') then
      local entity_name = line:match('"[^"]+"$')
      entities[entities_count] = { name = entity_name }
    elseif reading_entity and entities[entities_count].name ~= nil and line:match('^"[^"]+"%s+"[^"]+"$') then
      local field_name = line:match('^%s*"([^"]+)')
      local values = line:match('"([^"]+)"$')
      print("field name: " .. field_name)
      if field_name == "origin" then
        local x, y, z = values:match('^([%-%d%.]+) +([%-%d%.]+) +([%-%d%.]+)')
        if x then
          print("origin found: " .. x .. ", " .. y .. ", " .. z)
          entities[entities_count][field_name] = {
            x = tonumber(x),
            y = tonumber(y),
            z = tonumber(z)
          }
        end
      end
    elseif reading_entity and line == '}' then
      -- end of entity
      reading_entity = false
    elseif reading_worldspawn and line:match('^"classname"%s+"worldspawn"$') then
      -- still inside worldspawn header
      reading_worldspawn = false -- worldspawn was found
      inside_worldspawn = true
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
  print("Parsed entities count: " .. entities_count)
  return brushes
end


return map_parser

