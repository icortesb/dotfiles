return {
  {
    "mrjones2014/smart-splits.nvim",
    config = function()
      require("smart-splits").setup({})
      local ss = require("smart-splits")
      vim.keymap.set({ "n", "t" }, "<C-h>", ss.move_cursor_left)
      vim.keymap.set({ "n", "t" }, "<C-j>", ss.move_cursor_down)
      vim.keymap.set({ "n", "t" }, "<C-k>", ss.move_cursor_up)
      vim.keymap.set({ "n", "t" }, "<C-l>", ss.move_cursor_right)
      vim.keymap.set("n", "<A-h>", ss.resize_left)
      vim.keymap.set("n", "<A-j>", ss.resize_down)
      vim.keymap.set("n", "<A-k>", ss.resize_up)
      vim.keymap.set("n", "<A-l>", ss.resize_right)
    end,
  },
}
