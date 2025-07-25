vim.g.mapleader = " "

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>wf", ":lua vim.lsp.buf.format()<CR>:w<CR>")

-- enter visual mode then yank the line
vim.keymap.set("n", "<leader>c", "V:y<CR>")

-- yank to clipboard
vim.keymap.set("v", "<leader>y", '"+y')
