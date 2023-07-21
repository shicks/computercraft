-- TODO - look in current dir for all *_test.lua files
-- describe each and run all at once
-- summary at end

local indent = ""
local afterTest = false
local failed = false

local befores = {{}}
local afters = {{}}
local tearDowns = {{}}

local passCount = 0
local failCount = 0

function dump(obj)
  if type(obj) ~= 'table' then return tostring(obj) end
  local mt = getmetatable(obj)
  if mt and mt.__index then return tostring(obj) end
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

-- NOTE: `right` can include matchers.
function eq(left, right)
  if isMatcher(right) then return right.matches(left) end
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

function assertThrows(fn, ...)
  local ok, caught = pcall(fn, ...)
  expect(ok, is(false))
  return caught  
end


local Matcher = {mt = {}}
function Matcher.mt.__bnot(m)
  return matcher(
      function(subject) return not m.matches(subject) end,
      function() return 'not ' .. m.describe() end)
end
function Matcher.mt.__bor(a, b)
  return matcher(
      function(subject) return a.matches(subject) or b.matches(subject) end,
      function() return '(' .. a.describe() .. ' | ' .. b.describe() .. ')' end)
end
function Matcher.mt.__band(a, b)
  return matcher(
      function(subject) return a.matches(subject) and b.matches(subject) end,
      function() return '(' .. a.describe() .. ' & ' .. b.describe() .. ')' end)
end
function matcher(pred, name)
  if type(name) == 'string' then name = function() return name end end
  return setmetatable({
    matches = pred,
    describe = name,
  }, Matcher.mt)
end

function is(expected)
  return matcher(
      function(subject) return subject == expected end,
      function() return 'be ' .. tostring(expected) end)
end
function eql(expected)
  return matcher(
      function(subject) return eq(subject, expected) end,
      function() return 'deep-equal ' .. dump(expected) end)
end

function isMatcher(matcher)
  return getmetatable(matcher) == Matcher.mt
end

function expect(subject, matcher)
  if not isMatcher(matcher) then matcher = is(matcher) end
  if matcher.matches(subject) then return end
  error('Expected ' .. dump(subject) .. ' to ' .. matcher.describe(), 2)
end


-- Returns a "replacer" controller
-- Usage: local stubs = replacer()
--        stubs.replace(owner, 'prop', value)
--        tearDown(stubs.reset)
function replacer()
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

  return {replace = replace, reset = reset}
end


-- Returns a "mocks" controller
function mocks()

end


function mock(expected)
  -- 'expected' is a table:
  -- {
  --   {'foo', {arg1, arg2}, {}},
  --   {'bar', {arg}, {ret1, ret2}},
  -- }
  -- NOTE: this is very brittle, but it's the easiest thing
  -- TODO - what about coupled mocks that go in order?

  local i = 1
  function index(_, key)
    if key == 'verify' then
      return function()
        if i < #expected then error('Missing expected calls') end
      end
    end
    return function(...)
      local row = expected[i]
      if row == nil then error('Unexpected call to ' .. key) end
      i = i + 1
      if row[1] ~= key then error('Expected call to ' .. row[1] .. ' but got ' .. key) end
      local args = {...}
      wantargs = row[2]
      if not eq(args, wantargs) then error('Unexpected args to ' .. key .. ': expected ' .. dump(wantargs) .. ', but got ' .. dump(args)) end
      return unpack(row[3])
    end
  end
  return setmetatable({}, {__index = index})
end




local function testSummary()
  local s = ''
  if passCount > 0 then
    s = s .. '\x1b[32m' .. passCount .. ' tests passed\x1b[m'
  end
  if failCount > 0 then
    if s ~= '' then s = s .. ', ' end
    s = s .. '\x1b[31m' .. failCount .. ' tests failed\x1b[m'
    failed = true
  end
  if passCount + failCount == 0 then
    s = 'no tests executed'
    failed = true
  end
  exitCode = 0
  if failed then exitCode = 1 end
  print('Tests complete: ' .. s)
  os.exit(exitCode)
end

function beforeEach(fn)
  local b = befores[#befores]
  b[#b + 1] = fn
end

function afterEach(fn)
  local a = afters[#afters]
  a[#a + 1] = fn
end

function tearDown(fn)
  local t = tearDowns[#tearDowns]
  t[#t + 1] = fn
end

function describe(ctx, fn)
  print(indent .. '\x1b[1m' .. ctx .. '\x1b[m ...\n')
  indent = indent .. '  '
  befores[#befores + 1] = {}
  afters[#afters + 1] = {}
  tearDowns[#tearDowns + 1] = {}
  local ok, err = pcall(fn)
  if not ok then
    print('Error: ' .. err)
    print(indent .. '\x1b[31mFAIL\x1b[m')
    failed = true
  end
  indent = indent:sub(3)
  table.remove(afters, #afters)
  table.remove(befores, #befores)
  if afterTest then print('') end
  afterTest = false
  for _, t in pairs(table.remove(tearDowns, #tearDowns)) do
    t()
  end
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
    print(indent .. '\x1b[32m\xe2\x9c\x94 ' .. name .. '\x1b[m')
    passCount = passCount + 1
  else
    if not err and not hasErr then
      print('Error: no error specified')
    end
    print(indent .. '\x1b[31m\xe2\x9c\x98 ' .. name .. '\x1b[m')
    failed = true
    failCount = failCount + 1
  end
  afterTest = true
end

-- Only do this if run as "main"
if not pcall(debug.getlocal, 4, 1) then
  for _, test in pairs({...}) do
    describe(test, function()
      require(test:gsub('.lua$', ''))
    end)
  end

  testSummary()
end
