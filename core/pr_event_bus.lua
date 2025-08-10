pr_event_bus = {
  listeners = {}
}

function pr_event_bus:on(eventName, callback)
  if not self.listeners[eventName] then
    self.listeners[eventName] = {}
  end
  table.insert(self.listeners[eventName], callback)
end

function pr_event_bus:emit(eventName, ...)
  local callbacks = self.listeners[eventName]
  if callbacks then
    for _, cb in ipairs(callbacks) do
      cb(...)
    end
  end
end
