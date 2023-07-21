local stub = require('stub')()

local geo = require('geo')
local pos = geo.P()
local dir = geo.east

-- stub out the load/write functions
stub.replace(geo, 'loadPos', function() return pos end)
stub.replace(geo, 'loadDir', function() return dir end)
stub.replace(geo, 'writePos', function(p) pos = p end)
stub.replace(geo, 'writeDir', function(d) dir = d end)
tearDown(stub.reset)

local st = require('safeturtle')
local P = geo.P

local fakeBlocks = {
  stone = {name = 'minecraft:stone'},
  deepslate = {name = 'minecraft:deepslate'},
}

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
    expect(pos, is(P(0, 0, 0)))
  end)
  it('should start facing east', function()
    expect(dir, is(geo.east))
  end)
end)

describe('safeturtle.turnLeft', function()
  it('should update direction', function()
    turtle = mock({{'turnLeft', {}, {true}}})
    assert(st.turnLeft())
    expect(dir, is(geo.north))
  end)

  it('should propagate errors', function()
    turtle = mock({{'turnLeft', {}, {false, 'xyz'}}})
    expect({st.turnLeft()}, eql({false, 'xyz'}))
    expect(dir, is(geo.east))
  end)
end)

describe('safeturtle.turnRight', function()
  it('should update direction', function()
    turtle = mock({{'turnRight', {}, {true}}})
    assert(st.turnRight())
    expect(dir, is(geo.south))
  end)

  it('should propagate errors', function()
    turtle = mock({{'turnRight', {}, {false, 'xyz'}}})
    expect({st.turnRight()}, eql({false, 'xyz'}))
    expect(dir, is(geo.east))
  end)
end)

describe('safeturtle.turnAbout', function()
  it('should update direction', function()
    turtle = mock({
        {'turnLeft', {}, {true}},
        {'turnLeft', {}, {true}},
    })
    assert(st.turnAbout())
    expect(dir, is(geo.west))
  end)

  it('should propagate errors from the first call', function()
    turtle = mock({{'turnLeft', {}, {false, 'abc'}}})
    expect({st.turnAbout()}, eql({false, 'abc'}))
    expect(dir, is(geo.east))
  end)

  it('should propagate errors from the second call', function()
    turtle = mock({
        {'turnLeft', {}, {true}},
        {'turnLeft', {}, {false, 'abc'},
    }})
    expect({st.turnAbout()}, eql({false, 'abc'}))
    expect(dir, is(geo.north))
  end)
end)

describe('safeturtle.turnTo', function()
  it('should not turn if already facing', function()
    turtle = mock({})
    st.reset(P(), geo.east)
    assert(st.turnTo(geo.east))
    expect(dir, is(geo.east))
  end)

  it('should turn from east to north', function()
    turtle = mock({
        {'turnLeft', {}, {true}},
    })
    st.reset(P(), geo.east)
    assert(st.turnTo(geo.north))
    expect(dir, is(geo.north))
  end)

  it('should turn from east to west', function()
    turtle = mock({
        {'turnLeft', {}, {true}},
        {'turnLeft', {}, {true}},
    })
    st.reset(P(), geo.east)
    assert(st.turnTo(geo.west))
    expect(dir, is(geo.west))
  end)

  it('should turn from east to south', function()
    turtle = mock({
        {'turnRight', {}, {true}},
    })
    st.reset(P(), geo.east)
    assert(st.turnTo(geo.south))
    expect(dir, is(geo.south))
  end)

  it('should turn from north to east', function()
    turtle = mock({
        {'turnRight', {}, {true}},
    })
    st.reset(P(), geo.north)
    assert(st.turnTo(geo.east))
    expect(dir, is(geo.east))
  end)

  it('should turn from west to east', function()
    turtle = mock({
        {'turnLeft', {}, {true}},
        {'turnLeft', {}, {true}},
    })
    st.reset(P(), geo.west)
    assert(st.turnTo(geo.east))
    expect(dir, is(geo.east))
  end)

  it('should turn from south to east', function()
    turtle = mock({
        {'turnLeft', {}, {true}},
    })
    st.reset(P(), geo.south)
    assert(st.turnTo(geo.east))
    expect(dir, is(geo.east))
  end)

  it('should fail to turn to up/down', function()
    turtle = mock({})
    st.reset(P(), geo.east)
    assertThrows(st.turnTo, geo.up)
    assertThrows(st.turnTo, geo.dn)
  end)
end)

describe('safeturtle.inspectDir', function()
  it('should work with nil', function()
    turtle = mock({
      {'inspect', {}, {true, fakeBlocks.stone}},
    })
    expect({st.inspectDir()}, eql({true, fakeBlocks.stone}))
  end)

  it('should work in current direction', function()
    turtle = mock({
      {'inspect', {}, {true, fakeBlocks.stone}},
    })
    expect({st.inspectDir(geo.east)}, eql({true, fakeBlocks.stone}))
  end)

  it('should work up', function()
    turtle = mock({
      {'inspectUp', {}, {true, fakeBlocks.stone}},
    })
    expect({st.inspectDir(geo.up)}, eql({true, fakeBlocks.stone}))
  end)

  it('should work down', function()
    turtle = mock({
      {'inspectDown', {}, {true, fakeBlocks.stone}},
    })
    expect({st.inspectDir(geo.dn)}, eql({true, fakeBlocks.stone}))
  end)

  it('should work to left', function()
    turtle = mock({
      {'turnLeft', {}, {true}},
      {'inspect', {}, {true, fakeBlocks.deepslate}},
      {'turnRight', {}, {true}},
    })
    expect({st.inspectDir(geo.north)}, eql({true, fakeBlocks.deepslate}))
  end)

  it('should work to right', function()
    turtle = mock({
      {'turnRight', {}, {true}},
      {'inspect', {}, {true, fakeBlocks.deepslate}},
      {'turnLeft', {}, {true}},
    })
    expect({st.inspectDir(geo.south)}, eql({true, fakeBlocks.deepslate}))
  end)

  it('should work to rear', function()
    turtle = mock({
      {'turnLeft', {}, {true}},
      {'turnLeft', {}, {true}},
      {'inspect', {}, {true, fakeBlocks.deepslate}},
      {'turnLeft', {}, {true}},
      {'turnLeft', {}, {true}},
    })
    expect({st.inspectDir(geo.west)}, eql({true, fakeBlocks.deepslate}))
  end)

  it('should propagate a false return', function()
    turtle = mock({
      {'inspect', {}, {false, nil}},
    })
    expect({st.inspectDir()}, eql({false, nil}))
  end)

  -- TODO: What if the turn errors?  We don't currently handle it at all.
end)

describe('safeturtle.placeDir', function()
  it('should work with nil', function()
    turtle = mock({
      {'place', {}, {true}},
    })
    assert(st.placeDir())
  end)

  it('should work in current direction', function()
    turtle = mock({
      {'place', {}, {true}},
    })
    assert(st.placeDir(geo.east))
  end)

  it('should work up', function()
    turtle = mock({
      {'placeUp', {}, {true}},
    })
    assert(st.placeDir(geo.up))
  end)

  it('should work down', function()
    turtle = mock({
      {'placeDown', {}, {true}},
    })
    assert(st.placeDir(geo.dn))
  end)

  it('should work to left', function()
    turtle = mock({
      {'turnLeft', {}, {true}},
      {'place', {}, {true}},
      {'turnRight', {}, {true}},
    })
    assert(st.placeDir(geo.north))
  end)

  it('should work to right', function()
    turtle = mock({
      {'turnRight', {}, {true}},
      {'place', {}, {true}},
      {'turnLeft', {}, {true}},
    })
    assert(st.placeDir(geo.south))
  end)

  it('should work to rear', function()
    turtle = mock({
      {'turnLeft', {}, {true}},
      {'turnLeft', {}, {true}},
      {'place', {}, {true}},
      {'turnLeft', {}, {true}},
      {'turnLeft', {}, {true}},
    })
    assert(st.placeDir(geo.west))
  end)

  it('should propagate a false return', function()
    turtle = mock({
      {'place', {}, {false, 'xyz'}},
    })
    expect({st.placeDir()}, eql({false, 'xyz'}))
  end)

  -- TODO: What if the turn errors?  We don't currently handle it at all.
end)

describe('safeturtle.unsafeDigDir', function()
  it('should work with nil', function()
    turtle = mock({
      {'dig', {}, {true}},
    })
    assert(st.unsafeDigDir())
  end)

  it('should work in current direction', function()
    turtle = mock({
      {'dig', {}, {true}},
    })
    assert(st.unsafeDigDir(geo.east))
  end)

  it('should work up', function()
    turtle = mock({
      {'digUp', {}, {true}},
    })
    assert(st.unsafeDigDir(geo.up))
  end)

  it('should work down', function()
    turtle = mock({
      {'digDown', {}, {true}},
    })
    assert(st.unsafeDigDir(geo.dn))
  end)

  it('should work to left', function()
    turtle = mock({
      {'turnLeft', {}, {true}},
      {'dig', {}, {true}},
      {'turnRight', {}, {true}},
    })
    assert(st.unsafeDigDir(geo.north))
  end)

  it('should work to right', function()
    turtle = mock({
      {'turnRight', {}, {true}},
      {'dig', {}, {true}},
      {'turnLeft', {}, {true}},
    })
    assert(st.unsafeDigDir(geo.south))
  end)

  it('should work to rear', function()
    turtle = mock({
      {'turnLeft', {}, {true}},
      {'turnLeft', {}, {true}},
      {'dig', {}, {true}},
      {'turnLeft', {}, {true}},
      {'turnLeft', {}, {true}},
    })
    assert(st.unsafeDigDir(geo.west))
  end)

  it('should propagate a false return', function()
    turtle = mock({
      {'dig', {}, {false, 'xyz'}},
    })
    expect({st.unsafeDigDir()}, eql({false, 'xyz'}))
  end)

  -- TODO: What if the turn errors?  We don't currently handle it at all.
end)

describe('safeturtle.dig', function()
  it('should fail when nothing in front', function()
    turtle = mock({
      {'inspect', {}, {false}},
    })
    expect({st.dig()}, eql({false, 'No block'}))
  end)
end)
