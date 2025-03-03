return {
	"stevearc/conform.nvim",
	event = { "BufRead", "BufNewFile" },
	config = function()
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				cs = { "csharpier" },
			},
			format_on_save = {
				timeout = 2000,
				lap_fallback = true,
			},
		})
	end,
}
