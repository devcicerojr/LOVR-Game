local ECS = require('core/pr_ecs')

local scene_ecs = {}

function scene_ecs.new()
  return ECS.new()
end

function scene_ecs.registerSystems(ecs, render_systems, logic_systems, async_systems)
  for _, file in ipairs(render_systems or {}) do
    ecs:addSystem(require("../systems/render/pr_" .. file))
  end

  for _, file in ipairs(logic_systems or {}) do
    ecs:addSystem(require("../systems/logic/pr_" .. file))
  end

  for _, file in ipairs(async_systems or {}) do
    ecs:addSystem(require("../systems/logic/async/pr_" .. file))
  end
end

return scene_ecs
