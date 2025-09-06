require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "ZZ", "<cmd>wqa<CR>", { desc = "Save all and quit" })
map("n", "<leader>q", "<cmd>bdelete<CR>", { desc = "LSP: Code Action" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
--
--

map("n", "r", "<C-r>", { desc = "Redo", noremap = true, silent = true })
-- LSP bindings
-- Native LSP functions
map("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Go to Definition" })
map("n", "gD", vim.lsp.buf.type_definition, { desc = "LSP: Go to Type Definition" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "LSP: Go to Implementation" })
map("n", "gr", vim.lsp.buf.references, { desc = "LSP: Find References" })
map("n", "gh", vim.lsp.buf.hover, { desc = "LSP: Hover Docs" })

-- Diagnostic mappings (error/warning/etc)
vim.keymap.set("n", "g{", function()
  vim.diagnostic.goto_prev {
    severity = vim.diagnostic.severity.ERROR,
  }
  -- vim.diagnostic.goto_prev {
  --   severity = vim.diagnostic.severity.ERROR,
  -- }
end, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "g}", function()
  vim.diagnostic.goto_next {
    severity = vim.diagnostic.severity.ERROR,
  }
end, { desc = "Go to next diagnostic" })
map("n", "ge", function()
  vim.diagnostic.open_float(0, { scope = "cursor" })
end, { desc = "LSP: Hover Docs" })

map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename Symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code Action" })

--[[map("n", "<leader>f", function()
  vim.lsp.buf.format { async = true }
end, { desc = "LSP: Format Document" })
]]

-- Telescope integration
local builtin = require "telescope.builtin"
map("n", "<leader>td", builtin.lsp_definitions, { desc = "Telescope: LSP Definitions" })
map("n", "<leader>tD", builtin.lsp_type_definitions, { desc = "Telescope: LSP Type Definitions" })
map("n", "<leader>ti", builtin.lsp_implementations, { desc = "Telescope: LSP Implementations" })
map("n", "<leader>tr", builtin.lsp_references, { desc = "Telescope: LSP References" })

--[[
map('i', '<C-l>', function ()
  vim.fn.feedkeys(vim.fn['copilot#Accept'](), '')
end, { desc = 'Copilot Accept', noremap = true, silent = true })
]]

vim.keymap.set("n", "<F5>", function()
  require("dap").continue()
end)
vim.keymap.set("n", "<Leader>dr", function()
  require("dap").repl.open()
end)

-- Remap `/` to toggle comment
vim.keymap.set({ "n", "v" }, "<D-/>", "gcc", { noremap = false, silent = true })
vim.keymap.set({ "n", "v" }, "<D-/>", "gc", { noremap = false, silent = true })

vim.keymap.set("v", "<leader>cc", ":<C-u>CopilotChatOpen<CR>", { silent = true })
