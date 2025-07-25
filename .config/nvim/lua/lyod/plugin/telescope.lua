return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.6",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "smartpde/telescope-recent-files" },
	},
	enabled = not vim.g.vscode, -- Disable Telescope when running in VSCode
	config = function()
		require("telescope").load_extension("recent_files")
		require("telescope").setup({
			defaults = {
				file_ignore_patterns = {
					"node_modules",
				},
			},
		})

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
		vim.keymap.set("n", "<leader>pg", builtin.git_files, {})
		vim.keymap.set("n", "<leader>ps", function()
			builtin.grep_string({ search = vim.fn.input("Grep > ") })
		end)
		vim.keymap.set("n", "<leader>pp", builtin.buffers, { desc = "Telescope buffers" })

		vim.api.nvim_set_keymap(
			"n",
			"<Leader><Leader>",
			[[<cmd>lua require('telescope').extensions.recent_files.pick()<CR>]],
			{ noremap = true, silent = true }
		)
	end,
}
