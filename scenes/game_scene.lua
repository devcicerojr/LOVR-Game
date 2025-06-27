local ecs = require'../core/pr_ecs'
local game_scene = {}
game_scene.entities = {}
game_scene.world = {}

-- constants
k_player_spawn_pos = { x = 0 , y = 0 , z = -3}

-- entities
local player = (require'../entities/pr_player')(ecs)
local skybox = (require'../entities/pr_skybox')(ecs)

-- systems
local skybox_render = (require'../systems/pr_skybox_render')
ecs:addSystem(skybox_render)

local simple_render = (require'../systems/pr_simple_render')
ecs:addSystem(simple_render)

local animation_render = (require'../systems/pr_animation_render')
ecs:addSystem(animation_render)

function game_scene.load()
	game_scene.world = lovr.physics.newWorld()
	ecs.entities[player].position = k_player_spawn_pos
	-- -- player.world = game_scene.world
	-- -- ground.setWorld(game_scene.world)
	-- table.insert(game_scene.entities, skybox)
	-- -- table.insert(game_scene.entities, ground)
	-- -- table.insert(game_scene.entities, player)
	-- for _, entity in ipairs(game_scene.entities) do
	-- 	if type(entity.init) == "function" then
	-- 		entity.init()
	-- 	end
	-- end
end

function game_scene.update(dt)
	-- for _, entity in ipairs(game_scene.entities) do
	-- 	if type(entity.update) == "function" then
	-- 		entity.update(dt)
	-- 	end
	-- end
	ecs:update(dt)
	game_scene.world:update(dt)
end

function game_scene.draw(pass)
	ecs:draw(pass)
	-- for _, entity in ipairs(game_scene.entities) do
	-- 	if type(entity.draw) == "function" then
	-- 		entity.draw(pass)
	-- 	end
	-- end
	-- print("FPS: " .. lovr.timer.getFPS())
end

return game_scene