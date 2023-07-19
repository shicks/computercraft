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

for _, test in pairs({...}) do
  describe(test, function()
    require(test:gsub('.lua$', ''))
  end)
end

testSummary()
