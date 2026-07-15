-- TOKYONIGHT
return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("tokyonight").setup({
      style = "storm", -- storm, moon, night, or day
      transparent = true, -- Enable this to use the terminal's transparency
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        -- Backgrounds for sidebars
        sidebars = "transparent",
        floats = "transparent",
      },
    })
    vim.cmd("colorscheme tokyonight")
  end,
}

-- -- GRUVBOX
-- return {
--   "ellisonleao/gruvbox.nvim",
-- ...
-- }
