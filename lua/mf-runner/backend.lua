local M = {}

function M.run_makefile(option)
	vim.notify("running" .. "!make" .. option)
	vim.cmd("!make " .. option)
end

function M.create_makefile()
	local utils = require("mf-runner.utils")
	local filepath = utils.os_path(vim.fn.getcwd() .. "\\Makefile")
	-- FIX: THIS DOESNT WORK FOR SOME REASON
	if vim.fn.glob(filepath) then
		vim.notify("File already exists", vim.log.levels.INFO)
	else
		vim.cmd.edit("Makefile")
	end
end

return M
