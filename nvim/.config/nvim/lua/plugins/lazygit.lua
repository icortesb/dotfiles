return {
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "LazyGit",
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    },
    config = function()
      -- optional window customization
      vim.g.lazygit_floating_window_scaling_factor = 0.9
      vim.g.lazygit_floating_window_winblend = 10
      vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
    end,
  },
}
