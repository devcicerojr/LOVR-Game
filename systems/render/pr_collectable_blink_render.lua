local pr_ecs = require'../core/pr_ecs'

return {
  phase = "render",
  requires = { "model", "tracks_entity" },
  update_fn = function(id, c, pass) -- render
    local entity = pr_ecs.entities[id]
    local tracking_entity = entity.tracks_entity.entity_id
    -- local tracked_entity_transform = pr_ecs.entities[tracking_entity].transform.transform
    -- local tracked_entity_transform = pr_ecs.entities[tracking_entity].collider.collider:getPosition()
    local model = pr_ecs.entities[id].model.model

    if not model then
      return
    end

    local position = vec3(pr_ecs.entities[tracking_entity].collider.collider:getPosition()):add(entity.tracks_entity.transform_offset:getPosition())
    local orientation = entity.rotation.rotation

    pass:setColor(1, 1, 1, 1)
    pass:draw(model, position, vec3(1.5, 1, 1), orientation)
  end
}