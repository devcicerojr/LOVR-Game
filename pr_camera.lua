local pr_camera = {}

pr_camera.spectate = false
pr_camera.spec_cam = { x = 0 , y = 0 , z = 0 , angle = 0 , ax = 0 , ay = 0 , az = 0}
pr_camera.game_cam = { x = 0 , y = 0 , z = 0 , angle = 0 , ax = 0 , ay = 0 , az = 0}

function pr_camera.update(view)
  pr_camera.spec_cam = view
end

function pr_camera.setSpec(spec_mode)
  pr_camera.spectate = spec_mode   
end

function pr_camera.toggleSpec()
	pr_camera.spectate = not pr_camera.spectate
	if pr_camera.spectate == false then
		lovr.headset.stop()
	else
		lovr.headset.start()
	end
	print("toggled spec")
end

function pr_camera.init()
	pr_camera.game_cam.x = 0
	pr_camera.game_cam.y = 2.6
	pr_camera.game_cam.z = 2
	pr_camera.game_cam.angle = -0.436
	pr_camera.game_cam.ax = 1
	pr_camera.game_cam.ay = 0
	pr_camera.game_cam.az = 0
end

function pr_camera.getGameViewPose()
	local x, y, z = pr_camera.game_cam.x , pr_camera.game_cam.y , pr_camera.game_cam.z
  local angle , ax , ay , az = pr_camera.game_cam.angle, pr_camera.game_cam.ax
  local ay , az = pr_camera.game_cam.ay , pr_camera.game_cam.az
	return x, y, z, angle, ax, ay, az
end

function pr_camera.getSpecViewPose()
	local x, y, z = pr_camera.spec_cam.x , pr_camera.spec_cam.y , pr_camera.spec_cam.z
  local angle , ax , ay , az = pr_camera.spec_cam.angle, pr_camera.spec_cam.ax
  local ay , az = pr_camera.spec_cam.ay , pr_camera.spec_cam.az
	return x, y, z, angle, ax, ay, az
end

function pr_camera.zoomIn(zval)
	zval = zval or 0.25
	local angle, ax, ay, az
	local q -- quaternion
	local dir
	if pr_camera.spectate then
		angle, ax, ay, az = pr_camera.spec_cam.angle, pr_camera.spec_cam.ax, pr_camera.spec_cam.ay, pr_camera.spec_cam.az
		q = lovr.math.quat(angle, ax, ay, az)
		dir = q.direction(q)
		pr_camera.spec_cam.x = pr_camera.spec_cam.x - dir.x * zval
		pr_camera.spec_cam.y = pr_camera.spec_cam.y - dir.y * zval
		pr_camera.spec_cam.z = pr_camera.spec_cam.z - dir.z * zval
	end
end


function pr_camera.zoomOut(zval)
	zval = zval or -0.25
	local angle, ax, ay, az
	local q -- quaternion
	local dir
	if pr_camera.spectate then
		angle, ax, ay, az = pr_camera.spec_cam.angle, pr_camera.spec_cam.ax, pr_camera.spec_cam.ay, pr_camera.spec_cam.az
		q = lovr.math.quat(angle, ax, ay, az)
		dir = q.direction(q)
		pr_camera.spec_cam.x = pr_camera.spec_cam.x - dir.x * zval
		pr_camera.spec_cam.y = pr_camera.spec_cam.y - dir.y * zval
		pr_camera.spec_cam.z = pr_camera.spec_cam.z - dir.z * zval
	end
end

return pr_camera