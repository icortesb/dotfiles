return {
  {
    "lambdalisue/vim-suda",
    lazy = false,
    -- init, no config: plugin/suda.vim lee estas variables al cargarse
    init = function()
      vim.g.suda_smart_edit = 1
      vim.g.suda_smart_write = 1
    end,
  },
}
