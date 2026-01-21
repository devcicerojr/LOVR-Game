local pr_assets = {
  models = {},
  sounds = {}
}

function pr_assets.getModel(path)
  if not pr_assets.models[path] then
    pr_assets.models[path] = lovr.graphics.newModel(path)
  end
  return pr_assets.models[path]
end

return pr_assets