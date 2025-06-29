local ecs = require'../core/pr_ecs'
local lovr_world = require'../core/pr_world'
local game_scene = {}
game_scene.entities = {}

-- constants
k_player_spawn_pos = { x = 0 , y = 0 , z = -3}

-- entities

local player = (require'../entities/pr_player')(ecs)
local skybox = (require'../entities/pr_skybox')(ecs)
local ground = (require'../entities/pr_ground')(ecs)

local render_systems = {
	"skybox_render",
	"simple_render",
	"animation_render",
	"collider_render",
	"terrain_render"
}

local logic_systems = {
	"model_collider_track"
}

for _, file in ipairs(render_systems) do
	local system = require("../systems/pr_" .. file)
	ecs:addSystem(system)
end

for _, file in ipairs(logic_systems) do
	local system = require("../systems/logic/pr_" .. file)
	ecs:addSystem(system)
end

function game_scene.load()
	ecs.entities[player].position = k_player_spawn_pos
end

function game_scene.update(dt)
	lovr_world:update(dt)
	ecs:update(dt)
end

function game_scene.draw(pass)
	ecs:draw(pass)
	-- print("FPS: " .. lovr.timer.getFPS())
end

return game_scene