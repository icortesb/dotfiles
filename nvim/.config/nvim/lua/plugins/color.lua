-- Variable para rastrear el estado
local is_transparent = true

-- Tu función original (sin cambios)
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

-- Nueva función para alternar
local function toggle_bg()
    is_transparent = not is_transparent

    if is_transparent then
        enable_transparency()
        print("Modo Transparente")
    else
        -- Al recargar el tema, se eliminan las transparencias y vuelve el fondo sólido
        vim.cmd.colorscheme("tokyonight")
        vim.cmd("filetype detect")

        -- OPCIONAL: Si quieres un gris específico diferente al de Tokyonight,
        -- descomenta la siguiente línea y pon tu código Hex:
        -- vim.api.nvim_set_hl(0, "Normal", { bg = "#3e3e3e" })

        print("Modo Foco (Sólido)")
    end
end

return {
    {
        "folke/tokyonight.nvim",
        lazy = false, -- Aseguramos que cargue al inicio
        priority = 1000,
        config = function()
            -- 1. Cargar tema inicial
            vim.cmd.colorscheme("tokyonight")

            -- 2. Aplicar transparencia inicial
            enable_transparency()

            -- 3. Crear el Keymap (Atajo)
            -- Aquí usamos <leader>bg (background), cámbialo si prefieres otro
            vim.keymap.set("n", "<leader>bg", toggle_bg, { desc = "Alternar Fondo Transparente/Sólido" })
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
