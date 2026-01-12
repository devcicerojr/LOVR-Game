local ecs = require'../core/pr_ecs'
local pr_utils = require'../core/pr_utils'
local lovr_world = require'../core/pr_world'
local game_scene = {}
game_scene.entities = {}

local scene_resolution = {width = 1080 , height = 720}
local sampler = lovr.graphics.newSampler({filter = {'nearest', 'nearest', 'nearest'}})
local gTexture = lovr.graphics.newTexture(scene_resolution.width, scene_resolution.height)
local sTexture = lovr.graphics.newTexture(scene_resolution.width, scene_resolution.height, {format = 'd24s8'})
gTexture:setSampler(sampler)

local gpass = lovr.graphics.newPass(gTexture) --global pass
-- local gpass = lovr.graphics.newPass({gTexture, depth = {format = 'd24s8', texture = sTexture}}) --global pass





-- constants
local PLAYER_SPAWN_POS = lovr.math.newVec3(0, 2, 0)
local GROUND_TILE_WIDTH = 4
local GROUND_TILE_HEIGHT = 20
local WALL_HEIGHT = 5
local WALL_1_POS = lovr.math.vec3(0, WALL_HEIGHT / 2 , 0) -- default wall position
local WALL_2_POS = lovr.math.vec3(10, WALL_HEIGHT / 2, 0)
local WALL_3_POS = lovr.math.vec3(0, WALL_HEIGHT / 2, 40) -- mesh wall position

-- entities

local player = (require'../entities/pr_player')(ecs , PLAYER_SPAWN_POS)
-- local pole = (require'../entities/props/pr_pole')(ecs)
-- local ground = (require'../entities/pr_ground')(ecs)
-- local ground = (require'../entities/pr_heightmap_ground')(ecs, lovr.math.newVec3(1.0, 20.0, 1.0))
-- local asphalt_ground = (require'../entities/tiles/pr_asphalt_ground')(ecs)
-- local tile_grid = (require'../entities/pr_level_grid')(ecs, 8, 10)
-- local wall = (require'../entities/brushes/pr_wall')(ecs)
-- local wall2 = (require'../entities/brushes/pr_wall')(ecs, lovr.math.vec3(10, 0, 0))

function build_level()
	local skybox = (require'../entities/pr_skybox')(ecs)
	local tile_grid = (require'../entities/pr_level_grid')(ecs, GROUND_TILE_WIDTH, GROUND_TILE_HEIGHT)
	local collectable_blink = (require'../entities/dont_stop_delivery/pr_collectable_blink')(ecs)
	-- local sphere_collect = (require'../entities/dont_stop_delivery/pr_sphere_collectable')(ecs, vec3(0, 1, 15))
	-- local wall = (require'../entities/brushes/pr_wall')(ecs, WALL_1_POS)
	-- local wall2 = (require'../entities/brushes/pr_wall')(ecs, WALL_2_POS)
	-- local ch_wall = (require'../entities/brushes/pr_convex_hull_wall')(ecs, WALL_3_POS)
	-- local mesh_wall = (require'../entities/brushes/pr_mesh_wall')(ecs, WALL_3_POS)

	local side_walls_grid = (require'../entities/dont_stop_delivery/pr_side_walls_grid')(ecs)
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
	"brush_render_raw",
	"aabb_sensor_render",
	"textured_mesh_wall_render",
	"collectable_render",
	"collectable_blink_render",
	"car_obstacle_render"
}

local logic_systems = {
	"model_collider_track",
	-- "player_classic_tank_controls",
	-- "game_cam_handle",
	"game_cam_fixed_orientation",
	"animated_update",
	"gravity_applying",
	"k_gravity_collision_detect",

	-- "player_acc_dec_movement",
	-- "player_acc_dec_auto_movement",
	-- "player_acc_dec_all_dir_movement",
	"player_acc_dec_all_dir_movement_slide",
	
	"player_head_animation_blend",
	"dynamic_tile_spawner",
	"dynamic_wall_spawner",
	"game_cam_obstruction_logic",
	"collectable_update",
	"collectable_blink_update",
	"sphere_collectable_deleter",
	"car_obstacle_update"
}

local async_systems = {
	"spawn_collectables",
	"spawn_car_obstacles",
	"collectable_events"
}

for _, file in ipairs(render_systems) do
	local system = require("../systems/render/pr_" .. file)
	ecs:addSystem(system)
end

for _, file in ipairs(logic_systems) do
	local system = require("../systems/logic/pr_" .. file)
	-- if file == "dynamic_tile_spawner" or file == "dynamic_wall_spawner" then
	-- 	system.set_player_id(player)
	-- end
	ecs:addSystem(system)
end

for _, file in ipairs(async_systems) do
	local system = require("../systems/logic/async/pr_" .. file)
	ecs:addSystem(system)
end


-- TODO: move it to some async system event
function game_scene.player_respawn()
	local default_scale = {1, 1, 1}
	local default_rotation = lovr.math.quat(1, 0, 0, 0) -- no rotation
	-- ecs.entities[player].velocity.velocity:set(0, 0, 0) -- reset velocity
	ecs.entities[player].acc_dec_movement.curent_speed = lovr.math.newVec3(0, 0, 0)
	ecs.entities[player].transform.transform:set(PLAYER_SPAWN_POS.x, PLAYER_SPAWN_POS.y, PLAYER_SPAWN_POS.z, unpack(default_scale), 1, 0, 0, 0)

	-- If entity is non-kinematic, we cant modify its position by changing transform
	-- we must move the collider instead, and the entity itself will follow
	-- ecs.entities[player].transform.transform:translate(PLAYER_SPAWN_POS.x, PLAYER_SPAWN_POS.y, PLAYER_SPAWN_POS.z)
	-- ecs.entities[player].transform.transform:rotate(math.pi, 0, 1, 0)
	-- pr_utils.moved(player, lovr.math.vec3(0, 2, -3), lovr.math.quat(math.pi, 0, 1, 0)) -- this is needed because it handles kinematic/non-kinematic  positioning
end

function game_scene.load()
	-- spawning player
	-- ecs.entities[player].animation_state.current = 0 --idle animation
	build_level()
	
end

function game_scene.update(dt)
	ecs:update(dt)
	ecs:deleteDeadEntities()
end

function game_scene.draw(dpass)
	-- Shader configurations
	gpass:reset()
	gpass:setSampler('nearest')
	gpass:setShader(environment_shader.shader)
	environment_shader.setDefaultVals(gpass)

	gpass:setViewPose(1 ,  dpass:getViewPose(1, mat4()))
	gpass:setProjection(1, dpass:getProjection(1, mat4()))

	ecs:draw(gpass)
	-- print("FPS: " .. lovr.timer.getFPS())
	local pass = dpass
	pass:setSampler('nearest')
	pass:fill(gTexture)
	return lovr.graphics.submit(gpass, dpass)
end

return game_scene