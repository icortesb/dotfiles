return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
        require("copilot").setup({
            panel = {
                enabled = false,
            },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = "<Tab>",
                },
            },
        })
        vim.api.nvim_set_hl(0, "CopilotSuggestion", {
            fg = "#3d8f7a",
            italic = true,
        })
        vim.keymap.set("n", "<leader>tc", function()
            vim.cmd("Copilot toggle")
        end, { desc = "Toggle Copilot" })
    end,
}
