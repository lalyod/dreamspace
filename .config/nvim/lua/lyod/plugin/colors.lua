function InitMyColor()
	local color = "rose-pine"

	-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	-- vim.api.nvim_set_hl(0, "TelescopeFloat", { bg = "none" })
	-- vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })

	require("rose-pine").setup({
		variant = "auto", -- auto, main, moon, or dawn
		dark_variant = "main", -- main, moon, or dawn
		dim_inactive_windows = false,
		extend_background_behind_borders = true,

		enable = {
			terminal = true,
			legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
			migrations = true, -- Handle deprecated options automatically
		},

		styles = {
			bold = true,
			italic = true,
			transparency = true,
		},

		groups = {
			border = "muted",
			link = "iris",
			panel = "surface",

			error = "love",
			hint = "iris",
			info = "foam",
			note = "pine",
			todo = "rose",
			warn = "gold",

			git_add = "foam",
			git_change = "rose",
			git_delete = "love",
			git_dirty = "rose",
			git_ignore = "muted",
			git_merge = "iris",
			git_rename = "pine",
			git_stage = "iris",
			git_text = "rose",
			git_untracked = "subtle",

			h1 = "iris",
			h2 = "foam",
			h3 = "rose",
			h4 = "gold",
			h5 = "pine",
			h6 = "foam",
		},

		palette = {
			-- main = {
			-- 	base = "#222831",
			-- 	overlay = "#363738",
			-- },
		},

		highlight_groups = {
			-- Comment = { fg = "foam" },
			-- VertSplit = { fg = "muted", bg = "muted" },
		},

		before_highlight = function(group, highlight, palette)
			-- Disable all undercurls
			-- if highlight.undercurl then
			--     highlight.undercurl = false
			-- end
			--
			-- Change palette colour
			-- if highlight.fg == palette.pine then
			--     highlight.fg = palette.foam
			-- end
		end,
	})

	vim.cmd.colorscheme(color)
	-- require("lualine").setup({
	-- 	options = {
	-- 		icons_enabled = false,
	-- 		component_separators = { left = "|", right = "|" },
	-- 		section_separators = { left = "", right = "" },
	-- 	},
	-- 	sections = {
	-- 		lualine_a = { "mode", { "filename", path = 1 } },
	-- 		lualine_b = {},
	-- 		lualine_c = { "branch" },
	-- 		lualine_x = { "diff", "diagnostics", "encoding" },
	-- 		lualine_y = { "progress", "location" },
	-- 		lualine_z = {},
	-- 	},
	-- })
	-- vim.cmd.set("noshowmode")
end

return {
	{ "nvim-lualine/lualine.nvim" },
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			InitMyColor()
		end,
	},
}
