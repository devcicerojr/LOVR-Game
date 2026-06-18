local scene_ecs = require('../core/pr_scene_ecs')
local loading_scene = {}

local ecs = nil

loading_scene.entities = {}

local render_systems = {}

local logic_systems = {}

local function build_level()
end

function loading_scene.unload()
	ecs = nil
end

function loading_scene.player_respawn()
end

function loading_scene.load()
	ecs = scene_ecs.new()
	scene_ecs.registerSystems(ecs, render_systems, logic_systems)
	build_level()
end

function loading_scene.update(dt)
	if not ecs then return end
	ecs:update(dt)
end

function loading_scene.draw(pass)
	if not ecs then return end
	ecs:draw(pass)
end

return loading_scene
