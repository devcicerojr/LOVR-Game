print("ECS MODULE LOADED")

local ECS = {
  entities = {},
  logic_systems = {},
  render_systems = {},
  materials = {},
  next_id = 0,
  ids_for_deletion = {}
}

-- TODO: Implement a proper class system if needed

-- ECS.__index = ECS

-- function ECS.new()
--   local instance = {
--     entities = {},
--     logic_systems = {},
--     render_systems = {},
--     materials = {},
--     next_id = 0
--   }
--   setmetatable(instance, ECS)
--   return instance
-- end

function ECS:reset()
  self.entities = {}
  self.logic_systems = {}
  self.render_systems = {}
  self.materials = {}
  self.next_id = 0
  self.ids_for_deletion = {}
end

function ECS:newEntity()
  self.next_id = self.next_id + 1
  local id = self.next_id
  self.entities[id] = {}
  return id
end

function ECS:addComponent(id, component)
  if component.type == "ray_collider_sensor" then
    if self.entities[id]["sensors_array"] then
      component.data.callback_ctx_data.id = id
      self.entities[id]["sensors_array"].sensors[component.data.label] = component.data
    end
  else
    self.entities[id][component.type] = component.data
  end
end

function ECS:addSystem( kind , required_components, update_fn )
  table.insert(self[kind .. "_systems"] , 
  { required = required_components , updatefn = update_fn })
end

function ECS:addSystem(system)
  if system.phase == "logic" then
    table.insert(self.logic_systems , 
      { required = system.requires , 
      updatefn = system.update_fn })
  elseif system.phase == "render" then
    system.ecs = self
    table.insert(self.render_systems ,
      { required = system.requires ,
      updatefn = system.update_fn })
  end
end


function ECS:updateEach(required_components, updatefn, dt)
  local count = 0
  for id, c in pairs(self.entities) do
    local match = true
    count = count + 1
    for _, name in ipairs(required_components) do
      if not c[name] then
        match = false
        break
      end
    end
    if match then
      updatefn(id, c, dt)
    end
  end
  print("Ecs contains "..count.." elements")
end

function ECS:renderEach(required_components, drawfn, pass)
  for id, c in pairs(self.entities) do
    local match = true
    for _, name in ipairs(required_components) do
      if not c[name] then
        match = false
        break
      end
    end
    if match then
      drawfn(id, c, pass)
    end
  end
end


function ECS:update(dt)
  for _, system in ipairs(self.logic_systems) do
    ECS:updateEach(system.required , system.updatefn, dt)
  end
end

function ECS:draw(pass)
  for _, system in ipairs(self.render_systems) do
    ECS:renderEach(system.required , system.updatefn, pass)
  end
end

function ECS:addMaterial(name, material)
  if not self.materials[name] then
    self.materials[name] = material
  end
end

function ECS:getMaterial(name)
  return self.materials[name]
end

function ECS:getEntityByTag(tag) -- must be unique tag. Function will return at first match
  local ret_id = nil
  for id , c in pairs(self.entities) do
    local match = true
    for _, name in ipairs({tag}) do
      if not c[name] then
        match = false
        break
      end
    end
    if match then
      ret_id = id
    end
  end
  return ret_id
end

function ECS:clearObstructingVals()
  local obstruct_tag = 'is_camera_blocker'
  for id , c in pairs(self.entities) do
    if c[obstruct_tag] then
      self.entities[id].is_camera_blocker.is_blocking = false
    end
  end
end

function ECS:deleteDeadEntities()
  for _, id in ipairs(self.ids_for_deletion) do
    print("Deleting entity")
    self.entities[id] = nil
  end
  self.ids_for_deletion = {}
end

return ECS