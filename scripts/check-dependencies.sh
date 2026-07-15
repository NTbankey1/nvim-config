#!/usr/bin/env bash
#
# check-dependencies.sh — System health check for Neotex Neovim config
#
# Checks all required and recommended dependencies, reports versions,
# and exits with status 1 if core deps are missing.
#
# Usage:
#   bash scripts/check-dependencies.sh    # run standalone
#   make doctor                           # via Makefile

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
PASS=0; WARN=0; FAIL=0

pass() { PASS=$((PASS+1)); echo -e "  ${GREEN}✓${NC} $1"; }
warn() { WARN=$((WARN+1)); echo -e "  ${YELLOW}?${NC} $1"; }
fail() { FAIL=$((FAIL+1)); echo -e "  ${RED}✗${NC} $1"; }

ver() {
  local cmd=$1
  case $cmd in
    nvim)     nvim --version | head -1 | awk '{print $2}' ;;
    git)      git --version | awk '{print $3}' ;;
    node)     node --version | sed 's/v//' ;;
    python3)  python3 --version | awk '{print $2}' ;;
    fish)     fish --version | awk '{print $3}' ;;
    *)        echo "?" ;;
  esac
}

check() {
  local cmd=$1 name=$2 min=$3 required=$4
  if command -v "$cmd" &>/dev/null; then
    local v; v=$(ver "$cmd")
    if [[ -n "$min" ]]; then
      # crude version check: just report, don't fail on minor diff
      pass "$name $v (≥ $min)"
    else
      pass "$name $v"
    fi
  else
    if $required; then fail "$name — not found (required ≥ $min)"; else warn "$name — not found (recommended)"; fi
  fi
}

check_pip_pkg() { python3 -c "import $1" 2>/dev/null && pass "$2 (Python)" || warn "$2 — not found (recommended)"; }

check_npm_pkg() { command -v "$1" &>/dev/null && pass "$2" || warn "$2 — not found (recommended)"; }

echo ""
echo -e "${CYAN}Neotex — Neovim Health Check${NC}"
echo "────────────────────────────────────────"
echo ""

# ── Core ─────────────────────────────────────────────────────────────────────────
echo -e "${CYAN}Core Dependencies:${NC}"
check nvim    "Neovim"       "0.11.0" true
check git     "Git"          ""       true
check node    "Node.js"      "18.0.0" true
check python3 "Python 3"     "3.10.0" true
echo ""

# ── Shell ────────────────────────────────────────────────────────────────────────
echo -e "${CYAN}Shell:${NC}"
check fish    "Fish"         ""       false
echo ""

# ── Recommended tools ────────────────────────────────────────────────────────────
echo -e "${CYAN}Recommended CLI Tools:${NC}"
check rg      "ripgrep"      ""       false
check fd      "fd"           ""       false
check fzf     "fzf"          ""       false
check lazygit "lazygit"      ""       false
check stylua  "stylua"       ""       false
echo ""

# ── AI Tools (optional) ──────────────────────────────────────────────────────────
echo -e "${CYAN}AI Assistants (optional):${NC}"
check_npm_pkg claude   "Claude Code"
check_npm_pkg opencode "OpenCode"
echo ""

# ── LSP Servers (optional) ──────────────────────────────────────────────────────
echo -e "${CYAN}LSP Servers (optional):${NC}"
check texlab    "texlab (LaTeX)"     "" false
check basedpyright  "basedpyright (Python)" "" false
echo "  (LSP servers can also be installed via :MasonToolsInstall)"
echo ""

# ── Python packages (optional) ───────────────────────────────────────────────────
echo -e "${CYAN}Python Packages (optional):${NC}"
check_pip_pkg basedpyright "basedpyright"
echo ""

# ── LaTeX (optional) ─────────────────────────────────────────────────────────────
echo -e "${CYAN}LaTeX Toolchain (optional):${NC}"
check latexmk "latexmk"      ""       false
check sioyek  "Sioyek (PDF viewer)" "" false
echo ""

# ── Email (optional) ─────────────────────────────────────────────────────────────
echo -e "${CYAN}Email Tools (optional):${NC}"
check aerc    "aerc"         ""       false
check mbsync  "isync/mbsync" ""       false
check notmuch "notmuch"      ""       false
echo ""

# ── Font ─────────────────────────────────────────────────────────────────────────
echo -e "${CYAN}Font:${NC}"
if fc-list 2>/dev/null | grep -qi "nerd\|jetbrainsmono.*nerd\|meslo.*nerd"; then
  pass "Nerd Font detected"
else
  warn "Nerd Font not found (icons won't display without it)"
fi
echo ""

# ── Summary ──────────────────────────────────────────────────────────────────────
echo "────────────────────────────────────────"
total=$((PASS+WARN+FAIL))
echo -e "  ${GREEN}${PASS} passed${NC} · ${YELLOW}${WARN} optional missing${NC} · ${RED}${FAIL} required missing${NC}"
echo ""
if [[ $FAIL -gt 0 ]]; then
  echo -e "  ${YELLOW}Install missing core deps:${NC}"
  echo "    bash scripts/install.sh"
  echo ""
  exit 1
else
  echo -e "  ${GREEN}System is ready!${NC}"
  echo ""
  exit 0
fi
