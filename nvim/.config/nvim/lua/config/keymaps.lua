-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- <leader>fg = live grep (override LazyVim's git_files which requires a git repo)
map("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Live Grep" })

-- Opción A: Guardar y cerrar buffer manteniendo el layout (Como Ctrl+W en otros editores)
-- Usamos <leader>w (Espacio + w)
map("n", "<leader>w", function()
  vim.cmd("w") -- Guardar
  Snacks.bufdelete() -- Cerrar buffer usando Snacks (que maneja el layout correctamente)
end, { desc = "Guardar y Cerrar Buffer" })

-- Opción B: Solo cerrar buffer (sin guardar forzosamente) con <leader>q
map("n", "<leader>q", function()
  Snacks.bufdelete()
end, { desc = "Cerrar Buffer (Mantener Layout)" })
