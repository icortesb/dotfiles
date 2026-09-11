-- ~/.config/nvim/lua/plugins/webdev.lua
-- ts_ls, volar, eslint are handled by lazyvim.plugins.extras.lang.typescript and .vue
--
-- Repo con tsconfig.json roto (sin "node_modules" en exclude) que hace colgar
-- a vtsls: en vez de degradar TS en todos lados, poné esto en un `.lazy.lua`
-- en la raíz de ESE repo (lazy.nvim lo carga al abrir nvim ahí y pide confianza
-- la primera vez). Modo solo-sintaxis: sin rename/referencias entre archivos.
--
--   return {
--     { "neovim/nvim-lspconfig", opts = { servers = { vtsls = { settings = {
--       typescript = { tsserver = { useSyntaxServer = "always" } },
--     } } } } },
--   }
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Reemplaza emmet-vim: las abreviaturas aparecen en el completado (blink)
        emmet_language_server = {},
      },
    },
  },
}
