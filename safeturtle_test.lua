local geo = require('geo')
local pos = geo.P()
local dir = geo.east

-- stub out the load/write functions
local globalStubs = replacer()
globalStubs.replace(geo, 'loadPos', function() return pos end)
globalStubs.replace(geo, 'loadDir', function() return dir end)
globalStubs.replace(geo, 'writePos', function(p) pos = p end)
globalStubs.replace(geo, 'writeDir', function(d) dir = d end)
tearDown(globalStubs.reset)

local stubs = replacer()

local st = require('safeturtle')
local P = geo.P

local fakeBlocks = {
  chest = {name = 'minecraft:chest'},
  deepslate = {name = 'minecraft:deepslate'},
  sand = {name = 'minecraft:sand'},
  stone = {name = 'minecraft:stone'},
}

beforeEach(function()
  st.reset(geo.P(), geo.east)
  mc = mocks()
  stubs.replace(os, 'sleep', mc.mock('os.sleep'))
  turtle = mc.mock('turtle')
  _turtle = mc.expect(turtle)
end)

afterEach(function()
  mc.verify()
  turtle = nil
  _turtle = nil
  mc = nil
  stubs.reset()
end)

describe('test harness', function()
  it('should start at (0,0,0)', function()
    expect(pos, is(P(0, 0, 0)))
  end)
  it('should start facing east', function()
    expect(dir, is(geo.east))
  end)
end)

describe('safeturtle.turnLeft', function()
  it('should update direction', function()
    _turtle.turnLeft().ret(true)
    assert(st.turnLeft())
    expect(dir, is(geo.north))
  end)

  it('should propagate errors', function()
    _turtle.turnLeft().ret(false, 'xyz')
    expect({st.turnLeft()}, eql({false, 'xyz'}))
    expect(dir, is(geo.east))
  end)
end)

describe('safeturtle.turnRight', function()
  it('should update direction', function()
    _turtle.turnRight().ret(true)
    assert(st.turnRight())
    expect(dir, is(geo.south))
  end)

  it('should propagate errors', function()
    _turtle.turnRight().ret(false, 'xyz')
    expect({st.turnRight()}, eql({false, 'xyz'}))
    expect(dir, is(geo.east))
  end)
end)

describe('safeturtle.turnAbout', function()
  it('should update direction', function()
    _turtle.turnLeft().ret(true)
    _turtle.turnLeft().ret(true)
    assert(st.turnAbout())
    expect(dir, is(geo.west))
  end)

  it('should propagate errors from the first call', function()
    _turtle.turnLeft().ret(false, 'abc')
    expect({st.turnAbout()}, eql({false, 'abc'}))
    expect(dir, is(geo.east))
  end)

  it('should propagate errors from the second call', function()
    _turtle.turnLeft().ret(true)
    _turtle.turnLeft().ret(false, 'abc')
    expect({st.turnAbout()}, eql({false, 'abc'}))
    expect(dir, is(geo.north))
  end)
end)

describe('safeturtle.turnTo', function()
  it('should not turn if already facing', function()
    st.reset(P(), geo.east)
    assert(st.turnTo(geo.east))
    expect(dir, is(geo.east))
  end)

  it('should turn from east to north', function()
    _turtle.turnLeft().ret(true)
    st.reset(P(), geo.east)
    assert(st.turnTo(geo.north))
    expect(dir, is(geo.north))
  end)

  it('should turn from east to west', function()
    _turtle.turnLeft().ret(true)
    _turtle.turnLeft().ret(true)
    st.reset(P(), geo.east)
    assert(st.turnTo(geo.west))
    expect(dir, is(geo.west))
  end)

  it('should turn from east to south', function()
    _turtle.turnRight().ret(true)
    st.reset(P(), geo.east)
    assert(st.turnTo(geo.south))
    expect(dir, is(geo.south))
  end)

  it('should turn from north to east', function()
    _turtle.turnRight().ret(true)
    st.reset(P(), geo.north)
    assert(st.turnTo(geo.east))
    expect(dir, is(geo.east))
  end)

  it('should turn from west to east', function()
    _turtle.turnLeft().ret(true)
    _turtle.turnLeft().ret(true)
    st.reset(P(), geo.west)
    assert(st.turnTo(geo.east))
    expect(dir, is(geo.east))
  end)

  it('should turn from south to east', function()
    _turtle.turnLeft().ret(true)
    st.reset(P(), geo.south)
    assert(st.turnTo(geo.east))
    expect(dir, is(geo.east))
  end)

  it('should fail to turn to up/down', function()
    st.reset(P(), geo.east)
    assertThrows(st.turnTo, geo.up)
    assertThrows(st.turnTo, geo.dn)
  end)
end)

describe('safeturtle.inspectDir', function()
  it('should work with nil', function()
    _turtle.inspect().ret(true, fakeBlocks.stone)
    expect({st.inspectDir()}, eql({true, fakeBlocks.stone}))
  end)

  it('should work in current direction', function()
    _turtle.inspect().ret(true, fakeBlocks.stone)
    expect({st.inspectDir(geo.east)}, eql({true, fakeBlocks.stone}))
  end)

  it('should work up', function()
    _turtle.inspectUp().ret(true, fakeBlocks.stone)
    expect({st.inspectDir(geo.up)}, eql({true, fakeBlocks.stone}))
  end)

  it('should work down', function()
   _turtle.inspectDown().ret(true, fakeBlocks.stone)
    expect({st.inspectDir(geo.dn)}, eql({true, fakeBlocks.stone}))
  end)

  it('should work to left', function()
    _turtle.turnLeft().ret(true)
    _turtle.inspect().ret(true, fakeBlocks.deepslate)
    _turtle.turnRight().ret(true)
    expect({st.inspectDir(geo.north)}, eql({true, fakeBlocks.deepslate}))
  end)

  it('should work to right', function()
    _turtle.turnRight().ret(true)
    _turtle.inspect().ret(true, fakeBlocks.deepslate)
    _turtle.turnLeft().ret(true)
    expect({st.inspectDir(geo.south)}, eql({true, fakeBlocks.deepslate}))
  end)

  it('should work to rear', function()
    _turtle.turnLeft().ret(true)
    _turtle.turnLeft().ret(true)
    _turtle.inspect().ret(true, fakeBlocks.deepslate)
    _turtle.turnLeft().ret(true)
    _turtle.turnLeft().ret(true)
    expect({st.inspectDir(geo.west)}, eql({true, fakeBlocks.deepslate}))
  end)

  it('should propagate a false return', function()
    _turtle.inspect().ret(false, nil)
    expect({st.inspectDir()}, eql({false, nil}))
  end)

  -- TODO: What if the turn errors?  We don't currently handle it at all.
end)

describe('safeturtle.placeDir', function()
  it('should work with nil', function()
    _turtle.place().ret(true)
    assert(st.placeDir())
  end)

  it('should work in current direction', function()
    _turtle.place().ret(true)
    assert(st.placeDir(geo.east))
  end)

  it('should work up', function()
    _turtle.placeUp().ret(true)
    assert(st.placeDir(geo.up))
  end)

  it('should work down', function()
    _turtle.placeDown().ret(true)
    assert(st.placeDir(geo.dn))
  end)

  it('should work to left', function()
    _turtle.turnLeft().ret(true)
    _turtle.place().ret(true)
    _turtle.turnRight().ret(true)
    assert(st.placeDir(geo.north))
  end)

  it('should work to right', function()
    _turtle.turnRight().ret(true)
    _turtle.place().ret(true)
    _turtle.turnLeft().ret(true)
    assert(st.placeDir(geo.south))
  end)

  it('should work to rear', function()
    _turtle.turnLeft().ret(true)
    _turtle.turnLeft().ret(true)
    _turtle.place().ret(true)
    _turtle.turnLeft().ret(true)
    _turtle.turnLeft().ret(true)
    assert(st.placeDir(geo.west))
  end)

  it('should propagate a false return', function()
    _turtle.place().ret(false, 'xyz')
    expect({st.placeDir()}, eql({false, 'xyz'}))
  end)

  -- TODO: What if the turn errors?  We don't currently handle it at all.
end)

describe('safeturtle.unsafeDigDir', function()
  it('should work with nil', function()
    _turtle.dig().ret(true)
    assert(st.unsafeDigDir())
  end)

  it('should work in current direction', function()
    _turtle.dig().ret(true)
    assert(st.unsafeDigDir(geo.east))
  end)

  it('should work up', function()
    _turtle.digUp().ret(true)
    assert(st.unsafeDigDir(geo.up))
  end)

  it('should work down', function()
    _turtle.digDown().ret(true)
    assert(st.unsafeDigDir(geo.dn))
  end)

  it('should work to left', function()
    _turtle.turnLeft().ret(true)
    _turtle.dig().ret(true)
    _turtle.turnRight().ret(true)
    assert(st.unsafeDigDir(geo.north))
  end)

  it('should work to right', function()
    _turtle.turnRight().ret(true)
    _turtle.dig().ret(true)
    _turtle.turnLeft().ret(true)
    assert(st.unsafeDigDir(geo.south))
  end)

  it('should work to rear', function()
    _turtle.turnLeft().ret(true)
    _turtle.turnLeft().ret(true)
    _turtle.dig().ret(true)
    _turtle.turnLeft().ret(true)
    _turtle.turnLeft().ret(true)
    assert(st.unsafeDigDir(geo.west))
  end)

  it('should propagate a false return', function()
    _turtle.dig().ret(false, 'xyz')
    expect({st.unsafeDigDir()}, eql({false, 'xyz'}))
  end)

  -- TODO: What if the turn errors?  We don't currently handle it at all.
end)

describe('safeturtle.dig', function()
  it('should fail when nothing in front', function()
    _turtle.inspect().ret(false)
    expect({st.dig()}, eql({false, 'No block'}))
  end)

  it('should refuse to dig a chest', function()
    _turtle.inspect().ret(true, fakeBlocks.chest)
    expect({st.dig()}, eql({false, 'Refusing to mine minecraft:chest'}))
  end)

  it('should dig again after digging a falling block', function()
    _turtle.inspect().ret(true, fakeBlocks.sand)
    _turtle.dig().ret(true)
    mc.expect(os.sleep)(1)
    _turtle.inspect().ret(true, fakeBlocks.stone)
    _turtle.dig().ret(true)
    -- done setting up mocks: dig should succeed
    assert(st.dig())
  end)

  it('should dig when clear', function()
    _turtle.inspect().ret(true, fakeBlocks.stone)
    _turtle.dig().ret(true)
    -- done setting up mocks: dig should succeed
    assert(st.dig())
  end)
end)

describe('safeturtle.digDown', function()
  it('should fail when nothing below', function()
    _turtle.inspectDown().ret(false)
    expect({st.digDown()}, eql({false, 'No block'}))
  end)

  it('should refuse to dig a chest', function()
    _turtle.inspectDown().ret(true, fakeBlocks.chest)
    expect({st.digDown()}, eql({false, 'Refusing to mine minecraft:chest'}))
  end)

  it('should dig when clear', function()
    _turtle.inspectDown().ret(true, fakeBlocks.stone)
    _turtle.digDown().ret(true)
    -- done setting up mocks: dig should succeed
    assert(st.digDown())
  end)
end)

describe('safeturtle.digUp', function()
  it('should fail when nothing above', function()
    _turtle.inspectUp().ret(false)
    expect({st.digUp()}, eql({false, 'No block'}))
  end)

  it('should refuse to dig a chest', function()
    _turtle.inspectUp().ret(true, fakeBlocks.chest)
    expect({st.digUp()}, eql({false, 'Refusing to mine minecraft:chest'}))
  end)

  it('should dig again after digging a falling block', function()
    _turtle.inspectUp().ret(true, fakeBlocks.sand)
    _turtle.digUp().ret(true)
    mc.expect(os.sleep)(1)
    _turtle.inspectUp().ret(true, fakeBlocks.stone)
    _turtle.digUp().ret(true)
    -- done setting up mocks: dig should succeed
    assert(st.digUp())
  end)

  it('should dig when clear', function()
    _turtle.inspectUp().ret(true, fakeBlocks.stone)
    _turtle.digUp().ret(true)
    -- done setting up mocks: dig should succeed
    assert(st.digUp())
  end)
end)
