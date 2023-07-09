-- Library for safe turtle movement/manipulation

os.loadAPI('blocks.lua')
os.loadAPI('geo.lua')

currentPos = geo.loadPos()
currentDir = geo.loadDir()

function digDir(dir)
  -- Compare to current direction
  if dir == geo.up then
    digUp()
  elseif dir == geo.dn then
    digDown()
  else
    turnTo(dir)
    dig()
  end
end

function dig()
  -- Look at what's ahead.
  ok, info = turtle.inspect()
  if not ok then
    return false, 'no block'
  end

  -- Safety: don't dig certain rare blocks
  if blocks.isDoNotMine(info) then
    return false, 'refuse to mine ' .. info.name
  end

  -- Check for blocks with gravity and dig repeatedly
  if blocks.hasGravity(info) then
    -- Dig until the gravel is cleared
    ok, reason = turtle.dig()
    if not ok then
      return false, reason
    end
    os.sleep(1)
    return dig()
  end

  return false
end

function _setDir(dir)
  currentDir = dir
  geo.writeDir(dir)
end
function _setPos(pos)
  currentPos = pos
  geo.writePos(pos)
end

function turnTo(dir)
  if currentDir == dir then return true end
  if currentDir.left == dir then return turnLeft() end
  if currentDir.right == dir then return turnRight() end
  if currentDir.back == dir then return turnAbout() end
  error('Bad direction: ' .. dir.name)
end

function turnLeft()
  ok, reason = turtle.turnLeft()
  if not ok then return false, reason end
  _setDir(currentDir.left)
  return true
end

function turnRight()
  ok, reason = turtle.turnRight()
  if not ok then return false, reason end
  _setDir(currentDir.right)
  return true
end

function turnAbout()
  ok, reason = turnLeft()
  if not ok then return false, reason end
  return turnLeft()
end

function moveDir(dir)
  if dir == geo.up then
    return up()
  elseif dir == geo.dn then
    return down()
  elseif dir == currentDir.back then
    return back()
  end
  ok, reason = turnTo(dir)
  if not ok then return false, reason end
  return forward()
end

function up()
  ok, reason = turtle.up()
  if not ok then return false, reason end
  _setPos(currentPos + up.delta)
  return true
end

function down()
  ok, reason = turtle.down()
  if not ok then return false, reason end
  _setPos(currentPos + down.delta)
  return true
end

function forward()
  ok, reason = turtle.forward()
  if not ok then return false, reason end
  _setPos(currentPos + currentDir.delta)
  return true
end

function back()
  ok, reason = turtle.back()
  if not ok then return false, reason end
  _setPos(currentPos - currentDir.delta)
  return true
end
