-- chsarp dap config

local Path = require "plenary.path"

local dap = require "dap"
local dapui = require "dapui"
local dap_utils = require "dap.utils"

-- Helper to find executable csproj files
local function find_executable_projects()
  local handle = io.popen "find . -name '*.csproj'"
  if not handle then
    return {}
  end
  local result = handle:read "*a"
  handle:close()

  local projects = {}
  for line in result:gmatch "[^\r\n]+" do
    local content = Path:new(line):read()

    -- Match if OutputType is Exe or Sdk contains Microsoft.NET.Sdk.Web
    local is_exe = content:find "<OutputType>%s*Exe%s*</OutputType>"
    local is_web = content:find '<Project%s+Sdk="Microsoft%.NET%.Sdk%.Web"'
    if is_exe or is_web then
      table.insert(projects, line)
    end
  end

  return projects
end

local function create_output_window()
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.6),
    row = math.floor(vim.o.lines * 0.2),
    col = math.floor(vim.o.columns * 0.1),
    style = "minimal",
    border = "rounded",
  })
  return buf, win
end

-- fallback: auto-detect bin/Debug/*/ instead of hardcoding net8.0
local function detect_target_framework(project_dir)
  local glob = vim.fn.glob(project_dir .. "bin/Debug/*", 1, 1)
  for _, path in ipairs(glob) do
    if vim.fn.isdirectory(path) == 1 then
      return vim.fs.basename(path)
    end
  end
  return "net8.0" -- fallback fallback
end

local function find_runnable_projects()
  local handle = io.popen "find . -name '*.csproj'"
  if not handle then
    return {}
  end
  local result = handle:read "*a"
  handle:close()

  local projects = {}
  for line in result:gmatch "[^\r\n]+" do
    local file = io.open(line, "r")
    if file then
      local content = file:read "*a"
      file:close()
      local is_exe = content:find "<OutputType>%s*Exe%s*</OutputType>"
      local is_sdk_web = content:find "Microsoft%.NET%.Sdk%.Web"
      if is_exe or is_sdk_web then
        table.insert(projects, line)
      end
    end
  end

  return projects
end

local function setup_csharp()
  dap.adapters.coreclr = {

    type = "executable",

    command = "/Users/anweshbudhathoki/Documents/netcoredbg/bin/netcoredbg",
    --command = vim.fn.stdpath('data') .. "/mason/packages/netcoredbg/netcoredbg",
    --"netcoredbg",
    args = { "--interpreter=vscode" },
  }

  dap.configurations.cs = {
    {
      type = "coreclr",
      name = "Pick DLL to Debug",
      request = "launch",
      program = function()
        return coroutine.create(function(coro)
          local choices = find_runnable_projects()
          if #choices == 0 then
            vim.notify("No runnable projects found", vim.log.levels.ERROR)
            return
          end

          vim.ui.select(choices, {
            prompt = "Select a project to debug:",
            format_item = function(item)
              return item:gsub("^./", "")
            end,
          }, function(choice)
            if not choice then
              return
            end

            -- Create floating window for build output
            --local abuf, _ = create_output_window()
            --vim.api.nvim_buf_set_lines(abuf, 0, -1, false, { "🔧 Building project..." })

            local project_dir = choice:match "(.*/)"
            local file = io.open(choice, "r")
            if not file then
              return
            end
            local content = file:read "*a"
            file:close()
            local target_framework = content:match "<TargetFramework>(.-)</TargetFramework>"
              or detect_target_framework(project_dir)

            local build_cmd = { "dotnet", "build", choice, "-c", "Debug" }

            -- Create floating window for build output
            local buf, win = create_output_window()
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "🔧 Building project..." })

            vim.fn.jobstart(build_cmd, {
              stdout_buffered = false,
              stderr_buffered = false,
              on_stdout = function(_, data)
                if data then
                  vim.schedule(function()
                    vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
                  end)
                  -- scroll to bottom
                  vim.api.nvim_win_call(win, function()
                    vim.cmd "normal! G"
                  end)
                end
              end,
              on_stderr = function(_, data)
                if data then
                  vim.schedule(function()
                    vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
                  end)
                  -- scroll to bottom
                  vim.api.nvim_win_call(win, function()
                    vim.cmd "normal! G"
                  end)
                end
              end,
              on_exit = function(_, code)
                vim.schedule(function()
                  if code ~= 0 then
                    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "❌ Build failed." })
                    -- scroll to bottom
                    vim.api.nvim_win_call(win, function()
                      vim.cmd "normal! G"
                    end)
                    -- Close floating window after 3 seconds (3000 ms)
                    vim.defer_fn(function()
                      if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_win_close(win, true)
                      end
                    end, 2000)
                    coroutine.resume(coro, nil)
                  else
                    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "✅ Build succeeded." })
                    -- scroll to bottom
                    vim.api.nvim_win_call(win, function()
                      vim.cmd "normal! G"
                    end)

                    local dll_name = vim.fs.basename(choice):gsub("%.csproj$", ".dll")
                    local dll_path = vim.fn.getcwd()
                      .. "/"
                      .. project_dir
                      .. "bin/Debug/"
                      .. target_framework
                      .. "/"
                      .. dll_name

                    if vim.fn.filereadable(dll_path) == 0 then
                      vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "⚠️ DLL not found: " .. dll_path })
                      vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
                      vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
                      vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
                      -- scroll to bottom
                      vim.api.nvim_win_call(win, function()
                        vim.cmd "normal! G"
                      end)
                      -- Close floating window after 3 seconds (3000 ms)
                      vim.defer_fn(function()
                        if vim.api.nvim_win_is_valid(win) then
                          vim.api.nvim_win_close(win, true)
                        end
                      end, 2000)
                      coroutine.resume(coro, nil)
                    else
                      vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "✅  DLL found: " .. dll_path })
                      if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_win_close(win, true)
                      end
                      coroutine.resume(coro, dll_path)
                    end
                  end
                end)
              end,
            })
          end)
        end)
      end,
      cwd = vim.fn.getcwd() .. "/webapi",

      env = {
        DOTNET_ENVIRONMENT = "Development",
        ASPNETCORE_ENVIRONMENT = "Development",
      },
    },

    {
      type = "coreclr",
      name = "Attach",
      request = "attach",
      processId = dap_utils.pick_process,
    },

    --[[
        {
          type = "coreclr",
          name = "Attach (Smart)",
          request = "attach",
          processId = function()
            if not vim.g.roslyn_nvim_selected_solution then
              return vim.notify "No solution file found"
            end

            local csproj_files = require("roslyn.sln.api").projects(vim.g.roslyn_nvim_selected_solution)

            return dap_utils.pick_process {
              filter = function(proc)
                return vim.iter(csproj_files):find(function(file)
                  if vim.endswith(proc.name, vim.fn.fnamemodify(file, ":t:r")) then
                    return true
                  end
                end)
              end,
            }
          end,
        },]]
  }
end

return {
  setup_csharp = setup_csharp,
}
