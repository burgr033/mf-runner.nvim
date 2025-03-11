local M = {}

--- Display command output in a Snacks window
---@param output string The command output text
---@return nil
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
---@return nil
function M.run_makefile(chosen_target)
  local command = "make " .. chosen_target
  vim.notify("Running " .. command, vim.log.levels.INFO)

  local handle, err = io.popen(command .. " 2>&1") -- Capture stdout and stderr
  if not handle then
    vim.notify("Failed to run command: " .. (err or "unknown error"), vim.log.levels.ERROR)
    return
  end

  local result = handle:read "*a"
  local _, _, exit_code = handle:close()

  show_in_snacks_window(result)

  if exit_code and exit_code ~= 0 then vim.notify("Command exited with code: " .. exit_code, vim.log.levels.WARN) end
end

--- Edit the Makefile.
-- Opens the Makefile for editing if it exists, otherwise creates a new one.
---@return nil
function M.edit_makefile()
  local utils = require "mf-runner.utils"
  local filepath = utils.get_makefile_path()

  if vim.fn.filereadable(filepath) == 1 then
    vim.cmd.edit "Makefile"
    vim.notify("Editing existing Makefile", vim.log.levels.INFO)
  else
    vim.cmd.edit "Makefile"
    vim.notify("Creating new Makefile", vim.log.levels.INFO)
  end
end

return M
