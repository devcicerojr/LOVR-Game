local scene_ecs = require('../core/pr_scene_ecs')
local lovr_world = require'../core/pr_world'
local game_scene = {}

local ecs        = nil
local player     = nil
local coin_count = 0
local hidden_cursor   = nil
local flying_coins    = {}
local laser_beam      = nil
local sparks          = {}
local mouse_was_down  = false
local shoot_sfx       = nil
local skate_sfx       = nil
local skate_hit_sfx   = nil
local prev_grounded   = false
local prev_on_ramp    = false
local prev_is_jumping = false
local prev_player_x   = nil
local scene_view_pose = lovr.math.newMat4()
local scene_proj_mat  = lovr.math.newMat4()

game_scene.is_paused               = false
game_scene.return_to_title_requested = false

local pause_menu_index    = 1
local prev_dpad_up        = false
local prev_dpad_down      = false
local prev_w              = false
local prev_s              = false
local crosshair_y_frac     = 0.30   -- vertical position as fraction of H; driven by right stick
local confirm_dialog_open  = false
local confirm_dialog_index = 1   -- 1 = No (default), 2 = Yes
local enemies_defeated     = 0
local ENEMIES_TO_DEFEAT    = 20
local victory_dialog_open  = false
local prev_dpad_left      = false
local prev_dpad_right     = false
local prev_a              = false
local prev_d              = false

local PAUSE_MENU_ITEMS = { "Resume", "Toggle Full Screen", "Return to Title" }

local scene_resolution = {width = 1920 , height = 1080}
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
local LASER_DURATION    = 0.12
local LASER_RANGE       = 200
local SPARK_COUNT       = 18
local SPARK_SPEED       = 9
local SPARK_LIFETIME    = 0.45
local SPARK_GRAVITY          = 14
local CROSSHAIR_Y_SPEED      = 0.25   -- fraction of H per second
local CROSSHAIR_Y_MIN        = 0.30
local CROSSHAIR_Y_MAX        = 0.40
local CROSSHAIR_STICK_DEAD   = 0.12
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
	"ramp_render",
	"enemy_1_render",
	-- "dust_particles_render",
	"enemy_1_shadow_render",
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
	"enemy_1_update",
	"ramp_update",

	-- Runs after all movement so the collider reflects the current frame's transform.
	"model_collider_track",

	-- Camera runs after movement so it follows the frame-N position,
	-- matching the render system which also reads frame-N transform.
	"game_cam_fixed_orientation",

	"player_head_animation_blend",
	"player_body_animation_blend",
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
	"collectable_events",
	"spawn_enemy_1"
}

local function build_level()
	player = (require'../entities/pr_player')(ecs , PLAYER_SPAWN_POS)
	local skybox = (require'../entities/pr_skybox')(ecs)
	local tile_grid = (require'../entities/pr_level_grid')(ecs, GROUND_TILE_WIDTH, GROUND_TILE_HEIGHT)
	local collectable_blink = (require'../entities/dont_stop_delivery/pr_collectable_blink')(ecs)
	local side_walls_grid = (require'../entities/dont_stop_delivery/pr_side_walls_grid')(ecs)
	local side_scenario_grid = (require'../entities/dont_stop_delivery/pr_side_scenario_grid')(ecs)
end

local function stopAllSounds()
	if skate_sfx     then skate_sfx:stop()     end
	if shoot_sfx     then shoot_sfx:stop()     end
	if skate_hit_sfx then skate_hit_sfx:stop() end
	if ecs then
		for _, entity in pairs(ecs.entities) do
			if entity.audio_source and entity.audio_source.source then
				entity.audio_source.source:stop()
			end
		end
	end
end

function game_scene.unload()
	pr_event_bus:emit('game_scene_unloaded')
	if ecs then
		for _, entity in pairs(ecs.entities) do
			if entity.collider and entity.collider.collider then
				local col = entity.collider.collider
				if not col:isDestroyed() then col:destroy() end
			end
		end
	end
	ecs = nil
	player = nil
	game_scene.is_paused = false
	enemies_defeated     = 0
	victory_dialog_open  = false
	flying_coins = {}
	laser_beam   = nil
	sparks       = {}
	stopAllSounds()
	shoot_sfx     = nil
	skate_sfx     = nil
	skate_hit_sfx = nil
	lovr.mouse.setCursor(nil)
	hidden_cursor = nil
end

pr_event_bus:on('enemy_1_defeated', function()
	enemies_defeated = enemies_defeated + 1
	if enemies_defeated >= ENEMIES_TO_DEFEAT then
		victory_dialog_open = true
		stopAllSounds()
	end
end)

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

-- Returns the crosshair position in HUD coordinates.
-- X offsets based on player world-X so that positive X (move left) shifts right on screen.
-- Offset is capped at the screen position that corresponds to a 45-degree horizontal ray,
-- derived from proj[0][0] = 1/(aspect*tan(fov/2)); at 45° tan=1, so ndcX_max = proj[0][0].
local function get_crosshair_pos()
	local W, H = scene_resolution.width, scene_resolution.height
	if not ecs or not player or not ecs.entities[player] then
		return W * 0.5, H * crosshair_y_frac
	end
	local px      = select(1, ecs.entities[player].transform.transform:getPosition())
	local proj_m  = { scene_proj_mat:unpack(true) }
	local proj00  = proj_m[1]                        -- horizontal projection scale
	local ndcX    = (px / 80) * proj00               -- proj00 == ndc at 45°
	return W * 0.5 + W * 0.5 * ndcX, H * crosshair_y_frac
end

-- Converts the crosshair position to a world-space ray (origin + direction).
-- Uses the same VP matrix as worldToHUD, so NDC mapping is consistent.
local function cursorToWorldRay()
	local W, H    = scene_resolution.width, scene_resolution.height
	local cx, cy  = get_crosshair_pos()
	local ndcX    = (cx / W) * 2 - 1
	local ndcY    = (cy / H) * 2 - 1
	local view   = mat4(scene_view_pose):invert()
	local vp     = mat4(scene_proj_mat) * view
	local inv_vp = mat4(vp):invert()
	local m      = { inv_vp:unpack(true) }
	local function unproject(zndc)
		local rx = m[1]*ndcX + m[5]*ndcY + m[9]*zndc  + m[13]
		local ry = m[2]*ndcX + m[6]*ndcY + m[10]*zndc + m[14]
		local rz = m[3]*ndcX + m[7]*ndcY + m[11]*zndc + m[15]
		local rw = m[4]*ndcX + m[8]*ndcY + m[12]*zndc + m[16]
		if math.abs(rw) < 1e-6 then return nil end
		return rx/rw, ry/rw, rz/rw
	end
	local nx, ny, nz = unproject(-1)
	local fx, fy, fz = unproject(1)
	if not nx or not fx then return nil end
	local dx, dy, dz = fx-nx, fy-ny, fz-nz
	local len = math.sqrt(dx*dx + dy*dy + dz*dz)
	if len < 1e-6 then return nil end
	return nx, ny, nz, dx/len, dy/len, dz/len
end

local function drawPauseOverlay(pass)
	local W, H = scene_resolution.width, scene_resolution.height
	pass:setBlendMode('alpha', 'alphamultiply')
	pass:setColor(0, 0, 0, 0.65)
	pass:plane(W / 2, H / 2, 0, W, H)
	pass:setBlendMode('none')

	pass:setColor(1, 1, 1, 1)
	pass:text("Game Paused", W / 2, H * 0.30, 0, 64)

	local item_y = { H * 0.46, H * 0.54, H * 0.62 }
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

local function drawConfirmDialog(pass)
	local W, H = scene_resolution.width, scene_resolution.height
	pass:setColor(0, 0, 0, 1)
	pass:plane(W / 2, H / 2, 0, W * 0.62, H * 0.30)

	pass:setColor(1, 1, 1, 1)
	pass:text("Are you sure you want to return to title screen?", W / 2, H * 0.44, 0, 34)

	local btn_labels = { "No", "Yes" }
	local btn_x      = { W * 0.38, W * 0.62 }
	for i, label in ipairs(btn_labels) do
		if i == confirm_dialog_index then
			pass:setColor(0.95, 0.75, 0.1, 1)
		else
			pass:setColor(0.55, 0.55, 0.55, 1)
		end
		pass:text(label, btn_x[i], H * 0.56, 0, 44)
	end

	pass:setColor(1, 1, 1, 1)
end

local function drawVictoryDialog(pass)
	local W, H = scene_resolution.width, scene_resolution.height
	pass:setBlendMode('alpha', 'alphamultiply')
	pass:setColor(0, 0, 0, 0.78)
	pass:plane(W / 2, H / 2, 0, W, H)
	pass:setBlendMode('none')

	pass:setColor(1, 1, 1, 1)
	pass:text("All Enemies Defeated!", W / 2, H * 0.40, 0, 72)

	pass:setColor(0.95, 0.75, 0.1, 1)
	pass:text("Return to Title", W / 2, H * 0.58, 0, 48)

	pass:setColor(1, 1, 1, 1)
end

local function drawHUD(pass)
	local W, H = scene_resolution.width, scene_resolution.height
	pass:setShader()
	pass:setDepthTest()
	pass:setViewPose(1, lovr.math.mat4())
	pass:setProjection(1, lovr.math.mat4():orthographic(0, W, 0, H, -1, 1))
	pass:setColor(1, 0.9, 0.1)
	pass:text('Coins: ' .. tostring(coin_count), 60, 54, 0, 40, 0, 1, 0, 0, 0, 'left', 'middle')

	pass:setColor(1, 1, 1, 1)
	pass:text(tostring(enemies_defeated) .. '/' .. tostring(ENEMIES_TO_DEFEAT),
		W - 60, 54, 0, 40, 0, 1, 0, 0, 0, 'right', 'middle')

	local cx, cy = get_crosshair_pos()
	pass:setColor(1, 1, 1, 0.3)
	pass:circle(cx, cy, 0, 8, 0, 0, 0, 1, 'line')

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

	-- Enemy health bars projected from world space to HUD coordinates
	if ecs then
		local BAR_W   = 120
		local BAR_H   = 12
		local BORDER  = 2
		local RADIUS  = 1.0

		for _, entity in pairs(ecs.entities) do
			if entity.is_enemy_1 and entity.transform and entity.health
			   and entity.health.hit_display_timer > 0 then
				local ex, ey, ez = entity.transform.transform:getPosition()
				local sx, sy     = worldToHUD(ex, ey + RADIUS + 0.6, ez)

				if sx and sy then
					local ratio   = math.max(0, math.min(1, entity.health.current / entity.health.max))
					local fill_w  = BAR_W * ratio
					local r       = math.min(1.0, 2.0 * (1.0 - ratio))
					local g       = math.min(1.0, 2.0 * ratio)

					pass:setColor(0.1, 0.1, 0.1, 1)
					pass:plane(sx, sy, 0, BAR_W + BORDER * 2, BAR_H + BORDER * 2)

					if fill_w > 0 then
						pass:setColor(r, g, 0.0, 1)
						pass:plane(sx - (BAR_W - fill_w) * 0.5, sy, 0, fill_w, BAR_H)
					end
				end
			end
		end
	end

	pass:setColor(1, 1, 1)
end

function game_scene.load()
	coin_count   = 0
	flying_coins = {}
	laser_beam   = nil
	sparks       = {}
	local img = lovr.data.newImage(1, 1)
	hidden_cursor = lovr.mouse.newCursor(img, 0, 0)
	lovr.mouse.setCursor(hidden_cursor)
	shoot_sfx = lovr.audio.newSource('assets/sound_fx/shootok.wav', { decode = true })
	skate_sfx     = lovr.audio.newSource('assets/sound_fx/skatey.wav', { decode = true, loop = true, pitchable = true })
	skate_hit_sfx = lovr.audio.newSource('assets/sound_fx/skate_hit.wav', { decode = true })
	skate_hit_sfx:setPitch(1.5)
	prev_grounded   = false
	prev_on_ramp    = false
	prev_is_jumping = false
	prev_player_x   = nil
	skate_sfx:setPitch(1.4)
	skate_sfx:setVolume(0.3)
	game_scene.is_paused               = false
	game_scene.return_to_title_requested = false
	crosshair_y_frac    = 0.34
	pause_menu_index    = 1
	confirm_dialog_open  = false
	confirm_dialog_index = 1
	enemies_defeated     = 0
	victory_dialog_open  = false
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

	if victory_dialog_open then
		local confirm = pr_control.enter_pressed or pr_control.space_pressed
		                or pr_control.gc_btn_1_just_pressed or pr_control.gc_btn_8_just_pressed
		if confirm then
			pr_control.enter_pressed         = false
			pr_control.space_pressed         = false
			pr_control.gc_btn_1_just_pressed = false
			pr_control.gc_btn_8_just_pressed = false
			game_scene.return_to_title_requested = true
		end
		return
	end

	if not game_scene.is_paused then
		if pr_control.enter_pressed or pr_control.escape_pressed or pr_control.gc_btn_8_just_pressed then
			game_scene.is_paused = true
			if skate_sfx then skate_sfx:stop() end
			pause_menu_index     = 1
			prev_dpad_up         = false
			prev_dpad_down       = false
			prev_w               = false
			prev_s               = false
			pr_control.enter_pressed  = false
			pr_control.escape_pressed = false
			pr_event_bus:emit('game_paused_changed', ecs, true)
		end
	elseif confirm_dialog_open then
		local dpad_left_just  = pr_control.gc_dpad_left  and not prev_dpad_left
		local dpad_right_just = pr_control.gc_dpad_right and not prev_dpad_right
		prev_dpad_left  = pr_control.gc_dpad_left
		prev_dpad_right = pr_control.gc_dpad_right

		local a_just = pr_control.a_pressed and not prev_a
		local d_just = pr_control.d_pressed and not prev_d
		prev_a = pr_control.a_pressed
		prev_d = pr_control.d_pressed

		if dpad_left_just or dpad_right_just or a_just or d_just then
			confirm_dialog_index = 3 - confirm_dialog_index  -- toggles between 1 and 2
		end

		local confirm = pr_control.enter_pressed or pr_control.space_pressed
		                or pr_control.gc_btn_1_just_pressed or pr_control.gc_btn_8_just_pressed
		if confirm then
			pr_control.enter_pressed         = false
			pr_control.space_pressed         = false
			pr_control.gc_btn_1_just_pressed = false
			pr_control.gc_btn_8_just_pressed = false
			if confirm_dialog_index == 2 then
				game_scene.return_to_title_requested = true
			else
				confirm_dialog_open  = false
				confirm_dialog_index = 1
			end
		elseif pr_control.escape_pressed then
			pr_control.escape_pressed = false
			confirm_dialog_open  = false
			confirm_dialog_index = 1
		end
	else
		local dpad_up_just   = pr_control.gc_dpad_up   and not prev_dpad_up
		local dpad_down_just = pr_control.gc_dpad_down  and not prev_dpad_down
		prev_dpad_up   = pr_control.gc_dpad_up
		prev_dpad_down = pr_control.gc_dpad_down

		local w_just = pr_control.w_pressed and not prev_w
		local s_just = pr_control.s_pressed and not prev_s
		prev_w = pr_control.w_pressed
		prev_s = pr_control.s_pressed

		if dpad_up_just or w_just then
			pause_menu_index = 1 + (pause_menu_index - 2) % #PAUSE_MENU_ITEMS
		end
		if dpad_down_just or s_just then
			pause_menu_index = 1 + (pause_menu_index) % #PAUSE_MENU_ITEMS
		end

		local confirm = pr_control.enter_pressed or pr_control.escape_pressed or pr_control.space_pressed
		                or pr_control.gc_btn_1_just_pressed or pr_control.gc_btn_8_just_pressed
		if confirm then
			pr_control.enter_pressed  = false
			pr_control.escape_pressed = false
			pr_control.space_pressed  = false
			pr_control.gc_btn_1_just_pressed = false
			pr_control.gc_btn_8_just_pressed = false
			if pause_menu_index == 1 then
				game_scene.is_paused = false
				pr_event_bus:emit('game_paused_changed', ecs, false)
			elseif pause_menu_index == 2 then
				toggle_fullscreen()
			elseif pause_menu_index == 3 then
				confirm_dialog_open  = true
				confirm_dialog_index = 1
				prev_dpad_left  = pr_control.gc_dpad_left
				prev_dpad_right = pr_control.gc_dpad_right
				prev_a = pr_control.a_pressed
				prev_d = pr_control.d_pressed
			end
		end
	end

	if game_scene.is_paused then return end

	local stick_y = pr_control.axes[4] or 0
	if math.abs(stick_y) < CROSSHAIR_STICK_DEAD then stick_y = 0 end
	if pr_control.w_pressed then stick_y = stick_y - 1.0 end
	if pr_control.s_pressed then stick_y = stick_y + 1.0 end
	crosshair_y_frac = math.max(CROSSHAIR_Y_MIN, math.min(CROSSHAIR_Y_MAX,
		crosshair_y_frac + stick_y * CROSSHAIR_Y_SPEED * dt))

	game_anim_time = game_anim_time + math.min(dt, MAX_DT)
	ecs:update(math.min(dt, MAX_DT))
	ecs:deleteDeadEntities()

	if ecs and player and ecs.entities[player] then
		local g        = ecs.entities[player].gravity
		local grounded   = g and g.grounded   or false
		local on_ramp    = grounded and (g and g.last_ground_was_ramp or false)
		local is_jumping = g and g.is_jumping or false

		if skate_sfx then
			local acc_dec = ecs.entities[player].acc_dec_movement
			local sx      = acc_dec and acc_dec.current_speed.x or 0
			local sz      = acc_dec and acc_dec.current_speed.z or 0
			local spd_len = math.sqrt(sx * sx + sz * sz)
			local car_hit     = acc_dec and acc_dec.car_hit or false
			local should_play = grounded and spd_len > 0.1 and not car_hit

			if should_play and not skate_sfx:isPlaying() then
				skate_sfx:play()
			elseif not should_play and skate_sfx:isPlaying() then
				skate_sfx:stop()
			end

			if should_play then
				local vel_comp  = ecs.entities[player].velocity
				local max_speed = vel_comp and vel_comp.velocity.z or 40
				local speed_t   = math.min(spd_len / max_speed, 1.0)
				local dot       = math.abs(sz) / spd_len
				skate_sfx:setPitch((0.7 + speed_t * 0.7) + 1.5 * (1.0 - dot))
			end
		end

		if skate_hit_sfx then
			local landed    = grounded   and not prev_grounded
			local left_ramp = not on_ramp    and prev_on_ramp
			local play_hit  = landed
			               or left_ramp
			               or (on_ramp    and not prev_on_ramp)
			               or (is_jumping and not prev_is_jumping)
			if play_hit then
				skate_hit_sfx:setPitch((landed or left_ramp) and 1.7 or 1.5)
				skate_hit_sfx:stop()
				skate_hit_sfx:setVolume(0.8, 'linear')
				skate_hit_sfx:play()
			end
		end

		prev_grounded   = grounded
		prev_on_ramp    = on_ramp
		prev_is_jumping = is_jumping

		local px = select(1, ecs.entities[player].transform.transform:getPosition())
		if prev_player_x then
			local crossed_inner_10  = prev_player_x > 10  and px <= 10   -- coming inward from right
			local crossed_inner_neg = prev_player_x < -10 and px >= -10  -- coming inward from left
			local crossed_outer_10  = prev_player_x < 10  and px >= 10   -- going outward to right
			local crossed_outer_neg = prev_player_x > -10 and px <= -10  -- going outward to left
			local crossed = crossed_inner_10 or crossed_inner_neg or crossed_outer_10 or crossed_outer_neg
			if crossed and grounded and skate_hit_sfx then
				local high_pitch = crossed_inner_10 or crossed_inner_neg
				skate_hit_sfx:setVolume(0.5, 'linear')
				skate_hit_sfx:setPitch(high_pitch and 1.7 or 1.5)
				skate_hit_sfx:stop()
				skate_hit_sfx:play()
			end
		end
		prev_player_x = px
	end

	-- Laser: fire while mouse button 1 or controller button 6 held
	local mouse_is_down    = lovr.mouse.isDown(1) or pr_control.gc_btn_6
	local mouse_just_fired = mouse_is_down and not mouse_was_down
	mouse_was_down = mouse_is_down

	local player_impaired = false
	if ecs and player and ecs.entities[player] then
		local adc = ecs.entities[player].acc_dec_movement
		player_impaired = adc and adc.car_hit or false
	end

	if mouse_just_fired and not player_impaired and shoot_sfx then
		shoot_sfx:stop()
		shoot_sfx:play()
	end

	if mouse_is_down and not player_impaired and ecs and player and ecs.entities[player] then
		local ox, oy, oz, dx, dy, dz = cursorToWorldRay()
		if ox then
			local px, py, pz = ecs.entities[player].transform.transform:getPosition()
			local gun_x, gun_y, gun_z = px, py + 1.5, pz
			local ex = ox + dx * LASER_RANGE
			local ey = oy + dy * LASER_RANGE
			local ez = oz + dz * LASER_RANGE
			local hit, shape, hx, hy, hz, hnx, hny, hnz = lovr_world:raycast(vec3(ox,oy,oz), vec3(ex,ey,ez))
			laser_beam = {
				sx = gun_x, sy = gun_y, sz = gun_z,
				ex = hit and hx or ex,
				ey = hit and hy or ey,
				ez = hit and hz or ez,
				t  = LASER_DURATION,
			}
			-- Apply shot damage to enemy on the first frame of each click
			if mouse_just_fired and hit and hit:getTag() == 'enemy_1' then
				local damage = ecs.entities[player].shooter and ecs.entities[player].shooter.shot_damage or 2
				for _, entity in pairs(ecs.entities) do
					if entity.is_enemy_1 and entity.collider and entity.collider.collider == hit then
						entity.health.current         = math.max(0, entity.health.current - damage)
					entity.health.hit_display_timer = 0.8
						break
					end
				end
			end

			-- Spawn impact sparks on the first frame of each press
			if mouse_just_fired and hit then
				local nx = hnx or 0
				local ny = hny or 1
				local nz = hnz or 0
				for _ = 1, SPARK_COUNT do
					local rx = math.random() * 2 - 1
					local ry = math.random() * 2 - 1
					local rz = math.random() * 2 - 1
					local vx = nx * 0.6 + rx * 0.4
					local vy = ny * 0.6 + ry * 0.4
					local vz = nz * 0.6 + rz * 0.4
					local len = math.sqrt(vx*vx + vy*vy + vz*vz)
					if len > 1e-4 then
						local spd = SPARK_SPEED * (0.6 + math.random() * 0.4)
						vx, vy, vz = vx/len * spd, vy/len * spd, vz/len * spd
					end
					table.insert(sparks, { x=hx, y=hy, z=hz, vx=vx, vy=vy, vz=vz, t=SPARK_LIFETIME })
				end
			end
		end
	end
	if laser_beam then
		laser_beam.t = laser_beam.t - dt
		if laser_beam.t <= 0 then laser_beam = nil end
	end

	-- Advance spark physics (gravity + lifetime)
	local si = 1
	while si <= #sparks do
		local sp = sparks[si]
		sp.vy = sp.vy - SPARK_GRAVITY * dt
		sp.x  = sp.x  + sp.vx * dt
		sp.y  = sp.y  + sp.vy * dt
		sp.z  = sp.z  + sp.vz * dt
		sp.t  = sp.t  - dt
		if sp.t <= 0 then
			table.remove(sparks, si)
		else
			si = si + 1
		end
	end
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

	-- Laser beam
	if laser_beam then
		gpass:setShader()
		local alpha = laser_beam.t / LASER_DURATION
		gpass:setColor(1, 0.1, 0.1, alpha)
		--gpass:line(laser_beam.sx, laser_beam.sy, laser_beam.sz,
		--           laser_beam.ex, laser_beam.ey, laser_beam.ez)
		gpass:setColor(1, 1, 1)
	end

	-- Hit sparks
	if #sparks > 0 then
		gpass:setShader()
		local TRAIL = 0.14
		for _, sp in ipairs(sparks) do
			local p    = sp.t / SPARK_LIFETIME
			local spd  = math.sqrt(sp.vx*sp.vx + sp.vy*sp.vy + sp.vz*sp.vz)
			if spd > 1e-4 then
				local inv = TRAIL / spd
				gpass:setColor(1, 0.9 * p + 0.1, 0.0, math.min(p * 2, 1))
				gpass:line(sp.x, sp.y, sp.z,
				           sp.x - sp.vx*inv, sp.y - sp.vy*inv, sp.z - sp.vz*inv)
			end
		end
		gpass:setColor(1, 1, 1)
	end
	-- print("FPS: " .. lovr.timer.getFPS())
	-- local pass = dpass

	dpass:setSampler('nearest')
	dpass:fill(gTexture)
	drawHUD(dpass)
	if victory_dialog_open then
		drawVictoryDialog(dpass)
	elseif game_scene.is_paused then
		drawPauseOverlay(dpass)
		if confirm_dialog_open then
			drawConfirmDialog(dpass)
		end
	end
	return lovr.graphics.submit(gpass, dpass)
end

return game_scene
