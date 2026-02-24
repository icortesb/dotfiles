return {
    "stevearc/conform.nvim",
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                html = { "prettier" },
                css = { "prettier" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                astro = { "prettier" },
                php = { "php_cs_fixer" },
                json = { "prettier" },
                lua = { "stylua" },
            },

            formatters = {
                -- Configuración de Prettier (para encontrar plugins globales)
                prettier = {
                    require_cwd = false,
                    prefer_local = false,
                    args = {
                        "--plugin=/usr/lib/node_modules/prettier-plugin-astro/dist/index.js",
                        "--stdin-filepath",
                        "$FILENAME",
                    },
                    env = {
                        NODE_PATH = "/usr/lib/node_modules",
                    },
                },
                -- Configuración de PHP CS Fixer (PARA SOLUCIONAR TU ERROR)
                php_cs_fixer = {
                    env = {
                        PHP_CS_FIXER_IGNORE_ENV = "1", -- Ignora el error de versión de PHP
                    },
                },
            },

            format_on_save = {
                lsp_fallback = true,
                timeout_ms = 1000,
                async = false,
            },
        })
    end,
}
