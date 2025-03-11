--- Backend functions for mf-runner.nvim

local M = {}

--- given any output generated through makefile execution open up a snacks window and print the output
---@param output string any string that comes back from makefile execution
local function show_in_snacks_window(output)
  local snacks_available, Snacks = pcall(require, "snacks")
  if not snacks_available then
    vim.notify("Snacks.nvim is not installed", vim.log.levels.ERROR)
    return
  end

  Snacks.win {
    text = vim.split(output, "\n"),
    width = 0.8,
    height = 0.8,
    wo = {
      spell = false,
      wrap = false,
      signcolumn = "no",
      statuscolumn = " ",
      conceallevel = 3,
    },
  }
end

--- Run the specified Makefile target and show output in Snacks window.
---@param chosen_target string The target to run.
function M.run_makefile(chosen_target)
  local command = "make " .. chosen_target
  vim.notify("Running " .. command, vim.log.levels.INFO)

  local handle = io.popen(command .. " 2>&1") -- Capture stdout and stderr
  if handle then
    local result = handle:read "*a"
    handle:close()
    show_in_snacks_window(result)
  else
    vim.notify("Failed to run command", vim.log.levels.ERROR)
  end
end

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
