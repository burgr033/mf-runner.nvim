--- Backend functions for mf-runner.nvim

local M = {}

--- Run the specified Makefile target.
---@param chosen_option string The target to run.
function M.run_makefile(chosen_option)
  local command = "make " .. chosen_option
  local toggleTermAvailable, toggleTerm = pcall(require, "toggleterm")
  vim.notify("Running " .. command, vim.log.levels.INFO)
  if toggleTermAvailable then
    toggleTerm.exec_command('cmd="' .. command .. '"')
  else
    vim.cmd("!" .. command)
  end
end

--- Edit the Makefile.
-- Opens the Makefile for editing if it exists, otherwise notifies the user.
function M.edit_makefile()
  local utils = require "mf-runner.utils"
  local filepath = utils.os_path(vim.fn.getcwd() .. "\\Makefile")
  if vim.fn.filereadable(filepath) == 1 then
    vim.cmd.edit "Makefile"
  else
    vim.notify("File does not exist", vim.log.levels.INFO)
    vim.cmd.edit "Makefile"
  end
end

return M
