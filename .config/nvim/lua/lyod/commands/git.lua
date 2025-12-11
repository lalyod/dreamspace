local M = {}

local gs_state = {
	bufnr = nil
}

-- function to run git status command and get the output
local function get_git_status()
	-- using vim.system to run git command
	local result = vim.system({ 'git', 'status', '--porcelain' }, { text= true }):wait()

	-- check if command is sucessful
	if result.code ~= 0 then
		vim.notify("Git command faileld with error code: " .. result.code, vim.log.levels.ERROR)
		return {}
	end

	-- split output into lines
	local output_lines = vim.split(result.stdout, '\n', {plain= true})

	-- remove the last empty line if exist
	if output_lines[#output_lines] == '' then
		table.remove(output_lines)
	end

	return output_lines
end

local function get_git_root()
	local result = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
	if result.code ~= 0 then
		return nil
	end
	return vim.trim(result.stdout)
end

function M.open_git_status_window()
	-- get the "git status" output
	local status_lines = get_git_status()
	if #status_lines == 0 then
		vim.notify("There is no changes.", vim.log.levels.INFO)
		return
	end

	local buf

	if gs_state.bufnr and vim.api.nvim_buf_is_valid(gs_state.bufnr) then
		buf = gs_state.bufnr
	else
		buf = vim.api.nvim_create_buf(false, true)
		gs_state.bufnr = buf

		vim.api.nvim_buf_set_name(buf, "[Git Status]")
		vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
	end

	vim.api.nvim_buf_set_option(buf, 'modifiable', true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, status_lines)
	vim.api.nvim_buf_set_option(buf, 'modifiable', false)

	-- create new window to display buffer
	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'editor',
		width = 80,
		height = #status_lines + 2,
		row = vim.api.nvim_win_get_height(0) / 2 - (#status_lines / 2),
		col = vim.api.nvim_win_get_width(0) / 2 - 40,
		border = 'single',
	})

	-- Set some options for the new window
	vim.api.nvim_win_set_option(win, 'relativenumber', false)
	vim.api.nvim_win_set_option(win, 'number', false)
	vim.api.nvim_win_set_option(win, 'cursorline', true)
	vim.api.nvim_win_set_option(win, 'buftype', 'nofile')

	-- keymaps inside this buffer
	vim.keymap.set("n", "q", function() 
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end, { buffer = buf, nowait = true, silent = true })

	vim.keymap.set("n", "-", function() 
		local cursor = vim.api.nvim_win_get_cursor(win)
		local line = vim.api.nvim_buf_get_lines(buf, cursor[1]-1, cursor[1], false)[1]

		local filepath = line:sub(3):gsub("^%s+", "")
		local status = string.sub(line, 1, 2)
		local git_root = get_git_root()

		if not git_root then
			vim.notify("Not inside a git respository", vim.log.levels.ERROR)
			return
		end

		local fullpath = git_root .. "/" .. filepath

		if status == 'M ' or status == 'A ' or status == 'D ' then
			vim.system({ 'git', 'restore', '--staged', fullpath }, { text = true }):wait()
		elseif status == ' M' 
			or status == '??' 
			or status == 'AM' 
			or status == 'MM' 
			or status == ' D'
			or status == 'UU' then
			vim.system({ 'git', 'add', fullpath }, { text = true }):wait()
		end

		status_lines = get_git_status()
		vim.api.nvim_buf_set_option(buf, 'modifiable', true)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, status_lines)
		vim.api.nvim_buf_set_option(buf, 'modifiable', false)
	end, { buffer = buf, nowait = true, silent = true })

	vim.keymap.set("n", "r", function() 
		status_lines = get_git_status()

		vim.api.nvim_buf_set_option(buf, 'modifiable', true)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, status_lines)
		vim.api.nvim_buf_set_option(buf, 'modifiable', false)
	end, { buffer = buf, nowait = true, silent = true })

	vim.keymap.set("n", "cc", function() 
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end

		local git_dir = vim.fs.find(".git", { upward = true, type = "directory" })[1]
		if not git_dir then
			vim.notify("No .git directory found!", vim.log.levels.ERROR)
			return
		end

		local commit_file = git_dir .. "/COMMIT_EDITMSG"
		vim.cmd("edit " .. vim.fn.fnameescape(commit_file))
	end, { buffer = buf, nowait = true, silent = true })

	vim.keymap.set("n", "<CR>", function() 
		local cursor = vim.api.nvim_win_get_cursor(win)
		local line = vim.api.nvim_buf_get_lines(buf, cursor[1]-1, cursor[1], false)[1]

		local filepath = line:sub(3):gsub("^%s+", "")
		local file = vim.fs.find(filepath, { upward = true, type = "file" })[1]
		if not file then
			vim.notify("file found!", vim.log.levels.ERROR)
			return
		end


		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end

		vim.cmd("edit " .. vim.fn.fnameescape(file))

	end, { buffer = buf, nowait = true, silent = true })
end

vim.api.nvim_create_user_command('Gs', M.open_git_status_window, {
	desc = "Open a git status window"
})

return M
