-- Usage: mine 100
-- Mines forward 100 blocks, looks around for good stuff to grab

function run(args)

  distance = args[1]

  -- First check the fuel level
  fuelNeeded = 4 * distance
  if turtle.getFuelLevel() < fuelNeeded then
    print('Not enough fuel, need at least ' .. fuelNeeded)
    exit
  end

  returnStack = {}
  retreatLength = 0
  retreating = false

  -- Look around to see if there's a block we want nearby
  function lookAround()
    ok, block = turtle.inspectDown()
    if ok and want(block) then

    end

    ok, block = turtle.inspectUp()
    if ok and want(block) then

    end

    if table.maxn(returnStack) > 0 then
      ok, block = turtle.inspect()
      if ok and want(block) then

      end
    end

    turtle.turnLeft()
    ok, block = turtle.inspect()
    if ok and want(block) then

    end

    turtle.turnRight()
    turtle.turnRight()
    ok, block = turtle.inspect()
    if ok and want(block) then

    end

    turtle.turnLeft()

    -- continue...?

  end

  -- Now start going...?

end


wantedItems = {
  'diamond_ore',
  'redstone_ore',
  'iron_ore',
  'emerald_ore',
  'lapis_ore',
  'gold_ore',
  'quartz_ore'
}


-- Returns true if we want the item whose info is passed
function want(info)
  local name = info['name']
  for i = 1, table.maxn(wantedItems) do
    local item = wantedItems[i]
    if name == 'minecraft:' .. item or name == 'minecraft:deepslate_' .. item then
      return true
    end
  end
  return false
end



run({...})
