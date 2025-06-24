package.path = package.path .. "; .\\..\\entities\\?.lua"
local ground  = require'ground'
local player = require'player'
local skybox = require'desert_skybox'
local game_scene = {}
game_scene.entities = {}
game_scene.world = {}

function game_scene.load()
	game_scene.world = lovr.physics.newWorld()
	player.world = game_scene.world
	ground.setWorld(game_scene.world)
	table.insert(game_scene.entities, skybox)
	table.insert(game_scene.entities, ground)
	table.insert(game_scene.entities, player)
	for _, entity in ipairs(game_scene.entities) do
		if type(entity.init) == "function" then
			entity.init()
		end
	end
	lovr.timer.step()
end

function game_scene.update(dt)
	game_scene.world:update(dt)
	for _, entity in ipairs(game_scene.entities) do
		if type(entity.update) == "function" then
			entity.update(dt)
		end
	end
end

function game_scene.draw(pass)
	for _, entity in ipairs(game_scene.entities) do
		if type(entity.draw) == "function" then
			entity.draw(pass)
		end
	end
end

return game_scene