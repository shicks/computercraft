require('testutil')

local geo = require('geo')
local pos = geo.P()
local dir = geo.east
geo.loadPos = function() return pos end
geo.loadDir = function() return dir end
geo.writePos = function(p) pos = p end
geo.writeDir = function(d) dir = d end

local mock = require('mock')

local st = require('safeturtle')
local P = geo.P

beforeEach(function()
  st.reset(geo.P(), geo.east)
end)

afterEach(function()
  if turtle then
    turtle.verify()
    turtle = nil
  end
end)

describe('test harness', function()
  it('should start at (0,0,0)', function()
    assertSame(P(0, 0, 0), pos)
  end)
  it('should start facing east', function()
    assertSame(geo.east, dir)
  end)
end)

describe('safeturtle.turnLeft', function()
  it('should update direction', function()
    turtle = mock({{'turnLeft', {}, {true}}})
    assert(st.turnLeft())
    assertSame(geo.north, dir)
  end)

  it('should propagate errors', function()
    turtle = mock({{'turnLeft', {}, {false, 'xyz'}}})
    local ok, reason = st.turnLeft()
    assertSame(false, ok)
    assertSame('xyz', reason)
    assertSame(geo.east, dir)
  end)
end)

describe('safeturtle.turnRight', function()
  it('should update direction', function()
    turtle = mock({{'turnRight', {}, {true}}})
    assert(st.turnRight())
    assertSame(geo.south, dir)
  end)

  it('should propagate errors', function()
    turtle = mock({{'turnRight', {}, {false, 'xyz'}}})
    local ok, reason = st.turnRight()
    assertSame(false, ok)
    assertSame('xyz', reason)
    assertSame(geo.east, dir)
  end)
end)

describe('safeturtle.turnAbout', function()
  it('should update direction', function()
    turtle = mock({
        {'turnLeft', {}, {true}},
        {'turnLeft', {}, {true}},
    })
    assert(st.turnAbout())
    assertSame(geo.west, dir)
  end)

  it('should propagate errors from the first call', function()
    turtle = mock({{'turnLeft', {}, {false, 'abc'}}})
    ok, reason = st.turnAbout()
    assertSame(false, ok)
    assertSame('abc', reason)
    assertSame(geo.east, dir)
  end)

  it('should propagate errors from the second call', function()
    turtle = mock({
        {'turnLeft', {}, {true}},
        {'turnLeft', {}, {false, 'abc'},
    }})
    ok, reason = st.turnAbout()
    assertSame(false, ok)
    assertSame('abc', reason)
    assertSame(geo.north, dir)
  end)
end)

describe('safeturtle.turnTo', function()
  it('should turn from east to north', function()
    turtle = mock({
        {'turnLeft', {}, {true}},
    })
    st.reset(P(), geo.east)
    assert(st.turnTo(geo.north))
    assertSame(geo.north, dir)
  end)

  it('should turn from east to west', function()
    turtle = mock({
        {'turnLeft', {}, {true}},
        {'turnLeft', {}, {true}},
    })
    st.reset(P(), geo.east)
    assert(st.turnTo(geo.west))
    assertSame(geo.west, dir)
  end)

  it('should turn from east to south', function()
    turtle = mock({
        {'turnRight', {}, {true}},
    })
    st.reset(P(), geo.east)
    assert(st.turnTo(geo.south))
    assertSame(geo.south, dir)
  end)
end)
