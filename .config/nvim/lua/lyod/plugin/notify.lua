return {
	"rcarriga/nvim-notify",
	config = function()
		require('notify').setup({
			stages = "slide",
			fps = 30,
			timeout = 1000,
			background_colour = "#000000"
		})
		vim.notify = require('notify')
	end
}
