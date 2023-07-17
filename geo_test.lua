require('testutil')

local geo = require('geo')
local P = geo.P

describe('geo.P', function()
  it('should respect equality', function()
    assertSame(P(1, 2, 3), P(1, 2, 3))
    assertEqual(false, P(1, 2, 3) ~= P(1, 2, 3))
    assertEqual(true, P(1, 2, 3) ~= P(1, 2, 4))
    assertEqual(false, P(1, 2, 3) == P(1, 2, 4))
  end)
  it('should have a reasonable :str', function()
    assertEqual('(1, 2, 3)', P(1, 2, 3):str())
  end)
  it('should add', function()
    assertSame(P(2, 5, 8), P(1, 2, 3) + P(1, 3, 5))
  end)

  it('should subtract', function()
    assertSame(P(0, 1, 2), P(1, 3, 5) - P(1, 2, 3))
  end)

  it('should unary minus', function()
    assertSame(P(0, -1, 2), -P(0, 1, -2))
  end)

  it('should return x/y/z', function()
    local p = P(1, 3, 6)
    assertEqual(1, p.x)
    assertEqual(3, p.y)
    assertEqual(6, p.z)
  end)
end)

describe('geo.Dir', function()
  it('should parse', function()
    assertSame(geo.up, geo.Dir('U'))
    assertSame(geo.dn, geo.Dir('D'))
    assertSame(geo.west, geo.Dir('W'))
    assertSame(geo.east, geo.Dir('E'))
    assertSame(geo.north, geo.Dir('N'))
    assertSame(geo.south, geo.Dir('S'))
  end)

  it('should express relationships', function()
    assertSame(geo.up, geo.dn.opp)
    assertSame(geo.east, geo.north.right)
    assertSame(geo.west, geo.north.left)
    assertSame(geo.west, geo.east.back)
  end)
end)
