-- Prints files
-- Usage: cat [file...]

for _, fn in pairs({...}) do
  f = fs.open(fn, 'r')
  if f ~= nil then
    print(f.readAll())
  else
    print('File does not exist: ' .. fn)
  end
end
