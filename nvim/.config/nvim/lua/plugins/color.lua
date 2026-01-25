local function enable_transparency()
    local groups = {
        "Normal",
        "NormalNC",
        "VertSplit",
        "StatusLine",
        "LineNr",
        "Folded",
        "NormalFloat",
        "FloatBorder",
    }

    for _, group in ipairs(groups) do
        vim.api.nvim_set_hl(0, group, { bg = "none" })
    end
end

return {
    {
        "folke/tokyonight.nvim",
        config = function()
            vim.cmd.colorscheme("tokyonight")
            enable_transparency() -- aplicar transparencia después del theme
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            theme = "tokyonight",
        },
    },
}
