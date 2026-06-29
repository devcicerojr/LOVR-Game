-- local ecs = require'../core/pr_ecs'

return {
  phase = "logic",
  requires = {"animation_state", "all_dir_controls"},
  update_fn = function(ecs, id, c, dt) -- update function
    local entity    = ecs.entities[id]
    local animation = entity.animation_state
    local car_hit   = entity.acc_dec_movement and entity.acc_dec_movement.car_hit

    if car_hit then
      animation.current      = 0
      animation.car_hit_time = (animation.car_hit_time or 0) + dt
    else
      -- On the first frame out of falling, reset to rest pose so the body blend
      -- system (which runs after this) can apply cleanly on top.
      if animation.car_hit_time and animation.car_hit_time > 0 then
        entity.model.model:animate(1, 0)
      end
      animation.current      = 1
      animation.car_hit_time = 0
    end
  end
}