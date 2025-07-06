
local pr_component = require'../components/pr_components'

-- POS X = (i - 1) * tile_size + tile_size /2 - width/2 *(tile_size)
-- POS Z =  (j - 1) * tile_size + tile_size /2 - height/2 * (tile_size)
return function(ecs, width, height, tile_size)
  local id = ecs:newEntity()
  local grid = {
    tiles = {},
    width = width,
    height = height,
    tileSize = tile_size
  }

  for x = 1, width do
    grid.tiles[x] = {}
    for z = 1, height do
      local tile_spawn_pos = lovr.math.newVec3()
      tile_spawn_pos.x =  (x - 1) * tile_size + (tile_size / 2) - width/2 * (tile_size)
      tile_spawn_pos.y = 0
      tile_spawn_pos.z = (z - 1) * tile_size + (tile_size /2) - height/2 * (tile_size)
      grid.tiles[x][z] = (require'../entities/tiles/pr_asphalt_ground')(ecs, tile_spawn_pos)
    end
  end

  ecs:addComponent(id, pr_component.Grid(grid))
end