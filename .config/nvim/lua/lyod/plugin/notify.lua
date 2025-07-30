return {
	"rcarriga/nvim-notify",
	config = function()
		require('notify').setup({
			stages = "slide",
			fps = 30,
			background_color = "NotifyBackground"
			timeout = 1000
		})
		vim.notify = require('notify')
	end
}
