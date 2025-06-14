local pr_control = require'pr_control'
local pr_camera = require'pr_camera'
local cam_y_offset = 3.63
local cam_x_offset = 0.0
function lovr.keypressed(key, scancode, rpt)
  pr_control.keypressed(key, scancode, rpt)
end

function lovr.keyreleased(key, scancode)
  pr_control.keyreleased(key, scancode)
end

function lovr.load()

  cube = lovr.graphics.newTexture({
    left = 'assets/skybox/desert_skybox_right.png' ,
    right = 'assets/skybox/desert_skybox_left.png' ,
    top = 'assets/skybox/desert_skybox_top.png' ,
    bottom = 'assets/skybox/desert_skybox_down.png' ,
    front = 'assets/skybox/desert_skybox_front.png' ,
    back = 'assets/skybox/desert_skybox_back.png'
  })
  model = lovr.graphics.newModel('Test.glb')

	-- set up shader
  shader = lovr.graphics.newShader([[
    vec4 lovrmain() {
      return Projection * View * Transform * VertexPosition;
    }
  ]], [[
    Constants {
      vec4 ambience;
      vec4 lightColor;
      vec3 lightPos;
      float specularStrength;
      int metallic;
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

      vec4 baseColor = Color * getPixel(ColorTexture, UV);

      return baseColor * (ambience + diffuse + specular);
    }
  ]])
  pr_camera.init()
end

function lovr.update(dt)
  pr_control.update(dt)
end

function lovr.draw(pass)
  local x, y, z, angle, ax, ay, az 
  if pr_camera.spectate == false then
    x, y, z, angle, ax, ay, az = pr_camera.getGameViewPose()
    pass:setViewPose(1, x + cam_x_offset, y + cam_y_offset, z, -0.436, 1, ay, az)
  else 
    x, y, z, angle, ax, ay, az = pr_camera.getSpecViewPose()
    pass:setViewPose(1, x + cam_x_offset, y + cam_y_offset, z, -0.436, 1, ay, az)
  end
  pass:setShader(shader)

  local lightPos = vec3(10, 40.0, -20.0)

  -- Set shader values
  pass:send('ambience', {0.4, 0.4, 0.4, 1.0})
  pass:send('lightColor', {1.0, 1.0, 1.0, 1.0})
  pass:send('lightPos', lightPos)
  pass:send('specularStrength', 60)
  pass:send('metallic', 200.0)

  pass:setBlendMode('alpha', 'alphamultiply')
  pass:setSampler('nearest')
  -- pass:setWireframe(true)
  pass:draw(model, 0, 1, -3, 1, lovr.timer.getTime())
  -- pass:setWireframe(false)
  model:animate('walking', lovr.timer.getTime() % model:getAnimationDuration('walking'))
  
	pass:setShader() -- Reset to default/unlit
  pass:skybox(cube)
  pass:sphere(lightPos, -1, -3, 0.1) -- Represents light
end