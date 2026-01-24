return {
    {
	'nvim-treesitter/nvim-treesitter',
	branch = "master",
	lazy = false,
	build = ':TSUpdate',
	config = function()
	    local configs = require("nvim-treesitter.configs")
	    configs.setup({
		highlight = { enable = true },
		indend = { enable = true },
		autotags = { enable = true },
		ensure_installed = {
                    "lua", "tsx", "typescript", "php", "javascript",
                    "html", "css", "json", "astro", "bash",
                    "yaml", "sql", "regex", "dockerfile", "toml",
                    "gitignore", "go", "vim", "vimdoc"
                },
	    })
	end
    }
}
