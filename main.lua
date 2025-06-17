local pr_control = require'pr_control'
local pr_camera = require'pr_camera'
local game_scene = require'scenes.game_scene'
local cam_y_offset = 3.63
local cam_x_offset = 0.0
local terrainMesh

isDevBuild = false

function lovr.keypressed(key, scancode, rpt)
  pr_control.keypressed(key, scancode, rpt)
end

function lovr.wheelmoved(dx, dy)
  pr_control.wheelmoved(dx, dy)
end


function lovr.keyreleased(key, scancode)
  pr_control.keyreleased(key, scancode)
end

function lovr.load(arg)

  if arg[1] == 'DEVBUILD' then
    isDevBuild = true
    print("running in DEVBUILD mode")
  end

  game_scene.load()

  -- SCENE
  cube = lovr.graphics.newTexture({
    left = 'assets/skybox/desert_skybox_right.png' ,
    right = 'assets/skybox/desert_skybox_left.png' ,
    top = 'assets/skybox/desert_skybox_top.png' ,
    bottom = 'assets/skybox/desert_skybox_down.png' ,
    front = 'assets/skybox/desert_skybox_front.png' ,
    back = 'assets/skybox/desert_skybox_back.png'
  })

 

	-- set up shader
	shader = lovr.graphics.newShader([[
  vec4 lovrmain() {
    return DefaultPosition;
  }
]], [[
  Constants {
    vec4 ambience;
    vec4 lightColor;
    vec3 lightPos;
    float specularStrength;
    int metallic;
    float pixelSize;
    vec2 lovrResolution;
    int numDivs;
  };

  vec4 lovrmain() {
    // Diffuse
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(lightPos - PositionWorld);
    float diff = max(dot(norm, lightDir), 0.0);
    vec4 diffuse = diff * lightColor;

    // Specular
    vec3 viewDir = normalize(CameraPositionWorld - PositionWorld);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
    vec4 specular = specularStrength * spec * lightColor;

    // vec2 snappedUV = floor(UV / pixelSize) * pixelSize;
    // vec4 baseColor = Color * getPixel(ColorTexture, snappedUV);
    // return baseColor * (ambience + diffuse + specular);

    vec2 snappedUV = (vec2(ivec2(UV * float(numDivs))) + 0.5) / float(numDivs);
    vec4 baseColor = Color * getPixel(ColorTexture , snappedUV);
    return baseColor * (ambience + diffuse + specular);
  }
]])
  pr_camera.init()
end

function lovr.update(dt)
  pr_control.update(dt)
  game_scene.update(dt)
  pr_camera.updateCamPose(dt)
end

function lovr.draw(pass)
  if not pr_camera.spectate then
	  pass:setViewPose(1, pr_camera.game_cam.x , pr_camera.game_cam.y , pr_camera.game_cam.z, 
	  pr_camera.game_cam.angle, pr_camera.game_cam.ax, pr_camera.game_cam.ay, pr_camera.game_cam.az)
  end
  
  local lightPos = vec3(10, 40.0, -20.0)
  local width = lovr.system.getWindowWidth()
  local height = lovr.system.getWindowHeight()
  pass:setShader(shader)
  pass:send('ambience', {0.4, 0.4, 0.4, 1.0})
  pass:send('lightColor', {1.0, 1.0, 1.0, 1.0})
  pass:send('lightPos', lightPos)
  pass:send('specularStrength', 60)
  pass:send('metallic', 200.0)
  pass:send('pixelSize' , 0.000001)
  pass:send('lovrResolution', { width, height })
  pass:send('numDivs' , 64)


  -- Set shader values

  pass:setBlendMode('alpha', 'alphamultiply')
  pass:setSampler('nearest')
  -- pass:setWireframe(true)
  pass:draw(model, 0, 0, -3, 1, 3.15)
  -- pass:setWireframe(false)
  model:animate('walking', lovr.timer.getTime() % model:getAnimationDuration('walking'))

  pass:setColor(0.4, 0.8, 0.4) -- grassy green
 
  pass:setColor(1 , 1 , 1)
	pass:setShader() -- Reset to default/unlit
  pass:skybox(cube)
  pass:sphere(lightPos, -1, -3, 0.1) -- Represents light
end