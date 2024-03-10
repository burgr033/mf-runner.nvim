-- TODO: implement toggleterm for execution target
-- TODO: implement snippets of makefiles
-- TODO: check the syntax of Makefiles so to be sure that I parse them correctly
-- TODO: implement health.lua for checks if make is installed
-- TODO: comment functions
-- TODO: cleanup code...

local utils = require("mf-runner.utils")
local cmd = vim.api.nvim_create_user_command
local M = {}
M.setup = function(ctx)
	cmd("MFROpen", function()
		require("mf-runner.telescope").show()
	end, { desc = "Open mf-runner" })

	cmd("MFRCreate", function()
		require("mf-runner.backend").create_makefile()
	end, { desc = "Create a makefile file in the current directory" })

	cmd("MFRRun", function(tbl)
		require("mf-runner.backend").run_makefile(tbl.args)
	end, {
		desc = "Run Makefile",
		nargs = 1,
		complete = function(arg_lead)
			local options = utils.get_makefile_options()
			return options
		end,
	})
end

return M
