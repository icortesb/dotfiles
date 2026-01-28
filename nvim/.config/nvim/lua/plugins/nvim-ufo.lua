-- plugins/ufo.lua
return {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
        -- Opcional: Para mejorar la estética de los folds
        -- "luukvbaal/statuscol.nvim",
    },
    event = "BufReadPost", -- Cargar al leer un archivo
    config = function()
        local ufo = require("ufo")

        -- Configuración recomendada por el autor de nvim-ufo
        vim.o.foldcolumn = "1" -- Muestra una barrita a la izquierda con el nivel de fold
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true

        -- Configuración clave: Prioridad de proveedores
        -- Intenta usar LSP primero, luego Treesitter, y si fallan, usa indentación.
        require("ufo").setup({
            provider_selector = function(bufnr, filetype, buftype)
                return { "treesitter", "indent" }
            end,
        })

        -- Atajos de teclado para abrir/cerrar todo
        vim.keymap.set("n", "zR", ufo.openAllFolds)
        vim.keymap.set("n", "zM", ufo.closeAllFolds)
        -- 'za' ya funciona por defecto
    end,
}
