local M = {}

function M.run_makefile(option)
	local command = "make " .. option
	vim.notify("running " .. command, vim.log.levels.info)
	require("toggleterm").exec_command('cmd="' .. command .. '"')
end

function M.create_makefile()
	local utils = require "mf-runner.utils"
	local filepath = utils.os_path(vim.fn.getcwd() .. "\\Makefile")
	if vim.fn.filereadable(filepath) == 1 then
		vim.notify("File already exists", vim.log.levels.INFO)
	else
		vim.cmd.edit "Makefile"
	end
end

return M
