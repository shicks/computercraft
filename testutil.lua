local indent = ""
local failed = false

local befores = {{}}
local afters = {{}}

function beforeEach(fn)
  local b = befores[#befores]
  b[#b + 1] = fn
end

function afterEach(fn)
  local a = afters[#after]
  a[#a + 1] = fn
end

function describe(ctx, fn)
  print('\n' .. indent .. '\x1b[1m' .. ctx .. '\x1b[m ...\n')
  indent = indent .. '  '
  befores[#befores + 1] = {}
  afters[#afters + 1] = {}
  local ok, err = pcall(fn)
  if not ok then
    print('Error: ' .. err)
    print(indent .. '\x1b[31mFAIL\x1b[m')
    failed = true
  end
  indent = indent:sub(3)
  table.remove(afters, #afters)
  table.remove(befores, #befores)
end

function it(name, fn)
  local hasErr = false
  for _, bs in pairs(befores) do
    for _, b in pairs(bs) do
      local ok, err = pcall(b)
      if not ok then
        failed = true
        print('Error in beforeEach: ' .. err)
        hasErr = true
      end
    end
  end
  local ok, err = pcall(fn)
  if not ok then
    print('Error: ' .. err)
  end
  for i = #afters,1,-1 do
    local as = afters[i]
    for j = #as,1,-1 do
      local a = as[j]
      local ok2, err2 = pcall(a)
      if not ok2 then
        ok = false
        print('Error in afterEach: ' .. err)
        hasErr = true
      end
    end
  end
  if ok and not hasErr then
    print(indent .. '\x1b[32m' .. name .. '  ... PASS\x1b[m')
  else
    if not err and not hasErr then
      print('Error: no error specified')
    end
    print(indent .. '\x1b[31m' .. name .. '  ... FAIL\x1b[m')
    failed = true
  end
end

function eq(left, right)
  local t = type(left)
  if t ~= type(right) then return false end
  if t == 'table' then
    local seen = {}
    for k, v in pairs(left) do
      if not eq(v, right[k]) then return false end
      seen[k] = true
    end
    for k, v in pairs(right) do
      if not seen[k] then return false end
    end
    return getmetatable(left) == getmetatable(right)
  else
    return left == right
  end
end

function dump(obj)
  if type(obj) ~= 'table' then return tostring(obj) end
  local s = '{'
  local i = 1
  local first = true
  for k, v in pairs(obj) do
    if not first then s = s .. ', ' end
    first = false
    if k ~= i then
      s = s .. tostring(k) .. ': '
    end
    i = i + 1
    s = s .. dump(v)
  end
  return s .. '}'
end

function assertEqual(expected, actual)
  if not eq(expected, actual) then
    error('Expected equal(' .. dump(expected) .. ') but got ' .. dump(actual), 2)
  end
end

function assertSame(expected, actual)
  if expected ~= actual then
    error('Expected same(' .. tostring(expected) .. ') but got ' .. tostring(actual), 2)
  end
end
