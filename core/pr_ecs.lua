local ECS = {
  entities = {},
  logic_systems = {},
  render_systems = {},
  materials = {},
  next_id = 0
}

function ECS:newEntity()
  self.next_id = self.next_id + 1
  local id = self.next_id
  self.entities[id] = {}
  return id
end

function ECS:addComponent(id, component)
  self.entities[id][component.type] = component.data
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


function ECS:update(dt)
end

function ECS:updateEach(required_components, updatefn, dt)
  for id, c in pairs(self.entities) do
    local match = true
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
  self.materials[name] = material
end

function ECS:getMaterial(name)
  return self.materials[name]
end

return ECS