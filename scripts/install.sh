#!/usr/bin/env bash
#
# install.sh — One-command Neotex (Neovim) bootstrap
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/NTbankey1/nvim/main/scripts/install.sh | bash
#   bash scripts/install.sh                  # local
#   bash scripts/install.sh --minimal        # only core editor (no email/AI/LaTeX)
#
# Detects OS, installs system dependencies, sets up the config, and
# bootstraps lazy.nvim plugins — all in one shot.

set -euo pipefail

# ── Config ─────────────────────────────────────────────────────────────────────
REPO_URL="https://github.com/NTbankey1/nvim"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
BACKUP_DIR="${CONFIG_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
MINIMAL=false
[[ "${1:-}" == "--minimal" ]] && MINIMAL=true

# ── Colors ──────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

log()   { echo -e "${GREEN}✓${NC} $1"; }
warn()  { echo -e "${YELLOW}!${NC} $1"; }
err()   { echo -e "${RED}✗${NC} $1"; }
header(){ echo -e "\n${BLUE}━━━ $1 ━━━${NC}\n"; }
prompt_yes() {
  local msg=$1
  read -r -p "$msg [Y/n] " reply
  [[ -z "$reply" || "$reply" =~ ^[Yy] ]]
}

# ── OS Detection ────────────────────────────────────────────────────────────────
detect_os() {
  case "$(uname -s)" in
    Linux)
      if grep -qi 'fedora' /etc/os-release 2>/dev/null; then
        echo "fedora"
      elif grep -qi 'nixos' /etc/os-release 2>/dev/null; then
        echo "nixos"
      elif grep -qi 'ubuntu\|debian' /etc/os-release 2>/dev/null; then
        echo "debian"
      elif grep -qi 'arch' /etc/os-release 2>/dev/null; then
        echo "arch"
      elif grep -qi 'opensuse\|suse' /etc/os-release 2>/dev/null; then
        echo "suse"
      else
        echo "linux"
      fi
      ;;
    Darwin) echo "macos" ;;
    *)      echo "unknown" ;;
  esac
}

# ── Package manager commands ────────────────────────────────────────────────────
install_pkg() {
  local os=$1; shift
  case $os in
    fedora) sudo dnf install -y "$@" 2>/dev/null ;;
    debian) sudo apt-get install -y "$@" 2>/dev/null ;;
    arch)   sudo pacman -S --noconfirm "$@" 2>/dev/null ;;
    macos)  brew install "$@" 2>/dev/null ;;
    suse)   sudo zypper install -y "$@" 2>/dev/null ;;
    *)      warn "Unknown OS — skipping: $*" ;;
  esac
}

# ── Check if command exists ──────────────────────────────────────────────────────
has() { command -v "$1" &>/dev/null; }

# ── Step 1: System dependencies ─────────────────────────────────────────────────
install_system_deps() {
  header "System Dependencies"
  local os=$(detect_os)
  echo "Detected OS: $os"

  case $os in
    fedora)
      local core=(git nodejs fish ripgrep fd-find fzf)
      install_pkg "$os" "${core[@]}"

      # Neovim ≥ 0.11 on Fedora 43+
      if has nvim; then
        log "Neovim $(nvim --version | head -1 | awk '{print $2}')"
      else
        install_pkg "$os" neovim
      fi

      if ! $MINIMAL; then
        local extra=(stylua python3-pip npm)
        install_pkg "$os" "${extra[@]}"
        # LaTeX toolchain (big — skip unless user confirms)
        if prompt_yes "Install LaTeX toolchain (texlive, texlab, sioyek)? (∼800 MB)"; then
          install_pkg "$os" texlive-scheme-medium texlab sioyek
        fi
        # Email tools
        if prompt_yes "Install email tools (aerc, isync, notmuch)?"; then
          install_pkg "$os" aerc isync notmuch
        fi
      fi
      ;;

    debian)
      # For Debian/Ubuntu, we need to add Neovim ≥ 0.11 PPA first
      if ! has nvim || [[ "$(nvim --version | head -1 | awk '{print $2}' | cut -d. -f2)" -lt 11 ]]; then
        warn "Neovim ≥ 0.11 required. Adding unstable PPA..."
        sudo add-apt-repository -y ppa:neovim-ppa/unstable 2>/dev/null || true
        sudo apt-get update -qq
      fi
      local core=(git nodejs fish ripgrep fd-find fzf neovim)
      install_pkg "$os" "${core[@]}"
      if ! $MINIMAL; then
        install_pkg "$os" python3-pip npm stylua
        if prompt_yes "Install LaTeX toolchain (texlive, texlab, sioyek)?"; then
          install_pkg "$os" texlive-full texlab sioyek
        fi
      fi
      ;;

    arch)
      local core=(git nodejs fish ripgrep fd fzf neovim)
      install_pkg "$os" "${core[@]}"
      if ! $MINIMAL; then
        install_pkg "$os" python-pip npm stylua
        if prompt_yes "Install LaTeX toolchain?"; then
          install_pkg "$os" texlive-most texlab sioyek
        fi
      fi
      ;;

    macos)
      if ! has brew; then
        warn "Installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      local core=(git node fish ripgrep fd fzf neovim)
      install_pkg "$os" "${core[@]}"
      if ! $MINIMAL; then
        install_pkg "$os" stylua
        if prompt_yes "Install LaTeX toolchain?"; then
          install_pkg "$os" texlive texlab sioyek
        fi
      fi
      ;;

    nixos)
      warn "On NixOS, add packages to your configuration.nix or use nix-shell."
      echo "See: https://github.com/NTbankey1/nvim#nixos"
      # If in nix-shell with these deps, that's fine
      ;;

    *)
      warn "Unsupported OS. You'll need to install dependencies manually."
      warn "Required: git, nodejs ≥18, python3, ripgrep, fd, fzf, neovim ≥0.11"
      ;;
  esac
}

# ── Step 2: Clone / copy config ─────────────────────────────────────────────────
setup_config() {
  header "Configuration Setup"

  if [[ -d "$CONFIG_DIR" ]]; then
    warn "Existing config found at $CONFIG_DIR"
    if prompt_yes "Backup and replace it?"; then
      mv "$CONFIG_DIR" "$BACKUP_DIR"
      log "Backed up to $BACKUP_DIR"
    else
      warn "Skipping config setup."
      return
    fi
  fi

  if has git && git clone --depth=1 "$REPO_URL" "$CONFIG_DIR" 2>/dev/null; then
    log "Cloned from $REPO_URL"
  else
    # Fallback: if the script is being run FROM the repo, symlink
    local script_dir
    script_dir="$(cd "$(dirname "$0")/.." && pwd)"
    if [[ -f "$script_dir/init.lua" ]]; then
      ln -sf "$script_dir" "$CONFIG_DIR"
      log "Symlinked from $script_dir"
    else
      err "Cannot find init.lua. Please clone manually:"
      echo "  git clone $REPO_URL $CONFIG_DIR"
      exit 1
    fi
  fi
}

# ── Step 3: Nerd Font ───────────────────────────────────────────────────────────
setup_fonts() {
  header "Nerd Font"

  if fc-list 2>/dev/null | grep -qi "nerd\|JetBrainsMono.*Nerd\|Meslo.*Nerd"; then
    log "Nerd Font already installed"
    return
  fi

  if prompt_yes "Install JetBrainsMono Nerd Font? (recommended for icon support)"; then
    local tmpdir
    tmpdir=$(mktemp -d)
    local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    if has curl; then
      curl -fsSL "$url" -o "$tmpdir/font.zip"
    else
      wget -q "$url" -O "$tmpdir/font.zip"
    fi
    mkdir -p "$HOME/.local/share/fonts"
    unzip -qo "$tmpdir/font.zip" -d "$HOME/.local/share/fonts/" 2>/dev/null || true
    fc-cache -f "$HOME/.local/share/fonts/" 2>/dev/null
    rm -rf "$tmpdir"
    log "JetBrainsMono Nerd Font installed"
  fi
}

# ── Step 4: Python packages ─────────────────────────────────────────────────────
setup_python() {
  header "Python Packages"

  if $MINIMAL; then
    warn "Skipping Python packages (--minimal)"
    return
  fi

  local pkgs=()
  has basedpyright || pkgs+=(basedpyright)
  # uv is optional but recommended for MCP-Hub
  has uv || has pipx || pkgs+=(uv)

  if [[ ${#pkgs[@]} -gt 0 ]]; then
    if prompt_yes "Install Python packages (${pkgs[*]})?"; then
      if has uv; then
        uv pip install --system "${pkgs[@]}" 2>/dev/null || \
        pip3 install --user "${pkgs[@]}" 2>/dev/null && log "Python packages installed"
      else
        pip3 install --user "${pkgs[@]}" 2>/dev/null && log "Python packages installed"
      fi
    fi
  else
    log "Python deps already satisfied"
  fi
}

# ── Step 5: npm packages ────────────────────────────────────────────────────────
setup_npm() {
  header "npm Packages"

  if $MINIMAL; then
    warn "Skipping npm packages (--minimal)"
    return
  fi

  local pkgs=()
  has claude || pkgs+=("@anthropic/claude-code")
  has opencode || pkgs+=(opencode)

  if [[ ${#pkgs[@]} -gt 0 ]]; then
    if prompt_yes "Install npm/Python AI tools (${pkgs[*]})?"; then
      for pkg in "${pkgs[@]}"; do
        case $pkg in
          @anthropic/claude-code)
            if has npm; then
              npm install -g "$pkg" 2>/dev/null && log "$pkg installed" || warn "$pkg failed"
            fi
            ;;
          opencode)
            pip3 install --user opencode 2>/dev/null && log "opencode installed" || warn "opencode failed"
            ;;
        esac
      done
    fi
  else
    log "AI tools already installed"
  fi
}

# ── Step 6: Bootstrap lazy.nvim & plugins ─────────────────────────────────────
bootstrap_plugins() {
  header "Plugin Bootstrap"

  cd "$CONFIG_DIR"

  echo "Starting Neovim to install plugins (this may take 2-5 minutes)..."
  echo ""

  # First pass: install lazy.nvim and all declared plugins
  if nvim --headless "+Lazy! sync" +qa 2>&1; then
    log "Plugins installed"
  else
    warn "Some plugins may have failed. Run 'make doctor' after install."
  fi

  # Second pass: Mason tools (LSP servers, formatters)
  nvim --headless -c "lua require('mason-tool-installer').run_on_start = true; require('mason-tool-installer').check_install()" +qa 2>/dev/null || true
  log "LSP tools installed"

  # Silence the "first run" message for next launch
  nvim --headless -c "checkhealth" -c "qa" 2>/dev/null || true
  log "Health check complete"
}

# ── Step 7: Summary ──────────────────────────────────────────────────────────────
print_summary() {
  header "Installation Complete"

  echo -e "${CYAN}"
  echo "  ╔══════════════════════════════════════════════╗"
  echo "  ║        Neotex — Neovim is ready!             ║"
  echo "  ╚══════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo ""
  echo "  Quick start:"
  echo "    nvim                           Launch Neovim"
  echo ""
  echo "  Post-install checks:"
  echo "    make doctor     Check system dependencies"
  echo "    make health     Run :checkhealth"
  echo ""
  echo "  Configuration:"
  echo "    $CONFIG_DIR"
  echo ""
  echo "  Keybinding reference:"
  echo "    docs/MAPPINGS.md               Full reference"
  echo "    <leader>i                      Dashboard > Info"
  echo ""
  echo "  Other commands:"
  echo "    make update    Update all plugins"
  echo "    make backup    Backup this config"
  echo "    make clean     Clean caches"
  echo ""

  if ! $MINIMAL; then
    echo "  AI Assistants (optional):"
    if has claude; then
      echo "    claude         Launch Claude Code"
    fi
    if has opencode; then
      echo "    opencode       Launch OpenCode"
    fi
    echo ""
  fi

  # Remind about first-launch plugin compilation
  echo -e "${YELLOW}  Note: First launch may compile native plugins (Telescope fzf, Treesitter).${NC}"
  echo -e "${YELLOW}  This is normal — subsequent launches will be fast.${NC}"
  echo ""
}

# ── Main ─────────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo -e "${CYAN}"
  echo "  ███╗   ██╗███████╗ ██████╗ ████████╗███████╗██╗  ██╗"
  echo "  ████╗  ██║██╔════╝██╔═══██╗╚══██╔══╝██╔════╝╚██╗██╔╝"
  echo "  ██╔██╗ ██║█████╗  ██║   ██║   ██║   █████╗   ╚███╔╝ "
  echo "  ██║╚██╗██║██╔══╝  ██║   ██║   ██║   ██╔══╝   ██╔██╗ "
  echo "  ██║ ╚████║███████╗╚██████╔╝   ██║   ███████╗██╔╝ ██╗"
  echo "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝"
  echo -e "${NC}"
  echo "  Neovim Configuration Bootstrap"
  echo "  $(date)"
  echo ""

  install_system_deps
  setup_config
  setup_fonts
  setup_python
  setup_npm
  bootstrap_plugins
  print_summary
}

main "$@"
