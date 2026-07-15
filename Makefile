.PHONY: install doctor update check sync clean help backup restore

SHELL := /bin/bash
NVIM := $(shell command -v nvim 2>/dev/null || echo nvim)

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Full install: system deps + plugins + LSPs
	@bash scripts/install.sh

doctor: ## Check system health and dependencies
	@bash scripts/check-dependencies.sh

update: ## Update plugins and lockfile
	@$(NVIM) --headless "+Lazy! sync" +qa
	@echo "✓ Plugins updated. Re-indexing..."

check: ## Check plugin status
	@$(NVIM) --headless "+Lazy! check" +qa

sync: ## Sync plugins to lockfile state
	@$(NVIM) --headless "+Lazy! clean" +qa
	@$(NVIM) --headless "+Lazy! sync" +qa
	@echo "✓ Plugins synced"

clean: ## Clean plugin caches and build artifacts
	@$(NVIM) --headless "+Lazy! clean" +qa
	@rm -rf build/ 2>/dev/null; echo "✓ Clean complete"

backup: ## Backup current configuration
	@BACKUP_DIR="$$HOME/.config/nvim.backup.$$(date +%Y%m%d_%H%M%S)"; \
	cp -r "$$HOME/.config/nvim" "$$BACKUP_DIR"; \
	echo "✓ Backup created: $$BACKUP_DIR"

restore: ## Restore from latest backup
	@LATEST=$$(ls -d $$HOME/.config/nvim.backup.* 2>/dev/null | tail -1); \
	if [ -n "$$LATEST" ]; then \
		rm -rf "$$HOME/.config/nvim"; \
		mv "$$LATEST" "$$HOME/.config/nvim"; \
		echo "✓ Restored from: $$LATEST"; \
	else \
		echo "✗ No backup found"; exit 1; \
	fi

# ── Internal helpers ────────────────────────────────────────────────────────────

mason-install: ## Install LSP tools via Mason
	@$(NVIM) --headless -c "lua require('mason-tool-installer').run_on_start = true; require('mason-tool-installer').check_install()" +qa
	@echo "✓ Mason tools installed"

lint-nvim: ## Check config loads without errors
	@$(NVIM) --headless -c "lua vim.notify_level = vim.log.levels.ERROR" -c "lua require('neotex.config')" -c "qa!" 2>&1 || true
	@echo "✓ Config load checked"

health: ## Run :checkhealth
	@$(NVIM) --headless -c "checkhealth" -c "qa"
