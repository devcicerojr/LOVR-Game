local ecs = require'../core/pr_ecs'

return {
  phase = "logic",
  requires = {"animation_state", "all_dir_controls"},
  update_fn = function(id, c, dt) -- update function
    local animation = ecs.entities[id].animation_state
    -- if lovr.system.isKeyDown('i') or lovr.system.isKeyDown('k') 
    if true or lovr.system.isKeyDown('k')
    or lovr.system.isKeyDown('j') or lovr.system.isKeyDown('l') then
      animation.current = 1
    else
      animation.current = 0
    end
  end
}