-- Library for safe turtle movement/manipulation

local st = {} -- public exports
local _ = {}  -- private (and public) members

setmetatable(_, {__index = st})

local blocks = require('blocks')
local geo = require('geo')

local currentPos = geo.loadPos()
local currentDir = geo.loadDir()
local fillSlot = 0
local bucketSlot = 0
local emptySlot = 0

function _.setDir(dir)
  currentDir = dir
  geo.writeDir(dir)
end
function _.setPos(pos)
  currentPos = pos
  geo.writePos(pos)
end


function st.reset(pos, dir)
  _.setPos(pos)
  _.setDir(dir)
end

function st.turnLeft()
  local ok, reason = turtle.turnLeft()
  if not ok then return false, reason end
  _.setDir(currentDir.left)
  return true
end

function st.turnRight()
  local ok, reason = turtle.turnRight()
  if not ok then return false, reason end
  _.setDir(currentDir.right)
  return true
end

function st.turnAbout()
  local ok, reason = _.turnLeft()
  if not ok then return false, reason end
  return _.turnLeft()
end

function st.turnTo(dir)
  if currentDir == dir then return true end
  if currentDir.left == dir then return _.turnLeft() end
  if currentDir.right == dir then return _.turnRight() end
  if currentDir.back == dir then return _.turnAbout() end
  error('Bad direction: ' .. dir.name)
end

function _.withDir(dir, fn, fnUp, fnDn)
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
    _.turnTo(dir)
    local result = {fn()}
    _.turnTo(lastDir)
    return unpack(result)
  end
end

function _.withForward(dir, fn)
  if dir == geo.up or dir == geo.dn or dir == currentDir or dir == nil then
    return fn()
  else
    local lastDir = currentDir
    _.turnTo(dir)
    local result = {fn()}
    _.turnTo(lastDir)
    return unpack(result)
  end
end


function st.inspectDir(dir)
  return _.withDir(dir, turtle.inspect, turtle.inspectUp, turtle.inspectDn)
end


function st.placeDir(dir)
  return _.withDir(dir, turtle.place, turtle.placeUp, turtle.placeDn)
end


function st.unsafeDigDir(dir)
  return _.withDir(dir, turtle.dig, turtle.digUp, turtle.digDown)
end


function st.dig()
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
    return _.dig()
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


function st.digDown()
  -- Look at what's there.
  local ok, info = turtle.inspectDown()
  if not ok then return false, 'No block' end

  -- Safety: don't dig certain rare blocks
  if blocks.isDoNotMine(info) then
    return false, 'Refusing to mine ' .. info.name
  end

  return turtle.dig()
end


function st.digUp()
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


-- NOTE: This does not turn back to the side
function st.digDir(dir)
  if dir == geo.up then
    return _.digUp()
  elseif dir == geo.dn then
    return _.digDown()
  else
    _.turnTo(dir)
    return dig()
  end
end


function st.up()
  local ok, reason = turtle.up()
  if not ok then return false, reason end
  _.setPos(currentPos + up.delta)
  return true
end


function st.down()
  local ok, reason = _.clearGravityAbove()
  if not ok then return false, reason end
  ok, reason = turtle.down()
  if not ok then return false, reason end
  _.setPos(currentPos + down.delta)
  return true
end


function st.forward()
  local ok, reason = _.clearGravityAbove()
  if not ok then return false, reason end
  ok, reason = turtle.forward()
  if not ok then return false, reason end
  _.setPos(currentPos + currentDir.delta)
  return true
end


function st.back()
  local ok, reason = turtle.back()
  if not ok then return false, reason end
  _.setPos(currentPos - currentDir.delta)
  return true
end


-- NOTE: Does not turn back
function st.moveDir(dir)
  if dir == geo.up then
    return up()
  elseif dir == geo.dn then
    return down()
  elseif dir == currentDir.back then
    return back()
  end
  local ok, reason = _.turnTo(dir)
  if not ok then return false, reason end
  return _.forward()
end


-- Dig and then move forward.  Guards against possible race conditions if a
-- block falls after the dig.
function st.digAndMove()
  local ok, reason = _.dig()
  if not ok then return false, reason end

  local ok, info = turtle.inspect()
  if ok and blocks.hasGravity(info) then return _.digAndMove() end

  return _.forward()
end


-- Dig up until there's no blocks with gravity directly above us.
-- This prevents potential race conditions if we somehow end up
-- beneath one of these blocks and then move out, causing it to
-- fall behind us and block the path.
function st.clearGravityAbove()
  local ok, info = turtle.inspectUp()
  if ok and blocks.hasGravity(info) then return _.digUp() end
  return true
end


-- Try to get to a given position.  Will dig through natural blocks.
function _.goTo(pos)
  local dir = pos - currentPos
  -- sort directions, try to go the biggest dir first
  -- TODO - how to queue up intended directions?
  error('not implemented')
end


function st.findSlot(pred, firstTry)
  if firstTry then
    if pred(firstTry) then return firstTry end
  end
  for i = 1,16 do
    if pred(i) then return i end
  end
  return 0
end


function st.findItem(name, firstTry)
  local pred = name
  if type(name) == 'string' then
    pred = function(info) return info.name == name end
  end
  return _.findSlot(function(i)
      local info = turtle.getItemDetail(i)
      return info and pred(info)
  end, firstTry)
end


-- Try to clear a fluid in a direction.
-- This requires looking at inventory a bit.
function st.clearFluidDir(dir)
  if not dir then dir = currentDir end
  return _.withForward(dir, function()
    local ok, info = _.inspectDir(dir)
    if not ok or not blocks.isFluid(info) then return true end
    -- we have a fluid, so try to fill it
    local delay = 0.5
    if info.name == 'minecraft:lava' then delay = 2 end
    if blocks.isLavaSource(info) and turtle.getFuelLevel() < turtle.getFuelLimit() then
      -- it's a lava source, so try to use it to refuel
      bucketSlot = _.findItem('minecraft:bucket', bucketSlot)
      if bucketSlot > 0 then
        emptySlot = _.findSlot(function(i)
            return turtle.getItemCount(i) == 0 end,
          emptySlot)
        if turtle.getItemCount(bucketSlot) == 1 or emptySlot > 0 then
          turtle.select(bucketSlot)
          if _.placeDir(dir) then
            local fuelSlot = _.findItem('minecraft:lava_bucket', bucketSlot)
            if fuelSlot > 0 then
              turtle.select(fuelSlot)
              turtle.refuel()
              if fuelSlot ~= bucketSlot then turtle.transferTo(bucketSlot) end
            end
            os.sleep(2) -- give some time to reflow
            ok, info = _.inspectDir(dir)
            if not ok or not blocks.isFluid(info) then return true end
          end
        end
      end
    end
    -- find a fill block in inventory
    fillSlot = _.findItem(blocks.isFill, fillSlot)
    if fillSlot == 0 then return false, 'no suitable fill item' end
    turtle.select(fillSlot)
    ok, reason = _.placeDir(dir)
    if not ok then return false, reason end
    ok, reason = _.unsafeDigDir(dir)
    if not ok then return false, reason end
    os.sleep(delay)
    ok, info = _.inspectDir(dir)
    if ok and blocks.isFluid(info) then
      ok, reason = _.placeDir(dir)
      if not ok then return false, reason end
    end
    return true
  end)
end


function st.getCurrentDir()
  return currentDir
end


function st.fillDir(dir)
  fillSlot = findItem(blocks.isFill, fillSlot)
  if fillSlot == 0 then return false, 'no suitable fill item' end
  turtle.select(fillSlot)
  return _.placeDir(dir)
end


return st
