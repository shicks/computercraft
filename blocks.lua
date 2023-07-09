-- Library for metadata about blocks

function hasGravity(info)
  if info == nil then
    return false
  end
  local name = info['name']:gsub('^[^:]*:', '')
  return name == 'sand' or name == 'gravel'
end

valuablePats = {
  'ore',
  'diamond',
  'redstone',
  'lapis',
  'gold',
  'iron',
  'copper',
  'sand',
  'gravel',
  'quartz',
  'prismarine',
  'debris',
  'sponge',
  'obsidian',
}

local function findAny(s, t)
  for _, p in pairs(t) do
    if s:find(p) then return true end
  end
  return false
end

function isValuable(info)
  if info == nil then
    return false
  end
  local name = info['name']:gsub('^[^:]*:', '')
  -- note: don't mine redstone components, only ore
  if findAny(name, valuablePats) then
    return true
  end
  if findAny(name, {'stone', 'deepslate'}) then
    return false
  end

  -- TODO: unknown thing... how to handle?
  

  return false
end

doNotMinePats = {
  'glass',
  'spawner',
  'budding_amethyst',
  'chest',
  'barrel',
  'turtle',
  'computer',
  'shulker',
  'torch',
  'redstone_dust',
  'comparator',
  'repeater',
  'rail',
  -- should probably avoid work blocks, too...?
}

-- TODO - probably stick to just "digIfExpected(?)"
--      - where we expect natural ores...?
--    Can we teach it to go around surprising things? or just go home?

function isDoNotMine(info)
  if info == nil then
    return false
  end
  local name = info['name']:gsub('^[^:]*:', '')
  return findAny(name, doNotMinePats)
end
