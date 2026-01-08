local M = {}

--- Opens a picker UI to select a build target (Makefile or justfile)
---@return nil
function M.open_picker()
  local snacks_available, Snacks = pcall(require, "snacks")
  if not snacks_available then
    vim.notify("Snacks.nvim is not installed", vim.log.levels.ERROR)
    return
  end

  local utils = require "mf-runner.utils"
  local targets, file_type = utils.parse_build_file()

  if #targets == 0 then
    vim.notify("No targets found in build file", vim.log.levels.INFO)
    return
  end

  local prompt_text = file_type == "makefile" and "Makefile target" or "justfile recipe"

  Snacks.picker.select(targets, {
    prompt = prompt_text,
    format_item = function(item) return "🔹 " .. item end,
  }, function(selected_item, _)
    if selected_item then require("mf-runner.backend").run_build_target(selected_item) end
  end)
end

return M
