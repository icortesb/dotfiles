local conf = require("telescope.config").values
local themes = require("telescope.themes")

local function toggle_telescope(harpoon_files)
  local file_paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(file_paths, item.value)
  end
  local opts = themes.get_ivy({
    prompt_title = "Working List",
  })
  require("telescope.pickers")
    .new(opts, {
      finder = require("telescope.finders").new_table({ results = file_paths }),
      previewer = conf.file_previewer(opts),
      sorter = conf.generic_sorter(opts),
    })
    :find()
end

return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
      vim.keymap.set("n", "<leader>a", function()
        harpoon:list():add()
      end, { desc = "Harpoon add file" })
      vim.keymap.set("n", "<C-e>", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon menu" })
      vim.keymap.set("n", "<leader>fl", function()
        toggle_telescope(harpoon:list())
      end, { desc = "Harpoon telescope list" })
      vim.keymap.set("n", "<C-p>", function()
        harpoon:list():prev()
      end, { desc = "Harpoon prev" })
      vim.keymap.set("n", "<C-n>", function()
        harpoon:list():next()
      end, { desc = "Harpoon next" })
    end,
  },
}
