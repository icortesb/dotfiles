-- ~/.config/nvim/lua/plugins/webdev.lua
-- ts_ls, volar, eslint are handled by lazyvim.plugins.extras.lang.typescript and .vue
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            typescript = {
              -- Force syntax-only IntelliSense (no full project/type-graph load).
              -- Workaround for repos whose tsconfig.json's include/exclude is
              -- misconfigured (e.g. missing "node_modules" in exclude), which
              -- makes vtsls try to type-check the entire dependency tree and
              -- hang for minutes. Costs cross-file features (project-wide
              -- rename, find-all-references outside open buffers) but keeps
              -- hover/completion/diagnostics for open files instant.
              tsserver = { useSyntaxServer = "always" },
            },
          },
        },
      },
    },
  },
}

