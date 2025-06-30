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
	"model_with_collider_render",
	"model_animated_with_collider_render",
	"collider_render",
	"terrain_render"
}

local logic_systems = {
	"model_collider_track",
	"animated_update"
}

for _, file in ipairs(render_systems) do
	local system = require("../systems/render/pr_" .. file)
	ecs:addSystem(system)
end

for _, file in ipairs(logic_systems) do
	local system = require("../systems/logic/pr_" .. file)
	ecs:addSystem(system)
end

function game_scene.load()
	-- spawning player
	ecs.entities[player].animation_state.current = 0 --idle animation
	

	-- If entity is non-kinematic, we cant modify its position by changing transform
	-- we must move the collider instead, and the entity itself will follow
	ecs.entities[player].transform.transform:translate(0, 2, -3)
	ecs.entities[player].transform.transform:rotate(k_pi, 0, 1, 0)
	local collider =  ecs.entities[player].collider.collider
	collider:setKinematic(true)
	local collider_position = lovr.math.newVec3(collider:getPosition())
	local collider_orientation = lovr.math.newQuat(collider:getOrientation())
	collider_position:add(0, 2, -3)
	collider_orientation:mul(k_pi, 0, 1, 0)
	collider:setPose(lovr.math.vec3(collider_position:unpack()), lovr.math.quat(collider_orientation:unpack()))
	collider:setKinematic(false)
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