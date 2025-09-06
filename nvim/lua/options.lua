require "nvchad.options"

-- add yours here!

-- ~/.config/nvim/lua/custom/init.lua
vim.opt.relativenumber = true
vim.opt.number = true -- also keep the absolute number for the current line

-- open nerdtree in default
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv()[1]
    if arg and vim.fn.isdirectory(arg) == 1 then
      vim.cmd.cd(arg)
      -- vim.cmd "NvimTreeFocus"
    end
    if vim.fn.argc() == 0 and vim.v.this_session == '' then
      -- Only open NvimTree if no session is being restored
      require("nvim-tree.api").tree.open({ focus = false })
    end
  end,
})

-- Optional: open NvimTree after auto-session loads
vim.api.nvim_create_autocmd("User", {
  pattern = "SessionLoadPost",
  callback = function()
    require("nvim-tree.api").tree.open({ focus = false })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Always open nvim-tree
    require("nvim-tree.api").tree.open { focus = false }
  end,
})

-- In your config
-- vim.o.statusline = "%f %h%m%r%=%{get(b:,'gitblame_summary','')} %= %l,%c"


-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
