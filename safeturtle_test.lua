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

describe('safeturtle.turnLeft', function()
  it('should update direction', function()
    turtle = mock({{'turnLeft', {}, {true}}})
    assertSame(geo.east, dir)
    assert(st.turnLeft())
    assertSame(geo.north, dir)
    turtle.verify()
  end)
end)

describe('safeturtle.turnRight', function()
  it('should update direction', function()
    turtle = mock({{'turnRight', {}, {true}}})
    assertEqual(geo.east, dir)
    assert(st.turnRight())
    assertSame(geo.south, dir)
    turtle.verify()
  end)
end)
