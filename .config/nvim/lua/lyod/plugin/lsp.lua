return {
	"VonHeikemen/lsp-zero.nvim",
	branch = "v3.x",
	dependencies = {
		--- Uncomment the two plugins below if you want to manage the language servers from neovim
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
		{ "neovim/nvim-lspconfig" },
		{ "hrsh7th/nvim-cmp" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-nvim-lsp-signature-help" },
		{ "L3MON4D3/LuaSnip", version = "v2.*", dependencies = { "rafamadriz/friendly-snippets" } },
		{ "lukas-reineke/lsp-format.nvim" },
		{ "kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async" },
		{ "onsails/lspkind.nvim" },
	},
	config = function()
		-- issue https://github.com/nvim-telescope/telescope.nvim/issues/3436
		vim.o.winborder = "rounded"

		-- Folding
		vim.o.foldcolumn = "1" -- '0' is not bad
		vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true

		vim.keymap.set("n", "zR", require("ufo").openAllFolds)
		vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true,
		}
		local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
		for _, ls in ipairs(language_servers) do
			require("lspconfig")[ls].setup({
				capabilities = capabilities,
				-- you can add other fields for setting up lsp server in this table
			})
		end
		require("ufo").setup()

		-- LSP
		local lsp_zero = require("lsp-zero")
		local cmp = require("cmp")
		local cmp_action = require("lsp-zero").cmp_action()

		lsp_zero.on_attach(function(client, bufnr)
			lsp_zero.default_keymaps({ buffer = bufnr })
		end)

		require("luasnip.loaders.from_vscode").lazy_load()
		require("mason").setup({})
		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					require("lspconfig")[server_name].setup({})
				end,
				["yamlls"] = function()
					require("lspconfig").yamlls.setup({
						capabilities = capabilities,
						settings = {
							yaml = {
								schemas = {
									kubernetes = "/*.yaml",
									-- Add the schema for gitlab piplines
									-- ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = "*.gitlab-ci.yml",
								},
							},
						},
					})
				end,
				["volar"] = function()
					require("lspconfig").volar.setup({
						filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
					})
				end,
			},
		})

		lsp_zero.setup()
		cmp.setup({
			sources = {
				{ name = "luasnip" },
				{ name = "nvim_lsp" },
				{ name = "nvim_lsp_signature_help" },
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			mapping = cmp.mapping.preset.insert({
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-f>"] = cmp_action.luasnip_jump_forward(),
				["<C-b>"] = cmp_action.luasnip_jump_backward(),
				["<C-u>"] = cmp.mapping.scroll_docs(-4),
				["<C-d>"] = cmp.mapping.scroll_docs(4),
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				["<C-p>"] = cmp.mapping(function()
					if cmp.visible() then
						cmp.select_prev_item({ behavior = "insert" })
					else
						cmp.complete()
					end
				end),
				["<C-n>"] = cmp.mapping(function()
					if cmp.visible() then
						cmp.select_next_item({ behavior = "insert" })
					else
						cmp.complete()
					end
				end),
			}),
			formatting = {
				fields = { "abbr", "kind", "menu" },
				format = require("lspkind").cmp_format({
					mode = "symbol", -- show only symbol annotations
					maxwidth = 50, -- prevent the popup from showing more than provided characters
					ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
					symbol_map = {
						-- Method = "فعل",
					},
				}),
			},
		})
	end,
}
