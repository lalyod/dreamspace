vim.api.nvim_create_user_command('Prettier', function()
	vim.cmd('!prettier -w %')
end, {})

vim.api.nvim_create_autocmd('BufWritePost', {
	pattern = { "*.js", "*.ts", "*.tsx" , "*.jsx"},
	callback = function() 
		local notif = vim.notify("Prettiering a file please wait...", vim.log.levels.INFO, {
			title = "Prettier",
			timeout = false
		})

		local filepath = vim.fn.expand("%:P")
		vim.loop.spawn("prettier", {
			args = { "--write", filepath },
			stdio = nil,
		}, function (code, _) 
			vim.schedule(function()
				if code == 0 then
					vim.cmd("edit")
					vim.notify("Done!", vim.log.levels.SUCCESS, {
						title = 'Prettier',
						replace = notif,
						timeout = 1000
					})
				else
					vim.notify("Prettier failed with code " .. code, vim.log.levels.ERROR)
				end
			end)
		end)
	end,
})
