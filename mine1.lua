-- Usage: mine 100
-- Mines forward 100 blocks, looks around for good stuff to grab

function run(args)

  distance = args[1]

  -- First check the fuel level
  fuelNeeded = 2 * distance
  if turtle.getFuelLevel() < fuelNeeded then
    print('Not enough fuel, need at least ' .. fuelNeeded)
    exit
  end

  retreatLength = 0

  for i = 1, distance do
    turtle.dig()
    turtle.digUp()
    if not turtle.forward() then
      break
    end
    retreatLength = retreatLength + 1
  end

  for i = 1, retreatLength do
    turtle.back()
  end
end


run({...})
