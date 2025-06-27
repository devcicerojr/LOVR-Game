local ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "collider" },
  update_fn = function(id , c , pass) -- draw function
    local x, y, z = ecs.entities[id].collider.collider:getPosition()
    local radius = ecs.entities[id].collider.collider:getShape():getRadius()
    local length = ecs.entities[id].collider.collider:getShape():getLength()
    pass:setWireframe(true)
    pass:capsule(x, y, z, radius, length , 1, 0 , 0 , 0)
    pass:setWireframe(false)

  end
}
