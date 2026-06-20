local scene_ecs = require('../core/pr_scene_ecs')
local lovr_world = require'../core/pr_world'
local game_scene = {}

local ecs        = nil
local player     = nil
local coin_count = 0
local hidden_cursor   = nil
local flying_coins    = {}
local scene_view_pose = lovr.math.newMat4()
local scene_proj_mat  = lovr.math.newMat4()

game_scene.is_paused               = false
game_scene.return_to_title_requested = false

local pause_menu_index = 1
local prev_dpad_up     = false
local prev_dpad_down   = false

local PAUSE_MENU_ITEMS = { "Resume", "Return to Title" }

local scene_resolution = {width = 1080 , height = 720}
local sampler = lovr.graphics.newSampler({filter = {'nearest', 'nearest', 'nearest'}})
local gTexture = lovr.graphics.newTexture(scene_resolution.width, scene_resolution.height)
local sTexture = lovr.graphics.newTexture(scene_resolution.width, scene_resolution.height, {format = 'd24s8'})
gTexture:setSampler(sampler)

local gpass = lovr.graphics.newPass(gTexture) --global pass
-- local gpass = lovr.graphics.newPass({gTexture, depth = {format = 'd24s8', texture = sTexture}}) --global pass


-- constants
local PLAYER_SPAWN_POS  = lovr.math.newVec3(0, 2, 0)
local COIN_FLY_DURATION = 0.55
local COIN_ICON_SIZE    = 14
local GROUND_TILE_WIDTH = 4
local GROUND_TILE_HEIGHT = 20
local WALL_HEIGHT = 5
local WALL_1_POS = lovr.math.vec3(0, WALL_HEIGHT / 2 , 0) -- default wall position
local WALL_2_POS = lovr.math.vec3(10, WALL_HEIGHT / 2, 0)
local WALL_3_POS = lovr.math.vec3(0, WALL_HEIGHT / 2, 40) -- mesh wall position

local render_systems = {
	"skybox_render",
	"simple_render",
	-- "model_with_collider_render",
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
	"car_obstacle_render",
	"dust_particles_render",
	"blob_shadow_render"  -- must be last: blends over all opaque geometry
}

local logic_systems = {
	-- "player_classic_tank_controls",
	-- "game_cam_handle",
	"animated_update",
	"gravity_applying",
	"k_gravity_collision_detect",

	-- "player_acc_dec_movement",
	-- "player_acc_dec_auto_movement",
	-- "player_acc_dec_all_dir_movement",
	"player_acc_dec_all_dir_movement_slide",
	"car_obstacle_update",

	-- Runs after all movement so the collider reflects the current frame's transform.
	"model_collider_track",

	-- Camera runs after movement so it follows the frame-N position,
	-- matching the render system which also reads frame-N transform.
	"game_cam_fixed_orientation",

	"player_head_animation_blend",
	"dynamic_tile_spawner",
	"dynamic_wall_spawner",
	"dynamic_scenario_spawner",
	"game_cam_obstruction_logic",
	"collectable_update",
	"collectable_blink_update",
	"sphere_collectable_deleter",
}

local async_systems = {
	"spawn_pattern",
	"collectable_events"
}

local function build_level()
	player = (require'../entities/pr_player')(ecs , PLAYER_SPAWN_POS)
	local skybox = (require'../entities/pr_skybox')(ecs)
	local tile_grid = (require'../entities/pr_level_grid')(ecs, GROUND_TILE_WIDTH, GROUND_TILE_HEIGHT)
	local collectable_blink = (require'../entities/dont_stop_delivery/pr_collectable_blink')(ecs)
	local side_walls_grid = (require'../entities/dont_stop_delivery/pr_side_walls_grid')(ecs)
	local side_scenario_grid = (require'../entities/dont_stop_delivery/pr_side_scenario_grid')(ecs)
end

function game_scene.unload()
	pr_event_bus:emit('game_scene_unloaded')
	ecs = nil
	player = nil
	game_scene.is_paused = false
	flying_coins = {}
	lovr.mouse.setCursor(nil)
	hidden_cursor = nil
end

-- TODO: move it to some async system event
function game_scene.player_respawn()
	if not ecs or not player then return end

	coin_count = 0
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

local function worldToHUD(wx, wy, wz)
	local W, H = scene_resolution.width, scene_resolution.height
	local view = mat4(scene_view_pose):invert()
	local vp   = mat4(scene_proj_mat) * view
	local m    = { vp:unpack(true) }
	local rx   = m[1]*wx + m[5]*wy + m[9]*wz  + m[13]
	local ry   = m[2]*wx + m[6]*wy + m[10]*wz + m[14]
	local rw   = m[4]*wx + m[8]*wy + m[12]*wz + m[16]
	if rw <= 0 then return nil end
	return ((rx/rw) + 1) * 0.5 * W,
	       ((ry/rw) + 1) * 0.5 * H
end

local function drawPauseOverlay(pass)
	local W, H = scene_resolution.width, scene_resolution.height
	pass:setBlendMode('alpha', 'alphamultiply')
	pass:setColor(0, 0, 0, 0.65)
	pass:plane(W / 2, H / 2, 0, W, H)
	pass:setBlendMode('none')

	pass:setColor(1, 1, 1, 1)
	pass:text("Game Paused", W / 2, H * 0.30, 0, 64)

	local item_y = { H * 0.50, H * 0.58 }
	for i, item in ipairs(PAUSE_MENU_ITEMS) do
		if i == pause_menu_index then
			pass:setColor(1, 0.85, 0.1, 1)
		else
			pass:setColor(0.55, 0.55, 0.55, 1)
		end
		pass:text(item, W / 2, item_y[i], 0, 44)
	end

	pass:setColor(1, 1, 1, 1)
end

local function drawHUD(pass)
	local W, H = scene_resolution.width, scene_resolution.height
	pass:setShader()
	pass:setDepthTest()
	pass:setViewPose(1, lovr.math.mat4())
	pass:setProjection(1, lovr.math.mat4():orthographic(0, W, 0, H, -1, 1))
	pass:setColor(1, 0.9, 0.1)
	pass:text('Coins: ' .. tostring(coin_count), 60, 54, 0, 40)

	local win_w, win_h = lovr.system.getWindowDimensions()
	local mx, my = lovr.system.getMousePosition()
	local cx = mx * (W / win_w)
	local cy = my * (H / win_h)
	local size, gap = 14, 5
	pass:setColor(1, 1, 1, 0.9)
	pass:line(cx - size, cy, 0,  cx - gap, cy, 0)
	pass:line(cx + gap,  cy, 0,  cx + size, cy, 0)
	pass:line(cx, cy - size, 0,  cx, cy - gap, 0)
	pass:line(cx, cy + gap,  0,  cx, cy + size, 0)

	-- Flying coin animations (DKC-style collect effect)
	local target_x = 60
	local target_y = 54
	local dt_hud = lovr.timer.getDelta()
	pass:setBlendMode('alpha', 'alphamultiply')
	local fi = 1
	while fi <= #flying_coins do
		local fc   = flying_coins[fi]
		fc.t       = math.min(fc.t + dt_hud, COIN_FLY_DURATION)
		local p    = fc.t / COIN_FLY_DURATION
		local ease = 1 - (1 - p) ^ 3
		local inv  = 1 - ease
		local ctrl_x = (fc.sx + target_x) * 0.5
		local ctrl_y = (fc.sy + target_y) * 0.5 + 90
		local bx = inv*inv*fc.sx + 2*inv*ease*ctrl_x + ease*ease*target_x
		local by = inv*inv*fc.sy + 2*inv*ease*ctrl_y + ease*ease*target_y
		local icon  = COIN_ICON_SIZE * (1 - ease * 0.6)
		local alpha = p > 0.8 and (1 - p) / 0.2 or 1
		pass:setColor(1, 0.85, 0.1, alpha)
		pass:plane(bx, by, 0, icon, icon)
		if p >= 1 then
			coin_count = coin_count + 1
			table.remove(flying_coins, fi)
		else
			fi = fi + 1
		end
	end
	pass:setBlendMode('none')
	pass:setColor(1, 1, 1)
end

function game_scene.load()
	coin_count   = 0
	flying_coins = {}
	local img = lovr.data.newImage(1, 1)
	hidden_cursor = lovr.mouse.newCursor(img, 0, 0)
	lovr.mouse.setCursor(hidden_cursor)
	game_scene.is_paused               = false
	game_scene.return_to_title_requested = false
	pause_menu_index = 1
	game_anim_time   = 0
	pr_event_bus:on('coin_collected', function(ecs, id)
		local entity = ecs.entities[id]
		if entity and entity.transform then
			local wx, wy, wz = entity.transform.transform:getPosition()
			local sx, sy = worldToHUD(wx, wy, wz)
			if sx and sy then
				table.insert(flying_coins, { sx=sx, sy=sy, t=0 })
				return
			end
		end
		coin_count = coin_count + 1
	end)
	ecs = scene_ecs.new()
	scene_ecs.registerSystems(ecs, render_systems, logic_systems, async_systems)
	build_level()
end

local MAX_DT = 1 / 30  -- cap at 30 fps equivalent to prevent position spikes from frame stalls

function game_scene.update(dt)
	if not ecs then return end

	if not game_scene.is_paused then
		if pr_control.enter_pressed or pr_control.gc_btn_8_just_pressed then
			game_scene.is_paused = true
			pause_menu_index     = 1
			prev_dpad_up         = false
			prev_dpad_down       = false
			pr_control.enter_pressed = false
			pr_event_bus:emit('game_paused_changed', ecs, true)
		end
	else
		local dpad_up_just   = pr_control.gc_dpad_up   and not prev_dpad_up
		local dpad_down_just = pr_control.gc_dpad_down  and not prev_dpad_down
		prev_dpad_up   = pr_control.gc_dpad_up
		prev_dpad_down = pr_control.gc_dpad_down

		if dpad_up_just then
			pause_menu_index = 1 + (pause_menu_index) % #PAUSE_MENU_ITEMS
		end
		if dpad_down_just then
			pause_menu_index = 1 + (pause_menu_index) % #PAUSE_MENU_ITEMS
		end
		print("pause_menu_index: " .. pause_menu_index)

		local confirm = pr_control.enter_pressed or pr_control.space_pressed
		                or pr_control.gc_btn_1_just_pressed or pr_control.gc_btn_8_just_pressed
		if confirm then
			pr_control.enter_pressed = false
			pr_control.space_pressed = false
			pr_control.gc_btn_1_just_pressed = false
			pr_control.gc_btn_8_just_pressed = false
			if pause_menu_index == 1 then
				game_scene.is_paused = false
				pr_event_bus:emit('game_paused_changed', ecs, false)
			elseif pause_menu_index == 2 then
				game_scene.return_to_title_requested = true
			end
		end
	end

	if game_scene.is_paused then return end

	game_anim_time = game_anim_time + math.min(dt, MAX_DT)
	ecs:update(math.min(dt, MAX_DT))
	ecs:deleteDeadEntities()
end

function game_scene.draw(dpass)
	if not ecs then return end

	-- Shader configurations
	gpass:reset()
	gpass:setSampler('nearest')
	gpass:setShader(environment_shader.shader)
	environment_shader.setDefaultVals(gpass)

	dpass:getViewPose(1, scene_view_pose)
	dpass:getProjection(1, scene_proj_mat)
	gpass:setViewPose(1 ,  scene_view_pose)
	gpass:setProjection(1, scene_proj_mat)

	ecs:draw(gpass)
	-- print("FPS: " .. lovr.timer.getFPS())
	-- local pass = dpass

	dpass:setSampler('nearest')
	dpass:fill(gTexture)
	drawHUD(dpass)
	if game_scene.is_paused then
		drawPauseOverlay(dpass)
	end
	return lovr.graphics.submit(gpass, dpass)
end

return game_scene
