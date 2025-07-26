vim.api.nvim_create_user_command('Prettier', function()
	vim.cmd('!prettier -w %')
end, {})

vim.api.nvim_create_autocmd('BufWritePost', {
	pattern = { "*.js", "*.ts", "*.tsx" , "*.jsx"},
	callback = function() 
		local filepath = vim.fn.expand("%:P")
		vim.loop.spawn("prettier", {
			args = { "--write", filepath },
			stdio = nil,
		}, function (code, _) 
			vim.schedule(function()
				if code == 0 then
					vim.cmd("edit")
				else
					vim.notify("Prettier failed with code " .. code, vim.log.levels.ERROR)
				end
			end)
		end)
	end,
})
