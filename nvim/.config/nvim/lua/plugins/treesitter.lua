return {
	-- BLOQUE 1: Treesitter (El motor principal)
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")
			configs.setup({
				highlight = { enable = true },
				indent = { enable = true },

				-- IMPORTANTE: Aquí borramos la línea "autotag = { enable = true }"
				-- Si la dejas, te seguirá dando el error de "deprecated".

				ensure_installed = {
					"lua",
					"tsx",
					"typescript",
					"php",
					"javascript",
					"html",
					"css",
					"json",
					"astro",
					"bash",
					"yaml",
					"sql",
					"regex",
					"dockerfile",
					"toml",
					"gitignore",
					"go",
					"vim",
					"vimdoc",
				},
			})
		end,
	},

	-- BLOQUE 2: Autotag (Configuración nueva e independiente)
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter", -- Se carga solo cuando empiezas a escribir (más rápido)
		config = function()
			require("nvim-ts-autotag").setup({
				-- Aquí puedes poner opciones extra si quieres,
				-- pero vacío funciona perfecto.
			})
		end,
	},
}
