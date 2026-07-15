# Neotex — Neovim Configuration

A structured, feature-rich Neovim configuration optimized for **LaTeX**, **Markdown**, **Jupyter Notebooks**, **Python**, **Typst**, and **NixOS**, with deep AI assistant integration.

Author: **Benjamin Brast-McKie**

---

## Features at a Glance

- **AI Integration** — Claude Code, OpenCode, MCP-Hub, and Lectic with a unified tool picker
- **LaTeX Editing** — vimtex with Sioyek/Okular PDF viewer, latexmk, SyncTeX
- **Markdown** — Autolist smart lists, render-markdown, markdown-preview, flash.nvim navigation
- **Jupyter Notebooks** — Jupytext + NotebookNavigator + Iron.nvim (Python/Julia/R/Lua REPLs)
- **LSP** — basedpyright (Python), lua_ls (Lua), texlab (LaTeX), tinymist (Typst)
- **Completion** — blink.cmp with LuaSnip snippets, VimTeX citation/bibliography integration
- **Email** — Himalaya full TUI email client + aerc/notmuch quick integration
- **Speech-to-Text** — Built-in STT capability
- **Process Management** — Launch, pick, and kill system processes from within Neovim
- **Git** — gitsigns, git-worktree, telescope undo
- **UI** — TokyoNight theme (transparent), lualine, bufferline, neo-tree, noice.nvim, Snacks dashboard
- **Performance** — Disabled unused built-ins, bigfile mode, reduced updatetime, lazy-loaded plugins

---

## Requirements

| Dependency   | Minimum Version | Notes                                     |
|-------------|-----------------|-------------------------------------------|
| Neovim      | ≥ 0.11.0        | Uses native `vim.lsp.config` API          |
| Git         | any             | Plugin management, git-worktree           |
| Node.js     | ≥ 18            | MCP-Hub, some LSP servers                 |
| Python 3    | ≥ 3.10          | basedpyright, Jupyter, formatters         |
| Fish shell  | any             | Default terminal shell                     |
| `uv`        | latest          | Python package manager for MCP-Hub        |

### Optional System Dependencies

| Tool          | Purpose                          | Install (Fedora)                     |
|---------------|----------------------------------|---------------------------------------|
| Sioyek        | PDF viewer for LaTeX             | `sudo dnf install sioyek`            |
| Okular        | Alternative PDF viewer           | `sudo dnf install okular`            |
| latexmk       | LaTeX build tool                 | `sudo dnf install texlive-latexmk`   |
| texlab        | LaTeX LSP server                 | `sudo dnf install texlab`            |
| tinymist      | Typst LSP server                 | `sudo dnf install tinymist`          |
| basedpyright  | Python LSP server (recommended)  | `pip install basedpyright`           |
| aerc          | Terminal email client            | `sudo dnf install aerc`              |
| isync (mbsync)| IMAP mail sync                   | `sudo dnf install isync`             |
| notmuch       | Email indexing/search            | `sudo dnf install notmuch`           |
| stylua        | Lua formatter                    | `sudo dnf install stylua`            |
| Claude Code   | AI assistant (CLI)               | `npm install -g @anthropic/claude-code` |
| OpenCode      | AI assistant (CLI)               | `pip install opencode`               |

---

## Quick Install (one command)

```bash
curl -fsSL https://raw.githubusercontent.com/NTbankey1/nvim/main/scripts/install.sh | bash
```

Or for the minimal editor-only setup (no email, AI, or LaTeX):

```bash
curl -fsSL https://raw.githubusercontent.com/NTbankey1/nvim/main/scripts/install.sh | bash -s -- --minimal
```

The installer auto-detects your OS (Fedora, Debian/Ubuntu, Arch, macOS, or NixOS) and:

| Step | What it does |
|------|-------------|
| 1 | Installs system packages via `dnf`/`apt`/`pacman`/`brew` |
| 2 | Clones the config to `~/.config/nvim` (backs up existing) |
| 3 | Installs JetBrainsMono Nerd Font (optional, for icons) |
| 4 | Installs Python LSP servers (`basedpyright`) |
| 5 | Installs AI CLI tools (`claude-code`, `opencode`) — optional |
| 6 | Bootstraps all lazy.nvim plugins and Mason LSP tools |

After install, just run `nvim` — everything is ready.

---

## Manual Setup

```bash
# Clone the repository
git clone https://github.com/NTbankey1/nvim ~/.config/nvim

# Verify dependencies
bash ~/.config/nvim/scripts/check-dependencies.sh

# Bootstrap plugins (2–5 minutes)
nvim --headless "+Lazy! sync" +qa

# Install LSP tools via Mason
nvim --headless -c "lua require('mason-tool-installer').check_install()" +qa

# Launch Neovim
nvim
```

### Makefile Commands

| Command             | Purpose                        |
|---------------------|---------------------------------|
| `make install`      | Run the full install script    |
| `make doctor`       | Check system dependencies      |
| `make update`       | Sync plugins to lockfile       |
| `make health`       | Run `:checkhealth`             |
| `make backup`       | Back up current config         |
| `make restore`      | Restore from latest backup     |
| `make clean`        | Clear plugin caches            |

### Project Files

| File                  | Purpose                            |
|-----------------------|------------------------------------|
| `.editorconfig`       | Editor-agnostic coding style       |
| `.stylua.toml`        | Lua formatter configuration        |
| `Makefile`            | Common task runner                 |
| `scripts/install.sh`  | One-command bootstrap installer    |
| `scripts/check-dependencies.sh` | System health check       |
| `scripts/setup-with-claude.sh`  | Claude Code–assisted setup (interactive) |

### First-Time Setup

1. **Core settings** are in `lua/neotex/config/`
2. **Plugin configurations** are in `lua/neotex/plugins/`
3. **AI tools** are configured in `lua/neotex/plugins/ai/`
4. **Custom snippets** live in `snippets/` (SnipMate format)
5. **Filetype-specific settings** are in `after/ftplugin/`

For complete keybinding documentation, see `docs/MAPPINGS.md` or press `<leader>i` on the dashboard.

---

## Plugin Architecture

```
lua/neotex/
├── bootstrap.lua          # Entry point: lazy.nvim setup, plugin loading
├── config/                # Core configuration
│   ├── init.lua          # Module loader
│   ├── options.lua       # Neovim options & performance tuning
│   ├── keymaps.lua       # Non-leader keybindings
│   ├── autocmds.lua      # Autocommands
│   ├── claude-init.lua   # Claude Code worktree integration
│   └── notifications.lua # Unified notification system
├── plugins/
│   ├── editor/           # Editor enhancements
│   ├── lsp/              # Language server & completion
│   ├── tools/            # External tool integration
│   ├── ai/               # AI assistant plugins
│   ├── text/             # Text format processing
│   └── ui/               # User interface
├── util/                 # Shared utilities
│   ├── buffer.lua       # Buffer navigation
│   ├── claude-context.lua
│   ├── diagnostics.lua
│   ├── fold.lua         # Persistent folding
│   ├── notifications.lua
│   ├── process.lua      # Process management
│   ├── sleep-inhibit.lua
│   └── url.lua          # URL handling
├── yank/                 # Yank ring (history, highlight, telescope)
├── lib/                  # External library integrations
└── deprecated/           # Moved or replaced modules
```

---

## Plugin Categories

### Editor

| Plugin                  | Purpose                                 |
|-------------------------|-----------------------------------------|
| **which-key.nvim**      | Keybinding help popup (v3 API)          |
| **conform.nvim**        | Code formatting (stylua, prettier, black, etc.) |
| **nvim-lint**           | Asynchronous linting                    |
| **telescope.nvim**      | Fuzzy finder (files, grep, LSP, undo, bibtex) |
| **toggleterm.nvim**     | Floating/vertical terminal (Fish shell) |
| **nvim-treesitter**     | Syntax highlighting & indentation       |
| **flash.nvim**          | Enhanced jump navigation (`s` key)      |

### LSP & Completion

| Plugin                     | Purpose                                |
|----------------------------|----------------------------------------|
| **nvim-lspconfig**         | LSP client (native `vim.lsp.config`)   |
| **mason.nvim**             | LSP server/tool installer              |
| **blink.cmp**              | Completion engine (with blink.compat)  |
| **cmp-vimtex**             | LaTeX bibliography completion          |
| **LuaSnip**                | Snippet engine (SnipMate format)       |

**Configured LSP Servers:**
- `lua_ls` — Lua
- `basedpyright` — Python (strict type checking)
- `texlab` — LaTeX
- `tinymist` — Typst

### Tools

| Plugin                      | Purpose                                |
|-----------------------------|----------------------------------------|
| **gitsigns.nvim**           | Git indicators in sign column          |
| **snacks.nvim**             | Dashboard, bigfile mode, blame, picker |
| **autolist.nvim**           | Smart list handling in Markdown        |
| **mini.nvim**               | Comment, pairs, surround, etc.         |
| **autopairs.nvim**          | Auto-closing brackets/pairs            |
| **nvim-surround**           | Text surrounding (quotes, brackets)    |
| **todo-comments.nvim**      | Highlight TODO/FIX/NOTE comments       |
| **yank-ring.nvim**          | Yank history with telescope picker     |
| **LuaSnip**                 | Code snippets for markdown, tex, python, typst |
| **himalaya**                | Full-featured TUI email client         |
| **mail** (custom)           | aerc + notmuch quick integration       |
| **git-worktree.nvim**       | Git worktree management                |
| **STT** (custom)            | Speech-to-text dictation               |
| **process-picker** (custom) | System process launcher & manager      |

### AI Assistants

| Plugin                         | Purpose                                |
|--------------------------------|----------------------------------------|
| **claude-code.nvim**           | Claude Code sidebar integration        |
| **opencode.nvim**              | OpenCode embedded TUI                  |
| **mcphub.nvim**                | MCP-Hub server for AI tools            |
| **lectic** (custom)            | Lectic AI integration                  |
| **Unified AI Tool Picker**     | `<C-CR>` — pick between Claude/OpenCode |

**Keybindings:**
| Key          | Action                              |
|-------------|--------------------------------------|
| `<C-CR>`    | Unified AI tool picker               |
| `<leader>al`| AI load commands/agents picker       |
| `<leader>as`| AI tool session picker               |
| `<leader>ac`| Claude Code toggle                   |
| `<leader>ao`| OpenCode toggle                      |
| `<leader>ah`| MCP-Hub interface                    |

### Text Processing

| Plugin                    | Purpose                                |
|---------------------------|----------------------------------------|
| **vimtex**                | LaTeX (Sioyek viewer, latexmk, SyncTeX) |
| **lean.nvim**             | Lean theorem prover                    |
| **jupyter** (custom)      | Jupyter notebook integration           |
| **markdown-preview.nvim** | Live Markdown preview in browser       |
| **render-markdown.nvim**  | Render Markdown inline in Neovim       |
| **typst-preview**         | Typst document preview                 |

### UI

| Plugin                    | Purpose                                |
|---------------------------|----------------------------------------|
| **tokyonight.nvim**       | Colorscheme (storm variant, transparent) |
| **lualine.nvim**          | Statusline with Claude Code indicator  |
| **bufferline.nvim**       | Tab-like buffer bar                   |
| **neo-tree.nvim**         | File explorer                          |
| **nvim-web-devicons**     | File type icons                        |
| **noice.nvim**            | UI messages, cmdline, and more         |
| **snacks.nvim**           | Dashboard with session/recents/plugins |

---

## Keybindings

### Leader: `<Space>` | Local Leader: `,`

#### Top-Level

| Keybinding    | Action                              |
|---------------|-------------------------------------|
| `<leader>b`   | Telescope buffers                   |
| `<leader>d`   | Save and delete buffer              |
| `<leader>e`   | Toggle neo-tree explorer            |
| `<leader>q`   | Close active buffer                 |
| `<leader>u`   | Telescope undo history              |
| `<leader>w`   | Window management group             |
| `<leader>r`   | Run/Execute commands group          |
| `<leader>z`   | Fold/Zen mode group                 |
| `<leader>L`   | Lean group                          |
| `<leader>K`   | Process/ Kill group                 |

#### LSP (VSCode-style)

| Keybinding    | Action                              |
|---------------|-------------------------------------|
| `gd`          | Go to definition                    |
| `gh`          | Show hover documentation            |
| `gi`          | Go to implementation                |
| `gq`          | Code action (quick fix)             |
| `gr`          | Find references                     |
| `gt`          | Go to type definition               |
| `go`          | Go to document symbol               |
| `gO`          | Go to workspace symbol              |
| `<leader>rn`  | Rename symbol                       |
| `<leader>fm`  | Format document                     |
| `<leader>l`   | Show diagnostics (problems)         |
| `<leader>j`   | Next diagnostic                     |
| `<leader>k`   | Previous diagnostic                 |

#### Navigation & Editing

| Keybinding    | Action                              |
|---------------|-------------------------------------|
| `<C-p>`       | Find files (Telescope)              |
| `<C-s>`       | Spelling suggestions                |
| `<C-h/j/k/l>` | Window navigation                   |
| `<A-h/l>`     | Resize window horizontally          |
| `<A-j/k>`     | Move line/selection up/down         |
| `<Tab>`       | Next buffer (by modified time)      |
| `<S-Tab>`     | Previous buffer                     |
| `<CR>`        | Clear search highlighting           |
| `s`           | Flash jump                          |
| `S`           | Flash treesitter                    |

#### Terminal Mode

| Keybinding    | Action                              |
|---------------|-------------------------------------|
| `<C-t>`       | Toggle terminal                     |
| `<Esc>`       | Exit terminal mode                  |
| `<C-g>`       | Open file under cursor (Claude Code output) |
| `<C-h/j/k/l>` | Window navigation                   |

#### LaTeX

| Keybinding    | Action                              |
|---------------|-------------------------------------|
| `<leader>ll`  | LaTeX compile                       |
| `<leader>lv`  | LaTeX view (Sioyek)                 |
| `<leader>lk`  | LaTeX kill compiler                 |

#### Email (Aerc)

| Keybinding    | Action                              |
|---------------|-------------------------------------|
| `<leader>me`  | Open aerc email client              |
| `<leader>mc`  | Compose new email                   |
| `<leader>mS`  | Sync mail (mbsync + notmuch)        |
| `<leader>mf`  | Search mail (notmuch + telescope)   |
| `<leader>mi`  | Show inbox                          |
| `<leader>mu`  | Show unread                         |

#### Jupyter

| Keybinding    | Action                              |
|---------------|-------------------------------------|
| `<leader>jj`  | Previous cell                       |
| `<leader>jk`  | Next cell                           |
| `<leader>je`  | Execute cell                        |
| `<leader>jn`  | Execute cell and move to next       |
| `<leader>jo`  | Insert cell below                   |
| `<leader>jO`  | Insert cell above                   |
| `<leader>js`  | Split cell                          |
| `<leader>jc`  | Comment/merge cell                  |
| `<leader>ja`  | Run all cells                       |

#### NixOS

| Keybinding    | Action                              |
|---------------|-------------------------------------|
| `<leader>nr`  | Rebuild NixOS                       |
| `<leader>nh`  | Rebuild Home Manager                |
| `<leader>nu`  | Nix flake update                    |
| `<leader>ng`  | Nix garbage collect                 |
| `<leader>nd`  | Nix store diff                      |
| `<leader>np`  | NixOS options search                |

---

## Performance Optimizations

- **Disabled built-in plugins**: netrw, matchit, matchparen, tutor, 2html, zip, tar, gzip, spellfile
- **Bigfile mode** (snacks.nvim): Automatically disables Treesitter, folding, and other heavy features for files >100KB
- **Lazy loading**: Every plugin uses `event`, `cmd`, `ft`, or `keys` triggers — nothing loads at startup unless needed
- **Reduced `updatetime`**: 300ms for better responsiveness without sacrificing battery
- **Limited `synmaxcol`**: 200 columns to prevent syntax highlighting slowdowns
- **Efficient autocommands**: File reload detection uses `FocusGained`/`BufEnter` instead of `CursorHold`
- **Clean logging**: `'warn'` log level (90% reduction in debug output vs default)

---

## Troubleshooting

### Viewing Debug Messages

Debug messages are suppressed by default for a clean experience.

```lua
-- Show all levels including DEBUG
:lua vim.notify_level = vim.log.levels.DEBUG

-- Show TRACE messages (very verbose)
:lua vim.notify_level = vim.log.levels.TRACE

-- View notification history
<leader>rm

-- Restore normal notifications
:lua vim.notify_level = vim.log.levels.INFO
```

### Common Issues

| Problem                        | Solution                                      |
|--------------------------------|-----------------------------------------------|
| stylua LSP errors on NixOS     | Suppressed by `init.lua` — safe to ignore     |
| lspconfig deprecation warnings | Suppressed — handled via `vim.lsp.config`     |
| Missing formatters             | Run `:MasonToolsInstall`                      |
| Plugins not loading            | Run `:Lazy check && :Lazy clean && :Lazy sync`|
| Email sync issues              | Check `~/.mbsyncrc` and `~/.notmuch-config`   |
| Jupyter not working            | Install `jupytext` and `nbformat` via pip     |

---

## File-Specific Settings

Filetype-specific keymaps and options are in `after/ftplugin/`:

| File             | File                              |
|------------------|-----------------------------------|
| TeX/LaTeX        | `after/ftplugin/tex.lua`          |
| Markdown         | `after/ftplugin/markdown.lua`     |
| Python           | `after/ftplugin/python.lua`       |
| Typst            | `after/ftplugin/typst.lua`        |
| Lean             | `after/ftplugin/lean.lua`         |
| Lectic Markdown  | `after/ftplugin/lectic.markdown.lua` |
| TypeScript       | `after/ftplugin/typescript.lua`   |
| TypeScript React | `after/ftplugin/typescriptreact.lua` |
| Astro            | `after/ftplugin/astro.lua`        |

Custom snippets in `snippets/` (SnipMate format): `markdown.snippets`, `python.snippets`, `tex.snippets`, `typst.snippets`.

---

## License

This configuration is provided as-is for personal and educational use.
