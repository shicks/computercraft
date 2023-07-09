-- Usage: pastebin get 56xkXAzY loader.lua

-- Host this on pastebin to get an easy entrance into the raw github.
-- From there, we can pull a bunch of files.

base = 'https://raw.githubusercontent.com/shicks/computercraft/main/'
rand = math.random(1, 10000000)  -- cache buster
                               
-- First thing: pull the `manifest` file.
-- This gives a list of filenames to download.
                               
manifest = http.get(base .. 'manifest?' .. rand)
repeat
  name = manifest.readLine()
  print('Fetching file ' .. name)
  f = fs.open(name, 'w')
  f.write(http.get(base .. name .. '?' .. rand).readAll())
  f.close()
until name == nil
