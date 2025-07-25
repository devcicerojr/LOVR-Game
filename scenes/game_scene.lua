local ecs = require'../core/pr_ecs'
local pr_utils = require'../core/pr_utils'
local game_scene = {}
game_scene.entities = {}

-- constants
local PLAYER_SPAWN_POS = lovr.math.newVec3(0, 20, 0)
local GROUND_TILE_WIDTH = 8
local GROUND_TILE_HEIGHT = 10
local WALL_HEIGHT = 5
local WALL_1_POS = lovr.math.vec3(0, WALL_HEIGHT / 2 , 0) -- default wall position
local WALL_2_POS = lovr.math.vec3(10, WALL_HEIGHT / 2, 0)

-- entities

local player = (require'../entities/pr_player')(ecs)
-- local skybox = (require'../entities/pr_skybox')(ecs)
-- local pole = (require'../entities/props/pr_pole')(ecs)
-- local ground = (require'../entities/pr_ground')(ecs)
-- local ground = (require'../entities/pr_heightmap_ground')(ecs, lovr.math.newVec3(1.0, 20.0, 1.0))
-- local asphalt_ground = (require'../entities/tiles/pr_asphalt_ground')(ecs)
-- local tile_grid = (require'../entities/pr_level_grid')(ecs, 8, 10)
-- local wall = (require'../entities/brushes/pr_wall')(ecs)
-- local wall2 = (require'../entities/brushes/pr_wall')(ecs, lovr.math.vec3(10, 0, 0))

function build_level()
	local tile_grid = (require'../entities/pr_level_grid')(ecs, GROUND_TILE_WIDTH, GROUND_TILE_HEIGHT)
	local wall = (require'../entities/brushes/pr_wall')(ecs, WALL_1_POS)
	local wall2 = (require'../entities/brushes/pr_wall')(ecs, WALL_2_POS)
end
	


local render_systems = {
	"skybox_render",
	"simple_render",
	"model_with_collider_render",
	"model_animated_with_collider_render",
	"collider_render",
	"terrain_render",
	"ray_sensor_render",
	"textured_mesh_render",
	"brush_render",
	"aabb_sensor_render"
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
	local default_scale = {1, 1, 1}
	local default_rotation = lovr.math.quat(1, 0, 0, 0) -- no rotation
	-- ecs.entities[player].velocity.velocity:set(0, 0, 0) -- reset velocity
	ecs.entities[player].transform.transform:set(PLAYER_SPAWN_POS.x, PLAYER_SPAWN_POS.y, PLAYER_SPAWN_POS.z, unpack(default_scale), default_rotation:unpack())
	-- If entity is non-kinematic, we cant modify its position by changing transform
	-- we must move the collider instead, and the entity itself will follow
	-- ecs.entities[player].transform.transform:translate(PLAYER_SPAWN_POS.x, PLAYER_SPAWN_POS.y, PLAYER_SPAWN_POS.z)
	-- ecs.entities[player].transform.transform:rotate(k_pi, 0, 1, 0)
	-- pr_utils.moved(player, lovr.math.vec3(0, 2, -3), lovr.math.quat(k_pi, 0, 1, 0)) -- this is needed because it handles kinematic/non-kinematic  positioning
end

function game_scene.load()
	-- spawning player
	-- ecs.entities[player].animation_state.current = 0 --idle animation
	
	build_level()
end

function game_scene.update(dt)
	ecs:update(dt)
end

function game_scene.draw(pass)
	ecs:draw(pass)
	-- print("FPS: " .. lovr.timer.getFPS())
end

return game_scene