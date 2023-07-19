-- Stub properties out for testing
-- Usage: `local stub = require('stub')()` to get a new instane

-- Returns a new stub controller, with replace/reset methods
local function stub()
  local stubs = {}

  local function replace(owner, prop, replacement)
    stubs[#stubs + 1] = {owner, prop, owner[prop]}
    owner[prop] = replacement
  end

  local function reset()
    for _, r in pairs(stubs) do
      r[1][r[2]] = r[3]
    end
    stubs = {}
  end

  return {replace = replace, reset = reset, new = stub}
end

return stub
