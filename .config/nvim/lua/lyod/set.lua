vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.cmd.expandtab = true
-- vim.cmd.set("noexpandtab")
vim.opt.smartindent = true

vim.cmd("syntax match Tab /\t/")
vim.cmd("hi Tab gui=underline guifg=blue ctermbg=blue")

vim.cmd("imap <C-c> <Esc>")
vim.cmd("let g:omni_sql_no_default_maps = 1")

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 60

vim.opt.colorcolumn = "80"

vim.opt.wrap = false
vim.cmd.set("ignorecase smartcase")
