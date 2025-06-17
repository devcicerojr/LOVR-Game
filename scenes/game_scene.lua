package.path = package.path .. " .\\..\\entities\\?.lua"
local ground  = require'ground'
local player = require'player'
local game_scene = {}
game_scene.entities = {}

function game_scene.load()
	print(package.path)
	table.insert(game_scene.entities, ground)
	table.insert(game_scene.entities, player)
	for _, entity in ipairs(game_scene.entities) do
		if type(entity.init) == "function" then
			entity.init()
		end
	end
end

function game_scene.update(dt)
	for _, entity in ipairs(game_scene.entities) do
		if type(entity.update) == "function" then
			entity.update(dt)
		end
	end
end

function game_scene.draw()
	for _, entity in ipairs(game_scene.entities) do
		if type(entity.draw) == "function" then
			entity.draw()
		end
	end
end

return game_scene