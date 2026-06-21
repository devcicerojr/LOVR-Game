-- local ecs = require'../core/pr_ecs'
local player_id = nil
return {
  phase = "logic",
  requires = {"transform", "is_collectable", "collider"},
  update_fn = function(ecs, id, c, dt) -- update function
    if not player_id then
      player_id = ecs:getEntityByTag('is_player')
      if not player_id then return end
    end
    local player = ecs.entities[player_id]
    if not player or not player.collider then return end

    local p_minx, p_maxx, p_miny, p_maxy, p_minz, p_maxz = player.collider.collider:getAABB()
    local c_minx, c_maxx, c_miny, c_maxy, c_minz, c_maxz = ecs.entities[id].collider.collider:getAABB()

    if p_minx <= c_maxx and p_maxx >= c_minx
    and p_miny <= c_maxy and p_maxy >= c_miny
    and p_minz <= c_maxz and p_maxz >= c_minz then
      pr_event_bus:emit('coin_collected', ecs, id)
    end

    local player_pos_z = select(3, player.transform.transform:getPosition())
    local coin_pos_z   = select(3, ecs.entities[id].transform.transform:getPosition())
    if player_pos_z - coin_pos_z > 200 then
      pr_event_bus:emit('coin_expired', ecs, id)
    end
  end
}