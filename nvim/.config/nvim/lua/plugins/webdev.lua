-- ~/.config/nvim/lua/plugins/webdev.lua
return {
  { "neovim/nvim-lspconfig", opts = {
      servers = {
        tsserver = {},
        volar = {}, -- para Vue 3 + TypeScript
        eslint = {},
      },
    },
  },
}

