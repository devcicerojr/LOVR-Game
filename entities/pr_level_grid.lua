
local pr_component = require'../components/pr_components'

-- POS X = (i - 1) * tile_size + tile_size /2 - width/2 *(tile_size)
-- POS Z =  (j - 1) * tile_size + tile_size /2 - height/2 * (tile_size)
return function(ecs, width, height, tile_size)
  local id = ecs:newEntity()
  local tile_size = tile_size or 20.0
  local grid = {
    tiles = {},
    width = width,
    height = height,
    tileSize = tile_size
  }

  for x = 1, width do
    grid.tiles[x] = {}
    for z = 1, height do
      local tile_spawn_pos = vec3()
      tile_spawn_pos.x =  (x - 1) * tile_size + (tile_size / 2) - width/2 * (tile_size)
      tile_spawn_pos.y = 0
      tile_spawn_pos.z = (z - 1) * tile_size + (tile_size /2) - height/2 * (tile_size)
      if  tile_spawn_pos.x == -10 then
        grid.tiles[x][z] = (require'../entities/tiles/pr_tiled_ground')(ecs, tile_spawn_pos, tile_size, "assets/left_side_asphalt.png")
      elseif tile_spawn_pos.x == 10 then
        grid.tiles[x][z] = (require'../entities/tiles/pr_tiled_ground')(ecs, tile_spawn_pos, tile_size, "assets/right_side_asphalt.png")
      else
        grid.tiles[x][z] = (require'../entities/tiles/pr_tiled_ground')(ecs, tile_spawn_pos, tile_size)
      end
    end
  end

  ecs:addComponent(id, pr_component.Grid(grid))
  return id
end