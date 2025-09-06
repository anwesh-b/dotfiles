-- dap config

local function keymap(mode, lhs, rhs, opts)
  opts.desc = string.format("Dap: %s", opts.desc)
  vim.keymap.set(mode, lhs, function()
    rhs()
    vim.fn["repeat#set"](vim.keycode(lhs))
  end, opts)
end

return {
  {
    "mfussenegger/nvim-dap",
    keys = { "<leader>d<leader>", "<leader>db" },
    dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio", "tpope/vim-repeat" },
    opts = {
      ensure_installed = "netcoredbg",
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"

      local csConfig = require "plugins.dap.cs"
      dap.set_log_level "TRACE"

      -- You can put your dap config here or in a separate setup file
      ---@diagnostic disable-next-line: missing-fields
      dapui.setup {
        mappings = {
          edit = "i",
          remove = "dd",
        },
      }

      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "Error", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "Error", linehl = "DiffAdd", numhl = "" })

      -- Dap mappings
      keymap("n", "<leader>db", dap.toggle_breakpoint, { desc = "Add breakpoint" })
      keymap("n", "<leader>d<leader>", dap.continue, { desc = "Continue debugging" })
      keymap("n", "<leader>dl", dap.step_into, { desc = "Step into" })
      keymap("n", "<leader>dj", dap.step_over, { desc = "Step over" })

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      -- Automatically open DAP UI when debugging starts
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end


      -- CS setup
      csConfig.setup_csharp()
    end,
  },
}
