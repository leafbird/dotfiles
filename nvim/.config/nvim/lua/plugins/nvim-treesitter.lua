return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    require("nvim-treesitter").install({ "lua", "c_sharp", "html" })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "lua", "cs", "html" },
      callback = function() vim.treesitter.start() end,
    })
  end,
}
