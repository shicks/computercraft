-- Usage: shaft <length>
-- TODO - recover better (a simple startup script to retreat would also work)

local st = require('safeturtle')
local geo = require('geo')
local blocks = require('blocks')

function check(dir)
  local ok, info = st.inspectDir(dir)
  if ok and blocks.isValuable(info) then
    local ok, reason = st.digDir(dir)
    if not ok then return false, reason end
    os.sleep(2)
    return st.clearFluidDir(dir)
  end
  return st.clearFluidDir(dir)
end

function run(args)

  local distance = args[1]
  local dir = geo.dn

  -- First check the fuel level
  local fuelNeeded = 4 * distance
  if turtle.getFuelLevel() < fuelNeeded then
    print('Not enough fuel, need at least ' .. fuelNeeded)
    exit()
  end

  local retreatLength = 0

  for i = 1, distance do
    st.dig()
    st.digDir(dir)

    if dir == geo.up then
      st.fillDir(geo.dn)
    end

    st.clearFluidDir()
    -- NOTE: this could possibly 

    check(dir.opp)
    st.turnLeft()
    check()
    st.turnAbout()
    check()
    
    local ok, reason = st.moveDir(dir)
    if not ok then
      st.turnLeft()
      print('abort: ' .. reason)
      break
    end

    check(dir)
    if dir == geo.dn then
      st.fillDir(geo.dn)
    end

    dir = dir.opp
    check()
    st.turnAbout()
    check()
    st.turnRight()

    -- Check for fallen blocks
    local fwd = st.forward
    local ok, info = turtle.inspect()
    if ok and blocks.hasGravity(info) then fwd = st.digAndMove end

    local ok, reason = fwd()
    if not ok then
      print('abort: ' .. reason)
      break
    end
    retreatLength = retreatLength + 1
  end

  for i = 1, retreatLength do
    st.back()
  end
  if dir == geo.up then
    st.up()
  end
end


run({...})
