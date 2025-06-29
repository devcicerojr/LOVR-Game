-- Custom Types

function pr_Colora(r , g , b , a)
  return setmetatable({r = r or 1.0, g = g or 1.0, b = b or 1.0, a = a or 1.0}, pr_Colora_mt)
end

pr_Colora_mt = {
  __index = {
    toString = function(self)
      return string.format("pr_Colora(%.2f, %.2f, %.2f, %.2f)", self.r, self.g, self.b, self.a)
    end
  },

  __type = "pr_Colora" 
}