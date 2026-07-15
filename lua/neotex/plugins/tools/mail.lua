-----------------------------------------------------------
-- Email Integration for Neovim
--
-- Provides keybindings for email workflow integration:
-- - Open aerc in toggleterm floating window
-- - Quick mail sync (mbsync + notmuch)
-- - notmuch search from within Neovim
-- - New mail count in statusline
--
-- System dependencies (must be installed):
--   sudo dnf install aerc isync notmuch
--
-- Config files:
--   ~/.mbsyncrc          - IMAP sync config
--   ~/.notmuch-config    - Email indexer config
--   ~/.config/aerc/      - aerc email client config
--
-- Keybindings:
--   <leader>me - Open aerc email client
--   <leader>mc - Compose new email in aerc
--   <leader>mS - Sync mail (mbsync + notmuch)
--   <leader>mf - Search mail with notmuch (telescope)
--   <leader>mi - Show inbox (notmuch tag:inbox)
--   <leader>mu - Show unread (notmuch tag:unread)
-----------------------------------------------------------

-- Helper: run notmuch count silently
local function notmuch_count(query)
  local result = vim.fn.system("notmuch count " .. query .. " 2>/dev/null")
  return tonumber(vim.trim(result)) or 0
end

-- Helper: open aerc with optional extra args
local function open_aerc(extra_args)
  local ok, Terminal = pcall(function()
    return require("toggleterm.terminal").Terminal
  end)
  if not ok then
    vim.notify("toggleterm.nvim not available", vim.log.levels.ERROR)
    return
  end

  local cmd = "aerc" .. (extra_args and (" " .. extra_args) or "")
  local aerc = Terminal:new({
    cmd = cmd,
    direction = "float",
    float_opts = {
      border = "curved",
      width = function()
        return math.floor(vim.o.columns * 0.92)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.88)
      end,
      winblend = 5,
    },
    on_open = function(term)
      vim.cmd("startinsert!")
      vim.keymap.set("n", "q", function()
        term:close()
      end, { buffer = term.bufnr, noremap = true, silent = true })
      vim.keymap.set("n", "<Esc>", function()
        term:close()
      end, { buffer = term.bufnr, noremap = true, silent = true })
    end,
    on_close = function()
      vim.cmd("checktime") -- refresh buffers after aerc closes
    end,
  })
  aerc:toggle()
end

-- Helper: sync mail async with progress notification
local function sync_mail()
  vim.notify("📬 Syncing mail...", vim.log.levels.INFO, { title = "Mail" })
  vim.fn.jobstart({ "mbsync", "-a" }, {
    on_exit = function(_, code)
      if code ~= 0 then
        vim.notify("❌ mbsync failed (code " .. code .. ")", vim.log.levels.ERROR, { title = "Mail" })
        return
      end
      vim.fn.jobstart({ "notmuch", "new" }, {
        on_stdout = function(_, data)
          -- parse new message count from notmuch output
          for _, line in ipairs(data) do
            local added = line:match("Added (%d+) new message")
            if added and tonumber(added) > 0 then
              vim.schedule(function()
                vim.notify("✅ Mail synced — " .. added .. " new messages", vim.log.levels.INFO, { title = "Mail" })
              end)
              return
            end
          end
        end,
        on_exit = function(_, nc)
          if nc == 0 then
            vim.schedule(function()
              local unread = notmuch_count("tag:unread")
              vim.notify(
                "✅ Mail synced — " .. unread .. " unread",
                vim.log.levels.INFO,
                { title = "Mail" }
              )
            end)
          else
            vim.schedule(function()
              vim.notify("⚠️  notmuch indexing failed", vim.log.levels.WARN, { title = "Mail" })
            end)
          end
        end,
      })
    end,
  })
end

return {
  -- --------------------------------------------------------
  -- Toggleterm: aerc integration
  -- --------------------------------------------------------
  {
    "akinsho/toggleterm.nvim",
    keys = {
      {
        "<leader>me",
        function() open_aerc() end,
        desc = "Open aerc email client",
      },
      {
        "<leader>mc",
        function() open_aerc("-e mailto:") end,
        desc = "Compose new email",
      },
      {
        "<leader>mS",
        sync_mail,
        desc = "Sync mail (mbsync + notmuch)",
      },
    },
  },

  -- --------------------------------------------------------
  -- Telescope: notmuch search integration
  -- --------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    keys = {
      -- Search all mail
      {
        "<leader>mf",
        function()
          local pickers = require("telescope.pickers")
          local finders = require("telescope.finders")
          local conf = require("telescope.config").values
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")
          local previewers = require("telescope.previewers")

          local function notmuch_picker(query_override)
            local opts = require("telescope.themes").get_dropdown({
              prompt_title = "🔍 Notmuch Search",
              winblend = 5,
              layout_config = { width = 0.85, height = 0.75 },
            })

            pickers
              .new(opts, {
                finder = finders.new_async_job({
                  command_generator = function(prompt)
                    local q = query_override or (prompt ~= "" and prompt or "tag:inbox")
                    return {
                      "notmuch", "search",
                      "--format=text",
                      "--sort=newest-first",
                      q,
                    }
                  end,
                  entry_maker = function(line)
                    if not line or line == "" then return nil end
                    -- Format: thread:XXXX  date  [count] authors; subject
                    local thread_id = line:match("^(thread:%x+)")
                    local date     = line:match("^thread:%x+%s+(%S+)")
                    local subject  = line:match(";%s*(.+)$") or line
                    local display  = string.format("%-12s  %s", date or "", subject)
                    return {
                      value    = line,
                      display  = display,
                      ordinal  = line,
                      thread_id = thread_id,
                    }
                  end,
                }),
                sorter = conf.generic_sorter(opts),
                previewer = previewers.new_termopen_previewer({
                  get_command = function(entry)
                    if entry.thread_id then
                      return { "notmuch", "show", "--format=text", entry.thread_id }
                    end
                    return { "echo", "No preview available" }
                  end,
                }),
                attach_mappings = function(prompt_bufnr, _)
                  actions.select_default:replace(function()
                    local sel = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    if sel and sel.thread_id then
                      open_aerc(sel.thread_id)
                    end
                  end)
                  return true
                end,
              })
              :find()
          end

          notmuch_picker()
        end,
        desc = "Search mail (notmuch)",
      },

      -- Quick: show inbox
      {
        "<leader>mi",
        function()
          local pickers = require("telescope.pickers")
          local finders = require("telescope.finders")
          local conf    = require("telescope.config").values
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")

          local opts = require("telescope.themes").get_dropdown({
            prompt_title = "📥 Inbox",
            winblend = 5,
          })

          local inbox_items = vim.fn.systemlist(
            "notmuch search --format=text --sort=newest-first tag:inbox 2>/dev/null | head -50"
          )

          pickers.new(opts, {
            finder = finders.new_table({
              results = inbox_items,
              entry_maker = function(line)
                if not line or line == "" then return nil end
                local date    = line:match("^thread:%x+%s+(%S+)") or ""
                local subject = line:match(";%s*(.+)$") or line
                return {
                  value   = line,
                  display = string.format("%-12s  %s", date, subject),
                  ordinal = line,
                  thread_id = line:match("^(thread:%x+)"),
                }
              end,
            }),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, _)
              actions.select_default:replace(function()
                local sel = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if sel and sel.thread_id then
                  open_aerc(sel.thread_id)
                end
              end)
              return true
            end,
          }):find()
        end,
        desc = "Show inbox",
      },

      -- Quick: show unread
      {
        "<leader>mu",
        function()
          local unread = notmuch_count("tag:unread")
          if unread == 0 then
            vim.notify("✅ No unread mail", vim.log.levels.INFO, { title = "Mail" })
            return
          end
          local items = vim.fn.systemlist(
            "notmuch search --format=text --sort=newest-first tag:unread 2>/dev/null | head -50"
          )
          local pickers = require("telescope.pickers")
          local finders = require("telescope.finders")
          local conf    = require("telescope.config").values
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")

          local opts = require("telescope.themes").get_dropdown({
            prompt_title = "📭 Unread (" .. unread .. ")",
            winblend = 5,
          })

          pickers.new(opts, {
            finder = finders.new_table({
              results = items,
              entry_maker = function(line)
                if not line or line == "" then return nil end
                local date    = line:match("^thread:%x+%s+(%S+)") or ""
                local subject = line:match(";%s*(.+)$") or line
                return {
                  value    = line,
                  display  = string.format("%-12s  %s", date, subject),
                  ordinal  = line,
                  thread_id = line:match("^(thread:%x+)"),
                }
              end,
            }),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, _)
              actions.select_default:replace(function()
                local sel = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if sel and sel.thread_id then
                  open_aerc(sel.thread_id)
                end
              end)
              return true
            end,
          }):find()
        end,
        desc = "Show unread mail",
      },
    },
  },
}
