return {
    "ahmedkhalf/project.nvim",
    lazy = false, -- ⚠️ IMPORTANTE: no lazy-load
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        require("project_nvim").setup({
            detection_methods = { "pattern" },
            patterns = {
                ".git",
                "package.json",
                "astro.config.mjs",
            },
        })

        -- telescope integration
        require("telescope").load_extension("projects")

        -- keymap
        vim.keymap.set(
            "n",
            "<leader>fp",
            "<cmd>Telescope projects<cr>",
            { desc = "Telescope Projects" }
        )
    end,
}
