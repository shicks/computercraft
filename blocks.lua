-- Library for metadata about blocks

local exports = {}

local function hasGravity(info)
  if info == nil then
    return false
  end
  local name = info['name']:gsub('^[^:]*:', '')
  return name == 'sand' or name == 'gravel'
end
exports.hasGravity = hasGravity

local valuablePats = {
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
exports.isValuable = isValuable

local doNotMinePats = {
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

local function isDoNotMine(info)
  if info == nil then
    return false
  end
  local name = info['name']:gsub('^[^:]*:', '')
  return findAny(name, doNotMinePats)
end
exports.isDoNotMine = isDoNotMine


local naturalPats = {
  '^andesite$',
  '^basalt$',
  '^blackstone$',
  '^calcite$',
  'clay',
  'dirt', -- includes dirt_path, coarse_dirt
  '^granite$',
  'grass', -- includes grass plant and grass_block
  'gravel',
}


local digThroughTags = {
  -- 'sand',
  -- 'gravel',
  -- 'base_stone_overworld',
  -- 'dirt',
  -- 'nether_carver_replaceables',
  -- 'overworld_carver_replaceables',
  'obsidian',
  'replaceable_plants',
  'skulk_replaceable',
}

-- dig through these blocks when trying to go to a position
local function shouldDigThrough(info)
  if info == nil then return false end
  for _, t in pairs(digThroughTags) do
    if info.tags['minecraft:' .. t] then return true end
  end
  return false
end
exports.shouldDigThrough = shouldDigThrough

local canTravelThroughNames = {
  ['minecraft:lava'] = true,
  ['minecraft:water'] = true,
}

local function canTravelThrough(info)
  if info == nil then return true end
  if canTravelThroughNames[info.name] then return true end
  return false
end
exports.canTravelThrough = canTravelThrough


local fillNames = {
  ['minecraft:cobblestone'] = true,
  ['minecraft:cobbled_deepslate'] = true,
}

local function isFill(info)
  if info == nil then return false end
  if fillNames[info.name] then return true end
  return false
end
exports.isFill = isFill


local function isWater(info)
  return info ~= nil and info.name == 'minecraft:water'
end
exports.isWater = isWater

local function isWaterSource(info)
  return isWater(info) and info.state.level == 0
end
exports.isWaterSource = isWaterSource

-- NOTE: includes waterlogged blocks
local function isFlowingWater(info)
  if info == nil then return false end
  if isWater(info) then return info.state.level ~= 0 end
  return info.state.waterlogged == true
end
exports.isFlowingWater = isFlowingWater

local function isLavaSource(info)
  return info ~= nil and info.name == 'minecraft:lava' and info.state.level == 0
end
exports.isLavaSource = isLavaSource

local function isFlowingLava(info)
  return info ~= nil and info.name == 'minecraft:lava' and info.state.level ~= 0
end
exports.isFlowingLava = isFlowingLava


local function isFluid(info)
  if info == nil then return false end
  return info.name == 'minecraft:water' or info.name == 'minecraft:lava' or info.state.waterlogged == true
end
exports.isFluid = isFluid


return exports
