-- ~/.config/nvim/lua/plugins/go.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {}, -- Go Language Server
      },
    },
  },
}
