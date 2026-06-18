local scene_ecs = require('../core/pr_scene_ecs')
local test_scene = {}

local ecs = nil

test_scene.entities = {}

local render_systems = {}

local logic_systems = {}

local function build_level()
end

function test_scene.unload()
	ecs = nil
end

function test_scene.player_respawn()
end

function test_scene.load()
	ecs = scene_ecs.new()
	scene_ecs.registerSystems(ecs, render_systems, logic_systems)
	build_level()
end

function test_scene.update(dt)
	if not ecs then return end
	ecs:update(dt)
end

function test_scene.draw(pass)
	if not ecs then return end
	ecs:draw(pass)
end

return test_scene
