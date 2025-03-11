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

  local snacks_available, Snacks = pcall(require, "snacks")
  if not snacks_available then
    vim.notify("Snacks.nvim is not installed", vim.log.levels.ERROR)
    return
  end

  -- Create buffer and window first
  local win = Snacks.win {
    text = { "Starting " .. command .. "..." },
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

  local buf = win.buf
  local output_lines = {}

  -- Run make command asynchronously
  local jobid = vim.fn.jobstart(command, {
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(output_lines, line)
            -- Update buffer with new output
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_lines)
                -- Scroll to bottom if buffer is visible
                if vim.api.nvim_win_is_valid(win.win) then
                  vim.api.nvim_win_set_cursor(win.win, { #output_lines, 0 })
                end
              end
            end)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(output_lines, line)
            -- Update buffer with new output
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_lines)
                -- Scroll to bottom if buffer is visible
                if vim.api.nvim_win_is_valid(win.win) then
                  vim.api.nvim_win_set_cursor(win.win, { #output_lines, 0 })
                end
              end
            end)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        table.insert(output_lines, "")
        table.insert(output_lines, "Process exited with code: " .. exit_code)
        if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_lines) end

        local status = exit_code == 0 and "completed successfully" or "failed"
        vim.notify(
          "Command " .. status .. " (exit code: " .. exit_code .. ")",
          exit_code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
        )
      end)
    end,
    stdout_buffered = false,
    stderr_buffered = false,
  })

  if jobid <= 0 then
    vim.notify("Failed to start job", vim.log.levels.ERROR)
    return
  end

  -- Add keybinding to cancel the job
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    "q",
    "<cmd>lua vim.fn.jobstop(" .. jobid .. ")<CR><cmd>close<CR>",
    { noremap = true, silent = true, desc = "Stop job and close window" }
  )
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
