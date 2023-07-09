-- Prints files
-- Usage: cat [file...]

for fn in {...} do
  f = fs.open(fn, 'r')
  if f ~= nil then
    print(f.readAll())
  else
    print('File does not exist: ' .. fn)
  end
end
