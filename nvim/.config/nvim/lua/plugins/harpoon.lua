return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>a", function() require("harpoon"):list():add() end, desc = "Harpoon add file" },
      {
        "<C-e>",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon menu",
      },
      {
        "<leader>fl",
        function()
          local list = require("harpoon"):list()
          local items = {}
          for i = 1, list:length() do
            local item = list:get(i)
            if item then
              table.insert(items, { text = item.value, file = item.value })
            end
          end
          Snacks.picker({ title = "Working List", items = items, format = "file", layout = "ivy" })
        end,
        desc = "Harpoon list (picker)",
      },
      { "<C-p>", function() require("harpoon"):list():prev() end, desc = "Harpoon prev" },
      { "<C-n>", function() require("harpoon"):list():next() end, desc = "Harpoon next" },
    },
  },
}
