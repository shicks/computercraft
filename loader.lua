-- Usage: pastebin get VcP2gNGe loader.lua

-- Host this on pastebin to get an easy entrance into the raw github.
-- From there, we can pull a bunch of files.

base = 'https://raw.githubusercontent.com/shicks/computercraft/main/'

-- First thing: pull the `manifest` file.
-- This gives a list of filenames to download.

manifest = http.get(base .. 'manifest')
name = manifest.readLine()
while name ~= nil do
  f = fs.open(name, 'w')
  f.write(http.get(base .. name).readAll())
  f.close()
  name = manifest.readLine()
end
