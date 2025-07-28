local ecs = require'../core/pr_ecs'
local pr_utils = require'../core/pr_utils' 
local test_scene = {}

test_scene.entities = {}


function build_level()
end

local render_systems = {}


local logic_systems = {}


for _, file in ipairs(render_systems) do
	local system = require("../systems/render/pr_" .. file)
	ecs:addSystem(system)
end

for _, file in ipairs(logic_systems) do
	local system = require("../systems/logic/pr_" .. file)
	ecs:addSystem(system)
end

function test_scene.player_respawn()
end


function test_scene.load()
  build_level()
end

function test_scene.update(dt)
  ecs:update(dt)
end

function test_scene.draw(pass)
  ecs:draw(pass)
end

return test_scene
