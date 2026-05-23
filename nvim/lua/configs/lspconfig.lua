local nvlsp = require "nvchad.configs.lspconfig"

nvlsp.defaults()

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
})
vim.lsp.enable "gopls"

vim.lsp.config("typos_lsp", {
  cmd_env = { RUST_LOG = "error" },
  init_options = {
    config = "~/code/typos-lsp/crates/typos-lsp/tests/typos.toml",
    diagnosticSeverity = "Hint",
  },
})
vim.lsp.enable "typos_lsp"

vim.lsp.config("ts_ls", {
  filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
})
vim.lsp.enable "ts_ls"

vim.lsp.config("omnisharp", {
  cmd = { "dotnet", vim.fn.stdpath "data" .. "/mason/packages/omnisharp/OmniSharp.dll" },
  filetypes = { "cs", "vb" },
  root_markers = { "*.sln", "*.csproj", ".git" },
  settings = {
    enable_editorconfig_support = true,
    enable_ms_build_load_projects_on_demand = false,
    enable_roslyn_analyzers = false,
    organize_imports_on_format = true,
    enable_import_completion = true,
    sdk_include_prereleases = true,
    analyze_open_documents_only = false,
  },
})
vim.lsp.enable "omnisharp"

vim.lsp.enable "html"
vim.lsp.enable "cssls"

vim.lsp.config("pylsp", {
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
})
vim.lsp.enable "pylsp"
