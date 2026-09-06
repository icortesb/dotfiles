return {
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = false, -- true si querés ver el fondo de la terminal
      terminal_colors = true, -- usar los colores del tema en la terminal integrada
      diff = { mode = "bg" },
      borders = true,
      errors = { mode = "bg" },
      search = { theme = "vim" },
      styles = {
        -- mismos estilos que tenía oasis
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
      },
    },
    config = function(_, opts)
      require("nord").setup(opts)
      vim.cmd.colorscheme("nord")
    end,
  },

  -- Que LazyVim sepa cuál es el tema por defecto
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
  },

  -- Disable Snacks scroll animation
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
    },
  },
}
