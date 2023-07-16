-- Dig a tunnel.
--  1. Fill in torches every 20 blocks.
--  2. Build bridges over gaps.
--  3. Dig out veins.
--  4. Fill in fluid sources in path and on walls.
--  5. If fluid is still flowing in after eliminating sources,
--     then enclose with stone, iron bars/chains, doors, or glass.

-- NOTE: This will not protect against mobs wandering in from
-- a connected dark tunnel.  To avoid this, we'd need to just
-- fully enclose the tunnel, but we'd like a way to indicate
-- that there's something interesting to explore...

-- One possibility would be to use a different material for the
-- enclosure (i.e. deepslate bricks, which are easy to craft
-- from what we dig out) or to change the shape in a noticeable
-- way.  Or else to carry a large stack of a (less-renewable)
-- material, such as glass or iron bars.

-- In terms of flowing water/lava, we could potentially just
-- remove sources that are in or adjacent to the tunnel line,
-- and fill in blocks above the adjacent ones.  This wouldn't
-- necessarily eliminate _all_ flows, but (1) they'd be easier
-- to block out manually when they do survive, and (2) adjacent
-- tunnels would be able to take out the other sources.

-- Priority order:
--  1. digging out veins seems most important, since we don't
--     really need to bother going into the tunnel at all if
--     it's not leaving anything behind (except maybe to
--     explore interesting things?)
--      * but also, irrelevant if we're being exhaustive?
--  2. floor and ceiling

-- Considerations:
--  1. We should be able to pick up where we left off.
--      * keep the /currentTask file up-to-date?
--      * `tunnel n 100`
--      * `tunnel 0 0 0 n 100` - auto-backtrack could be hard?
--      * `tunnel --continue n 100 -- w u` for backtracking?

--  2. If we hit a "Do Not Mine" block, just try to go over/under?
--     What if we can't get around it? - just go back...

-- State:
--  tunnel 

--      x
--     x x
--    nx x
--   n nx3
--  1n n3 3 4
-- 1 1n23 34 4
-- 1 12 23c4 4
--  1a2 2c c4
--  a a2bc c
--  a ab bc
--   a b b
--      b

-- plan: dig tunnel for N blocks
--       forward 8 blocks on other side
--       dig tunnel back N blocks
--       forward 8 more...?
--   when to return to drop off stuff?
--   when to go back and change Y level?
--   can we auto-detect where to start?
