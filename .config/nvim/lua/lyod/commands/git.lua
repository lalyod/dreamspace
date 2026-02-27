local M = {}

local gs_state = {
	bufnr = nil,
	win = nil,
	git_root = nil,
}

local function get_git_root()
	local cwd = vim.fn.getcwd()
	local result = vim.system({ 'git', 'rev-parse', '--show-toplevel' }, { text = true, cwd = cwd }):wait()
	if result.code ~= 0 then
		return nil
	end
	return vim.trim(result.stdout)
end

local function git_run(args, callback)
	local git_root = gs_state.git_root or get_git_root()
	if not git_root then
		vim.notify("Not inside a git repository", vim.log.levels.ERROR)
		if callback then callback(false) end
		return
	end
	vim.system(args, { text = true, cwd = git_root }, function(result)
		if callback then callback(result) end
	end)
end

local function refresh_buffer(buf, callback)
	git_run({ 'git', 'status', '--porcelain' }, function(result)
		if not result or result.code ~= 0 then
			vim.schedule(function()
				vim.notify("Git status failed: " .. (result and result.stderr or ""), vim.log.levels.ERROR)
			end)
			if callback then callback() end
			return
		end
		local lines = vim.split(result.stdout, '\n', { plain = true })
		if lines[#lines] == '' then
			table.remove(lines)
		end
		vim.schedule(function()
			if not buf or not vim.api.nvim_buf_is_valid(buf) then
				if callback then callback() end
				return
			end
			vim.api.nvim_buf_set_option(buf, 'modifiable', true)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
			vim.api.nvim_buf_set_option(buf, 'modifiable', false)
			if callback then callback() end
		end)
	end)
end

local function stage_file(buf, fullpath, callback)
	git_run({ 'git', 'add', fullpath }, function(result)
		if result and result.code ~= 0 then
			vim.schedule(function()
				vim.notify("Git add failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
			end)
		end
		refresh_buffer(buf, callback)
	end)
end

local function unstage_file(buf, fullpath, callback)
	git_run({ 'git', 'restore', '--staged', fullpath }, function(result)
		if result and result.code ~= 0 then
			vim.schedule(function()
				vim.notify("Git restore failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
			end)
		end
		refresh_buffer(buf, callback)
	end)
end

local function commit_staged(message, callback)
	git_run({ 'git', 'commit', '-m', message }, function(result)
		if result then
			vim.schedule(function()
				if result.code == 0 then
					vim.notify("Commit successful", vim.log.levels.INFO)
				else
					vim.notify("Git commit failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
				end
			end)
		end
		if callback then callback() end
	end)
end

local function open_file(filepath)
	local git_root = gs_state.git_root or get_git_root()
	if not git_root then
		vim.notify("Not inside a git repository", vim.log.levels.ERROR)
		return
	end
	local fullpath = git_root .. "/" .. filepath
	if gs_state.win and vim.api.nvim_win_is_valid(gs_state.win) then
		vim.api.nvim_win_close(gs_state.win, true)
	end
	vim.cmd("edit " .. vim.fn.fnameescape(fullpath))
end

local function open_commit_buffer(buf, callback)
	local commit_buf = vim.api.nvim_create_buf(false, false)
	vim.api.nvim_buf_set_name(commit_buf, "[Commit Message]")
	vim.api.nvim_buf_set_option(commit_buf, 'bufhidden', 'wipe')
	vim.api.nvim_buf_set_option(commit_buf, 'filetype', 'gitcommit')

	local win = vim.api.nvim_open_win(commit_buf, true, {
		relative = 'editor',
		width = 60,
		height = 10,
		row = (vim.o.lines - 10) / 2,
		col = (vim.o.columns - 60) / 2,
		border = 'single',
	})

	vim.api.nvim_win_set_option(win, 'relativenumber', false)
	vim.api.nvim_win_set_option(win, 'number', false)
	vim.api.nvim_win_set_option(win, 'cursorline', true)

	vim.api.nvim_buf_set_lines(commit_buf, 0, -1, false, { '', '# Enter commit message (first line is subject)' })
	vim.api.nvim_buf_set_option(commit_buf, 'modifiable', true)
	vim.api.nvim_win_set_cursor(win, { 1, 0 })

	local function close_commit_win()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	local function do_commit()
		local lines = vim.api.nvim_buf_get_lines(commit_buf, 0, -1, false)
		local message_lines = {}
		for _, line in ipairs(lines) do
			if not line:match('^#') and line ~= '' then
				table.insert(message_lines, line)
			end
		end
		local message = table.concat(message_lines, '\n')

		close_commit_win()

		if message == '' then
			vim.notify("Empty commit message", vim.log.levels.WARN)
			if callback then callback() end
			return
		end

		vim.notify("Committing...", vim.log.levels.INFO)

		git_run({ 'git', 'commit', '-m', message }, function(result)
			if result then
				vim.schedule(function()
					if result.code == 0 then
						vim.notify("Commit successful", vim.log.levels.INFO)
					else
						vim.notify("Git commit failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
					end
				end)
			end
			if callback then callback() end
		end)
	end

	vim.keymap.set('n', '<CR>', do_commit, { buffer = commit_buf, nowait = true, silent = true })
	vim.keymap.set('n', 'cc', do_commit, { buffer = commit_buf, nowait = true, silent = true })
	vim.keymap.set('n', 'q', close_commit_win, { buffer = commit_buf, nowait = true, silent = true })
	vim.keymap.set('n', '<Esc>', close_commit_win, { buffer = commit_buf, nowait = true, silent = true })
end

function M.open_git_status_window()
	local git_root = get_git_root()
	if not git_root then
		vim.notify("Not inside a git repository", vim.log.levels.ERROR)
		return
	end
	gs_state.git_root = git_root

	git_run({ 'git', 'status', '--porcelain' }, function(result)
		if not result or result.code ~= 0 then
			vim.notify("Git command failed: " .. (result and result.stderr or ""), vim.log.levels.ERROR)
			return
		end

		local status_lines = vim.split(result.stdout, '\n', { plain = true })
		if status_lines[#status_lines] == '' then
			table.remove(status_lines)
		end

		if #status_lines == 0 then
			vim.notify("No changes", vim.log.levels.INFO)
			return
		end

		vim.schedule(function()
			local buf
			if gs_state.bufnr and vim.api.nvim_buf_is_valid(gs_state.bufnr) then
				buf = gs_state.bufnr
			else
				buf = vim.api.nvim_create_buf(false, true)
				gs_state.bufnr = buf
				vim.api.nvim_buf_set_name(buf, "[Git Status]")
				vim.api.nvim_buf_set_option(buf, 'bufhidden', 'delete')
			end

			vim.api.nvim_buf_set_option(buf, 'modifiable', true)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, status_lines)
			vim.api.nvim_buf_set_option(buf, 'modifiable', false)

			local win_opts = {
				relative = 'editor',
				width = 80,
				height = math.min(#status_lines + 2, vim.o.lines - 4),
				row = (vim.o.lines - math.min(#status_lines + 2, vim.o.lines - 4)) / 2,
				col = (vim.o.columns - 80) / 2,
				border = 'single',
			}

			local win = vim.api.nvim_open_win(buf, true, win_opts)
			gs_state.win = win

			vim.api.nvim_win_set_option(win, 'relativenumber', false)
			vim.api.nvim_win_set_option(win, 'number', false)
			vim.api.nvim_win_set_option(win, 'cursorline', true)

			local function close_window()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
			end

			local function handle_staging(unstage_patterns, stage_patterns)
				local cursor = vim.api.nvim_win_get_cursor(win)
				local line = vim.api.nvim_buf_get_lines(buf, cursor[1] - 1, cursor[1], false)[1]
				if not line or #line < 3 then
					return
				end

				local filepath = line:sub(3):gsub("^%s+", "")
				local status = line:sub(1, 2)

				if not gs_state.git_root then
					vim.notify("Not inside a git repository", vim.log.levels.ERROR)
					return
				end

				local fullpath = gs_state.git_root .. "/" .. filepath

				for _, pat in ipairs(unstage_patterns) do
					if status == pat then
						unstage_file(buf, fullpath)
						return
					end
				end

				for _, pat in ipairs(stage_patterns) do
					if status == pat then
						stage_file(buf, fullpath)
						return
					end
				end
			end

			vim.keymap.set('n', 'q', close_window, { buffer = buf, nowait = true, silent = true })
			vim.keymap.set('n', '<Esc>', close_window, { buffer = buf, nowait = true, silent = true })
			vim.keymap.set('n', '-', function()
				handle_staging({ 'M ', 'A ', 'D ' }, { ' M', '??', 'AM', 'MM', ' D', 'UU' })
			end, { buffer = buf, nowait = true, silent = true })
			vim.keymap.set('n', 'r', function()
				refresh_buffer(buf)
			end, { buffer = buf, nowait = true, silent = true })
			vim.keymap.set('n', 'cc', function()
				close_window()
				open_commit_buffer(buf, function()
					refresh_buffer(buf)
				end)
			end, { buffer = buf, nowait = true, silent = true })
			vim.keymap.set('n', '<CR>', function()
				local cursor = vim.api.nvim_win_get_cursor(win)
				local line = vim.api.nvim_buf_get_lines(buf, cursor[1] - 1, cursor[1], false)[1]
				if not line or #line < 3 then
					return
				end

				local filepath = line:sub(3):gsub("^%s+", "")
				open_file(filepath)
			end, { buffer = buf, nowait = true, silent = true })
		end)
	end)
end

vim.api.nvim_create_user_command('Gs', M.open_git_status_window, {
	desc = "Open a git status window"
})

function M.push()
	local git_root = get_git_root()
	if not git_root then
		vim.notify("Not inside a git repository", vim.log.levels.ERROR)
		return
	end

	vim.ui.select({ "Yes", "No" }, {
		prompt = "Push to upstream?",
	}, function(choice)
		if not choice then return end

		local args = { 'git', 'push' }
		if choice == "Yes" then
			table.insert(args, '-u')
		end

		vim.schedule(function()
			vim.notify("Pushing...", vim.log.levels.INFO)
		end)
		vim.system(args, { text = true, cwd = git_root }, function(result)
			vim.schedule(function()
				if result and result.code == 0 then
					vim.notify("Push successful", vim.log.levels.INFO)
				else
					vim.notify("Push failed: " .. (result and result.stderr or "Unknown error"), vim.log.levels.ERROR)
				end
			end)
		end)
	end)
end

vim.api.nvim_create_user_command('Gpush', M.push, {
	desc = "Push to remote"
})

return M
