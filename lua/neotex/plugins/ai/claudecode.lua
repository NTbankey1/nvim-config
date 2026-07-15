return {
  "greggh/claude-code.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    -- Window configuration
    window = {
      split_ratio = 0.40,        -- 40% width, matching old config
      position = "vertical",     -- Vertical split (sidebar)
      enter_insert = true,       -- Auto-enter insert mode
      hide_numbers = true,       -- Clean terminal appearance
      hide_signcolumn = true,
    },

    -- File refresh detection
    refresh = {
      enable = true,             -- Enable file change detection
      updatetime = 100,
      timer_interval = 1000,
      show_notifications = true, -- Show when files are refreshed
    },

    -- Git configuration
    git = {
      use_git_root = true,       -- Set working directory to git root
    },

    -- Shell configuration to suppress pushd output
    shell = {
      separator = "&&",
      pushd_cmd = "pushd >/dev/null 2>&1",  -- Suppress pushd output
      popd_cmd = "popd >/dev/null 2>&1",    -- Suppress popd output
    },

    -- Base command: dùng cc-nvim (kết nối đến proxy Headroom đang chạy qua cc-hr --daemon)
    -- cc-nvim: wrapper nhẹ, set ANTHROPIC_BASE_URL=http://127.0.0.1:8787 rồi exec claude
    -- Proxy cc-hr phải được khởi động riêng bằng: cc-hr --daemon
    command = "cc-nvim",

    -- Command variants for different modes
    command_variants = {
      continue = "--continue",
      resume = "--resume",
      verbose = "--verbose",
    },

    -- Keymaps configuration - disabled here as we define them in keys
    keymaps = {
      toggle = {
        normal = false,          -- Disable default keymaps
        terminal = false,
        variants = {
          continue = false,      -- Disable <leader>cC keymap
          verbose = false,       -- Disable <leader>cV keymap
        },
      },
      window_navigation = false, -- Disable window navigation keymaps
      scrolling = false,         -- Disable scrolling keymaps
    },
  },

  -- Keys are defined in keymaps.lua for centralized management
  keys = {},

  config = function(_, opts)
    require("claude-code").setup(opts)

    -- Auto-start cc-hr proxy daemon nếu chưa chạy (kiểm tra port 8787)
    vim.defer_fn(function()
      local proxy_port = 8787
      local check_cmd = string.format("lsof -ti :%d >/dev/null 2>&1", proxy_port)
      local proxy_running = os.execute(check_cmd) == 0
      if not proxy_running then
        -- Khởi proxy ngầm, không chặn Neovim
        vim.fn.jobstart({ "bash", "-c", "cc-hr --daemon > /tmp/cc-hr-daemon.log 2>&1" }, {
          detach = true,
          on_exit = function(_, code)
            if code == 0 then
              vim.schedule(function()
                vim.notify("[cc-hr] Proxy daemon đã sẵn sàng ✓", vim.log.levels.INFO)
              end)
            else
              vim.schedule(function()
                vim.notify("[cc-hr] Proxy daemon khởi động thất bại — xem /tmp/cc-hr-daemon.log", vim.log.levels.WARN)
              end)
            end
          end,
        })
      end
    end, 500)

    -- Setup session management with proper initialization order
    vim.defer_fn(function()
      -- Initialize session manager first
      local session_manager = require("neotex.plugins.ai.claude.core.session-manager")
      session_manager.setup()

      -- Then setup the main AI claude module
      local ok, claude_module = pcall(require, "neotex.plugins.ai.claude")
      if ok and claude_module and claude_module.setup then
        claude_module.setup()
      end

      -- Initialize Claude context reader for lualine integration
      local ctx_ok, ctx_module = pcall(require, "neotex.util.claude-context")
      if ctx_ok and ctx_module and ctx_module.setup then
        ctx_module.setup()
      end
    end, 100)

    -- Configure terminal behavior to match old setup
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "*claude*",
      callback = function()
        -- Make buffer unlisted to prevent it from appearing in tabs/bufferline
        vim.bo.buflisted = false
        -- Set buffer type to prevent it from being considered a normal buffer
        vim.bo.buftype = "terminal"
        -- Hide from buffer lists
        vim.bo.bufhidden = "hide"
        -- Set custom filetype for lualine extension matching
        vim.bo.filetype = "claude-code"

        -- Note: Terminal STT toggle (<C-'>) is defined globally in stt/init.lua
        -- Note: <C-CR> mapping for Claude Code toggle is defined in keymaps.lua
      end,
    })

    -- Additional autocmd to catch any Claude Code terminal buffers that might get listed later
    -- IMPORTANT: Check buftype == "terminal" FIRST to avoid catching .claude/ directory files
    vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
      pattern = "*",
      callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        -- Only unlist Claude Code terminal buffers, not .claude/ directory files
        if vim.bo.buftype == "terminal" and (bufname:match("claude") or bufname:match("ClaudeCode")) then
          vim.bo.buflisted = false
          vim.bo.bufhidden = "hide"
        end
      end,
    })
  end,
}
