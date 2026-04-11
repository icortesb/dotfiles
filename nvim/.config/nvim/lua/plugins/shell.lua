-- ~/.config/nvim/lua/plugins/sh.lua
return {
  { "neovim/nvim-lspconfig", opts = {
      servers = {
        bashls = {},
      },
    },
  },
}

