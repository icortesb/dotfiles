return {
  {
    "ahmedkhalf/project.nvim",
    lazy = false,
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern" },
        patterns = {
          ".git",
          "package.json",
          "astro.config.mjs",
        },
      })
      -- defer extension loading so telescope is fully initialized
      vim.schedule(function()
        require("telescope").load_extension("projects")
      end)
      vim.keymap.set("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Telescope Projects" })
    end,
  },
}
