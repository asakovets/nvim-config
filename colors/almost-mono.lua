-- You probably always want to set this in your vim file
vim.opt.background = "light"
vim.g.colors_name = "almost-mono"

-- By setting our module to nil, we clear lua's cache,
-- which means the require ahead will *always* occur.
--
-- This isn't strictly required but it can be a useful trick if you are
-- incrementally editing your config a lot and want to be sure your themes
-- changes are being picked up without restarting neovim.
--
-- Note if you're working in on your theme and have :Lushify'd the buffer,
-- your changes will be applied with our without the following line.
--
-- The performance impact of this call can be measured in the hundreds of
-- *nanoseconds* and such could be considered "production safe".
package.loaded["lush_theme.almost-mono"] = nil

-- include our theme file and pass it to lush to apply
require ("lush") (require ("lush_theme/almost-mono"))

-- Return our parsed theme for extension or use elsewhere.
vim.g.terminal_color_0 = "#000000" -- black
vim.g.terminal_color_1 = "#DC322F" -- red
vim.g.terminal_color_2 = "#009908" -- green
vim.g.terminal_color_3 = "#B58900" -- yellow
vim.g.terminal_color_4 = "#268BD2" -- blue
vim.g.terminal_color_5 = "#D33682" -- magenta
vim.g.terminal_color_6 = "#2AA198" -- cyan
vim.g.terminal_color_7 = "#000000" -- white

-- All bright colors dimmed to black :
vim.g.terminal_color_8 = "#000000"
vim.g.terminal_color_9 = "#CB4B16"
vim.g.terminal_color_10 = "#586E75"
vim.g.terminal_color_11 = "#3c3f40"
vim.g.terminal_color_12 = "#839496"
vim.g.terminal_color_13 = "#6C71C4"
vim.g.terminal_color_14 = "#93A1A1"
vim.g.terminal_color_15 = "#000000"
