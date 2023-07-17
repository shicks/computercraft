require('testutil')

return function(expected)
  -- 'expected' is a table:
  -- {
  --   {'foo', {arg1, arg2}, {}},
  --   {'bar', {arg}, {ret1, ret2}},
  -- }
  -- NOTE: this is very brittle, but it's the easiest thing

  local i = 1
  function index(_, key)
    if key == 'verify' then
      return function()
        if i < #expected then error('Missing expected calls') end
      end
    end
    local row = expected[i]
    if row == nil then error('Unexpected call to ' .. key) end
    i = i + 1
    if row[1] ~= key then error('Expected call to ' .. row[1] .. ' but got ' .. key) end
    return function(...)
      local args = {...}
      wantargs = row[2]
      if not eq(args, wantargs) then error('Unexpected args to ' .. key .. ': expected ' .. dump(wantargs) .. ', but got ' .. dump(args)) end
      return unpack(row[3])
    end
  end
  return setmetatable({}, {__index = index})
end
