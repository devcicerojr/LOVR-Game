local ecs = require'../core/pr_ecs'
local pr_utils = require'../core/pr_utils'
local game_scene = {}
game_scene.entities = {}

-- constants
local k_player_spawn_pos = lovr.math.newVec3(0, 20, 0)

-- entities

local player = (require'../entities/pr_player')(ecs)
local skybox = (require'../entities/pr_skybox')(ecs)
-- local pole = (require'../entities/props/pr_pole')(ecs)
-- local ground = (require'../entities/pr_ground')(ecs)
local ground = (require'../entities/pr_heightmap_ground')(ecs, lovr.math.newVec3(1.0, 20.0, 1.0))
-- local asphalt_ground = (require'../entities/tiles/pr_asphalt_ground')(ecs)
-- local tile_grid = (require'../entities/pr_level_grid')(ecs, 8, 10)

local render_systems = {
	"skybox_render",
	"simple_render",
	"model_with_collider_render",
	"model_animated_with_collider_render",
	"collider_render",
	"terrain_render",
	"ray_sensor_render",
	"textured_mesh_render"
}

local logic_systems = {
	"model_collider_track",
	"player_classic_tank_controls",
	"game_cam_handle",
	"animated_update",
	"gravity_applying",
	"k_gravity_collision_detect",
	"player_acc_dec_movement",
	"player_head_animation_blend",
}

for _, file in ipairs(render_systems) do
	local system = require("../systems/render/pr_" .. file)
	ecs:addSystem(system)
end

for _, file in ipairs(logic_systems) do
	local system = require("../systems/logic/pr_" .. file)
	ecs:addSystem(system)
end

function game_scene.player_respawn()
	ecs.entities[player].transform.transform:set(k_player_spawn_pos.x, k_player_spawn_pos.y, k_player_spawn_pos.z, 1, 1, 1, 1, 0, 0, 0)
end

function game_scene.load()
	-- spawning player
	ecs.entities[player].animation_state.current = 0 --idle animation
	

	-- If entity is non-kinematic, we cant modify its position by changing transform
	-- we must move the collider instead, and the entity itself will follow
	ecs.entities[player].transform.transform:translate(k_player_spawn_pos.x, k_player_spawn_pos.y, k_player_spawn_pos.z)
	-- ecs.entities[player].transform.transform:rotate(k_pi, 0, 1, 0)
	pr_utils.moved(player, lovr.math.vec3(0, 2, -3), lovr.math.quat(k_pi, 0, 1, 0)) -- this is needed because it handles kinematic/non-kinematic  positioning

end

function game_scene.update(dt)
	ecs:update(dt)
end

function game_scene.draw(pass)
	ecs:draw(pass)
	print("FPS: " .. lovr.timer.getFPS())
end

return game_scene