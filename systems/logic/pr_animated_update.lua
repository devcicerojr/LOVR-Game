local ecs = require'../core/pr_ecs'

return {
  phase = "logic",
  requires = {"animation_state"},
  update_fn = function(id, c, dt) -- update function
    local animation = ecs.entities[id].animation_state
    if lovr.system.isKeyDown('i') then
      animation.current = 1
    elseif lovr.system.isKeyDown('k') then
      animation.current = 1
    else
      animation.current = 0
    end
  end
}