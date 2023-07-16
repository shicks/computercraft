-- Library for safe turtle movement/manipulation

local exports = {}

local blocks = require('blocks')
local geo = require('geo')

local currentPos = geo.loadPos()
local currentDir = geo.loadDir()
local fillSlot = 0
local bucketSlot = 0
local emptySlot = 0


local function _withDir(dir, fn, fnUp, fnDn)
  if dir == geo.up then
    if not fnUp then error('no up function') end
    return fnUp()
  elseif dir == geo.dn then
    if not fnDn then error('no down function') end
    return fnDn()
  elseif dir == nil then
    return fn()
  else
    local lastDir = currentDir
    turnTo(dir)
    local result = {fn()}
    turnTo(lastDir)
    return unpack(result)
  end
end


local function _withForward(dir, fn)
  if dir == geo.up or dir == geo.dn or dir == currentDir or dir == nil then
    return fn()
  else
    local lastDir = currentDir
    turnTo(dir)
    local result = {fn()}
    turnTo(lastDir)
    return unpack(result)
  end
end


local function inspectDir(dir)
  return _withDir(dir, turtle.inspect, turtle.inspectUp, turtle.inspectDn)
end
exports.inspectDir = inspectDir


local function placeDir(dir)
  return _withDir(dir, turtle.place, turtle.placeUp, turtle.placeDn)
end
exports.placeDir = placeDir


local function unsafeDigDir(dir)
  return _withDir(dir, turtle.dig, turtle.digUp, turtle.digDown)
end
exports.unsafeDigDir = unsafeDigDir


-- NOTE: This does not turn back to the side
local function digDir(dir)
  if dir == geo.up then
    return digUp()
  elseif dir == geo.dn then
    return digDown()
  else
    turnTo(dir)
    return dig()
  end
end
exports.digDir = digDir


local function dig()
  -- Look at what's ahead.
  local ok, info = turtle.inspect()
  if not ok then return false, 'No block' end

  -- Safety: don't dig certain rare blocks
  if blocks.isDoNotMine(info) then
    return false, 'Refusing to mine ' .. info.name
  end

  -- Check for blocks with gravity and dig repeatedly
  if blocks.hasGravity(info) then
    -- Dig until the gravel is cleared
    local ok, reason = turtle.dig()
    if not ok then return false, reason end
    os.sleep(1)
    return dig()
  end

  local ok, reason = turtle.dig()
  if not ok then return false, reason end

  -- TODO - what about if this caused other gravity blocks to fall??
  -- should we check ahead again??
  -- don't really want to wait a second
  --   - could maybe check _above_ after we move?
  --   - digAndMove?

  return true
end
exports.dig = dig


local function digDown()
  -- Look at what's there.
  local ok, info = turtle.inspectDown()
  if not ok then return false, 'No block' end

  -- Safety: don't dig certain rare blocks
  if blocks.isDoNotMine(info) then
    return false, 'Refusing to mine ' .. info.name
  end

  return turtle.dig()
end
exports.digDown = digDown


local function digUp()
  -- Look at what's there.
  local ok, info = turtle.inspectUp()
  if not ok then return false, 'No block' end

  -- Safety: don't dig certain rare blocks
  if blocks.isDoNotMine(info) then
    return false, 'Refusing to mine ' .. info.name
  end

  -- Check for blocks with gravity and dig repeatedly
  if blocks.hasGravity(info) then
    -- Dig until the gravel is cleared
    local ok, reason = turtle.dig()
    if not ok then return false, reason end
    os.sleep(1)
    return dig()
  end

  return turtle.dig()
end
exports.digUp = digUp


-- Dig and then move forward.  Guards against possible race conditions if a
-- block falls after the dig.
local function digAndMove()
  local ok, reason = dig()
  if not ok then return false, reason end

  local ok, info = turtle.inspect()
  if ok and blocks.hasGravity(info) then return digAndMove() end

  return forward()
end
exports.digAndMove = digAndMove


local function _setDir(dir)
  currentDir = dir
  geo.writeDir(dir)
end
local function _setPos(pos)
  currentPos = pos
  geo.writePos(pos)
end


local function turnTo(dir)
  if currentDir == dir then return true end
  if currentDir.left == dir then return turnLeft() end
  if currentDir.right == dir then return turnRight() end
  if currentDir.back == dir then return turnAbout() end
  error('Bad direction: ' .. dir.name)
end
exports.turnTo = turnTo


local function turnLeft()
  local ok, reason = turtle.turnLeft()
  if not ok then return false, reason end
  _setDir(currentDir.left)
  return true
end
exports.turnLeft = turnLeft


local function turnRight()
  local ok, reason = turtle.turnRight()
  if not ok then return false, reason end
  _setDir(currentDir.right)
  return true
end
exports.turnRight = turnRight


local function turnAbout()
  local ok, reason = turnLeft()
  if not ok then return false, reason end
  return turnLeft()
end
exports.turnAbout = turnAbout


-- NOTE: Does not turn back
local function moveDir(dir)
  if dir == geo.up then
    return up()
  elseif dir == geo.dn then
    return down()
  elseif dir == currentDir.back then
    return back()
  end
  local ok, reason = turnTo(dir)
  if not ok then return false, reason end
  return forward()
end
exports.moveDir = moveDir


local function up()
  local ok, reason = turtle.up()
  if not ok then return false, reason end
  _setPos(currentPos + up.delta)
  return true
end
exports.up = up


local function down()
  local ok, reason = clearGravityAbove()
  if not ok then return false, reason end
  ok, reason = turtle.down()
  if not ok then return false, reason end
  _setPos(currentPos + down.delta)
  return true
end
exports.down = down


local function forward()
  local ok, reason = clearGravityAbove()
  if not ok then return false, reason end
  ok, reason = turtle.forward()
  if not ok then return false, reason end
  _setPos(currentPos + currentDir.delta)
  return true
end
exports.forward = forward


local function back()
  local ok, reason = turtle.back()
  if not ok then return false, reason end
  _setPos(currentPos - currentDir.delta)
  return true
end
exports.back = back


-- Dig up until there's no blocks with gravity directly above us.
-- This prevents potential race conditions if we somehow end up
-- beneath one of these blocks and then move out, causing it to
-- fall behind us and block the path.
local function clearGravityAbove()
  local ok, info = turtle.inspectUp()
  if ok and blocks.hasGravity(info) then return digUp() end
  return true
end
exports.clearGravityAbove = clearGravityAbove


-- Try to get to a given position.  Will dig through natural blocks.
function goTo(pos)
  local dir = pos - currentPos
  -- sort directions, try to go the biggest dir first
  -- TODO - how to queue up intended directions?
  error('not implemented')
end


local function findSlot(pred, firstTry)
  if firstTry then
    if pred(firstTry) then return firstTry end
  end
  for i = 1,16 do
    if pred(i) then return i end
  end
  return 0
end
exports.findSlot = findSlot


local function findItem(name, firstTry)
  local pred = name
  if type(name) == 'string' then
    pred = function(info) return info.name == name end
  end
  return findSlot(function(i)
      local info = turtle.getItemDetail(i)
      return info and pred(info)
  end, firstTry)
end
exports.findItem = findItem


-- Try to clear a fluid in a direction.
-- This requires looking at inventory a bit.
local function clearFluidDir(dir)
  if not dir then dir = currentDir end
  return _withForward(dir, function()
    local ok, info = inspectDir(dir)
    if not ok or not blocks.isFluid(info) then return true end
    -- we have a fluid, so try to fill it
    local delay = 0.5
    if info.name == 'minecraft:lava' then delay = 2 end
    if blocks.isLavaSource(info) and turtle.getFuelLevel() < turtle.getFuelLimit() then
      -- it's a lava source, so try to use it to refuel
      bucketSlot = findItem('minecraft:bucket', bucketSlot)
      if bucketSlot > 0 then
        emptySlot = findSlot(function(i)
            return turtle.getItemCount(i) == 0 end,
          emptySlot)
        if turtle.getItemCount(bucketSlot) == 1 or emptySlot > 0 then
          turtle.select(bucketSlot)
          if placeDir(dir) then
            local fuelSlot = findItem('minecraft:lava_bucket', bucketSlot)
            if fuelSlot > 0 then
              turtle.select(fuelSlot)
              turtle.refuel()
              if fuelSlot != bucketSlot then turtle.transferTo(bucketSlot) end
            end
            os.sleep(2) -- give some time to reflow
            ok, info = inspectDir(dir)
            if not ok or not blocks.isFluid(info) then return true end
          end
        end
      end
    end
    -- find a fill block in inventory
    fillSlot = findItem(blocks.isFill, fillSlot)
    if fillSlot == 0 then return false, 'no suitable fill item' end
    turtle.select(fillSlot)
    ok, reason = placeDir(dir)
    if not ok then return false, reason end
    ok, reason = unsafeDigDir(dir)
    if not ok then return false, reason end
    os.sleep(delay)
    ok, info = inspectDir(dir)
    if ok and blocks.isFluid(info) then
      ok, reason = placeDir(dir)
      if not ok then return false, reason end
    end
    return true
  end)
end
exports.clearFluidDir = clearFluidDir


local function getCurrentDir()
  return currentDir
end
exports.getCurrentDir = getCurrentDir


local function fillDir(dir)
  fillSlot = findItem(blocks.isFill, fillSlot)
  if fillSlot == 0 then return false, 'no suitable fill item' end
  turtle.select(fillSlot)
  return placeDir(dir)
end
exports.fillDir = fillDir


return exports
