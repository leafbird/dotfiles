return {
    "seblyng/roslyn.nvim",
    ft = "cs",
    opts = {
      -- your configuration comes here; leave empty for default settings

      -- neovim 자체 버그로 보이는 오류현상이 있어 비활성화 처리.
      -- https://github.com/neovim/neovim/issues/28058
      -- LSP[roslyn]: Error SERVER_REQUEST_HANDLER_ERROR: "...rogram Files/Neovim/share/nvim/runtime/lua/vim/_watch.lua:99: ENOENT: no such file or directory"
      filewatching = false,

      config = {
        settings = {
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
          }
        }
      }
    }
}
