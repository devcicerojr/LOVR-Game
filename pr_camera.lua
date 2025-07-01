local pr_camera = {}

pr_camera.spectate = false
pr_camera.spec_cam = lovr.math.newMat4()
pr_camera.game_cam = lovr.math.newMat4()

function pr_camera.update(view)
  pr_camera.spec_cam = view
end

function pr_camera.updateSpecCamPose()
	
  local pass = lovr.headset.getPass() -- headset pass is used for spectate camera
  local x , y , z , angle, ax , ay , az = pass:getViewPose(1)
	pr_camera.spec_cam:set(x, y, z, 1, 1, 1,  angle, ax, ay, az)
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
	pr_camera.game_cam:set(0, 4, 1, -0.436, 1, 0, 0)
end

function pr_camera.getGameViewPose()
	return pr_camera.game_cam:getPose()
end

function pr_camera.getSpecViewPose()
	return pr_camera.spec_cam:getPose()
end

function pr_camera.zoomIn(zval)
	zval = zval or 0.25
	local angle, ax, ay, az
	local q -- quaternion
	local dir
	if pr_camera.spectate then
		q = lovr.math.newQuat(pr_camera.spec_cam:getOrientation())
		dir = q:direction()
		dir:mul(-zval)

		pr_camera.spec_cam:translate(dir)
  end
end


function pr_camera.zoomOut(zval)
	zval = zval or 0.25
	local angle, ax, ay, az
	local q -- quaternion
	local dir
	if pr_camera.spectate then
		q = lovr.math.newQuat(pr_camera.spec_cam:getOrientation())
		dir = q:direction()
		dir:mul(zval)
		pr_camera.spec_cam:translate(dir)
  end
end

return pr_camera