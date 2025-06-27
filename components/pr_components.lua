pr_components = {}

pr_components.position = function ( x , y , z)
  return { x = x or 0 , y = y or 0 , z = z or 0 }
end

pr_components.velocity = function ( vx , vy , vz)
  return { vx = vx or 0 , vy = vy or 0 , vz = vz or 0 }
end
