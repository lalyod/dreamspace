vim.api.nvim_create_user_command('Prettier', function()
	vim.cmd('!prettier -w %')
end, {})

vim.api.nvim_create_autocmd('BufWritePost', {
	pattern = { "*.js", "*.ts", "*.tsx" , "*.jsx"},
	callback = function() 
		vim.cmd("silent !prettier -w %")
	end,
})
