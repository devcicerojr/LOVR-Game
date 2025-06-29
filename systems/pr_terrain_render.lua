local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires =  { "mesh" , "terrain_collider"},
  update_fn = function(id, c, pass) -- draw function
    local color = ecs.entities[id].mesh.base_color
    pass:setColor(color.r, color.g, color.b)
    pass:draw(ecs.entities[id].mesh.mesh)
  end
}