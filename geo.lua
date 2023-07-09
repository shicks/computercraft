-- Coordinate class.

P = {mt = {}, prototype = {}}

setmetatable(P, {
  __call = function(_, x, y, z)
    return setmetatable({_p = {x or 0, y or 0, z or 0}}, P.mt)
  end,
})

function P.mt.__index(p, prop)
  if prop == 'x' then return p._p[1]
  elseif prop == 'y' then return p._p[2]
  elseif prop == 'z' then return p._p[3]
  else return P.prototype[prop] end
end

function P.mt.__newindex()
  error('P is immutable')
end

function P.mt.__add(a, b)
  return P(a._p[1] + b._p[1], a._p[2] + b._p[2], a._p[3] + b._p[3])
end

function P.mt.__sub(a, b)
  return P(a._p[1] - b._p[1], a._p[2] - b._p[2], a._p[3] - b._p[3])
end

function P.mt.__unm(a)
  return P(-a._p[1], -a._p[2], -a._p[3])
end

function P.mt.__eq(a, b)
  return a._p[1] == b._p[1] and a._p[2] == b._p[2] and a._p[3] == b._p[3]
end

function P.prototype:x()
  return self._p[1]
end

function P.prototype:y()
  return self._p[2]
end

function P.prototype:z()
  return self._p[3]
end

function P.prototype:str()
  return ('(%d, %d, %d)'):format(self._p[1], self._p[2], self._p[3])
end

-- Direction.

Dir = {mt = {}}
setmetatable(Dir, {
  __call = function(_, name)
   if name == 'E' then return east end
   if name == 'W' then return west end
   if name == 'N' then return north end
   if name == 'S' then return south end
   if name == 'U' then return up end
   if name == 'D' then return dn end
   return nil
  end,
})
function Dir.mt.__index(d, p)
  return d._t[p]
end
function Dir.mt.__newindex()
  error('Dir is immutable')
end
function Dir._new(name)
  return setmetatable({_t = {name = name}}, Dir.mt)
end

east = Dir._new('E')
west = Dir._new('W')
north = Dir._new('N')
south = Dir._new('S')
up = Dir._new('U')
dn = Dir._new('D')

east._t.left = north
north._t.left = west
west._t.left = south
south._t.left = east
up._t.left = up
dn._t.left = dn

east._t.right = south
south._t.right = west
west._t.right = north
north._t.right = east
up._t.right = up
dn._t.right = dn

east._t.back = west
south._t.back = north
west._t.back = east
north._t.back = south
-- This one is a little questionable...? but back = left.left
up._t.back = up
dn._t.back = dn

east._t.delta = P(1, 0, 0)
west._t.delta = -east.delta
north._t.delta = P(0, 0, -1)
south._t.delta = -north.delta
up._t.delta = P(0, 1, 0)
dn._t.delta = -up.delta


-- Memory.

function loadPos()
  f = fs.open('pos', 'r')
  if f == nil then
    return P()
  end
  x = tonumber(f.readLine())
  y = tonumber(f.readLine())
  z = tonumber(f.readLine())
  return P(x, y, z)
end

function loadDir()
  f = fs.open('dir', 'r')
  if f == nil then
    return east
  end
  return Dir(f.read())
end

function writePos(p)
  f = fs.open('pos', 'w')
  f.write(p.x .. '\n' .. p.y .. '\n' .. p.z)
  f.close()
end

function writeDir(d)
  f = fs.open('dir', 'w')
  f.write(d.name)
  f.close()
end
