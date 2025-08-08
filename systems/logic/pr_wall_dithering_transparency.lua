local pr_ecs = require'../core/pr_ecs'
local lovr_world = require'../core/pr_world'

return {
  phase = "logic",
  requires = {"is_player", "transform", "game_cam"},
  update_fn = function(id, c, dt) --update function
    local entity = pr_ecs.entities[id]
    local player_pos = vec3(entity.transform.transform:getPosition())
    local player_orientation = quat(entity.transform.transform:getOrientation())
    local game_cam = entity.game_cam
    local game_cam_pos_offset = vec3(game_cam.game_cam_offset:getPosition())
    game_cam_pos_offset:rotate(player_orientation)
    local game_cam_pos_world = vec3(player_pos):add(game_cam_pos_offset)


    pr_ecs:clearObstructingVals()
    local obstruct_collider = lovr_world:raycast(game_cam_pos_world , player_pos , 'wall')
    if obstruct_collider then
      local collider_data = obstruct_collider:getUserData()
      if not collider_data then
        print("NIL collider user data")
      else
        local wall_id = collider_data.id
        pr_ecs.entities[wall_id].is_camera_blocker.is_blocking = true
      end
    end
  end
}