local geo = {}

-- Coordinate class.

geo.P = {mt = {}, prototype = {}}
local P = geo.P

setmetatable(geo.P, {
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

function P.prototype:str()
  return ('(%d, %d, %d)'):format(self._p[1], self._p[2], self._p[3])
end

-- Direction.

local Dir = {mt = {}}
geo.Dir = Dir

setmetatable(Dir, {
  __call = function(_, name)
   if name == 'E' then return geo.east end
   if name == 'W' then return geo.west end
   if name == 'N' then return geo.north end
   if name == 'S' then return geo.south end
   if name == 'U' then return geo.up end
   if name == 'D' then return geo.dn end
   return nil
  end,
})
function Dir.mt.__index(d, p)
  return d._t[p]
end
function Dir.mt.__newindex()
  error('Dir is immutable')
end
function Dir.mt.__tostring(d)
  return 'Dir(' .. d._t.name .. ')'
end
function Dir._new(name)
  return setmetatable({_t = {name = name}}, Dir.mt)
end

geo.east = Dir._new('E')
geo.west = Dir._new('W')
geo.north = Dir._new('N')
geo.south = Dir._new('S')
geo.up = Dir._new('U')
geo.dn = Dir._new('D')

geo.east._t.left = geo.north
geo.north._t.left = geo.west
geo.west._t.left = geo.south
geo.south._t.left = geo.east
geo.up._t.left = geo.up
geo.dn._t.left = geo.dn

geo.east._t.right = geo.south
geo.south._t.right = geo.west
geo.west._t.right = geo.north
geo.north._t.right = geo.east
geo.up._t.right = geo.up
geo.dn._t.right = geo.dn

geo.east._t.back = geo.west
geo.south._t.back = geo.north
geo.west._t.back = geo.east
geo.north._t.back = geo.south
-- This one is a little questionable...? but back = left.left
geo.up._t.back = geo.up
geo.dn._t.back = geo.dn

geo.east._t.opp = geo.west
geo.south._t.opp = geo.north
geo.west._t.opp = geo.east
geo.north._t.opp = geo.south
geo.up._t.opp = geo.dn
geo.dn._t.opp = geo.up

geo.east._t.delta = P(1, 0, 0)
geo.west._t.delta = -geo.east.delta
geo.north._t.delta = P(0, 0, -1)
geo.south._t.delta = -geo.north.delta
geo.up._t.delta = P(0, 1, 0)
geo.dn._t.delta = -geo.up.delta


-- Memory.

function geo.loadPos()
  local f = fs.open('pos', 'r')
  if f == nil then
    return P()
  end
  local x = tonumber(f.readLine())
  local y = tonumber(f.readLine())
  local z = tonumber(f.readLine())
  return P(x, y, z)
end

function geo.loadDir()
  local f = fs.open('dir', 'r')
  if f == nil then
    return east
  end
  return Dir(f.read())
end

function geo.writePos(p)
  f = fs.open('pos', 'w')
  f.write(p.x .. '\n' .. p.y .. '\n' .. p.z)
  f.close()
end

function geo.writeDir(d)
  f = fs.open('dir', 'w')
  f.write(d.name)
  f.close()
end


return geo
