local utils = require "mf-runner.utils"
local cmd = vim.api.nvim_create_user_command
local M = {}

--- Initialize the plugin and create user commands
---@return nil
M.setup = function()
  local snacks_available, _ = pcall(require, "snacks")

  if snacks_available then
    cmd(
      "MFROpen",
      function() require("mf-runner.picker").open_picker() end,
      { desc = "Open mf-runner picker for Makefile targets" }
    )
  end

  cmd(
    "MFREdit",
    function() require("mf-runner.backend").edit_makefile() end,
    { desc = "Edit existing Makefile or create a new one" }
  )

  cmd("MFRRun", function(tbl) require("mf-runner.backend").run_makefile(tbl.args) end, {
    desc = "Run specified Makefile target",
    nargs = 1,
    complete = function() return utils.parseMakefile() or {} end,
  })
end

return M
