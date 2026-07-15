-- neotex.plugins.editor.which-key
-- Keybinding configuration and display using which-key.nvim v3 API

--[[ WHICH-KEY MAPPINGS - COMPLETE REFERENCE
-----------------------------------------------------------

This module configures which-key.nvim using the modern v3 API with icon support.
All mappings are organized alphabetically by leader letter and use `cond` functions
for filetype-specific features instead of autocmds.

The configuration provides:
- Helper functions for filetype detection
- All mappings grouped by letter with conditional visibility
- Clean separation of concerns without autocmd pollution

----------------------------------------------------------------------------------
TOP-LEVEL MAPPINGS (<leader>)                   | DESCRIPTION
----------------------------------------------------------------------------------
<leader>b - Telescope buffers                   | Show all open buffers
<leader>d - Save and delete buffer              | Save file and close buffer
<leader>e - Toggle NvimTree explorer            | Open/close file explorer
<leader>q - Close buffer                        | Close active editor (VSCode-style)
<leader>u - Open Telescope undo                 | Show undo history with preview

SINGLE-LETTER GROUPS (<leader>X)
----------------------------------------------------------------------------------
<leader>w - Window management (+ save)          | Split, navigate, close, save
<leader>r - Run/Execute commands                | Debug, model checker, python, etc.
<leader>z - Fold/Zen                            | Toggle fold, folding method, etc.
<leader>L - Lean4                               | Build, infoview, etc.
<leader>T - Tabs (WezTerm)                      | Next/prev/go-to tab in WezTerm
<leader>K - Kill/Process                        | Launch, pick, kill all processes

[Additional documentation continues as before...]
]]

-- Import notification module for TTS toggle functionality
local notify = require('neotex.util.notifications')

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = {
    'echasnovski/mini.nvim',
  },
  opts = {
    preset = "classic",
    delay = function(ctx)
      return ctx.plugin and 0 or 200
    end,
    show_help = false,    -- Remove bottom help/status bar
    show_keys = false,    -- Remove key hints
    win = {
      border = "rounded",
      padding = { 1, 2 },
      title = false,
      title_pos = "center",
      zindex = 1000,
      wo = {
        winblend = 10,
      },
      bo = {
        filetype = "which_key",
        buftype = "nofile",
      },
    },
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
    layout = {
      width = { min = 20, max = 50 },
      height = { min = 4, max = 25 },
      spacing = 3,
      align = "left",
    },
    keys = {
      scroll_down = "<c-d>",
      scroll_up = "<c-u>",
    },
    sort = { "local", "order", "group", "alphanum", "mod" },
    disable = {
      bt = { "help", "quickfix", "terminal", "prompt" },
      ft = { "neo-tree" }
    },
    triggers = {
      { "<leader>", mode = { "n", "v" } }
    }
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- ============================================================================
    -- GLOBAL FUNCTIONS
    -- ============================================================================

    -- RunModelChecker: Find and run dev_cli.py for model checking
    _G.RunModelChecker = function()
      -- Try to find dev_cli.py in the current project or its parent
      local current_dir = vim.fn.getcwd()
      local dev_cli_path = nil

      -- Check current directory
      if vim.fn.filereadable(current_dir .. "/code/dev_cli.py") == 1 then
        dev_cli_path = current_dir .. "/code/dev_cli.py"
      -- Check if we're in a worktree and look in parent
      elseif current_dir:match("-feature-") or current_dir:match("-bugfix-") or current_dir:match("-refactor-") then
        local parent = current_dir:match("(.*/[^/]+)%-[^/]+%-[^/]+$")
        if parent and vim.fn.filereadable(parent .. "/code/dev_cli.py") == 1 then
          dev_cli_path = parent .. "/code/dev_cli.py"
        end
      -- Fallback to known ModelChecker location
      elseif vim.fn.filereadable("/home/benjamin/Documents/Philosophy/Projects/ModelChecker/code/dev_cli.py") == 1 then
        dev_cli_path = "/home/benjamin/Documents/Philosophy/Projects/ModelChecker/code/dev_cli.py"
      end

      if dev_cli_path then
        local file = vim.fn.expand("%:p:r") .. ".py"
        vim.cmd(string.format("TermExec cmd='%s %s'", dev_cli_path, file))
      else
        vim.notify("Could not find code/dev_cli.py in project", vim.log.levels.ERROR)
      end
    end

    -- ============================================================================
    -- HELPER FUNCTIONS FOR FILETYPE DETECTION
    -- ============================================================================

    -- Toggle TTS_ENABLED in the project-specific config file
    -- @param config_path string Path to the tts-config.sh file
    -- @return success boolean True if toggle succeeded
    -- @return message string Success message ("TTS enabled" or "TTS disabled")
    -- @return error string Error message if success is false
    local function toggle_tts_config(config_path)
      -- Validate file exists (redundant check, but safe)
      if vim.fn.filereadable(config_path) ~= 1 then
        return false, nil, "Config file not readable: " .. config_path
      end

      -- Read file with error handling
      local ok, lines = pcall(vim.fn.readfile, config_path)
      if not ok then
        return false, nil, "Failed to read config: " .. tostring(lines)
      end

      -- Find and toggle TTS_ENABLED
      local modified = false
      local message
      for i, line in ipairs(lines) do
        if line:match("^TTS_ENABLED=") then
          if line:match("=true$") then
            lines[i] = "TTS_ENABLED=false"
            message = "TTS disabled"
          else
            lines[i] = "TTS_ENABLED=true"
            message = "TTS enabled"
          end
          modified = true
          break
        end
      end

      if not modified then
        return false, nil, "TTS_ENABLED not found in config file"
      end

      -- Write file with error handling
      local write_ok, write_err = pcall(vim.fn.writefile, lines, config_path)
      if not write_ok then
        return false, nil, "Failed to write config: " .. tostring(write_err)
      end

      return true, message, nil
    end

    local function is_python()
      return vim.bo.filetype == "python"
    end

    local function is_markdown()
      return vim.tbl_contains({ "markdown", "md" }, vim.bo.filetype)
    end

    local function is_lectic()
      return vim.tbl_contains({ "lec", "markdown", "md" }, vim.bo.filetype)
    end

    local function is_jupyter()
      return vim.bo.filetype == "ipynb"
    end

    local function is_jupyter_or_python()
      return vim.bo.filetype == "ipynb" or vim.bo.filetype == "python"
    end

    local function is_pandoc_compatible()
      return vim.tbl_contains({ "markdown", "md", "tex", "latex", "org", "rst", "html", "docx" }, vim.bo.filetype)
    end


    -- Helper function for bibexport
    local function run_bibexport()
      local filepath = vim.fn.expand('%:p')
      local filedir = vim.fn.expand('%:p:h')
      local filename = vim.fn.expand('%:t:r')
      local output_bib = filename .. '.bib'
      local aux_file = 'build/' .. filename .. '.aux'

      -- Build the command to run in terminal
      local cmd = string.format('cd "%s" && bibexport -o "%s" "%s"', filedir, output_bib, aux_file)
      vim.cmd('terminal ' .. cmd)
    end

    -- ============================================================================
    -- TOP-LEVEL SINGLE KEY MAPPINGS
    -- ============================================================================

    wk.add({
      { "<leader>b", "<cmd>Telescope buffers<CR>", desc = "show all editors (vscode)", icon = "󰓩" },
      { "<leader>d", "<cmd>lua if vim.fn.filereadable(vim.fn.expand('%')) == 1 then vim.cmd('update!') end; smart_bufdelete()<CR>", desc = "delete buffer", icon = "󰩺" },
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "explorer", icon = "󰙅" },
      { "<leader>q", "<cmd>bd<CR>", desc = "close active editor (vscode)", icon = "󰅖" },
      { "<leader>qq", "<cmd>wa! | qa!<CR>", desc = "quit all", icon = "󰗼" },
      { "<leader>u", "<cmd>Telescope undo<CR>", desc = "undo", icon = "󰕌" },
    })

    -- CloseOtherBuffers: Close all listed buffers except the current one
    _G.CloseOtherBuffers = function()
      local current = vim.api.nvim_get_current_buf()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
          vim.api.nvim_buf_delete(buf, { force = false })
        end
      end
    end

    -- Global AI toggles are now in keymaps.lua for centralized management

    -- ============================================================================
    -- <leader>a - AI/ASSISTANT GROUP
    -- ============================================================================

    wk.add({
      -- <leader>w - Window management
      { "<leader>w", group = "window", icon = "󰧠", mode = { "n", "v" } },
      { "<leader>ww", "<cmd>w<CR>", desc = "save file", icon = "󰆓" },
      { "<leader>wv", "<cmd>vert sb<CR>", desc = "vertical split", icon = "󰯌" },
      { "<leader>ws", "<cmd>sb<CR>", desc = "horizontal split", icon = "󰕰" },
      { "<leader>wc", "<cmd>close<CR>", desc = "close window", icon = "󰆴" },
      { "<leader>wo", "<cmd>only<CR>", desc = "close others", icon = "󰅘" },
      { "<leader>w=", "<C-w>=", desc = "equalize windows", icon = "󰁫" },
      { "<leader>wm", function() vim.cmd("resize | vertical resize") end, desc = "maximize window", icon = "󰊓" },

      -- <leader>a - AI/ASSISTANT
      { "<leader>a", group = "ai", icon = "󰚩", mode = { "n", "v" } },

      -- Mở Claude Code (cc-nvim -> Headroom proxy -> free-claude-code)
      { "<leader>al", function()
        -- Normal mode: mở picker lệnh AI
        local ok, picker = pcall(require, "neotex.plugins.ai.shared.picker.ai-tool-picker")
        if ok and picker then
          if not picker._initialized then picker.setup() end
          picker.show_commands_picker()
        else
          -- Fallback: mở thẳng Claude
          local claude_ok, claude = pcall(require, "neotex.plugins.ai.claude")
          if claude_ok and claude and claude.smart_toggle then
            claude.smart_toggle()
          else
            vim.cmd("ClaudeCode")
          end
        end
      end, desc = "ai: load commands/agents", mode = { "n" }, icon = "󰀩" },

      { "<leader>al", function()
        -- Visual mode: gửi đoạn code đang chọn cho Claude
        local ok, visual = pcall(require, "neotex.plugins.ai.claude.core.visual")
        if ok and visual and visual.send_visual_to_claude then
          visual.send_visual_to_claude()
        else
          vim.notify("[AI] Không thể gửi lựa chọn — module visual không tải được", vim.log.levels.WARN)
        end
      end, desc = "ai: send selection to claude", mode = { "v" }, icon = "󰀩" },

      -- Mở/Đóng sidebar Claude Code
      { "<leader>ac", function()
        vim.cmd("ClaudeCode")
      end, desc = "ai: toggle claude sidebar", icon = "󰗃" },

      -- Xem và chọn phần phiên (sessions) cũ
      { "<leader>as", function()
        -- ================================================================
        -- Claude System Manager — Deep Optimization Suite
        -- ================================================================
        local home = vim.fn.expand("$HOME") .. "/.claude"
        local M = {}

        -- Hàm lấy dung lượng
        local function _size(path)
          local h = io.popen("du -sh " .. path .. " 2>/dev/null | cut -f1")
          local s = h and h:read("*l") or "?"
          if h then h:close() end
          return s ~= "" and s or "?"
        end
        local function _bytes(path)
          local h = io.popen("du -sb " .. path .. " 2>/dev/null | cut -f1")
          local b = h and tonumber(h:read("*l")) or 0
          if h then h:close() end
          return b or 0
        end

        -- === SCAN: thu thập dữ liệu ===
        local targets = {
          { path = home .. "/projects",    label = "Projects",    action = "clean_projects" },
          { path = home .. "/downloads",   label = "Downloads",   action = "clean_downloads" },
          { path = home .. "/file-history",label = "File history", action = "clean_history" },
          { path = home .. "/plugins",     label = "Plugins",     action = "clean_plugins" },
          { path = home .. "/backups",     label = "Backups",     action = "clean_backups" },
          { path = home .. "/logs",        label = "Logs",        action = "clean_logs" },
          { path = home .. "/paste-cache", label = "Paste cache",  action = "clean_cache" },
          { path = home .. "/cache",       label = "Cache",        action = "clean_cache" },
          { path = home .. "/sessions",    label = "Sessions",    action = "clean_sessions" },
          { path = home .. "/telemetry",   label = "Telemetry",   action = "clean_telemetry" },
        }

        local total_bytes = 0
        local report = {}
        for _, t in ipairs(targets) do
          local b = _bytes(t.path)
          t.bytes = b
          total_bytes = total_bytes + b
          table.insert(report, string.format("  %-15s %s  (%s)", t.label, _size(t.path), t.bytes > 0 and "" or "󰩫"))
        end
        table.insert(report, "")
        table.insert(report, string.format("  TOTAL:     %.1f MB", total_bytes / 1024 / 1024))
        table.insert(report, "")
        table.insert(report, "    = has data  󰩫  = empty")

        -- === MENU ===
        local choices = {
          "Dismiss",
          "🩺  Health check",
          "🔍  Browse sessions",
          "🧹  Clean ALL temp (logs+cache+paste+downloads)",
          "🗑️  Clean stale sessions",
          "📦  Clean old project memories",
          "⚰️  Purge telemetry",
        }
        vim.notify(table.concat(report, "\n"), vim.log.levels.INFO, {
          title = "Claude System Manager",
          timeout = 10000,
        })

        vim.ui.select(choices, { prompt = "Claude Optimizer" }, function(c)
          if not c or c == "Dismiss" then return end

          if c:match("Health") then
            pcall(vim.cmd, "ClaudeSessionHealth")

          elseif c:match("Browse") then
            pcall(vim.cmd, "ClaudeSessionPicker")

          elseif c:match("Clean ALL") then
            local cmds = {
              "rm -rf " .. home .. "/logs/* 2>/dev/null",
              "rm -rf " .. home .. "/cache/* 2>/dev/null",
              "rm -rf " .. home .. "/paste-cache/* 2>/dev/null",
              "rm -rf " .. home .. "/downloads/* 2>/dev/null",
              "rm -rf " .. home .. "/file-history/* 2>/dev/null",
              "rm -rf " .. home .. "/backups/*.old 2>/dev/null",
              "find " .. home .. "/logs -name '*.log' -mtime +7 -delete 2>/dev/null",
            }
            local freed = 0
            for _, t in ipairs(targets) do
              if t.label == "Logs" or t.label == "Cache" or t.label == "Paste cache" or t.label == "Downloads" or t.label == "File history" then
                freed = freed + t.bytes
              end
            end
            for _, cmd in ipairs(cmds) do
              os.execute(cmd)
            end
            local after = _bytes(home .. "/downloads") + _bytes(home .. "/logs") + _bytes(home .. "/paste-cache") + _bytes(home .. "/cache") + _bytes(home .. "/file-history")
            vim.notify(string.format("Freed %.1f MB! Remaining temp: %.1f MB",
              freed / 1024 / 1024, after / 1024 / 1024), vim.log.levels.INFO)

          elseif c:match("stale sessions") then
            pcall(vim.cmd, "ClaudeSessionCleanup")

          elseif c:match("old project") then
            local items = {}
            local h = io.popen("ls -1t " .. home .. "/projects/ 2>/dev/null")
            if h then
              for line in h:lines() do
                local p = home .. "/projects/" .. line
                local s = _bytes(p)
                table.insert(items, { name = line, path = p, size = s })
              end
              h:close()
            end
            if #items == 0 then
              vim.notify("No project memories found", vim.log.levels.INFO)
              return
            end
            local pick_items = {}
            for _, item in ipairs(items) do
              table.insert(pick_items, string.format("%s (%s)", item.name, _size(item.path)))
            end
            table.insert(pick_items, 1, "Cancel")
            vim.ui.select(pick_items, { prompt = "Delete project memory?" }, function(pick)
              if not pick or pick == "Cancel" then return end
              local name = pick:match("^([^ ]+)")
              if name then
                os.execute("rm -rf " .. home .. "/projects/" .. name)
                vim.notify("Deleted: " .. name, vim.log.levels.INFO)
              end
            end)

          elseif c:match("telemetry") then
            local b = _bytes(home .. "/telemetry")
            os.execute("rm -rf " .. home .. "/telemetry/* 2>/dev/null")
            vim.notify(string.format("Purged telemetry (freed %s)", b > 0 and string.format("%.1f MB", b / 1024 / 1024) or "0"), vim.log.levels.INFO)
          end
        end)
      end, desc = "ai: deep system optimizer", icon = "󰉚" },

      -- Tạo Git worktree mới + phiên Claude độc lập
      { "<leader>aw", function()
        local ok, claude = pcall(require, "neotex.plugins.ai.claude")
        if ok and claude and claude.create_worktree_with_claude then
          claude.create_worktree_with_claude({})
        else
          vim.notify("[AI] Không tải được module worktree", vim.log.levels.WARN)
        end
      end, desc = "ai: new worktree + claude session", icon = "󰆷" },

      -- Restore phiên đã đóng (resume last session)
      { "<leader>ar", function()
        vim.cmd("ClaudeCode --resume")
      end, desc = "ai: restore last session", icon = "󱎎" },

      -- Kill các process AI chạy ngầm
      { "<leader>ak", function()
        -- Kill inhibitors
        local files = vim.fn.glob("/tmp/claude-inhibitor-*.pid", false, true)
        if #files > 0 then
          for _, f in ipairs(files) do
            local lines = vim.fn.readfile(f)
            local pid = lines and lines[1] and vim.fn.trim(lines[1]) or ""
            if pid ~= "" then vim.fn.system("kill " .. pid .. " 2>/dev/null") end
            vim.fn.delete(f)
          end
          vim.notify(string.format("[AI] Đã kill %d phần tiến trình", #files), vim.log.levels.INFO)
        else
          vim.notify("[AI] Không có phiên nào đang chạy ngầm", vim.log.levels.INFO)
        end
      end, desc = "ai: kill background sessions", icon = "󰆲" },

      -- Hỏi AI về diagnostics (lỗi code)
      { "<leader>ad", function()
        local diags = vim.diagnostic.get(0)
        if #diags == 0 then
          vim.notify("[AI] Không có lỗi nào trong file này", vim.log.levels.INFO)
          return
        end
        local msg = "Fix the following errors:\n"
        for _, d in ipairs(diags) do
          msg = msg .. string.format("  Line %d: %s\n", d.lnum + 1, d.message)
        end
        vim.fn.setreg('"', msg)
        vim.cmd("ClaudeCode")
        vim.notify("[AI] Nội dung lỗi đã copy vào clipboard. Dán (p) vào Claude.", vim.log.levels.INFO)
      end, desc = "ai: ask about diagnostics", icon = "󰄓" },

      -- ⭐ Quick Ask: gửi code quanh cursor + diagnostics cho Claude
      { "<leader>aa", function()
        local filepath = vim.api.nvim_buf_get_name(0)
        local ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
        local line = vim.api.nvim_win_get_cursor(0)[1]
        local total = vim.api.nvim_buf_line_count(0)
        local start = math.max(0, line - 30)
        local end_ = math.min(total, line + 30)
        local context = table.concat(vim.api.nvim_buf_get_lines(0, start - 1, end_, false), "\n")
        local diags = vim.diagnostic.get(0)
        local diag_text = ""
        if #diags > 0 then
          local dlines = {}
          for _, d in ipairs(diags) do
            table.insert(dlines, string.format("L%d %s", d.lnum + 1, d.message))
          end
          diag_text = "\n\nErrors:\n" .. table.concat(dlines, "\n")
        end
        local prompt = string.format("File: %s | line %d\n```%s\n%s\n```%s", vim.fn.fnamemodify(filepath, ":t"), line, ft, context, diag_text)
        vim.fn.setreg('"', prompt)
        local ok, visual = pcall(require, "neotex.plugins.ai.claude.core.visual")
        if ok and visual and visual.send_visual_to_claude then
          visual.send_visual_to_claude()
        else
          vim.cmd("ClaudeCode")
          vim.notify("[AI] Code context copied! Paste into Claude", vim.log.levels.INFO)
        end
      end, desc = "ai: quick ask (code+errors)", icon = "󰠰" },

      -- ⭐ Auto-fix: gửi toàn bộ file + lỗi cho Claude
      { "<leader>af", function()
        local filepath = vim.api.nvim_buf_get_name(0)
        local ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
        local diags = vim.diagnostic.get(0)
        local errors = {}
        for _, d in ipairs(diags) do
          if d.severity <= vim.diagnostic.severity.WARN then
            table.insert(errors, string.format("L%d: %s", d.lnum + 1, d.message))
          end
        end
        if #errors == 0 then
          vim.notify("[AI] No errors to fix!", vim.log.levels.INFO)
          return
        end
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local prompt = string.format("Fix these errors in %s:\n%s\n\n```%s\n%s\n```",
          vim.fn.fnamemodify(filepath, ":t"), table.concat(errors, "\n"), ft, table.concat(lines, "\n"))
        vim.fn.setreg('"', prompt)
        local ok, visual = pcall(require, "neotex.plugins.ai.claude.core.visual")
        if ok and visual and visual.send_visual_to_claude then
          visual.send_visual_to_claude()
        else
          vim.cmd("ClaudeCode")
          vim.notify("[AI] Error context copied! Paste into Claude", vim.log.levels.INFO)
        end
      end, desc = "ai: auto-fix errors (full file)", icon = "󰓓" },

      -- ⭐ Explain: gửi toàn bộ file cho Claude giải thích
      { "<leader>ae", function()
        local filepath = vim.api.nvim_buf_get_name(0)
        local ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local prompt = string.format("Explain this code in detail:\n```%s\n%s\n```", ft, table.concat(lines, "\n"))
        vim.fn.setreg('"', prompt)
        local ok, visual = pcall(require, "neotex.plugins.ai.claude.core.visual")
        if ok and visual and visual.send_visual_to_claude then
          visual.send_visual_to_claude()
        else
          vim.cmd("ClaudeCode")
          vim.notify("[AI] File content copied! Paste into Claude", vim.log.levels.INFO)
        end
      end, desc = "ai: explain code", icon = "󰋽" },

      -- Health check
      { "<leader>aH", function()
        local ok, claude = pcall(require, "neotex.plugins.ai.claude")
        if ok and claude then
          vim.notify(string.format("[AI] Claude module OK | proxy port 8787: %s",
            vim.fn.system("lsof -ti :8787") ~= "" and "RUNNING" or "STOPPED"
          ), vim.log.levels.INFO)
        else
          vim.notify("[AI] Claude module FAILED to load", vim.log.levels.ERROR)
        end
      end, desc = "ai: health check", icon = "󰌮" },

      -- Khởi động phiên cc-hr mới (kill proxy cũ -> start proxy mới -> mở Claude)
      { "<leader>an", function()
        vim.notify("[cc-hr] Đang khởi động phiên mới...", vim.log.levels.INFO)
        -- Kill proxy cũ trên port 8787 nếu đang chạy
        vim.fn.jobstart({ "bash", "-c", "lsof -ti :8787 | xargs kill 2>/dev/null; sleep 0.5" }, {
          on_exit = function()
            -- Start cc-hr daemon mới
            vim.fn.jobstart({ "bash", "-c", "cc-hr --daemon > /tmp/cc-hr-daemon.log 2>&1" }, {
              detach = true,
              on_exit = function(_, code)
                vim.schedule(function()
                  if code == 0 then
                    vim.notify("[cc-hr] Proxy mới đã sẵn sàng ✓ — mở Claude Code...", vim.log.levels.INFO)
                    vim.defer_fn(function()
                      vim.cmd("ClaudeCode")
                    end, 500)
                  else
                    vim.notify("[cc-hr] Khởi động thất bại! Xem /tmp/cc-hr-daemon.log", vim.log.levels.ERROR)
                  end
                end)
              end,
            })
          end,
        })
      end, desc = "ai: new cc-hr session", icon = "󰑓" },

      -- Toggle yolo mode (--dangerously-skip-permissions)
      { "<leader>ay", function()
        local config_path = vim.fn.expand("~/.config/nvim/lua/neotex/plugins/ai/claudecode.lua")

        if vim.fn.filereadable(config_path) ~= 1 then
          notify.editor(
            "Claude Code config not found",
            notify.categories.ERROR,
            { config_path = config_path }
          )
          return
        end

        local lines = vim.fn.readfile(config_path)
        local modified = false
        local yolo_enabled = false

        for i, line in ipairs(lines) do
          if line:match('%s*command = "cc%-nvim') or line:match('%s*command = "claude') then
            if line:match('--dangerously%-skip%-permissions') then
              -- Disable yolo mode
              lines[i] = '    command = "cc-nvim",'
              yolo_enabled = false
            else
              -- Enable yolo mode
              lines[i] = '    command = "cc-nvim --dangerously-skip-permissions",'
              yolo_enabled = true
            end
            modified = true
            break
          end
        end

        if not modified then
          notify.editor(
            "Could not find command line in config",
            notify.categories.ERROR,
            { config_path = config_path }
          )
          return
        end

        local write_ok = pcall(vim.fn.writefile, lines, config_path)
        if not write_ok then
          notify.editor(
            "Failed to write config file",
            notify.categories.ERROR,
            { config_path = config_path }
          )
          return
        end

        notify.editor(
          yolo_enabled and "Yolo mode enabled (restart required)" or "Yolo mode disabled (restart required)",
          notify.categories.USER_ACTION,
          { config_path = config_path, yolo_enabled = yolo_enabled }
        )
      end, desc = "toggle yolo mode", icon = "󰒓" },

      -- Kill all Claude Code session sleep inhibitors
      { "<leader>ak", function()
        local files = vim.fn.glob("/tmp/claude-inhibitor-*.pid", false, true)
        if #files == 0 then
          vim.notify("No active Claude sleep inhibitors", vim.log.levels.INFO)
          return
        end
        for _, f in ipairs(files) do
          local lines = vim.fn.readfile(f)
          local pid = lines and lines[1] and vim.fn.trim(lines[1]) or ""
          if pid ~= "" then
            vim.fn.system("kill " .. pid .. " 2>/dev/null")
          end
          vim.fn.delete(f)
        end
        vim.notify(string.format("Released %d Claude sleep inhibitor(s)", #files), vim.log.levels.INFO)
      end, desc = "kill sleep inhibitors", icon = "󰒲" },

      -- Model picker - select Claude Code model (DISABLED)
      -- { "<leader>am", function()
      --   local function get_claude_settings_path()
      --     local git = require("neotex.plugins.ai.claude.claude-session.git")
      --     if git.is_git_repo() then
      --       local git_root = git.get_git_root()
      --       if git_root and git_root ~= "" then
      --         local claude_dir = git_root .. "/.claude"
      --         if vim.fn.isdirectory(claude_dir) == 0 then
      --           vim.fn.mkdir(claude_dir, "p")
      --         end
      --         return claude_dir .. "/settings.local.json", "project"
      --       end
      --     end
      --     return vim.fn.expand("~/.claude/settings.local.json"), "global"
      --   end
      --
      --   local config_path, config_scope = get_claude_settings_path()
      --
      --   local models = {
      --     { id = "opus", label = "Opus 4.6 (1M)" },
      --     { id = "sonnet", label = "Sonnet 4.6" },
      --     { id = "haiku", label = "Haiku 4.5" },
      --   }
      --
      --   local current_model = nil
      --   local file = io.open(config_path, "r")
      --   if file then
      --     local content = file:read("*all")
      --     file:close()
      --     local ok, settings = pcall(vim.fn.json_decode, content)
      --     if ok and settings and settings.model then
      --       current_model = settings.model
      --     end
      --   end
      --
      --   vim.ui.select(models, {
      --     prompt = "Select Claude model:",
      --     format_item = function(item)
      --       local marker = (item.id == current_model) and " [*]" or ""
      --       return string.format("%s%s", item.label, marker)
      --     end,
      --   }, function(choice)
      --     if not choice then return end
      --     local settings = {}
      --     local read_file = io.open(config_path, "r")
      --     if read_file then
      --       local content = read_file:read("*all")
      --       read_file:close()
      --       local ok, data = pcall(vim.fn.json_decode, content)
      --       if ok and data then settings = data end
      --     end
      --     if choice.id then
      --       settings.model = choice.id
      --     else
      --       settings.model = nil
      --     end
      --     local write_ok, write_err = pcall(function()
      --       local write_file = io.open(config_path, "w")
      --       if not write_file then error("Cannot open file for writing") end
      --       write_file:write(vim.fn.json_encode(settings))
      --       write_file:close()
      --     end)
      --     if not write_ok then
      --       notify.editor("Failed to write settings: " .. tostring(write_err), notify.categories.ERROR)
      --       return
      --     end
      --     notify.editor(
      --       string.format("Model set to %s (%s settings, takes effect on next Claude Code open)", choice.label, config_scope),
      --       notify.categories.USER_ACTION,
      --       { model = choice.id, scope = config_scope }
      --     )
      --   end)
      -- end, desc = "model (claude)", icon = "󰘦" },
    })

    -- ============================================================================
    -- <leader>f - FIND GROUP
    -- ============================================================================

    wk.add({
      { "<leader>f", group = "find", icon = "󰍉", mode = { "n", "v" } },
      { "<leader>fa", "<cmd>lua require('telescope.builtin').find_files({ no_ignore = true, hidden = true, search_dirs = { '~/' } })<CR>", desc = "all files", icon = "󰈙" },
      { "<leader>fb", "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<CR>", desc = "buffers", icon = "󰓩" },
      { "<leader>fc", "<cmd>Telescope bibtex format_string=\\citet{%s}<CR>", desc = "citations", icon = "󰈙" },
      { "<leader>ff", "<cmd>Telescope live_grep theme=ivy<CR>", desc = "project", icon = "󰊄" },
      { "<leader>fl", "<cmd>Telescope resume<CR>", desc = "last search", icon = "󰺄" },
      { "<leader>fp", "<cmd>lua require('neotex.util.misc').copy_buffer_path()<CR>", desc = "copy buffer path", icon = "󰆏" },
      { "<leader>fo", function() _G.open_file_under_cursor() end, desc = "open file at cursor (Claude paths)", icon = "󰈈" },
      { "<leader>fq", "<cmd>Telescope quickfix<CR>", desc = "quickfix", icon = "󰁨" },
      { "<leader>fg", "<cmd>Telescope git_commits<CR>", desc = "git history", icon = "󰊢" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "help", icon = "󰞋" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "keymaps", icon = "󰌌" },
      { "<leader>fr", "<cmd>Telescope registers<CR>", desc = "registers", icon = "󰊄" },
      { "<leader>fs", "<cmd>Telescope grep_string<CR>", desc = "string", icon = "󰊄", mode = { "n", "v" } },
      { "<leader>fw", "<cmd>lua SearchWordUnderCursor()<CR>", desc = "word", icon = "󰊄", mode = { "n", "v" } },
      { "<leader>fy", function() require("neotex.yank").telescope_history() end, desc = "yanks", icon = "󰆏", mode = { "n", "v" } },
    })

    -- ============================================================================
    -- GIT REPO HELPER: finds git root from current buffer, falls back to cwd
    -- ============================================================================

    -- LSP helper: kiểm tra LSP server có hỗ trợ method không
    local function _lsp_supported(method)
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then
        vim.notify("No LSP server active for this file type", vim.log.levels.WARN)
        return false
      end
      for _, client in ipairs(clients) do
        if client.supports_method(method) then
          return true
        end
      end
      vim.notify("LSP doesn't support: " .. method, vim.log.levels.WARN)
      return false
    end

    local function _lsp_call(method, fn)
      return function()
        if _lsp_supported(method) then
          fn()
        end
      end
    end

    -- Detect .gitignore based on project files
    local function _detect_gitignore(dir)
      local files = {}
      pcall(function() files = vim.fn.readdir(dir) end)
      local ignores = { "# Generated by Neovim auto-git-init" }
      local all = table.concat(files, " ")

      if all:match("package%.json") or all:match("node_modules") then
        table.insert(ignores, "node_modules/"); table.insert(ignores, "dist/")
        table.insert(ignores, ".env"); table.insert(ignores, "*.log")
      end
      if all:match("__pycache__") or all:match("%.py$") or all:match("requirements") then
        table.insert(ignores, "__pycache__/"); table.insert(ignores, "*.py[cod]")
        table.insert(ignores, ".env"); table.insert(ignores, "venv/"); table.insert(ignores, ".venv/")
      end
      if all:match("Cargo%.toml") then table.insert(ignores, "target/") end
      if all:match("go%.mod") then table.insert(ignores, "*.exe"); table.insert(ignores, "*.test") end
      if all:match("%.typ") then table.insert(ignores, "*.pdf") end
      table.insert(ignores, ""); table.insert(ignores, ".DS_Store"); table.insert(ignores, "Thumbs.db")
      table.insert(ignores, "*.swp"); table.insert(ignores, "*~")
      return table.concat(ignores, "\n")
    end

    local function _git_cwd()
      local buf_path = vim.api.nvim_buf_get_name(0)
      if buf_path and buf_path ~= "" then
        local root = vim.fn.systemlist("cd " .. vim.fn.shellescape(vim.fn.fnamemodify(buf_path, ":h")) .. " && git rev-parse --show-toplevel 2>/dev/null")
        if root and #root > 0 and root[1] ~= "" then
          return vim.fn.trim(root[1])
        end
      end
      local cwd_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")
      if cwd_root and #cwd_root > 0 and cwd_root[1] ~= "" then
        return vim.fn.trim(cwd_root[1])
      end
      return nil
    end

    local function _tele_git(picker)
      return function()
        local git_root = _git_cwd()
        if not git_root then
          vim.notify("Not in a git repository", vim.log.levels.WARN)
          return
        end
        local cur_cwd = vim.fn.getcwd()
        vim.fn.chdir(git_root)
        pcall(function()
          require("telescope.builtin")[picker]({ cwd = git_root })
        end)
        vim.fn.chdir(cur_cwd)
      end
    end

    -- ============================================================================
    -- <leader>g - GIT GROUP
    -- ============================================================================

    wk.add({
      -- Group header
      { "<leader>g", group = "GIT", icon = "󰊢", mode = { "n", "v" } },

      -- Overview & Repo Operations
      { "<leader>gb", _tele_git("git_branches"),    desc = "switch branch",   icon = "󰘬" },
      { "<leader>gc", _tele_git("git_commits"),     desc = "browse commits",  icon = "󰜘" },
      { "<leader>gC", _tele_git("git_bcommits"),    desc = "file history",    icon = "󰉏" },
      -- Git Init Master (chủ động init + .gitignore + commit)
      { "<leader>gi", function()
        local cwd = vim.fn.getcwd()
        local git_dir = cwd .. "/.git"
        if vim.fn.isdirectory(git_dir) == 1 then
          vim.notify("Already a git repository", vim.log.levels.INFO)
          return
        end
        local project_name = vim.fn.fnamemodify(cwd, ":t")
        vim.ui.select({ "Yes, init git", "No, skip" }, {
          prompt = string.format("Init git for '%s'?", project_name),
        }, function(choice)
          if not choice or choice:match("No") then return end
          -- Tạo .gitignore thông minh
          local ignore_path = cwd .. "/.gitignore"
          if vim.fn.filereadable(ignore_path) == 0 then
            local gitignore = _detect_gitignore(cwd)
            if gitignore then
              vim.fn.writefile(vim.split(gitignore, "\n", { plain = true }), ignore_path)
            end
          end
          vim.fn.system("cd " .. vim.fn.shellescape(cwd) .. " && git init 2>/dev/null")
          if vim.v.shell_error ~= 0 then
            vim.notify("git init failed!", vim.log.levels.ERROR)
            return
          end
          -- Git add + first commit
          vim.fn.system("cd " .. vim.fn.shellescape(cwd) .. " && git add -A && git commit -m 'initial commit' 2>/dev/null")
          vim.notify(string.format("✓ Git ready: LazyGit=<Space>gg, Changes=<Space>gs", project_name),
            vim.log.levels.INFO, { title = "Git Init", timeout = 5000 })
        end)
      end, desc = "⭐ init git repo (+ .gitignore)", icon = "󰊢" },
      { "<leader>gs", function()
        local git_root = _git_cwd()
        if not git_root then
          vim.notify("Not in a git repository", vim.log.levels.WARN)
          return
        end
        require("snacks").picker.git_status({ cwd = git_root })
      end, desc = "changed files", icon = "󰅧" },
      { "<leader>gN", "<cmd>Neotree git_status position=left<CR>", desc = "changed files (tree)", icon = "󰙅" },
      { "<leader>gg", function()
        local ok, snacks = pcall(require, "snacks")
        if ok then
          -- Gọi lazygit qua Snacks (floating terminal)
          snacks.lazygit({ cwd = _git_cwd() })
        else
          -- Fallback: mở terminal trực tiếp
          vim.cmd("tab term lazygit")
        end
      end, desc = "lazygit",   icon = "󰊢" },
      { "<leader>gS", _tele_git("git_stash"),              desc = "stash",           icon = "󰆊" },
      { "<leader>gl", "<cmd>Gitsigns blame_line<CR>",       desc = "line blame",      icon = "󰓇", mode = { "n", "v" } },
      { "<leader>gt", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = "toggle blame", icon = "󰔡" },

      -- Hunk Operations
      { "<leader>gj", "<cmd>Gitsigns next_hunk<CR>",       desc = "next hunk",        icon = "󰮰" },
      { "<leader>gh", "<cmd>Gitsigns prev_hunk<CR>",       desc = "prev hunk",        icon = "󰮲" },
      { "<leader>gd", "<cmd>Gitsigns diffthis<CR>",         desc = "diff hunk",        icon = "󰁛" },
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>",     desc = "preview hunk",     icon = "󰆈" },
      { "<leader>ga", "<cmd>Gitsigns stage_hunk<CR>",       desc = "stage hunk",       icon = "󰡖", mode = { "n", "v" } },
      { "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<CR>",  desc = "unstage hunk",     icon = "󰜺" },
      { "<leader>gx", "<cmd>Gitsigns reset_hunk<CR>",       desc = "reset hunk",       icon = "󰅙", mode = { "n", "v" } },

      -- Review & Restore (xem thay đổi + quay lại bản gốc)
      { "<leader>g.", function()
        local git_root = _git_cwd()
        if not git_root then
          vim.notify("Not in a git repository", vim.log.levels.WARN)
          return
        end
        require("snacks").picker.git_status({ cwd = git_root })
      end, desc = "review all changes", icon = "󰅧" },
      { "<leader>gD", "<cmd>Gitsigns diffthis HEAD<CR>",    desc = "diff file vs HEAD", icon = "󰁛" },
      { "<leader>gR", function()
        local bufpath = vim.api.nvim_buf_get_name(0)
        if bufpath == "" then
          vim.notify("No file in buffer", vim.log.levels.WARN)
          return
        end
        local ok, result = pcall(vim.fn.system, "git -C " .. vim.fn.shellescape(vim.fn.fnamemodify(bufpath, ":h")) .. " rev-parse --show-toplevel 2>/dev/null")
        if not ok or result == "" or result:match("fatal") then
          vim.notify("Not in a git repository", vim.log.levels.WARN)
          return
        end
        local relpath = vim.fn.system("git -C " .. vim.fn.shellescape(vim.fn.fnamemodify(bufpath, ":h")) .. " ls-files --full-name " .. vim.fn.shellescape(bufpath) .. " 2>/dev/null"):gsub("%s+", "")
        if relpath == "" then
          vim.notify("File is not tracked by git", vim.log.levels.WARN)
          return
        end
        -- Confirm before destructive action
        vim.ui.select({ "Yes, restore current file", "No, cancel" }, {
          prompt = "Restore " .. vim.fn.fnamemodify(bufpath, ":t") .. " to last committed state?",
        }, function(choice)
          if choice and choice:match("^Yes") then
            vim.cmd("silent !git -C " .. vim.fn.shellescape(vim.fn.fnamemodify(bufpath, ":h")) .. " checkout -- " .. vim.fn.shellescape(bufpath))
            vim.cmd("edit!")
            vim.notify("Restored: " .. vim.fn.fnamemodify(bufpath, ":t"), vim.log.levels.INFO)
          end
        end)
      end, desc = "restore file to original", icon = "󰄘" },

      -- Claude Worktree Management
      { "<leader>gw", "<cmd>ClaudeWorktree<CR>",            desc = "new claude worktree",     icon = "󰘬" },
      { "<leader>gv", "<cmd>ClaudeSessions<CR>",            desc = "view claude worktrees",   icon = "󰋼" },
      { "<leader>gr", "<cmd>ClaudeRestoreWorktree<CR>",     desc = "restore claude worktree", icon = "󰑐" },
    })

    -- ============================================================================
    -- <leader>h - HELP GROUP
    -- ============================================================================

    wk.add({
      { "<leader>h", group = "help", icon = "󰞋" },
      { "<leader>ha", "<cmd>Telescope autocommands<CR>", desc = "autocommands", icon = "󰆘" },
      { "<leader>hc", "<cmd>Telescope commands<CR>", desc = "commands", icon = "󰘳" },
      { "<leader>hh", "<cmd>Telescope help_tags<CR>", desc = "help tags", icon = "󰞋" },
      { "<leader>hH", "<cmd>Telescope highlights<CR>", desc = "highlights", icon = "󰸱" },
      { "<leader>hk", "<cmd>Telescope keymaps<CR>", desc = "keymaps", icon = "󰌌" },
      { "<leader>hl", "<cmd>LspInfo<CR>", desc = "lsp info", icon = "󰅴" },
      { "<leader>hL", "<cmd>Lazy<CR>", desc = "lazy plugin manager", icon = "󰒲" },
      { "<leader>hm", "<cmd>Telescope man_pages<CR>", desc = "man pages", icon = "󰈙" },
      { "<leader>hM", "<cmd>Mason<CR>", desc = "mason lsp installer", icon = "󰏖" },
      { "<leader>hn", "<cmd>NullLsInfo<CR>", desc = "null-ls info", icon = "󰅴" },
      { "<leader>hN", "<cmd>Telescope vim_options<CR>", desc = "vim options", icon = "󰒕" },
      { "<leader>hr", "<cmd>Telescope reloader<CR>", desc = "reload modules", icon = "󰜉" },
      { "<leader>ht", "<cmd>TSPlaygroundToggle<CR>", desc = "treesitter playground", icon = "󰔡" },
    })

    -- ============================================================================
    -- <leader>T - TABS GROUP (WezTerm)
    -- ============================================================================

    wk.add({
      { "<leader>T", group = "tabs", icon = "󰓩", mode = { "n", "v" } },
      { "<leader>TN", function() require("wezterm").switch_tab.relative(-1) end, desc = "prev tab", icon = "󰮲" },
      { "<leader>TP", function() require("wezterm").switch_tab.relative(1) end, desc = "next tab", icon = "󰮰" },
      { "<leader>TT", function()
        local wezterm = require("wezterm")
        local count = vim.v.count
        if count > 0 then
          wezterm.switch_tab.index(count - 1) -- WezTerm uses 0-based indexing
        else
          vim.notify("Use count to specify tab (e.g., 2<leader>TT for tab 2)", vim.log.levels.INFO)
        end
      end, desc = "go to tab N", icon = "󰓩" },
    })

    -- ============================================================================
    -- <leader>i - LSP & LINT GROUP
    -- ============================================================================

    wk.add({
      -- Group header
      { "<leader>i", group = "LSP & Lint", icon = "󰅴", mode = { "n", "v" } },

      -- Navigation: Go To / Peek
      { "<leader>id", "<cmd>Telescope lsp_definitions<CR>",       desc = "go to definition",      icon = "󰳦" },
      { "<leader>iD", _lsp_call("textDocument/declaration", function() vim.lsp.buf.declaration() end), desc = "go to declaration", icon = "󰳦" },
      { "<leader>iT", _lsp_call("textDocument/typeDefinition", function() vim.lsp.buf.type_definition() end), desc = "go to type definition", icon = "󰌷" },
      { "<leader>ii", "<cmd>Telescope lsp_implementations<CR>",   desc = "go to implementations", icon = "󰡱" },
      { "<leader>ir", "<cmd>Telescope lsp_references<CR>",        desc = "find references",       icon = "󰌹" },

      -- Navigation: Jump History (quay lại vị trí cũ)
      { "<leader>i[", function() vim.api.nvim_input("<C-o>") end, desc = "jump back",   icon = "󰜴" },
      { "<leader>i]", function() vim.api.nvim_input("<C-i>") end, desc = "jump forward", icon = "󰜵" },

      -- Symbols: Document & Workspace
      { "<leader>io", "<cmd>Telescope lsp_document_symbols<CR>",  desc = "document symbols",  icon = "󰉐" },
      { "<leader>iO", "<cmd>Telescope lsp_workspace_symbols<CR>", desc = "workspace symbols", icon = "󰉐" },

      -- Diagnostics: Inspection & Navigation
      { "<leader>il", "<cmd>lua vim.diagnostic.open_float()<CR>", desc = "line diagnostics",      icon = "󰅚" },
      { "<leader>ib", "<cmd>Telescope diagnostics bufnr=0<CR>",   desc = "buffer diagnostics",    icon = "󰅦" },
      { "<leader>iP", "<cmd>Telescope diagnostics<CR>",           desc = "workspace diagnostics", icon = "󰅦" },
      { "<leader>in", "<cmd>lua vim.diagnostic.goto_next()<CR>",  desc = "next diagnostic",       icon = "󰮰" },
      { "<leader>ip", "<cmd>lua vim.diagnostic.goto_prev()<CR>",  desc = "prev diagnostic",       icon = "󰮲" },
      { "<leader>iy", "<cmd>lua CopyDiagnosticsToClipboard()<CR>",desc = "copy diagnostics",      icon = "󰆏" },

      -- Actions: Code & Text
      { "<leader>ic", _lsp_call("textDocument/codeAction", function() vim.lsp.buf.code_action() end), desc = "code action", icon = "󰌵", mode = { "n", "v" } },
      { "<leader>iR", _lsp_call("textDocument/rename", function() vim.lsp.buf.rename() end), desc = "rename symbol", icon = "󰑕" },
      { "<leader>ih", _lsp_call("textDocument/hover", function() vim.lsp.buf.hover() end), desc = "hover documentation", icon = "󰈈" },
      { "<leader>iF", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "format code", icon = "󰉣", mode = { "n", "v" } },

      -- Linting
      { "<leader>iL", function() require("lint").try_lint() end, desc = "lint file",            icon = "󰁨" },
      { "<leader>iB", "<cmd>LintToggle buffer<CR>",              desc = "toggle buffer linting", icon = "󰔡" },
      { "<leader>ig", "<cmd>LintToggle<CR>",                     desc = "toggle global linting", icon = "󰔡" },

      -- LSP Management
      { "<leader>is", "<cmd>LspRestart<CR>", desc = "restart LSP", icon = "󰜉" },
      { "<leader>it", function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients > 0 then
          vim.cmd('LspStop')
          require('neotex.util.notifications').lsp('LSP stopped', require('neotex.util.notifications').categories.USER_ACTION)
        else
          vim.cmd('LspStart')
          require('neotex.util.notifications').lsp('LSP started', require('neotex.util.notifications').categories.USER_ACTION)
        end
      end, desc = "toggle LSP", icon = "󰓦" },

      -- Open File Externally (mở file bằng app phù hợp)
      { "<leader>iI", function()
        local bufpath = vim.api.nvim_buf_get_name(0)
        if bufpath == "" or vim.fn.filereadable(bufpath) == 0 then
          vim.notify("File not found on disk", vim.log.levels.WARN)
          return
        end
        local ext = vim.fn.fnamemodify(bufpath, ":e"):lower()
        local name = vim.fn.fnamemodify(bufpath, ":t")
        -- .md → mở render preview trong Brave (có sơ đồ, ảnh, LaTeX...)
        if ext == "md" then
          vim.cmd("MarkdownPreview")
          vim.notify("Markdown preview opened in Brave", vim.log.levels.INFO)
          return
        end
        -- .docx / .odt → mở trong LibreOffice (xem bản đẹp, có sơ đồ, bảng biểu)
        -- Còn muốn sửa thì mở trực tiếp file .docx trong Neovim (tự động convert markdown)
        if ext == "docx" or ext == "odt" then
          vim.fn.jobstart({ "xdg-open", bufpath }, { detach = true })
          vim.notify("Opened: " .. name .. " (edit in Neovim, :w to save back)", vim.log.levels.INFO)
          return
        end
        -- File khác → mở bằng app mặc định của hệ thống
        vim.fn.jobstart({ "xdg-open", bufpath }, { detach = true })
        vim.notify("Opened: " .. name, vim.log.levels.INFO)
      end, desc = "open file (md→Brave, docx→LibreOffice, khác→app)", icon = "󰥶" },
      { "<leader>iK", function()
        vim.notify("Close external image viewer manually", vim.log.levels.INFO)
      end, desc = "close image", icon = "󰅗" },
    })

    -- ============================================================================
    -- <leader>j - JUPYTER GROUP
    -- ============================================================================

    wk.add({
      -- Group header (static name, conditional visibility)
      { "<leader>j", group = "jupyter", icon = "󰌠", cond = is_jupyter },

      -- Jupyter-specific mappings
      { "<leader>ja", "<cmd>lua require('notebook-navigator').run_all_cells()<CR>", desc = "run all cells", icon = "󰐊", cond = is_jupyter },
      { "<leader>jb", "<cmd>lua require('notebook-navigator').run_cells_below()<CR>", desc = "run cells below", icon = "󰐊", cond = is_jupyter },
      { "<leader>jc", "<cmd>lua require('notebook-navigator').comment_cell()<CR>", desc = "comment cell", icon = "󰆈", cond = is_jupyter },
      { "<leader>jd", "<cmd>lua require('notebook-navigator').merge_cell('d')<CR>", desc = "merge with cell below", icon = "󰅀", cond = is_jupyter },
      { "<leader>je", "<cmd>lua require('notebook-navigator').run_cell()<CR>", desc = "execute cell", icon = "󰐊", cond = is_jupyter },
      { "<leader>jf", "<cmd>lua require('iron.core').send(nil, vim.fn.readfile(vim.fn.expand('%')))<CR>", desc = "send file to REPL", icon = "󰊠", cond = is_jupyter },
      { "<leader>ji", "<cmd>lua require('iron.core').repl_for('python')<CR>", desc = "start IPython REPL", icon = "󰌠", cond = is_jupyter },
      { "<leader>jj", "<cmd>lua require('notebook-navigator').move_cell('d')<CR>", desc = "next cell", icon = "󰮰", cond = is_jupyter },
      { "<leader>jk", "<cmd>lua require('notebook-navigator').move_cell('u')<CR>", desc = "previous cell", icon = "󰮲", cond = is_jupyter },
      { "<leader>jl", "<cmd>lua require('iron.core').send_line()<CR>", desc = "send line to REPL", icon = "󰊠", cond = is_jupyter },
      { "<leader>jn", "<cmd>lua require('notebook-navigator').run_and_move()<CR>", desc = "execute and next", icon = "󰒭", cond = is_jupyter },
      { "<leader>jo", "<cmd>lua require('neotex.util.diagnostics').add_jupyter_cell_with_closing()<CR>", desc = "insert cell below", icon = "󰐕", cond = is_jupyter },
      { "<leader>jO", "<cmd>lua require('notebook-navigator').add_cell_above()<CR>", desc = "insert cell above", icon = "󰐖", cond = is_jupyter },
      { "<leader>jq", "<cmd>lua require('iron.core').close_repl()<CR>", desc = "exit REPL", icon = "󰚌", cond = is_jupyter },
      { "<leader>jr", "<cmd>lua require('iron.core').send(nil, string.char(12))<CR>", desc = "clear REPL", icon = "󰃢", cond = is_jupyter },
      { "<leader>js", "<cmd>lua require('notebook-navigator').split_cell()<CR>", desc = "split cell", icon = "󰤋", cond = is_jupyter },
      { "<leader>jt", "<cmd>lua require('iron.core').run_motion('send_motion')<CR>", desc = "send motion to REPL", icon = "󰊠", cond = is_jupyter },
      { "<leader>ju", "<cmd>lua require('notebook-navigator').merge_cell('u')<CR>", desc = "merge with cell above", icon = "󰅂", cond = is_jupyter },
      { "<leader>jv", "<cmd>lua require('iron.core').visual_send()<CR>", desc = "send visual selection to REPL", icon = "󰊠", mode = { "n", "v" }, cond = is_jupyter_or_python },
    })

    -- ============================================================================
    -- <leader>m - MAIL GROUP
    -- ============================================================================

    wk.add({
      { "<leader>m", group = "mail", icon = "󰇮" },
      { "<leader>mA", "<cmd>HimalayaAccounts<CR>", desc = "switch account", icon = "󰌏" },
      { "<leader>mf", "<cmd>HimalayaFolder<CR>", desc = "change folder", icon = "󰉋" },
      { "<leader>mF", "<cmd>HimalayaRecreateFolders<CR>", desc = "recreate folders", icon = "󰝰" },
      { "<leader>mh", "<cmd>HimalayaHealth<CR>", desc = "health check", icon = "󰸉" },
      { "<leader>mi", "<cmd>HimalayaSyncInfo<CR>", desc = "sync status", icon = "󰋼" },
      { "<leader>mm", "<cmd>HimalayaToggle<CR>", desc = "toggle sidebar", icon = "󰊫" },
      { "<leader>ms", "<cmd>HimalayaSyncInbox<CR>", desc = "sync inbox", icon = "󰜉" },
      { "<leader>mS", "<cmd>HimalayaSyncFull<CR>", desc = "full sync", icon = "󰜉" },
      { "<leader>mr", "<cmd>TermExec cmd='find ~/Mail/Logos -name .mbsyncstate -delete; find ~/Mail/Logos -name .uidvalidity -delete; rm -f /home/benjamin/Mail/.claude/output/email.md; mbsync logos'<CR><C-w>l", desc = "maildir resync", icon = "󰔟" },
      { "<leader>mt", "<cmd>HimalayaAutoSyncToggle<CR>", desc = "toggle auto-sync", icon = "󰑖" },
      { "<leader>mw", "<cmd>HimalayaWrite<CR>", desc = "write email", icon = "󰝒" },
      { "<leader>mW", "<cmd>HimalayaSetup<CR>", desc = "setup wizard", icon = "󰗀" },
      { "<leader>mx", "<cmd>HimalayaCancelSync<CR>", desc = "cancel all syncs", icon = "󰚌" },
      { "<leader>mX", "<cmd>HimalayaBackupAndFresh<CR>", desc = "backup & fresh", icon = "󰁯" },
    })

    -- NOTE: Compose buffer and email preview keymaps are now registered
    -- buffer-locally in email_composer.lua and email_preview.lua respectively.
    -- This enables them to appear in which-key menu for their specific buffers.
    -- (Task 73 - buffer-local which-key registration pattern)

    -- ============================================================================
    -- <leader>n - NIXOS GROUP
    -- ============================================================================

    wk.add({
      { "<leader>n", group = "nixos", icon = "󱄅" },
      { "<leader>nd", "<cmd>TermExec cmd='nix develop'<CR><C-w>j", desc = "develop", icon = "󰐊" },
      { "<leader>nf", "<cmd>TermExec cmd='sudo nixos-rebuild switch --flake ~/.dotfiles/'<CR><C-w>l", desc = "rebuild flake", icon = "󰜉" },
      { "<leader>ng", "<cmd>TermExec cmd='nix-collect-garbage --delete-older-than 15d'<CR><C-w>j", desc = "garbage", icon = "󰩺" },
      { "<leader>nh", "<cmd>TermExec cmd='home-manager switch --flake ~/.dotfiles/'<CR><C-w>l", desc = "home-manager", icon = "󰋜" },
      { "<leader>nm", "<cmd>TermExec cmd='brave https://mynixos.com' open=0<CR>", desc = "my-nixos", icon = "󰖟" },
      { "<leader>np", "<cmd>TermExec cmd='brave https://search.nixos.org/packages' open=0<CR>", desc = "packages", icon = "󰏖" },
      { "<leader>nr", "<cmd>TermExec cmd='~/.dotfiles/update.sh'<CR><C-w>l", desc = "rebuild nix", icon = "󰜉" },
      { "<leader>nu", "<cmd>TermExec cmd='cd ~/.dotfiles && ./update.sh --update'<CR><C-w>j", desc = "update inputs + rebuild", icon = "󰚰" },
    })

    -- ============================================================================
    -- <leader>p - PANDOC GROUP
    -- ============================================================================

    wk.add({
      -- Group header (static name, conditional visibility)
      { "<leader>p", group = "pandoc", icon = "󰈙", cond = is_pandoc_compatible },

      -- Pandoc-specific mappings
      { "<leader>ph", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.html'<CR>", desc = "html", icon = "󰌝", cond = is_pandoc_compatible },
      { "<leader>pl", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.tex'<CR>", desc = "latex", icon = "󰐺", cond = is_pandoc_compatible },
      { "<leader>pm", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.md'<CR>", desc = "markdown", icon = "󱀈", cond = is_pandoc_compatible },
      { "<leader>pp", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.pdf' open=0<CR>", desc = "pdf", icon = "󰈙", cond = is_pandoc_compatible },
      { "<leader>pv", "<cmd>TermExec cmd='sioyek %:p:r.pdf &' open=0<CR>", desc = "view", icon = "󰛓", cond = is_pandoc_compatible },
      { "<leader>pw", "<cmd>TermExec cmd='pandoc %:p -o %:p:r.docx'<CR>", desc = "word", icon = "󰈭", cond = is_pandoc_compatible },
    })

    -- ============================================================================
    -- <leader>r - RUN GROUP
    -- ============================================================================

    wk.add({
      { "<leader>r", group = "run", icon = "󰌵" },
      { "<leader>rc", "<cmd>TermExec cmd='rm -rf ~/.cache/nvim' open=0<CR>", desc = "clear plugin cache", icon = "󰃢" },
      { "<leader>rd", function()
          local notify = require('neotex.util.notifications')
          notify.toggle_debug_mode()
        end, desc = "toggle debug mode", icon = "󰃤" },
      { "<leader>rl", "<cmd>lua require('neotex.util.diagnostics').show_all_errors()<CR>", desc = "show linter errors", icon = "󰅚" },
      { "<leader>rh", "<cmd>LocalHighlightToggle<CR>", desc = "highlight", icon = "󰠷" },
      { "<leader>rk", "<cmd>BufDeleteFile<CR>", desc = "kill file and buffer", icon = "󰆴" },
      { "<leader>rK", "<cmd>TermExec cmd='rm -rf ~/.local/share/nvim/lazy && rm -f ~/.config/nvim/lazy-lock.json' open=0<CR>", desc = "wipe plugins and lock file", icon = "󰩺" },
      { "<leader>rm", "<cmd>lua RunModelChecker()<CR>", desc = "model checker", icon = "󰐊", mode = "n" },
      { "<leader>rM", "<cmd>lua Snacks.notifier.show_history()<cr>", desc = "show messages", icon = "󰍡" },
      { "<leader>rp", "<cmd>TermExec cmd='python %:p:r.py'<CR>", desc = "python run", icon = "󰌠", cond = is_python },
      { "<leader>rr", "<cmd>AutolistRecalculate<CR>", desc = "reorder list", icon = "󰔢", cond = is_markdown },
      { "<leader>rR", "<cmd>ReloadConfig<cr>", desc = "reload configs", icon = "󰜉" },
      { "<leader>re", "<cmd>Neotree ~/.config/nvim/snippets/<CR>", desc = "snippets edit", icon = "󰩫" },
      { "<leader>rs", "<cmd>TermExec cmd='ssh brastmck@eofe10.mit.edu'<CR>", desc = "ssh", icon = "󰣀" },
      { "<leader>rz", function()
          require('neotex.util.sleep-inhibit').toggle()
        end, desc = "toggle sleep inhibitor", icon = "󰒲" },
      { "<leader>rg", "<cmd>lua OpenUrlUnderCursor()<CR>", desc = "go to URL", icon = "󰖟" },
    })

    -- ============================================================================
    -- <leader>z - FOLD GROUP
    -- ============================================================================

    wk.add({
      { "<leader>z", group = "fold", icon = "󰘖", mode = { "n", "v" } },
      { "<leader>zF", "<cmd>lua ToggleAllFolds()<CR>", desc = "toggle all folds", icon = "󰘖" },
      { "<leader>zo", "za", desc = "toggle fold under cursor", icon = "󰘖" },
      { "<leader>zt", "<cmd>lua ToggleFoldingMethod()<CR>", desc = "toggle folding method", icon = "󰘖" },
    })

    -- ============================================================================
    -- <leader>L - LEAN GROUP
    -- ============================================================================

    wk.add({
      { "<leader>L", group = "lean", icon = "󰐊", mode = { "n", "v" } },
      { "<leader>Lb", "<cmd>TermExec cmd='lake build'<CR>", desc = "lean build", icon = "󰐊" },
      { "<leader>Li", function() require('lean.infoview').toggle() end, desc = "toggle infoview", icon = "󰊕" },
    })

    -- ============================================================================
    -- <leader>s - SURROUND GROUP
    -- ============================================================================

    wk.add({
      { "<leader>s", group = "surround", icon = "󰅪", mode = { "n", "v" } },
      { "<leader>sc", "<Plug>(nvim-surround-change)", desc = "change", icon = "󰏫" },
      { "<leader>sd", "<Plug>(nvim-surround-delete)", desc = "delete", icon = "󰚌" },
      { "<leader>ss", "<Plug>(nvim-surround-normal)", desc = "surround", icon = "󰅪", mode = "n" },
      { "<leader>ss", "<Plug>(nvim-surround-visual)", desc = "surround selection", icon = "󰅪", mode = "v" },
    })

    -- ============================================================================
    -- <leader>S - SESSIONS GROUP
    -- ============================================================================

    wk.add({
      { "<leader>S", group = "sessions", icon = "󰆔" },
      { "<leader>Sd", "<cmd>SessionManager delete_session<CR>", desc = "delete", icon = "󰚌" },
      { "<leader>Sl", "<cmd>SessionManager load_session<CR>", desc = "load", icon = "󰉖" },
      { "<leader>Ss", "<cmd>SessionManager save_current_session<CR>", desc = "save", icon = "󰆓" },
    })

    -- ============================================================================
    -- <leader>t - TODO GROUP
    -- ============================================================================

    wk.add({
      { "<leader>t", group = "todo", icon = "󰄬" },
      { "<leader>tl", "<cmd>TodoLocList<CR>", desc = "todo location list", icon = "󰈙" },
      { "<leader>tn", function() require("todo-comments").jump_next() end, desc = "next todo", icon = "󰮰" },
      { "<leader>tp", function() require("todo-comments").jump_prev() end, desc = "previous todo", icon = "󰮲" },
      { "<leader>tq", "<cmd>TodoQuickFix<CR>", desc = "todo quickfix", icon = "󰁨" },
      { "<leader>tt", "<cmd>TodoTelescope<CR>", desc = "todo telescope", icon = "󰄬" },
    })

    -- ============================================================================
    -- <leader>x - TEXT GROUP
    -- ============================================================================

    wk.add({
      { "<leader>x", group = "text", icon = "󰤌", mode = { "n", "v" } },
      { "<leader>xa", desc = "align", icon = "󰉞", mode = { "n", "v" } },
      { "<leader>xA", desc = "align with preview", icon = "󰉞", mode = { "n", "v" } },
      { "<leader>xd", desc = "toggle diff overlay", icon = "󰦓" },
      { "<leader>xs", desc = "split/join toggle", icon = "󰤋", mode = { "n", "v" } },
      { "<leader>xw", desc = "toggle word diff", icon = "󰦓" },
    })

    -- ============================================================================
    -- <leader>v - VOICE GROUP (STT)
    -- ============================================================================

    wk.add({
      { "<leader>v", group = "voice", icon = "󰍬" },
      { "<leader>vh", function() require('neotex.plugins.tools.stt').health() end, desc = "health check", icon = "󰸉" },
      { "<leader>vr", function() require('neotex.plugins.tools.stt').start_recording() end, desc = "start recording", icon = "󰑊" },
      { "<leader>vs", function() require('neotex.plugins.tools.stt').stop_recording() end, desc = "stop recording", icon = "󰓛" },
      { "<leader>vv", function() require('neotex.plugins.tools.stt').toggle_recording() end, desc = "toggle recording", icon = "󰔊" },
    })

    -- ============================================================================
    -- <leader>K - KILL/PROCESS GROUP
    -- ============================================================================

    local function process_launch()
      local ok, process = pcall(require, "neotex.util.process")
      if ok then
        process.launch()
      else
        vim.notify("Process manager not available", vim.log.levels.WARN)
      end
    end

    wk.add({
      { "<leader>K", group = "kill", icon = "\u{f035a}", mode = { "n", "v" } },
      { "<leader>Kl", process_launch, desc = "launch", icon = "\u{f04b2}" },
      { "<leader>Kp", function()
        local ok, picker = pcall(require, "neotex.plugins.tools.process-picker")
        if ok then
          picker.show()
        else
          vim.notify("Process picker not available", vim.log.levels.WARN)
        end
      end, desc = "processes", icon = "\u{f04b2}" },
      { "<leader>Kk", function()
        local ok, process = pcall(require, "neotex.util.process")
        if ok then
          process.stop_all()
          vim.notify("All processes stopped", vim.log.levels.INFO)
        else
          vim.notify("Process manager not available", vim.log.levels.WARN)
        end
      end, desc = "kill all", icon = "\u{f035a}" },
    })

  end,
}
