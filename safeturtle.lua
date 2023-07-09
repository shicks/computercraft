-- Library for safe turtle movement/manipulation

loadAPI('blocks.lua')
loadAPI('geo.lua')

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
    return false
  end

  -- Safety: don't dig certain rare blocks
  if blocks.isDoNotMine(info) then
    return false
  end

  -- Check for blocks with gravity and dig repeatedly
  if blocks.hasGravity(info) then
    -- Dig until the gravel is cleared
    if not turtle.dig() then
      return false
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
  if not turtle.turnLeft() then return false end
  _setDir(currentDir.left)
  return true
end

function turnRight()
  if not turtle.turnRight() then return false end
  _setDir(currentDir.right)
  return true
end

function turnAbout()
  if not turnLeft() then return false end
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
  if not turnTo(dir) then return false end
  return forward()
end

function up()
  if not turtle.up() then return false end
  _setPos(currentPos + up.delta)
  return true
end

function down()
  if not turtle.down() then return false end
  _setPos(currentPos + down.delta)
  return true
end

function forward()
  if not turtle.forward() then return false end
  _setPos(currentPos + currentDir.delta)
  return true
end

function back()
  if not turtle.back() then return false end
  _setPos(currentPos - currentDir.delta)
  return true
end
