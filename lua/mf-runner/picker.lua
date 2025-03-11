local M = {}

--- open the snacks picker
function M.open_picker()
  local snacks_available, Snacks = pcall(require, "snacks")
  local targets = require("mf-runner.utils").parseMakefile()
  if not snacks_available then
    vim.notify("Snacks.nvim is not installed", vim.log.levels.ERROR)
    return
  end

  Snacks.picker.select(targets, {
    prompt = "Makefile target",
    format_item = function(item) return "🔹 " .. item end, -- Customize display
  }, function(selected_item, _)
    if selected_item then require("mf-runner.backend").run_makefile(selected_item) end
  end)
end

return M
