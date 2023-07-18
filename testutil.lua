function eq(left, right)
  local t = type(left)
  if t ~= type(right) then return false end
  if t == 'table' then
    local seen = {}
    for k, v in pairs(left) do
      if not eq(v, right[k]) then return false end
      seen[k] = true
    end
    for k, v in pairs(right) do
      if not seen[k] then return false end
    end
    return getmetatable(left) == getmetatable(right)
  else
    return left == right
  end
end

function dump(obj)
  if type(obj) ~= 'table' then return tostring(obj) end
  local s = '{'
  local i = 1
  local first = true
  for k, v in pairs(obj) do
    if not first then s = s .. ', ' end
    first = false
    if k ~= i then
      s = s .. tostring(k) .. ': '
    end
    i = i + 1
    s = s .. dump(v)
  end
  return s .. '}'
end

function assertEqual(expected, actual)
  if not eq(expected, actual) then
    error('Expected equal(' .. dump(expected) .. ') but got ' .. dump(actual), 2)
  end
end

function assertSame(expected, actual)
  if expected ~= actual then
    error('Expected same(' .. tostring(expected) .. ') but got ' .. tostring(actual), 2)
  end
end
