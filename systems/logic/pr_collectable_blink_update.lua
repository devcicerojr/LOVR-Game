local ecs =   require'../core/pr_ecs'

local VISIBLE_TIME = 40
local VISIBLE_COUNTER = 0

return {
  phase = "logic",
  requires = {"tracks_entity", "rotation", "state_machine", "is_collected_coin_effect"},
  update_fn = function(id, c, dt) -- update function
    local entity_rotation = ecs.entities[id].rotation.rotation
    entity_rotation:mul(quat(20 * dt, 0, 1, 0))

    if ecs.entities[id].state_machine.state_machine.current_state == "visible" then
      VISIBLE_COUNTER = VISIBLE_COUNTER + 1
      if VISIBLE_COUNTER >= VISIBLE_TIME then
        ecs.entities[id].state_machine.state_machine.current_state = "invisible"
        VISIBLE_COUNTER = 0
      end
    end
    
  end
}