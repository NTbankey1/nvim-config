return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "antosha417/nvim-lsp-file-operations", event = "BufReadPost" },
  },
  config = function()
    -- Neovim 0.11+ uses native vim.lsp.config API instead of lspconfig framework
    -- See :help lspconfig-nvim-0.11 for migration details

    -- Define diagnostics configuration
    local signs = { Error = "", Warn = "", Hint = "󰠠", Info = "" }
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = signs.Error,
          [vim.diagnostic.severity.WARN] = signs.Warn,
          [vim.diagnostic.severity.HINT] = signs.Hint,
          [vim.diagnostic.severity.INFO] = signs.Info,
        },
      },
      update_in_insert = false,
      severity_sort = true,
    })

    -- Get capabilities (with blink.cmp enhancement if available)
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, blink = pcall(require, "blink.cmp")
    if ok then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end

    -- Configure LSP servers using vim.lsp.config (Neovim 0.11+ native API)
    vim.lsp.config("lua_ls", {
      cmd = { "lua-language-server" },
      filetypes = { "lua" },
      root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    })

    vim.lsp.config("basedpyright", {
      cmd = { "basedpyright-langserver", "--stdio" },
      filetypes = { "python" },
      root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".git" },
      capabilities = capabilities,
      settings = {
        basedpyright = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "workspace",
            typeCheckingMode = "basic",
            diagnosticSeverityOverrides = {
              -- === TYPE SAFETY (errors — likely bugs or runtime crashes) ===
              reportArgumentType = "error",
              reportAssignmentType = "error",
              reportAttributeAccessIssue = "error",
              reportCallIssue = "error",
              reportGeneralTypeIssues = "error",
              reportIndexIssue = "error",
              reportOperatorIssue = "error",
              reportReturnType = "error",
              reportAbstractUsage = "error",
              reportIncompatibleMethodOverride = "error",
              reportIncompatibleVariableOverride = "error",
              reportPropertyTypeMismatch = "error",
              reportUndefinedVariable = "error",
              reportUnboundVariable = "error",
              reportUnhashable = "error",
              reportTypedDictNotRequiredAccess = "error",
              reportFunctionMemberAccess = "error",
              reportInconsistentOverload = "error",
              reportInvalidStringEscapeSequence = "error",
              reportInvalidTypeArguments = "error",
              reportInvalidTypeForm = "error",
              reportInvalidTypeVarUse = "error",
              reportMissingImports = "error",
              reportAssertTypeFailure = "error",

              -- === OPTIONAL SAFETY (warnings — potential issues) ===
              reportOptionalCall = "warning",
              reportOptionalContextManager = "warning",
              reportOptionalIterable = "warning",
              reportOptionalMemberAccess = "warning",
              reportOptionalOperand = "warning",
              reportOptionalSubscript = "warning",
              reportPossiblyUnboundVariable = "warning",
              reportPrivateUsage = "warning",
              reportPrivateImportUsage = "warning",
              reportRedeclaration = "warning",
              reportUninitializedInstanceVariable = "warning",
              reportMatchNotExhaustive = "warning",
              reportOverlappingOverload = "warning",
              reportImportCycles = "warning",
              reportDeprecated = "warning",

              -- === TYPE COMPLETENESS (warnings — missing type info) ===
              reportMissingParameterType = "warning",
              reportMissingTypeArgument = "warning",
              reportMissingTypeStubs = "warning",
              reportUnknownArgumentType = "warning",
              reportUnknownLambdaType = "warning",
              reportUnknownMemberType = "warning",
              reportUnknownParameterType = "warning",
              reportUnknownVariableType = "warning",
              reportUntypedBaseClass = "warning",
              reportUntypedClassDecorator = "warning",
              reportUntypedFunctionDecorator = "warning",
              reportUntypedNamedTuple = "warning",
              reportTypeCommentUsage = "warning",

              -- === CODE QUALITY (warnings — bad practices, confusion) ===
              reportUnusedClass = "warning",
              reportUnusedFunction = "warning",
              reportUnusedImport = "warning",
              reportUnusedVariable = "warning",
              reportUnusedCoroutine = "warning",
              reportWildcardImportFromLibrary = "warning",
              reportConstantRedefinition = "warning",
              reportDuplicateImport = "warning",
              reportImplicitStringConcatenation = "warning",
              reportInvalidStubStatement = "warning",
              reportUnnecessaryComparison = "warning",
              reportUnnecessaryContains = "warning",
              reportCallInDefaultInitializer = "warning",
              reportUnsupportedDunderAll = "warning",
              reportMissingSuperCall = "warning",
              reportAssertAlwaysTrue = "warning",

              -- === NOISY / LOW VALUE (information, not actionable) ===
              reportUnnecessaryCast = "information",
              reportUnnecessaryIsInstance = "information",
              reportUnnecessaryTypeIgnoreComment = "information",
              reportIncompleteStub = "information",
              reportMissingModuleSource = "information",
              reportUnusedCallResult = "information",
              reportUnusedExpression = "information",

              -- === OPTED OUT (explicitly disabled) ===
              reportImplicitOverride = "none",
            },
          },
        },
      },
    })

    vim.lsp.config("texlab", {
      cmd = { "texlab" },
      filetypes = { "tex", "plaintex", "bib" },
      root_markers = { ".latexmkrc", ".texlabroot", "texlabroot", "Tectonic.toml", ".git" },
      capabilities = capabilities,
      settings = {
        texlab = {
          build = { onSave = true },
          chktex = {
            onEdit = false,
            onOpenAndSave = false,
          },
          diagnosticsDelay = 300,
        },
      },
    })

    vim.lsp.config("tinymist", {
      cmd = { "tinymist" },
      filetypes = { "typst" },
      root_markers = { "typst.toml", ".git" },
      capabilities = capabilities,
      settings = {
        formatterMode = "typstyle",  -- Use typstyle for formatting (bundled with tinymist)
        exportPdf = "onSave",        -- Export PDF when file is saved
        semanticTokens = "enable",   -- Enable semantic highlighting
      },
    })

    -- Enable configured servers
    vim.lsp.enable({ "lua_ls", "basedpyright", "texlab", "tinymist" })
  end,
}