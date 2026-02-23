require("config.options")
require("config.keybinds")
require("config.lazy")
vim.env.PATH = vim.env.PATH .. ":/home/icortesb/.config/composer/vendor/bin"

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        local dir = vim.fn.expand("%:p:h")
        if vim.fn.isdirectory(dir) == 1 then
            vim.cmd("lcd " .. dir)
        end
    end,
})
