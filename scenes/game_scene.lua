local ecs = require'../core/pr_ecs'
local lovr_world = require'../core/pr_world'
local game_scene = {}
game_scene.entities = {}

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

local collider_render = (require'../systems/pr_collider_render')
ecs:addSystem(collider_render)

function game_scene.load()
	ecs.entities[player].position = k_player_spawn_pos
end

function game_scene.update(dt)
	ecs:update(dt)
	lovr_world:update(dt)
end

function game_scene.draw(pass)
	ecs:draw(pass)
	-- print("FPS: " .. lovr.timer.getFPS())
end

return game_scene