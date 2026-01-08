local M = {}

--- Run the specified build target and show output in Snacks window.
---@param chosen_target string The target to run.
---@return nil
function M.run_build_target(chosen_target)
  local utils = require "mf-runner.utils"
  local file_type, err = utils.detect_build_file()

  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  if not file_type then
    vim.notify("No build file found", vim.log.levels.ERROR)
    return
  end

  local command
  if file_type == "makefile" then
    command = "make " .. chosen_target
  elseif file_type == "justfile" then
    command = "just " .. chosen_target
  end

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

  -- Run command asynchronously
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

--- Backward compatibility: Run makefile target
---@param chosen_target string The target to run.
---@return nil
function M.run_makefile(chosen_target) M.run_build_target(chosen_target) end

--- Edit the build file (Makefile or justfile).
-- Opens the file for editing if it exists, otherwise creates a new one.
---@return nil
function M.edit_build_file()
  local utils = require "mf-runner.utils"
  local file_type, err = utils.detect_build_file()

  -- If both files exist, show error
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  -- If a file exists, open it
  if file_type == "makefile" then
    vim.cmd.edit "Makefile"
    vim.notify("Editing existing Makefile", vim.log.levels.INFO)
    return
  elseif file_type == "justfile" then
    vim.cmd.edit "justfile"
    vim.notify("Editing existing justfile", vim.log.levels.INFO)
    return
  end

  -- No file exists, prompt user to choose
  vim.ui.select({ "Makefile", "justfile" }, {
    prompt = "No build file found. Create:",
  }, function(choice)
    if choice == "Makefile" then
      vim.cmd.edit "Makefile"
      vim.notify("Creating new Makefile", vim.log.levels.INFO)
    elseif choice == "justfile" then
      vim.cmd.edit "justfile"
      vim.notify("Creating new justfile", vim.log.levels.INFO)
    end
  end)
end

--- Backward compatibility: Edit makefile
---@return nil
function M.edit_makefile() M.edit_build_file() end

return M
