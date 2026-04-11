return {
  {
    "uhs-robert/oasis.nvim",
    name = "oasis",
    priority = 1000,
    lazy = false,
    opts = {
      -- Aquí seleccionamos la variante específica "night"
      style = "night",

      -- Otras opciones para personalizarlo
      transparent = false, -- Pon true si quieres ver tu fondo de terminal
      terminal_colors = true, -- Usar colores del tema en la terminal integrada
      styles = {
        -- Puedes poner estilos (italic, bold) a partes específicas
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "dark", -- Estilo para NvimTree/NeoTree
        floats = "dark", -- Estilo para ventanas flotantes
      },
    },
    config = function(_, opts)
      require("oasis").setup(opts)
      vim.cmd.colorscheme("oasis")
    end,
  },

  -- Configurar LazyVim para que sepa que este es tu tema por defecto
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "oasis",
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
