-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- <leader>fg = live grep (override LazyVim's git_files which requires a git repo)
map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Live Grep" })

-- Guardar y cerrar buffer manteniendo el layout (como Ctrl+W en otros editores).
-- Va en <leader>bw para no tapar el grupo de ventanas (<leader>w*).
-- Para cerrar sin guardar usá <leader>bd (LazyVim, también con Snacks.bufdelete).
map("n", "<leader>bw", function()
  vim.cmd("w")
  Snacks.bufdelete()
end, { desc = "Guardar y Cerrar Buffer" })
